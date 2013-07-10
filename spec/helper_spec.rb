#encoding: UTF-8

require 'spec_helper'

describe Egnyte::Helper do
  describe "#normalize_path" do
    Egnyte::Helper.normalize_path('/banana').should == 'banana'
    Egnyte::Helper.normalize_path('banana/').should == 'banana'
    Egnyte::Helper.normalize_path('/banana/').should == 'banana'
    Egnyte::Helper.normalize_path('banana').should == 'banana'
    Egnyte::Helper.normalize_path('/ban/ana/').should == 'ban/ana'
  end
end