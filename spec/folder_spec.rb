#encoding: UTF-8

require 'spec_helper'

describe Egnyte::Folder do
  before(:each) do
    @session = Egnyte::Session.new({
      key: 'api_key',
      domain: 'test',
      access_token: 'access_token'
    }, :implicit, 0.0)
    @client = Egnyte::Client.new(@session)
  end

  describe "#upload" do
    it "upload file to appropriate endpoint, and return a file object" do
      stub_request(:post, "https://test.egnyte.com/pubapi/v1/fs-content/apple/banana/LICENSE.txt")
        .with(:headers => { 'Authorization' => 'Bearer access_token' }, :body => File.open('./LICENSE.txt').read)
        .to_return(:body => '', :status => 200, :headers => {
          'ETag' => 'c0c6c151-104b-4ddd-a0c7-eea809fc8a6a',
          'X-Sha512-Checksum' => '434390eddf638ab28e0f4668dca32e4a2b05c96eb3c8c0ca889788e204158cb4f240f1055ebac35745ede0e2349c83b407b9e4e0109bdc0b5ccdfe332a60fcfc',
          'last_modified' => 'Mon, 05 Aug 2013 22:37:35 GMT'
        })

      folder = Egnyte::Folder.new({
        'path' => 'apple/banana',
        'name' => 'banana'
      }, @session)

      file = nil

      File.open( './LICENSE.txt' ) do |data|
        file = folder.upload('LICENSE.txt', data)
      end

      file.is_folder.should == false
      file.name.should == 'LICENSE.txt'
      file.entry_id.should == 'c0c6c151-104b-4ddd-a0c7-eea809fc8a6a'
      file.checksum.should == '434390eddf638ab28e0f4668dca32e4a2b05c96eb3c8c0ca889788e204158cb4f240f1055ebac35745ede0e2349c83b407b9e4e0109bdc0b5ccdfe332a60fcfc'
      file.last_modified.should == 'Mon, 05 Aug 2013 22:37:35 GMT'
      file.size.should == 1071
    end
  end

  describe "#create" do
    it "should call post to fs/path with appropriate payload and return folder object" do
      stub_request(:post, "https://test.egnyte.com/pubapi/v1/fs/apple/banana/New%20Folder")
        .with(:headers => { 'Authorization' => 'Bearer access_token' }, :body => JSON.dump({"action" => "add_folder"}))
        .to_return(:body => '', :status => 200)

      folder = Egnyte::Folder.new({
        'path' => 'apple/banana',
        'name' => 'banana'
      }, @session)

      new_folder = folder.create('New Folder')
      new_folder.name.should == 'New Folder'
      new_folder.path.should == 'apple/banana/New Folder'
      new_folder.folders.should == []
    end
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
