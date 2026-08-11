require "net/http"

module Fcm::HttpClient
  OPEN_TIMEOUT = 5.seconds
  READ_TIMEOUT = 10.seconds
  WRITE_TIMEOUT = 10.seconds

  module_function

  def post(endpoint, body, headers)
    request = Net::HTTP::Post.new(endpoint, headers)
    request.body = body

    http = Net::HTTP.new(endpoint.host, endpoint.port)
    http.use_ssl = endpoint.scheme == "https"
    http.open_timeout = OPEN_TIMEOUT
    http.read_timeout = READ_TIMEOUT
    http.write_timeout = WRITE_TIMEOUT
    http.request(request)
  end
end
