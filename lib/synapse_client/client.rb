require 'synapse_client/merchant'
require 'synapse_client/user'

module SynapseClient

  class Client

    attr_reader :merchant
    attr_reader :user
    attr_reader :is_dev

    def initialize(options = {})
      options.to_options!.compact

      @is_dev        = options[:devmode] || Rails.env.development? rescue false
      @merchant      = SynapseClient::Merchant.new(options)
      @user          = SynapseClient::User.new(options)
    end

    def link_account(options = {})
      @user.link_account(options, self)
    end
    def unlink_account(options = {})
      @user.unlink_account(options, self)
    end

    def finish_linking(options = {})
      mfa_answer = SynapseClient::MfaAnswer.new(options)
      mfa_answer.finish_linking(self)
    end

    def submit_order(options = {})
      order = SynapseClient::Order.new(options)
      order.submit(self)
    end

    def get_security_questions
      request  = SynapseClient::Request.new("/api/v2/questions/show/", {}, self)
      response = request.post

      if response.instance_of?(SynapseClient::Error)
        response
      else
        ret = []
        response["questions"].each do |q|
          ret.push SynapseClient::SecurityQuestion.new(q)
        end
        ret
      end
    end

    def put_security_questions(options)
      request  = SynapseClient::Request.new("/api/v2/questions/answers/", options, self)
      response = request.post

      if response.instance_of?(SynapseClient::Error)
        response
      else
        true
      end
    end

    def get_bank_accounts
      @user.get_bank_accounts(self)
    end

  end
end

