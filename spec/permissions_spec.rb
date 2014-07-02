#encoding: UTF-8

require 'spec_helper'

describe Egnyte::Permission do
  before(:each) do
    @invalid_permission_hash = {}
    @valid_permission_hash = {
      users: ['david', 'dpfeffer'],
      groups: ['Apples'],
      permission: 'Owner'
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
      expect(@permission).to be_valid
    end

    it 'raises an error if it does not have all required fields' do
      expect(Egnyte::Permission.new(@invalid_permission_hash)).to_not be_valid
    end

  end

  describe "#to_json" do

    it 'should render a valid json representation of a permission object' do
      expect(@permission.to_json).to eq "{\"users\":[\"david\",\"dpfeffer\"],\"groups\":[\"Apples\"],\"permission\":\"Owner\"}"
    end

  end

end
