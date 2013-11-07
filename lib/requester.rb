require "net/http"
require 'json'

module Requester
  class RedirectLimitExceeded < StandardError; end

  def get(uri_string, redirect_limit = 10)
    raise RedirectLimitExceeded if not redirect_limit > 0

    uri = URI.parse(uri_string)
    response = nil
    Net::HTTP.start(uri.host, uri.port, timeout: 5) do |http|
      request = Net::HTTP::Get.new uri
      response = http.request request
    end
    case response
    when Net::HTTPRedirection
      get response['Location'], redirect_limit - 1
    when Net::HTTPSuccess
      JSON.parse response.body
    else
      response.error!
    end
  end

  def post(uri_string, params=[])
    uri = URI(uri_string)
    http = Net::HTTP.new(uri.host, uri.port)
    response = Net::HTTP.post_form(uri, params)
    if response.is_a? Net::HTTPOK
      JSON.parse response.body
    else
      response.error!
    end
  end
end