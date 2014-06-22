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

  describe "#params_to_s" do
  end

  describe "#params_to_filter_string" do
  	it 'should convert a parameters hash to an Egnyte formatted filter string' do
  		expect(Egnyte::Helper.params_to_filter_string({email: 'test@egnyte.com'})).to eq "?filter=email%20eq%20%22test@egnyte.com%22"
  		expect(Egnyte::Helper.params_to_filter_string({authType: 'ad', userType: 'power'})).to eq "?filter=authType%20eq%20%22ad%22&filter=userType%20eq%20%22power%22"
  	end
  end

end
