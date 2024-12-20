require_relative "boot"

require "rails"

require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"

Bundler.require(*Rails.groups)

module AccountifyApp
  class Application < Rails::Application
    config.load_defaults 7.0

    config.generators.system_tests = nil

    config.autoload_paths << Rails.root.join('lib')
  end
end
