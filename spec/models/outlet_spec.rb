# == Schema Information
#
# Table name: outlets
#
#  id           :integer(4)      not null, primary key
#  service_url  :string(255)
#  organization :string(255)
#  info_url     :string(255)
#  account      :string(255)
#  language     :string(255)
#  updated_by   :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  service      :string(255)
#

require 'spec_helper'

describe Outlet do
  
  before(:each) do
    @good_token = AuthToken.create!(
      :email => "valid@example.gov", 
      :phone => "555-1212",
    )
    @attr = { 
      :service_url  => "http://twitter.com/example", 
      :organization => "Example Project",
      :info_url     => "http://example.gov",
      :language     => "English",
      :service      => :twitter,
      :account      => "something",
      :auth_token   => @good_token.token,
    }
  end
  
  it "should create a new instance given valid attributes" do 
    Outlet.create!(@attr)
  end  
  
  it "should record the correct updated_by email" do
    outlet = Outlet.create!(@attr)
    outlet.updated_by.should_not be_nil
  end
  
  describe "new-object validation" do
    it "should require a service URL" do
      no_url_outlet = Outlet.new(@attr.merge(:service_url => ""))
      no_url_outlet.should_not be_valid
    end

    it "should not allow bulk updates of updated_by" do
      forced_outlet = Outlet.new(@attr.merge(:updated_by => "user@example.gov", :auth_token => nil))
      forced_outlet.should_not be_valid
    end

    invalid_url = "blern.foo.com"
  
    it "should require a valid service URL" do
      bad_url_outlet = Outlet.new(@attr.merge(:service_url => invalid_url))
      bad_url_outlet.should_not be_valid
    end

    it "should accept a missing info URL" do
      missing_url_outlet = Outlet.new(@attr.merge(:info_url => ""))
      missing_url_outlet.should be_valid
    end

    it "should require a valid info URL" do
      bad_url_outlet = Outlet.new(@attr.merge(:info_url => invalid_url))
      bad_url_outlet.should_not be_valid
    end
  end
  
  describe "resolve" do

    it "should produce a new instance if not present" do
      new_outlet_url = "http://twitter.com/example2"
      new_outlet = Outlet.resolve(new_outlet_url)
      new_outlet.service_url.should == new_outlet_url
      new_outlet.account.should_not be_nil
      new_outlet.service.should_not be_nil
    end
    
    it "should return an existing instance if present" do
      outlet = Outlet.resolve(@attr[:service_url])
      outlet.auth_token = @attr[:auth_token]
      outlet.save
      resolved_outlet = Outlet.resolve(@attr[:service_url])
      resolved_outlet.should == outlet
    end
    
  end
  
  describe "sponsorships" do
    before(:each) do
      @outlet = Outlet.create!(@attr)
      @agency = Agency.create!(:name => "Department of Departments")
    end
    
    it "should have a sponsorships method" do
      @outlet.should respond_to(:sponsorships)
    end

    it "should set the sponsoring agency" do
      @outlet.sponsorships.create!(:agency_id => @agency)
    end
  end
  
  describe "service" do
    before(:each) do
      @outlet = Outlet.create!(@attr)
    end
    
    it "should have a service method" do
      @outlet.should respond_to(:service)
    end
    
    it "should return the service type" do
      @outlet.service.should_not be_nil
    end
    
    it "should provide service-specific information" do
      @outlet.should respond_to(:service_info)
      @outlet.service_info.account.should_not be_nil
    end
  end
  
  describe "verification" do
    before(:each) do
      @outlet = Outlet.create!(@attr)
    end
    
    it "should have a verified? method" do
      @outlet.should respond_to(:verified?)
    end
  end
end
