module Killbill::HelloWorld
  class User < ActiveRecord::Base
    attr_accessible :kb_account_id
  end
end
