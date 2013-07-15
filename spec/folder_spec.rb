#encoding: UTF-8

require 'spec_helper'

describe Egnyte::Folder do
  before(:each) do
    session = Egnyte::Session.new({
      key: 'api_key',
      domain: 'test',
      access_token: 'access_token'
    })
    @client = Egnyte::Client.new(session)
  end

  describe "Folder::find" do
    it "should return a folder object if the folder exists" do
      stub_request(:get, "https://test.egnyte.com/pubapi/v1/fs/Shared")
        .with(:headers => { 'Authorization' => 'Bearer access_token' })
        .to_return(:body => File.read('./spec/fixtures/list_folder.json'), :status => 200)

      @client.folder.name.should == 'docs'
    end

    it "should raise FileOrFolderNotFound error for a non-existent folder" do
      stub_request(:get, "https://test.egnyte.com/pubapi/v1/fs/banana")
        .with(:headers => { 'Authorization' => 'Bearer access_token' })
        .to_return(:status => 404)

      lambda {@client.folder('banana')}.should raise_error( Egnyte::FileFolderNotFound ) 
    end

    it "should raise FolderExpected if path to file provided" do
      stub_request(:get, "https://test.egnyte.com/pubapi/v1/fs/Shared")
        .with(:headers => { 'Authorization' => 'Bearer access_token' })
        .to_return(:body => File.read('./spec/fixtures/list_file.json'), :status => 200)

      lambda {@client.folder}.should raise_error( Egnyte::FolderExpected ) 
    end
  end

  describe "#files" do
    it "should return an array of file objects" do
      stub_request(:get, "https://test.egnyte.com/pubapi/v1/fs/Shared")
        .with(:headers => { 'Authorization' => 'Bearer access_token' })
        .to_return(:body => File.read('./spec/fixtures/list_folder.json'), :status => 200)

      folder = @client.folder
      file = folder.files.first
      file.is_a?(Egnyte::File).should == true
      file.path.should == 'Shared/test.txt'
    end

    it "should return an empty array if there arent any files in the folder" do
      stub_request(:get, "https://test.egnyte.com/pubapi/v1/fs/Shared")
        .with(:headers => { 'Authorization' => 'Bearer access_token' })
        .to_return(:body => File.read('./spec/fixtures/folder_listing_no_files.json'), :status => 200)

      folder = @client.folder
      files = folder.files
      files.size.should == 0
    end
  end

  describe "#folders" do
    it "should return an array of file objects" do
      stub_request(:get, "https://test.egnyte.com/pubapi/v1/fs/Shared")
        .with(:headers => { 'Authorization' => 'Bearer access_token' })
        .to_return(:body => File.read('./spec/fixtures/list_folder.json'), :status => 200)

      folder = @client.folder
      file = folder.folders.first
      file.is_a?(Egnyte::Folder).should == true
      file.path.should == 'Shared/subfolder1'
    end
  end
end
