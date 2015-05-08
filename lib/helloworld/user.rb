module Killbill::HelloWorld
  class User < ActiveRecord::Base
    self.table_name = 'hello_world_users'
  end
end
