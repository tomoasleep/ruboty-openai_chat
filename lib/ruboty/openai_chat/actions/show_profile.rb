# frozen_string_literal: true

require_relative "base"

module Ruboty
  module OpenAIChat
    module Actions
      class ShowProfile < Base
        def call
          if (profile = memory.namespace(NAMESPACE)[PROFILE_KEY])
            message.reply(profile, code: true)
          else
            message.reply("No profile is set.")
          end
        rescue StandardError => e
          message.reply(e.message, code: true)
          raise e if ENV["OPENAI_CHAT_DEBUG"]

          true
        end
      end
    end
  end
end
