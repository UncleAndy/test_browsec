require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TestBrowsec
  class Application < Rails::Application
    config.time_zone = 'Moscow'

    config.i18n.default_locale = :ru
    config.i18n.locale = :ru

    config.encoding = "utf-8"

    config.active_record.raise_in_transactional_callbacks = true

    config.autoload_paths += %W(#{config.root}/app/services)
  end
end
