require 'spec_helper'

describe Requester do
  let(:requester) do
    Class.new{ include Requester }.new
  end

  describe "#get" do
    it "limits the number of redirects to follow" do
      url = 'http://www.example.com/_status'
      redirect = Net::HTTPRedirection.new('1.1', '302', 'Found')
      redirect['Location'] = url
      FakeWeb.register_uri(:get, url, response: redirect)

      expect { requester.get(url) }.to raise_error Requester::RedirectLimitExceeded
    end
  end
end
