# frozen_string_literal: true

require_relative "base"

module Ruboty
  module OpenAIChat
    module Actions
      class RememberProfile < Base
        def call
          new_profile = message[:body].strip
          memory.namespace(NAMESPACE)[PROFILE_KEY] = new_profile

          message.reply("Remembered the profile.")
        rescue StandardError => e
          message.reply(e.message, code: true)
          raise e if ENV["OPENAI_CHAT_DEBUG"]

          true
        end
      end
    end
  end
end
