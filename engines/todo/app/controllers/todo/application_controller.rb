module Todo
  class ApplicationController < ::ApplicationController
    include Console::PluginInterface
    helper :all
  end
end
