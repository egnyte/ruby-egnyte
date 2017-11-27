#encoding: UTF-8

require 'spec_helper'

describe Egnyte::EgnyteError do
  before(:each) do
    session = Egnyte::Session.new({
      key: 'api_key',
      domain: 'test',
      access_token: 'access_token'
    }, :implicit, 0.0)
    @client = Egnyte::Client.new(session)
  end

  subject {@client.file('/Shared/example.txt')}

  context "status: 200" do
    before do
      stub_request(:get, "https://test.egnyte.com/pubapi/v1/fs/Shared/example.txt")
        .to_return(:body => File.read('./spec/fixtures/list_file.json'), :status => 200)
    end
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

end