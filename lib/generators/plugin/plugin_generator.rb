# frozen_string_literal: true

# 새 Console 플러그인(Rails Engine) 생성 제너레이터
#
# 사용법:
#   bin/rails generate plugin note 메모
#   bin/rails generate plugin note 메모 --icon=notebook --position=30
#
# 삭제:
#   bin/rails destroy plugin note
class PluginGenerator < Rails::Generators::Base
  argument :plugin_name, type: :string, desc: "플러그인 이름 (예: note)"
  argument :label, type: :string, desc: "네비게이션 표시 이름 (예: 메모)"

  class_option :icon, type: :string, default: "box", desc: "Lucide 아이콘 이름"
  class_option :position, type: :numeric, default: 100, desc: "메뉴 정렬 순서"

  def create_engine_structure
    empty_directory engine_path
    empty_directory "#{engine_path}/app/controllers/#{plugin_name}"
    empty_directory "#{engine_path}/app/models/#{plugin_name}"
    empty_directory "#{engine_path}/app/views/#{plugin_name}"
    empty_directory "#{engine_path}/config"
    empty_directory "#{engine_path}/db/migrate"
    empty_directory "#{engine_path}/lib/#{plugin_name}"
  end

  def create_gemspec
    create_file "#{engine_path}/#{plugin_name}.gemspec", <<~RUBY
      require_relative "lib/#{plugin_name}/version"

      Gem::Specification.new do |spec|
        spec.name        = "#{plugin_name}"
        spec.version     = #{module_name}::VERSION
        spec.authors     = ["Console"]
        spec.summary     = "#{label} 플러그인"

        spec.files = Dir.chdir(File.expand_path(__dir__)) do
          Dir["{app,config,db,lib}/**/*", "Rakefile"]
        end

        spec.add_dependency "rails", ">= 8.0"
      end
    RUBY
  end

  def create_lib_files
    create_file "#{engine_path}/lib/#{plugin_name}.rb", <<~RUBY
      require "#{plugin_name}/version"

      module #{module_name}
        # DB가 분리되어 있으므로 테이블명에 네임스페이스 접두사 불필요
        def self.table_name_prefix
          ""
        end
      end

      require "#{plugin_name}/engine"
    RUBY

    create_file "#{engine_path}/lib/#{plugin_name}/version.rb", <<~RUBY
      module #{module_name}
        VERSION = "0.1.0"
      end
    RUBY

    create_file "#{engine_path}/lib/#{plugin_name}/engine.rb", <<~RUBY
      module #{module_name}
        class Engine < ::Rails::Engine
          isolate_namespace #{module_name}

          initializer "#{plugin_name}.register_plugin", after: :load_config_initializers do
            ::PluginRegistry.register(
              name: :#{mount_path},
              label: "#{label}",
              icon: "#{icon}",
              path: "/#{mount_path}",
              position: #{position}
            )
          end
        end
      end
    RUBY
  end

  def create_application_controller
    create_file "#{engine_path}/app/controllers/#{plugin_name}/application_controller.rb", <<~RUBY
      module #{module_name}
        class ApplicationController < ::ApplicationController
          include Console::PluginInterface
        end
      end
    RUBY
  end

  def create_application_record
    create_file "#{engine_path}/app/models/#{plugin_name}/application_record.rb", <<~RUBY
      module #{module_name}
        class ApplicationRecord < ActiveRecord::Base
          self.abstract_class = true

          connects_to database: { writing: :#{plugin_name}, reading: :#{plugin_name} }
        end
      end
    RUBY
  end

  def create_routes
    create_file "#{engine_path}/config/routes.rb", <<~RUBY
      #{module_name}::Engine.routes.draw do
        # 여기에 라우트를 추가하세요
        # resources :items
        # root "items#index"
      end
    RUBY
  end

  def update_gemfile
    append_to_file "Gemfile", "gem \"#{plugin_name}\", path: \"engines/#{plugin_name}\"\n"
  end

  def update_routes
    inject_into_file "config/routes.rb",
                     "  mount #{module_name}::Engine, at: \"/#{mount_path}\"\n",
                     after: "# 플러그인 Engine 마운트\n"
  end

  def update_database_yml
    # 각 환경의 queue: 섹션 앞에 삽입 (queue DB 경로로 환경 구분)
    { "development" => [ "storage/development_#{plugin_name}.sqlite3", "storage/development_queue.sqlite3" ],
      "test" => [ "storage/test_#{plugin_name}.sqlite3", "storage/test_queue.sqlite3" ],
      "production" => [ "\"/storage/production_#{plugin_name}.sqlite3\"", "\"/storage/production_queue.sqlite3\"" ] }.each do |_env, (plugin_db, queue_db)|
      inject_into_file "config/database.yml",
                       db_config_block(plugin_db),
                       before: "  queue:\n    <<: *default\n    database: #{queue_db}\n"
    end
  end

  def update_dockerfile
    # RUN bundle install 앞에 삽입하여 중복 방지
    inject_into_file "Dockerfile",
                     dockerfile_copy_lines,
                     before: "RUN bundle install"
  end

  def print_next_steps
    say ""
    say "=== 플러그인 '#{plugin_name}' 생성 완료! ===", :green
    say ""
    say "다음 단계:"
    say "  1. bundle install"
    say "  2. 모델, 컨트롤러, 뷰, 마이그레이션 작성"
    say "  3. bin/rails db:migrate 실행"
  end

  private

  def engine_path
    "engines/#{plugin_name}"
  end

  def module_name
    plugin_name.camelize
  end

  def mount_path
    plugin_name.pluralize
  end

  def icon
    options[:icon]
  end

  def position
    options[:position]
  end

  def db_config_block(db_path)
    <<~YAML.indent(2)
      #{plugin_name}:
        <<: *default
        database: #{db_path}
        migrations_paths: engines/#{plugin_name}/db/migrate
    YAML
  end

  def dockerfile_copy_lines
    <<~DOCKER
      COPY engines/#{plugin_name}/#{plugin_name}.gemspec engines/#{plugin_name}/
      COPY engines/#{plugin_name}/lib/#{plugin_name}/version.rb engines/#{plugin_name}/lib/#{plugin_name}/
    DOCKER
  end
end
