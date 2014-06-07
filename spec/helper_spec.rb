#encoding: UTF-8

require 'spec_helper'

describe Egnyte::Helper do
  describe "#normalize_path" do
  	it 'should remove leading and trailing slashes' do
	    expect(Egnyte::Helper.normalize_path('/banana')).to eq('banana')
	    expect(Egnyte::Helper.normalize_path('banana/')).to eq('banana')
	    expect(Egnyte::Helper.normalize_path('/banana/')).to eq('banana')
	    expect(Egnyte::Helper.normalize_path('banana')).to eq('banana')
	    expect(Egnyte::Helper.normalize_path('/ban/ana/')).to eq('ban/ana')
	end
  end
end
