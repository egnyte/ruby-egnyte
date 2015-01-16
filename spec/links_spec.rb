#encoding: UTF-8

require 'spec_helper'

describe Egnyte::Link do
  before(:each) do
    @invalid_link_params = {}
    @valid_folder_link_params = {
      path: '/Shared/Documents',
      type: 'folder',
      accessibility: 'Anyone'
    }
    @valid_file_link_params = {
      path: '/Shared/Documents/test.txt',
      type: 'file',
      accessibility: 'Anyone'
    }
    stub_request(:get, "https://test.egnyte.com/pubapi/v1/userinfo").
             with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'Bearer access_token', 'User-Agent'=>'Ruby'}).
             to_return(:status => 200, :body => "", :headers => {})
    @session = Egnyte::Session.new({
      key: 'api_key',
      domain: 'test',
      access_token: 'access_token'
    }, :implicit, 0.0)
    @client = Egnyte::Client.new(@session)
    @folder_link = Egnyte::Link.new(@session, @valid_folder_link_params)
    @file_link = Egnyte::Link.new(@session, @valid_file_link_params)
  end

  describe "#initialize" do

    it 'instantiates a valid link if it has all required fields' do
      expect(@folder_link).to be_valid
      expect(@file_link).to be_valid
    end

  end

  context "Posting to Egnyte" do

      before(:each) do
        stub_request(:post, "https://test.egnyte.com/pubapi/v1/links")
           .with(:body => @folder_link.to_json,
                :headers => {'Authorization'=>'Bearer access_token', 'Content-Type'=>'application/json'})
           .to_return(:status => 201, :body => File.read('./spec/fixtures/link/link_create.json'), :headers => {})
        stub_request(:get, "https://test.egnyte.com/pubapi/v1/links/jFmtRccgU0")
           .with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'Bearer access_token', 'User-Agent'=>'Ruby'})
           .to_return(:status => 200, :body => File.read('./spec/fixtures/link/link.json'), :headers => {})
      end

    describe "#create" do

      it "should create a new link if valid" do
        @link = Egnyte::Link.create(@session, @valid_folder_link_params)
        expect(@link.id).to eq 'jFmtRccgU0'
      end

      it "should raise an error if it tries to create an invaid link" do
        expect{ Egnyte::Link.create(@session, @invalid_link_params) }.to raise_error(Egnyte::MissingAttribute)
      end

    end

    describe "#save" do

      it 'should raise an error if an attribute is missing' do
        @folder_link.path = nil
        expect{ @folder_link.save }.to raise_error(Egnyte::MissingAttribute)
      end

      it 'should save a valid new link object by sending a POST to the Egnyte Link API' do
        @folder_link = @folder_link.save
        expect(@folder_link.id).to eq 'jFmtRccgU0'
        expect(@folder_link.path).to eq '/Shared/Documents'
      end

    end

  end

  describe "#Link::find" do

    it 'should return an Egnyte::Link object from a link id string' do
      stub_request(:get, "https://test.egnyte.com/pubapi/v1/links/jFmtRccgU0")
        .with(:headers => {'Authorization'=>'Bearer access_token'})
        .to_return(:status => 200, :body => File.read('./spec/fixtures/link/link.json'), :headers => {})
      link = @client.link('jFmtRccgU0')
      expect(link).to be_an Egnyte::Link
      expect(link.id).to eq 'jFmtRccgU0'
    end

  end

  describe "#Link::all" do

    it 'should list all links' do
      stub_request(:get, "https://test.egnyte.com/pubapi/v1/links")
          .with(:headers => { 'Authorization' => 'Bearer access_token' })
          .to_return(:body => File.read('./spec/fixtures/link/link_list.json'), :status => 200)
      list = Egnyte::Link.all(@session)
      expect(list).to be_an Array
      expect(list.first).to be_a String
      expect(list.size).to eq 4
    end

  end

  describe "#Link::where" do

    it 'should find links that match the where filter' do
      stub_request(:get, "https://test.egnyte.com/pubapi/v1/links?path=/Shared/Documents")
         .with(:headers => {'Authorization'=>'Bearer access_token'})
         .to_return(:status => 200, :body => File.read('./spec/fixtures/link/link_list.json'), :headers => {})
      link_list = Egnyte::Link.where(@session, {path: '/Shared/Documents'})
      expect(link_list).to be_an Array
      expect(link_list.size).to eq 4
      expect(link_list.first).to be_a String
    end

    it 'should return an empty array if no match is found' do
      stub_request(:get, "https://test.egnyte.com/pubapi/v1/links?path=/YagniFubar")
         .with(:headers => {'Authorization'=>'Bearer access_token'})
         .to_return(:status => 200, :body => File.read('./spec/fixtures/link/link_list_empty.json'), :headers => {})
      link_list = Egnyte::Link.where(@session, {path: '/YagniFubar'})
      expect(link_list).to be_an Array
      expect(link_list.size).to eq 0
    end

  end

  describe "#User::delete" do

    it 'should delete a link by id if the link exists' do
      stub_request(:delete, "https://test.egnyte.com/pubapi/v1/links/jFmtRccgU0")
        .with(:headers => {'Authorization'=>'Bearer access_token'})
        .to_return(:status => 200, :body => "", :headers => {})
      expect(Egnyte::User).to receive(:delete)
      Egnyte::User.delete(@session, 'jFmtRccgU0')
    end
    
  end

  describe "#to_json" do

    it 'should render a valid json representation of a folder link' do
      expect(@folder_link.to_json).to eq "{\"path\":\"/Shared/Documents\",\"type\":\"folder\",\"accessibility\":\"Anyone\"}"
    end

    it 'should render a valid json representation of a file link' do
      expect(@file_link.to_json).to eq "{\"path\":\"/Shared/Documents/test.txt\",\"type\":\"file\",\"accessibility\":\"Anyone\"}"
    end

  end

end
