configure do
  # Usage: rackup -Ilib -E test
  if (development? or test?) and !Killbill::HelloWorld::Initializer.instance.initialized?
    require 'logger'
    Killbill::HelloWorld::Initializer.instance.initialize! File.expand_path(File.dirname(__FILE__) + '../../../../'),
                                                           nil,
                                                           Logger.new(STDOUT)
  end
end

after do
  # return DB connections to the Pool if required
  ActiveRecord::Base.connection.close
end

# curl -v http://127.0.0.1:9292/plugins/killbill-helloworld/users/6939c8c0-cf89-11e2-8b8b-0800200c9a66
# Given a Kill Bill account id, retrieve the Kill Bill - HelloWorld mapping
get '/plugins/killbill-helloworld/users/:id', :provides => 'json' do
  mapping = Killbill::HelloWorld::User.find_by_kb_account_id(params[:id])

  if mapping
    mapping.to_json
  else
    status 404
  end
end
