class AccountDeleter
  class FalsyResultError < StandardError; end
  class TransactionUnsupportedError < StandardError; end

  class PluginDeletionError < StandardError
    def initialize(plugin_name, original_error_class)
      super("회원 탈퇴 플러그인 데이터 삭제 실패 [#{plugin_name}], error: #{original_error_class}")
    end
  end

  def initialize(user, plugins: PluginRegistry.all, data_cleaner: Console::PluginDataCleaner, logger: Rails.logger)
    @user = user
    @plugins = plugins
    @data_cleaner = data_cleaner
    @logger = logger
  end

  def call
    validate_plugin_transactions!

    ApplicationRecord.transaction(requires_new: true) do
      within_plugin_transactions(@plugins) do
        clean_plugin_data
        @user.destroy!
      end
    end

    true
  rescue PluginDeletionError => error
    @logger.error("#{error.message}, user_id: #{@user.id}")
    false
  rescue StandardError => error
    @logger.error("회원 탈퇴 계정 삭제 실패, user_id: #{@user.id}, error: #{error.class}")
    false
  end

  private

  def within_plugin_transactions(plugins, &operation)
    return operation.call if plugins.empty?

    plugin, *remaining_plugins = plugins
    @data_cleaner.with_transaction(plugin_name: plugin.name) do
      within_plugin_transactions(remaining_plugins, &operation)
    end
  end

  def validate_plugin_transactions!
    @plugins.each do |plugin|
      next if @data_cleaner.transaction_supported?(plugin_name: plugin.name)

      raise PluginDeletionError.new(plugin.name, TransactionUnsupportedError)
    end
  end

  def clean_plugin_data
    @plugins.each do |plugin|
      clean_plugin_data_for(plugin)
    end
  end

  def clean_plugin_data_for(plugin)
    return if @data_cleaner.clean_data_for(plugin_name: plugin.name, user_id: @user.id)

    raise PluginDeletionError.new(plugin.name, FalsyResultError)
  rescue PluginDeletionError
    raise
  rescue StandardError => error
    raise PluginDeletionError.new(plugin.name, error.class)
  end
end
