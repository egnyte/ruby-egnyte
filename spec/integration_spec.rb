require 'spec_helper'
require 'helper/account'
require 'egnyte'

describe Egnyte, :skip => true do
  before do
    WebMock.allow_net_connect!
    
    @session = Egnyte::Session.new({
      api_key: ACCOUNT['api_key'],
      access_token: ACCOUNT['access_token'],
      domain: ACCOUNT['domain']
    })

    @root_folder = ACCOUNT['root_folder']

    @client = Egnyte::Client.new(@session)

    @file_data = File.open( 'spec/fixtures/uploads/large_turtle.JPG' )
    @file_name = 'large_turtle.jpg'
    @client.folder(@root_folder + '/test_attachments/file_test').upload(@file_name, @file_data)
  end

  after do
    @client.file(@root_folder + '/test_attachments/file_test/large_turtle.jpg').delete
  end

  it "raises an AuthError if not client auth fails" do
    session = Egnyte::Session.new({
      api_key: 'bad-key',
      access_token: 'bad-token',
      domain: 'bad-banana'
    })

    @bad_client = Egnyte::Client.new(session)

    lambda {@bad_client.root_folder}.should raise_error
  end

  describe Egnyte::Client do
    describe '#initialize' do
      it 'can initialize a client properly' do
        @session.should_not == nil
        @client.should_not == nil
      end
    end

    describe '#file' do
      it 'can stream a file download multiple times without error' do
        first_size = @client.file(@root_folder + '/test_attachments/file_test/large_turtle.jpg').stream.read.size
        for i in (0..25) do
          data = @client.file(@root_folder + '/test_attachments/file_test/large_turtle.jpg').stream.read
          data.size.should == first_size
        end
      end
    end

    describe '#folder' do
      it 'can list the items in a folder' do
        @client.folder(@root_folder + '/test_attachments').folders.count.should == 3
      end

      it 'can create and delete a folder' do
        @client.folder(@root_folder + '/test_attachments').create('/christmas')
        @client.folder(@root_folder + '/test_attachments').folders.count.should == 4
        @client.folder(@root_folder + '/test_attachments/christmas').delete
        @client.folder(@root_folder + '/test_attachments').folders.count.should == 3
      end

      it 'can upload a file' do
        @client.folder(@root_folder + '/test_attachments/folder_test').files.count.should == 0
        @client.folder(@root_folder + '/test_attachments/folder_test').upload(@file_name, @file_data)
        @client.folder(@root_folder + '/test_attachments/folder_test').files.count.should == 1
        @client.file(@root_folder + '/test_attachments/folder_test/large_turtle.jpg').delete
      end
    end
  end
end