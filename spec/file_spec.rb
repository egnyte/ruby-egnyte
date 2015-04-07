#encoding: UTF-8

require 'spec_helper'

describe Egnyte::File do
  before(:each) do
    stub_request(:get, "https://test.egnyte.com/pubapi/v1/userinfo").
             with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'Bearer access_token', 'User-Agent'=>'Ruby'}).
             to_return(:status => 200, :body => "", :headers => {})
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

  describe "#download" do
    it "should stream the file contents" do
      stub_request(:get, "https://test.egnyte.com/pubapi/v1/fs/Shared/banana.txt")
        .with(:headers => { 'Authorization' => 'Bearer access_token' })
        .to_return(:body => File.read('./spec/fixtures/list_file.json'), :status => 200)

      stub_request(:get, "https://test.egnyte.com/pubapi/v1/fs-content/Shared/banana.txt")
        .with(:headers => { 'Authorization' => 'Bearer access_token' })
        .to_return(:body => 'Banana Text', :status => 200)

      expect(@client.file('Shared/banana.txt').download).to eq('Banana Text')
    end
  end

  describe "#delete" do
    it "should delete the file" do
      stub_request(:get, "https://test.egnyte.com/pubapi/v1/fs/Shared/banana.txt")
        .with(:headers => { 'Authorization' => 'Bearer access_token' })
        .to_return(:body => File.read('./spec/fixtures/list_file.json'), :status => 200)

      stub_request(:delete, "https://test.egnyte.com/pubapi/v1/fs/Shared/banana.txt")
        .with(:headers => { 'Authorization' => 'Bearer access_token' })
        .to_return(:body => '{"status":"no more banana"}', :status => 200)

      expect(@client.file('Shared/banana.txt').delete).to eq({ "status" => "no more banana" })
    end
  end
end
