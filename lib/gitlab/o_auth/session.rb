module Gitlab
  module OAuth
    module Session
      def self.create(provider, ticket)
        Rails.cache.write("doggohub:#{provider}:#{ticket}", ticket, expires_in: Gitlab.config.omniauth.cas3.session_duration)
      end

      def self.destroy(provider, ticket)
        Rails.cache.delete("doggohub:#{provider}:#{ticket}")
      end

      def self.valid?(provider, ticket)
        Rails.cache.read("doggohub:#{provider}:#{ticket}").present?
      end
    end
  end
end
