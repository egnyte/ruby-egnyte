#encoding: UTF-8

require 'spec_helper'
require 'egnyte'

describe Egnyte::Client do
  before(:each) do
  end

  describe "#folder.create" do
    it "should create a new folder object at the specified path" do
      session = Egnyte::Session.new({
        key: 'api_key',
        domain: 'attachmentsme',
        access_token: 'access_token'
      })
      client = Egnyte::Client.new(session)
      client.create_folder('/apple/banana')
    end
  end
end