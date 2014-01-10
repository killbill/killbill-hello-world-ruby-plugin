require 'spec_helper'

class FakeJavaUserAccountApi
  attr_accessor :accounts

  def initialize
    @accounts = []
  end

  def get_account_by_id(id, context)
    @accounts.find { |account| account.id == id.to_s }
  end
end

describe Killbill::HelloWorld::HelloWorldPlugin do
  before(:each) do
    @plugin = Killbill::HelloWorld::HelloWorldPlugin.new
    @plugin.conf_dir = File.expand_path(File.dirname(__FILE__) + '../../../')

    logger = Logger.new(STDOUT)
    logger.level = Logger::INFO
    @plugin.logger = logger

    @account_api = FakeJavaUserAccountApi.new
    svcs = { :account_user_api => @account_api }
    @plugin.kb_apis = Killbill::Plugin::KillbillApi.new('helloworld', svcs)

    @plugin.start_plugin
  end

  after(:each) do
    @plugin.stop_plugin
  end

  it 'should be able to listen to account events' do
    kb_account_id = create_kb_account

    # Verify the initial state of our table
    Killbill::HelloWorld::User.count.should == 0

    # Send a creation event
    @plugin.on_event OpenStruct.new(:event_type => :ACCOUNT_CREATION, :account_id => kb_account_id)

    # Verify the account exists
    Killbill::HelloWorld::User.count.should == 1

    # Send an update event
    @plugin.on_event OpenStruct.new(:event_type => :ACCOUNT_CHANGE, :account_id => kb_account_id)

    # Verify we didn't create dups
    Killbill::HelloWorld::User.count.should == 1

    # Create a new user
    kb_account_id = create_kb_account
    @plugin.on_event OpenStruct.new(:event_type => :ACCOUNT_CREATION, :account_id => kb_account_id)

    Killbill::HelloWorld::User.count.should == 2
  end

  private

  def create_kb_account
    external_key = Time.now.to_i.to_s + '-test'
    kb_account_id = SecureRandom.uuid
    email = external_key + '@tester.com'

    account = Killbill::Plugin::Model::Account.new
    account.id = kb_account_id
    account.external_key = external_key
    account.email = email
    account.name = 'Integration Spector'

    @account_api.accounts << account

    return kb_account_id
  end
end
