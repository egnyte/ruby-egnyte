#encoding: UTF-8

require 'spec_helper'

describe Egnyte::Client do
  before(:each) do
    @session = Egnyte::Session.new({
      key: 'api_key',
      domain: 'test',
      access_token: 'access_token'
    })
  end
end