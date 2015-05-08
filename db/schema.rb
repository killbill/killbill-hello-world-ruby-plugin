require 'active_record'

ActiveRecord::Schema.define(:version => 20130606153635) do
  create_table 'hello_world_users', :force => true do |t|
    t.string 'kb_account_id', :null => false
    t.datetime 'created_at', :null => false
    t.datetime 'updated_at', :null => false
  end

  add_index(:hello_world_users, :kb_account_id, :unique => true)
end
