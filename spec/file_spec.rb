#encoding: UTF-8

require 'spec_helper'

describe Egnyte::File do
  before(:each) do
    session = Egnyte::Session.new({
      key: 'api_key',
      domain: 'test',
      access_token: 'access_token'
    }, :implicit, 0.0)
    @client = Egnyte::Client.new(session)
  end

  describe "File::find" do
    it "should return a file object if the file exists" do
      stub_request(:get, "https://test.egnyte.com/pubapi/v1/fs/Shared/example.txt")
        .with(:headers => { 'Authorization' => 'Bearer access_token' })
        .to_return(:body => File.read('./spec/fixtures/list_file.json'), :status => 200)

      expect(@client.file('/Shared/example.txt').name).to eq('example.txt')
    end

    it "should raise FileOrFolderNotFound error for a non-existent file" do
      stub_request(:get, "https://test.egnyte.com/pubapi/v1/fs/Shared/banana.txt")
        .with(:headers => { 'Authorization' => 'Bearer access_token' })
        .to_return(:status => 404)

      expect{@client.file('Shared/banana.txt')}.to raise_error( Egnyte::RecordNotFound ) 
    end

    it "should raise FileExpected if path to folder provided" do
      stub_request(:get, "https://test.egnyte.com/pubapi/v1/fs/Shared")
        .with(:headers => { 'Authorization' => 'Bearer access_token' })
        .to_return(:body => File.read('./spec/fixtures/list_folder.json'), :status => 200)

      expect{@client.file('/Shared')}.to raise_error( Egnyte::FileExpected ) 
    end
  end

end
