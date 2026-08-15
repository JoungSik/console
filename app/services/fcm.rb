module Fcm
  class Error < StandardError; end
  class ConfigurationError < Error; end
  class InvalidRegistrationError < Error; end
end
