#encoding: UTF-8

require 'spec_helper'

describe Egnyte::EgnyteError do
  let!(:session) {Egnyte::Session.new({
    key: 'api_key',
    domain: 'test',
    access_token: 'access_token'
  }, :implicit, 0.0)}
  let!(:client) { Egnyte::Client.new(session) }

  subject {client.file('/Shared/example.txt')}

  def stub_success
    stub_request(:get, "https://test.egnyte.com/pubapi/v1/fs/Shared/example.txt")
      .to_return(:body => File.read('./spec/fixtures/list_file.json'), :status => 200)
  end

  context "status: 200" do
    before { stub_success }
    it "works" do
      expect {subject}.not_to raise_error
    end
  end

  let(:error_message) {"Something new in sandwiches"}
  context "with a json error" do
    before do
      stub_request(:get, "https://test.egnyte.com/pubapi/v1/fs/Shared/example.txt")
        .to_return(:body => { "Errors": [{ "description": error_message, "code": "400" }] }.to_json, :status =>
          400)
    end
    it "raises expected error class" do
      expect {subject}.to raise_error(Egnyte::BadRequest)
    end
    it "raises expected error with message " do
      expect {subject}.to raise_error /#{error_message}/
    end
  end

  context "with a  non json error" do
    before do
      stub_request(:get, "https://test.egnyte.com/pubapi/v1/fs/Shared/example.txt")
        .to_return(:body => "#{error_message} which doesn't look like JSON!", :status => 400)
    end
    let(:error_message) {"Something new in sandwitches"}
    it "raises expected error class" do
      expect {subject}.to raise_error(Egnyte::BadRequest)
    end
    it "raises expected error with message " do
      expect {subject}.to raise_error /#{error_message}/
    end
  end

  context "with a  non json error" do
    before do
      stub_request(:get, "https://test.egnyte.com/pubapi/v1/fs/Shared/example.txt")
        .to_return(:body => "#{error_message} which doesn't look like JSON!", :status => 400)
    end
    let(:error_message) {"Something new in sandwitches"}
    it "raises expected error class" do
      expect {subject}.to raise_error(Egnyte::BadRequest)
    end
    it "raises expected error with message " do
      expect {subject}.to raise_error /#{error_message}/
    end
  end

  context "with a standard 403" do
    before do
      stub_request(:get, "https://test.egnyte.com/pubapi/v1/fs/Shared/example.txt")
        .to_return(:body => "#{error_message} which doesn't look like JSON!", :status => 403)
    end
    let(:error_message) {"Something new in sandwitches"}
    it "raises expected error class" do
      expect {subject}.to raise_error(Egnyte::InsufficientPermissions)
    end
    it "raises expected error with message " do
      expect {subject}.to raise_error /#{error_message}/
    end
  end

  context "with a 403 indicating over Quota Per Second" do
    def stub_rate_limit_exceeded_per_second(retry_after: 1)
      stub_request(:get, "https://test.egnyte.com/pubapi/v1/fs/Shared/example.txt")
        .to_return(:body => "#{error_message} which doesn't look like JSON!", :status => 403,
          headers: { 'X-Mashery-Error-Code' => 'ERR_403_DEVELOPER_OVER_QPS', 'Retry-After' => retry_after })
    end
    context "when not configured for retries" do
      before {stub_rate_limit_exceeded_per_second}

      let(:error_message) {"Something new in sandwitches"}

      it "raises with retry_after" do
        expect {subject}.to raise_error(Egnyte::RateLimitExceededPerSecond) do |e|
          expect(e.retry_after).to eq(1)
        end
      end
    end

    context "when configured for retries" do
      let!(:session) {Egnyte::Session.new({
        key: 'api_key',
        domain: 'test',
        access_token: 'access_token'
      }, :implicit, 0.0, retries: 3)}

      it "will retry and succeed" do
        stub_rate_limit_exceeded_per_second(retry_after: 0)
        stub_rate_limit_exceeded_per_second(retry_after: 0)
        stub_success
        expect {subject}.not_to raise_error
      end

      it "will retry and run out of times" do
        stub_rate_limit_exceeded_per_second(retry_after: 0)
        stub_rate_limit_exceeded_per_second(retry_after: 0)
        stub_rate_limit_exceeded_per_second(retry_after: 0)
        expect {subject}.to raise_error(Egnyte::RateLimitExceededPerSecond)
      end
      it "won't retry if wait too long" do
        stub_rate_limit_exceeded_per_second(retry_after: 6000)
        expect {subject}.to raise_error(Egnyte::RateLimitExceededPerSecond)
      end
    end
  end

  context "with a 403 indicating over Daily Quota" do
    before do
      stub_request(:get, "https://test.egnyte.com/pubapi/v1/fs/Shared/example.txt")
        .to_return(:body => "#{error_message} which doesn't look like JSON!", :status => 403,
          headers: { 'X-Mashery-Error-Code' => 'ERR_403_DEVELOPER_OVER_RATE', 'Retry-After' => 100 })
    end

    let(:error_message) {"Something new in sandwitches"}

    it "returns correct retry_after" do
      expect {subject}.to raise_error(Egnyte::RateLimitExceededQuota) do |e|
        expect(e.retry_after).to eq(100)
      end
    end
  end

end
