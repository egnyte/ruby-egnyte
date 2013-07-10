#encoding: UTF-8

require 'spec_helper'
require 'egnyte'

describe Egnyte::Client do
  before(:each) do
  end

  describe "#folder" do
    it "should use Folder::find to lookup a folder" do
      stub_request(:get, "https://test.egnyte.com/pubapi/v1/fs/Shared/")
        .with(:headers => { 'Authorization' => 'Bearer access_token' })
        .to_return(:body => File.read('./spec/fixtures/list_folder.json'), :status => 200)

      session = Egnyte::Session.new({
        key: 'api_key',
        domain: 'test',
        access_token: 'access_token'
      })
      
      client = Egnyte::Client.new(session)
      client.folder.name.should == 'docs'
    end

    it "should raise a FileOrFolderNotFound error for a non-existent path" do

    end
  end
end