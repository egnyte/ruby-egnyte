#encoding: UTF-8

require 'spec_helper'

describe Egnyte::User do
  before(:each) do
    @invalid_user_params = {}
    @valid_user_params = {
      :userName => "userA",
      :email => "userA@example.com",
      :name => {
        :familyName => "A",
        :givenName => "user"
      },
      :authType => "egnyte",
      :userType => "power",
      :active => true,
      :sendInvite => true
    }
    @session = Egnyte::Session.new({
      key: 'api_key',
      domain: 'test',
      access_token: 'access_token'
    }, :implicit, 0.0)
    @client = Egnyte::Client.new(@session)
    @user = Egnyte::User.new(@session, @valid_user_params)
  end

  describe "#initialize" do

    it 'instantiates a valid user if it has all required fields' do
      expect(@user).to be_valid
    end

  end

  describe "#create" do

    it "should create a new user if valid" do
      stub_request(:post, "https://test.egnyte.com/pubapi/v2/users")
         .with(:body => @user.to_json,
              :headers => {'Authorization'=>'Bearer access_token', 'Content-Type'=>'application/json'})
         .to_return(:status => 201, :body => File.read('./spec/fixtures/user/user_create.json'), :headers => {})
      @user = Egnyte::User.create(@session, @valid_user_params)
      expect(@user.id).to eq 12163350648
    end

    it "should raise an error if it tries to create an invaid user" do
      expect{ Egnyte::User.create(@session, @invalid_user_params) }.to raise_error(Egnyte::MissingAttribute)
    end

  end

  describe "#save" do

    it 'should raise an error if an attribute is missing' do
      @user.userName = nil
      expect{ @user.save }.to raise_error(Egnyte::MissingAttribute)
    end

    it 'should save a valid new user object by sending a POST to the Egnyte User API' do
      stub_request(:post, "https://test.egnyte.com/pubapi/v2/users")
         .with(:body => @user.to_json,
              :headers => {'Authorization'=>'Bearer access_token', 'Content-Type'=>'application/json'})
         .to_return(:status => 201, :body => File.read('./spec/fixtures/user/user_create.json'), :headers => {})
      @user = @user.save
      expect(@user.id).to eq 12163350648
    end

    it 'should update an existing user object by sending a PATCH to the Egnyte User API' do
      stub_request(:patch, "https://test.egnyte.com/pubapi/v2/users/12163350648")
         .with(:body => @user.to_json_for_update,
              :headers => {'Authorization'=>'Bearer access_token', 'Content-Type'=>'application/json'})
         .to_return(:status => 200, :body => File.read('./spec/fixtures/user/user_update.json'), :headers => {})
      @valid_user_params[:id] = 12163350648
      @user = Egnyte::User.new(@session, @valid_user_params)
      @user.save
    end

  end

  describe "#User::find" do

    it 'should find a user by id if the user exists' do
      stub_request(:get, "https://test.egnyte.com/pubapi/v2/users/12408258604")
        .with(:headers => {'Authorization'=>'Bearer access_token'})
        .to_return(:status => 200, :body => File.read('./spec/fixtures/user/user_find.json'), :headers => {})
      user = @client.user(12408258604)
      expect(user).to be_an Egnyte::User
      expect(user.id).to eq 12408258604
    end

  end

  describe "#User::find_by_email" do

    it 'should find a user by email if the user exists' do
      stub_request(:get, "https://test.egnyte.com/pubapi/v2/users?count=100&filter=email%20eq%20%22afisher@example.com%22&startIndex=1")
        .with(:headers => {'Authorization'=>'Bearer access_token'})
        .to_return(:status => 200, :body => File.read('./spec/fixtures/user/user_by_email.json'), :headers => {})
      user = @client.user_by_email('afisher@example.com')
      expect(user).to be_an Egnyte::User
      expect(user.id).to eq 12408258604
    end

  end

  describe "#User::all" do

    it 'should list all users' do
      stub_request(:get, "https://test.egnyte.com/pubapi/v2/users?count=100&startIndex=1")
          .with(:headers => { 'Authorization' => 'Bearer access_token' })
          .to_return(:body => File.read('./spec/fixtures/user/user_all.json'), :status => 200)
      list = Egnyte::User.all(@session)
      expect(list).to be_an Array
      expect(list.first).to be_an Egnyte::User
      expect(list.size).to eq 50
    end

  end

  describe "#User::where" do

    it 'should find users that match the where filter' do
      stub_request(:get, "https://test.egnyte.com/pubapi/v2/users?count=100&filter=email%20eq%20%22afisher@example.com%22&startIndex=1")
         .with(:headers => {'Authorization'=>'Bearer access_token'})
         .to_return(:status => 200, :body => File.read('./spec/fixtures/user/user_by_email.json'), :headers => {})
      user_list = Egnyte::User.where(@session, {email: 'afisher@example.com'})
      expect(user_list).to be_an Array
      expect(user_list.first).to be_an Egnyte::User
      expect(user_list.first.id).to eq 12408258604
      expect(user_list.size).to eq 1
    end

    it 'should return an empty array if no match is found' do
      stub_request(:get, "https://test.egnyte.com/pubapi/v2/users?filter=email%20eq%20%22FakeEmailThatDoesNotExist%22&startIndex=1&count=100")
         .with(:headers => {'Authorization'=>'Bearer access_token'})
         .to_return(:status => 200, :body => '{"startIndex":1,"totalResults":0,"itemsPerPage":100,"resources":[]}', :headers => {})
      user_list = Egnyte::User.where(@session, {email: 'FakeEmailThatDoesNotExist'})
      expect(user_list).to be_an Array
      expect(user_list.size).to eq 0
    end

  end

  describe "#User::search" do

    before(:each) do
      stub_request(:get, "https://test.egnyte.com/pubapi/v2/users?count=100&startIndex=1")
          .with(:headers => { 'Authorization' => 'Bearer access_token' })
          .to_return(:body => File.read('./spec/fixtures/user/user_all.json'), :status => 200)
    end

    it 'should find users that match the search criteria' do
      user_list = Egnyte::User.search(@session, 'example.com')
      expect(user_list).to be_an Array
      expect(user_list.first).to be_an Egnyte::User
      expect(user_list.size).to eq 50
    end

    it 'should return an empty array if no match is found' do
      user_list = Egnyte::User.search(@session, 'NonexistantSearchCriteria')
      expect(user_list).to be_an Array
      expect(user_list.size).to eq 0
    end

  end

  describe "#User::delete" do

    it 'should delete a user by id if the user exists' do
      stub_request(:delete, "https://test.egnyte.com/pubapi/v2/users/12408258604")
        .with(:headers => {'Authorization'=>'Bearer access_token'})
        .to_return(:status => 200, :body => "", :headers => {})
      expect(Egnyte::User).to receive(:delete).and_return({})
      Egnyte::User.delete(@session, 12408258604)
    end

  end

  describe "#User::links" do

    it 'should find link associated with this user' do
      stub_request(:get, "https://test.egnyte.com/pubapi/v2/users/12408258604")
        .with(:headers => {'Authorization'=>'Bearer access_token'})
        .to_return(:status => 200, :body => File.read('./spec/fixtures/user/user_find.json'), :headers => {})
      stub_request(:get, "https://test.egnyte.com/pubapi/v1/links?username=afisher")
        .with(:headers => {'Authorization'=>'Bearer access_token'})
        .to_return(:status => 200, :body => File.read('./spec/fixtures/link/link_list.json'), :headers => {})
      Egnyte::User.links(@session, 12408258604)
    end

  end

  describe "#User::permissions" do

    it 'should find link associated with this user' do
      stub_request(:get, "https://test.egnyte.com/pubapi/v2/users/12408258604")
        .with(:headers => {'Authorization'=>'Bearer access_token'})
        .to_return(:status => 200, :body => File.read('./spec/fixtures/user/user_find.json'), :headers => {})
      stub_request(:get, "https://test.egnyte.com/pubapi/v1/links?username=afisher")
        .with(:headers => {'Authorization'=>'Bearer access_token'})
        .to_return(:status => 200, :body => File.read('./spec/fixtures/link/link_list.json'), :headers => {})
      Egnyte::User.links(@session, 12408258604)
    end

  end

end
