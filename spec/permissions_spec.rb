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
    @valid_permission_structure_from_api = {
        "users" => [
            { "subject" => "david", "permission" => "Owner" },
            { "subject" => "dpfeffer", "permission" => "Editor" }
        ],
        "groups" => [
            { "subject" => "Test Group", "permission" => "Editor" }
        ]
    }
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

    it 'can construct a valid permission listing response from the API' do
      perm = Egnyte::Permission.new(@valid_permission_structure_from_api)
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
