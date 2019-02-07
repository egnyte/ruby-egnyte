require 'spec_helper'

describe Egnyte::Group do
  before(:each) do
    @invalid_group_params = {}
    @valid_group_params = {
      :displayName => "Test with members",
      :members => [9967960066, 9967960068]
    }
    @session = Egnyte::Session.new({
      key: 'api_key',
      domain: 'test',
      access_token: 'access_token'
    }, :implicit, 0.0)
    @client = Egnyte::Client.new(@session)
    @group = Egnyte::Group.new(@session, @valid_group_params)
    @group2 = Egnyte::Group.new(@session, "Test without members")
  end

  describe "#initialize" do

    it 'instantiates a valid group if only a name is provided' do
      expect(@group).to be_valid
    end

    it 'instantiates a valid group if a name and group members are provided' do
      expect(@group2).to be_valid
    end

  end

  describe "#create" do

    it "should create a new group if valid" do
      stub_request(:post, "https://test.egnyte.com/pubapi/v2/groups")
        .with(:body => @group.to_json_for_api_call,
              :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'Bearer access_token', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'})
        .to_return(:status => 201, :body => File.read('./spec/fixtures/group/group_create.json'), :headers => {})
      @group = Egnyte::Group.create(@session, @valid_group_params)
      expect(@group.id).to eq "5ef70bb0-edeb-4fcb-86d4-e1e1a0b6c9dc"
    end

    it "should raise an error if it tries to create an invaid group" do
      expect{ Egnyte::Group.create(@session, @invalid_group_params) }.to raise_error(Egnyte::MissingAttribute)
    end

  end

  describe "#save" do

    it 'should raise an error if an attribute is missing' do
      @group.displayName = nil
      expect{ @group.save }.to raise_error(Egnyte::MissingAttribute)
    end

    it 'should save a valid new group object by sending a POST to the Egnyte Group API' do
      stub_request(:post, "https://test.egnyte.com/pubapi/v2/groups")
        .with(:body => @group.to_json_for_api_call,
              :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'Bearer access_token', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'})
        .to_return(:status => 201, :body => File.read('./spec/fixtures/group/group_create.json'), :headers => {})
      @group = @group.save
      expect(@group.id).to eq "5ef70bb0-edeb-4fcb-86d4-e1e1a0b6c9dc"
    end

    it 'should update an existing group object by sending a PUT to the Egnyte Group API' do
      stub_request(:put, "https://test.egnyte.com/pubapi/v2/groups/5ef70bb0-edeb-4fcb-86d4-e1e1a0b6c9dc")
         .with(:body => @group.to_json_for_api_call,
              :headers => {'Authorization'=>'Bearer access_token', 'Content-Type'=>'application/json'})
         .to_return(:status => 200, :body => File.read('./spec/fixtures/group/group_create.json'), :headers => {})
      @valid_group_params[:id] = "5ef70bb0-edeb-4fcb-86d4-e1e1a0b6c9dc"
      @group = Egnyte::Group.new(@session, @valid_group_params)
      @group.save
    end

  end

  describe "#Group::find" do

    it 'should find a group by id if the group exists' do
      stub_request(:get, "https://test.egnyte.com/pubapi/v2/groups/5ef70bb0-edeb-4fcb-86d4-e1e1a0b6c9dc")
        .with(:headers => {'Authorization'=>'Bearer access_token'})
        .to_return(:status => 200, :body => File.read('./spec/fixtures/group/group_create.json'), :headers => {})
      @group = @client.group('5ef70bb0-edeb-4fcb-86d4-e1e1a0b6c9dc')
      expect(@group).to be_an Egnyte::Group
      expect(@group.id).to eq '5ef70bb0-edeb-4fcb-86d4-e1e1a0b6c9dc'
    end

  end

  describe "#Groups::all" do

    it 'should list all users' do
      stub_request(:get, "https://test.egnyte.com/pubapi/v2/groups?count=100&startIndex=1")
          .with(:headers => { 'Authorization' => 'Bearer access_token' })
          .to_return(:body => File.read('./spec/fixtures/group/group_all.json'), :status => 200)
      list = Egnyte::Group.all(@session)
      expect(list).to be_an Array
      expect(list.first).to be_an Egnyte::Group
      expect(list.size).to eq 3
    end

  end

  describe "#Group::where" do

    it 'should find groups that match the where filter' do
      stub_request(:get, "https://test.egnyte.com/pubapi/v2/groups?count=100&filter=displayName%20eq%20%22Finance%22&startIndex=1")
         .with(:headers => {'Authorization'=>'Bearer access_token'})
         .to_return(:status => 200, :body => File.read('./spec/fixtures/group/group_by_parameter.json'), :headers => {})
      group_list = Egnyte::Group.where(@session, {displayName: "Finance"})
      expect(group_list).to be_an Array
      expect(group_list.first).to be_an Egnyte::Group
      expect(group_list.first.id).to eq "d5ea2e76-63e4-4b47-92af-0d7ba6972e3c"
      expect(group_list.size).to eq 1
    end

    it 'should return an empty array if no match is found' do
      stub_request(:get, "https://test.egnyte.com/pubapi/v2/groups?count=100&filter=displayName%20eq%20%22FakeEmailThatDoesNotExist%22&startIndex=1")
         .with(:headers => {'Authorization'=>'Bearer access_token'})
         .to_return(:status => 200, :body => File.read('./spec/fixtures/group/group_by_parameter_empty.json'), :headers => {})
      group_list = Egnyte::Group.where(@session, {displayName: "FakeEmailThatDoesNotExist"})
      expect(group_list).to be_an Array
      expect(group_list.size).to eq 0
    end

  end

  describe "#User::search" do

    before(:each) do
      stub_request(:get, "https://test.egnyte.com/pubapi/v2/groups?count=100&startIndex=1")
          .with(:headers => { 'Authorization' => 'Bearer access_token' })
          .to_return(:body => File.read('./spec/fixtures/group/group_all.json'), :status => 200)
    end

    it 'should find users that match the search criteria' do
      user_list = Egnyte::Group.search(@session, "Fin")
      expect(user_list).to be_an Array
      expect(user_list.first).to be_an Egnyte::Group
      expect(user_list.size).to eq 1
    end

    it 'should return an empty array if no match is found' do
      user_list = Egnyte::Group.search(@session, 'NonexistantSearchCriteria')
      expect(user_list).to be_an Array
      expect(user_list.size).to eq 0
    end

  end

  describe "#Group::delete" do

    it 'should delete a group by id if the group exists' do
      stub_request(:delete, "https://test.egnyte.com/pubapi/v2/groups/5ef70bb0-edeb-4fcb-86d4-e1e1a0b6c9dc")
        .with(:headers => {'Authorization'=>'Bearer access_token'})
        .to_return(:status => 200, :body => "", :headers => {})
      expect(Egnyte::User).to receive(:delete).and_return({})
      Egnyte::User.delete(@session, "5ef70bb0-edeb-4fcb-86d4-e1e1a0b6c9dc")
    end

  end

end
