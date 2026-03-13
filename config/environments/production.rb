require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?
  config.assets.compile = false
  config.active_support.deprecation = :notify
  config.active_support.report_deprecations = false
  config.log_level = :info
  config.log_formatter = ::Logger::Formatter.new
  config.i18n.fallbacks = true
end
