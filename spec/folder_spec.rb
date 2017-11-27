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
    context "when the upload fails (e.g. when the service is unavailable)" do
      it "raises an appropriate exception" do
        file_contents = 'Some data.'

        stub_request(:post, "https://test.egnyte.com/pubapi/v1/fs-content/apple/banana/LICENSE.txt")
          .with(:headers => { 'Authorization' => 'Bearer access_token' }, :body => file_contents)
          .to_return(:body => '', :status => 503)

          folder = Egnyte::Folder.new({
            'path' => 'apple/banana',
            'name' => 'banana'
          }, @session)

          expect {
            folder.upload('LICENSE.txt', StringIO.new(file_contents))
          }.to raise_error(Egnyte::RequestError)
      end
    end

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

      expect(file.is_folder).to be false
      expect(file.name).to eq('LICENSE.txt')
      expect(file.entry_id).to eq('c0c6c151-104b-4ddd-a0c7-eea809fc8a6a')
      expect(file.checksum).to eq('434390eddf638ab28e0f4668dca32e4a2b05c96eb3c8c0ca889788e204158cb4f240f1055ebac35745ede0e2349c83b407b9e4e0109bdc0b5ccdfe332a60fcfc')
      expect(file.last_modified).to eq('Mon, 05 Aug 2013 22:37:35 GMT')
      expect(file.size).to eq(1103)
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
      expect(new_folder.name).to eq('New Folder')
      expect(new_folder.path).to eq('apple/banana/New Folder')
      expect(new_folder.folders).to eq([])
    end
  end

  describe "Folder::find" do
    it "should return a folder object if the folder exists" do
      stub_request(:get, "https://test.egnyte.com/pubapi/v1/fs/Shared")
        .with(:headers => { 'Authorization' => 'Bearer access_token' })
        .to_return(:body => File.read('./spec/fixtures/list_folder.json'), :status => 200)

      expect(@client.folder.name).to eq('docs')
    end

    it "should raise FileOrFolderNotFound error for a non-existent folder" do
      stub_request(:get, "https://test.egnyte.com/pubapi/v1/fs/banana")
        .with(:headers => { 'Authorization' => 'Bearer access_token' })
        .to_return(:status => 404)

      expect {@client.folder('banana')}.to raise_error( Egnyte::RecordNotFound )
    end

    it "should raise FolderExpected if path to file provided" do
      stub_request(:get, "https://test.egnyte.com/pubapi/v1/fs/Shared")
        .with(:headers => { 'Authorization' => 'Bearer access_token' })
        .to_return(:body => File.read('./spec/fixtures/list_file.json'), :status => 200)

      expect {@client.folder}.to raise_error( Egnyte::FolderExpected )
    end
  end

  describe "Folder::permissions" do
    it "should return a folder permissions object if the folder exists" do
      stub_request(:get, "https://test.egnyte.com/pubapi/v1/fs/Shared")
        .with(:headers => { 'Authorization' => 'Bearer access_token' })
        .to_return(:body => File.read('./spec/fixtures/list_folder.json'), :status => 200)
      expect(@client.folder.name).to eq('docs')
    end

    it "should raise FileOrFolderNotFound error for a non-existent folder" do
      stub_request(:get, "https://test.egnyte.com/pubapi/v1/fs/banana")
        .with(:headers => { 'Authorization' => 'Bearer access_token' })
        .to_return(:status => 404)

      expect {@client.folder('banana')}.to raise_error( Egnyte::RecordNotFound )
    end

    it "should raise FolderExpected if path to file provided" do
      stub_request(:get, "https://test.egnyte.com/pubapi/v1/fs/Shared")
        .with(:headers => { 'Authorization' => 'Bearer access_token' })
        .to_return(:body => File.read('./spec/fixtures/list_file.json'), :status => 200)

      expect {@client.folder}.to raise_error( Egnyte::FolderExpected )
    end
  end

  describe "#files" do
    it "should return an array of file objects" do
      stub_request(:get, "https://test.egnyte.com/pubapi/v1/fs/Shared")
        .with(:headers => { 'Authorization' => 'Bearer access_token' })
        .to_return(:body => File.read('./spec/fixtures/list_folder.json'), :status => 200)

      folder = @client.folder
      file = folder.files.first
      expect(file).to be_instance_of(Egnyte::File)
      expect(file.path).to eq('Shared/test.txt')
    end

    it "should return an empty array if there arent any files in the folder" do
      stub_request(:get, "https://test.egnyte.com/pubapi/v1/fs/Shared")
        .with(:headers => { 'Authorization' => 'Bearer access_token' })
        .to_return(:body => File.read('./spec/fixtures/folder_listing_no_files.json'), :status => 200)

      folder = @client.folder
      files = folder.files
      expect(files.size).to eq(0)
    end
  end

  describe "#folders" do
    it "should return an array of file objects" do
      stub_request(:get, "https://test.egnyte.com/pubapi/v1/fs/Shared")
        .with(:headers => { 'Authorization' => 'Bearer access_token' })
        .to_return(:body => File.read('./spec/fixtures/list_folder.json'), :status => 200)

      folder = @client.folder
      file = folder.folders.first
      expect(file).to be_instance_of(Egnyte::Folder)
      expect(file.path).to eq('Shared/subfolder1')
    end
  end

  context "permissions" do
    before(:each) do
      stub_request(:get, "https://test.egnyte.com/pubapi/v1/fs/Shared")
        .with(:headers => { 'Authorization' => 'Bearer access_token' })
        .to_return(:body => File.read('./spec/fixtures/list_folder.json'), :status => 200)
    end

    describe "#permissions" do
      it "should returned a parsed list permissions" do
        stub_request(:get, "https://test.egnyte.com/pubapi/v1/perms/folder/Shared")
          .with(:headers => { 'Authorization' => 'Bearer access_token' })
          .to_return(:body => File.read('./spec/fixtures/permission/permission_list.json'), :status => 200)
        folder = Egnyte::Folder.find(@session, 'Shared')
        permissions = folder.permissions
        expect(permissions.class).to eq Egnyte::Permission
        expect(permissions.data['groups'].size).to eq 2
        expect(permissions.data['users'].size).to eq 66
        expect(permissions.data['users']['knikolaus']).to eq "Owner"
      end
    end

    describe "#apply_permission" do
      it "should call the apply method in Egnyte::Permission" do
        stub_request(:post, "https://test.egnyte.com/pubapi/v1/perms/folder/Shared")
          .with(:headers => { 'Authorization' => 'Bearer access_token' })
          .to_return(:body => "", :status => 200)
        perm_obj = Egnyte::Permission.build_from_api_listing({'users' => [{'subject' => 'thintz', 'permission' => 'Viewer'}]})
        folder = Egnyte::Folder.find(@session, 'Shared')
        expect(Egnyte::Permission).to receive(:apply)
        folder.apply_permissions(perm_obj)
      end
    end

  end

end
