#encoding: UTF-8

require 'spec_helper'

describe Egnyte::File do
  before(:each) do
    session = Egnyte::Session.new({
      key: 'api_key',
      domain: 'test',
      access_token: 'access_token'
    })
    @client = Egnyte::Client.new(session)
  end

  describe "File::find" do
    it "should return a file object if the file exists" do
      stub_request(:get, "https://test.egnyte.com/pubapi/v1/fs/Shared/example.txt")
        .with(:headers => { 'Authorization' => 'Bearer access_token' })
        .to_return(:body => File.read('./spec/fixtures/list_file.json'), :status => 200)

      @client.file('/Shared/example.txt').name.should == 'example.txt'
    end

    it "should raise FileOrFolderNotFound error for a non-existent file" do
      stub_request(:get, "https://test.egnyte.com/pubapi/v1/fs/Shared/banana.txt")
        .with(:headers => { 'Authorization' => 'Bearer access_token' })
        .to_return(:status => 404)

      lambda {@client.file('Shared/banana.txt')}.should raise_error( Egnyte::FileFolderNotFound ) 
    end

    it "should raise FileExpected if path to folder provided" do
      stub_request(:get, "https://test.egnyte.com/pubapi/v1/fs/Shared")
        .with(:headers => { 'Authorization' => 'Bearer access_token' })
        .to_return(:body => File.read('./spec/fixtures/list_folder.json'), :status => 200)

      lambda {@client.file('/Shared')}.should raise_error( Egnyte::FileExpected ) 
    end
  end

end