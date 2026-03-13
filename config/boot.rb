ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup"
require "bootsnap/setup" if File.exist?(File.expand_path("../vendor/bundle/ruby/*/gems/bootsnap-*/lib/bootsnap/setup", __dir__))
