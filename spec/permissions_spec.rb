#encoding: UTF-8

require 'spec_helper'

describe Egnyte::Permission do
  before(:each) do
    @valid_permission_hash = {
        "users" => {
            "david" => "Owner",
            "dpfeffer" => "Editor"
        },
        "groups" => { "Test Group" => "Editor" }
    }
    @invalid_permission_hash = {
        "blah" => {
          "david" => "Owner",
          "dpfeffer" => "Editor"
        }
    }
    @lowercase_permission_hash = {
        "users" => {
            "david" => "owner",
            "dpfeffer" => "editor"
        },
        "groups" => { "Test Group" => "editor" }
    }
    @crazy_permission_hash = {
        "users" => {
            "david" => "crazy",
            "dpfeffer" => "Viewer"
        },
        "groups" => { "Test Group" => "perms" }
    }
    @valid_permission_structure_from_api = JSON.parse(File.read('./spec/fixtures/permission/permission_list.json'))
    @session = Egnyte::Session.new({
      key: 'api_key',
      domain: 'test',
      access_token: 'access_token'
    }, :implicit, 0.0)
    @client = Egnyte::Client.new(@session)
    @permission = Egnyte::Permission.new(@valid_permission_hash)
  end

  describe "#initialize" do

    it 'instantiates a valid permission set if it has all required fields' do
      expect(@permission.valid?).to be true
      expect(@permission.has_data?).to be true
    end

    it 'raises an error if it does not have valid fields' do
      expect {Egnyte::Permission.new(@invalid_permission_hash)}.to raise_error( Egnyte::InvalidParameters )
    end

    it 'drops invalid permission levels' do
      @permission = Egnyte::Permission.new(@crazy_permission_hash)
      expect(@permission.data["users"]["dpfeffer"]).to eq "Viewer"
      expect(@permission.data["users"]["david"]).to be nil
    end

    it 'capitalizes the first letter of permission levels' do
      @permission = Egnyte::Permission.new(@lowercase_permission_hash)
      expect(@permission.data["users"]["david"]).to eq "Owner"
    end

    it 'can construct a valid permission listing response from the API' do
      perm = Egnyte::Permission.build_from_api_listing(@valid_permission_structure_from_api)
      expect(perm.valid?).to be true
      expect(perm.has_data?).to be true
    end

  end

  describe "#to_json" do

    it 'should render a valid json representation of a permission object' do
      expect(@permission.to_json).to eq "{\"users\":{\"david\":\"Owner\",\"dpfeffer\":\"Editor\"},\"groups\":{\"Test Group\":\"Editor\"}}"
    end

  end

  describe "#merge" do

    it 'should be able to merge two permission objects' do
      @permission.merge!({
          "users" => {
              "jsmith" => "Owner" ,
              "jdoe" => "Editor"
          }
      })
    end

  end

end
