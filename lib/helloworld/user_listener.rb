module Killbill::HelloWorld
  class UserListener
    def initialize(kb_apis, logger)
      @kb_apis = kb_apis
      @logger = logger
    end

    def update(account_id)
      user = User.where(:kb_account_id => account_id).first_or_create!

      # Find the Kill Bill account associated with that account id
      kb_account = @kb_apis.account_user_api.get_account_by_id(account_id, @kb_apis.create_context)

      @logger.info "Successfully saved #{kb_account.name} (#{kb_account.email})"
    end
  end
end
