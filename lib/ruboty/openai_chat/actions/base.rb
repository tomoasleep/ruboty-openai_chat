# frozen_string_literal: true

module Ruboty
  module OpenAIChat
    module Actions
      # @abstract
      class Base
        NAMESPACE = "openai-chat-actions-chat"
        PROFILE_KEY = "profile"

        attr_reader :message

        # @param message [Ruboty::Message]
        def initialize(message)
          @message = message
        end

        # @return [Ruboty::Robot]
        def robot
          message.robot
        end

        # @return [Memory]
        def memory
          @memory ||= Memory.new(robot)
        end

        # @return [Array<String>]
        def pretexts
          [ENV["OPENAI_CHAT_PRETEXT"], memory.namespace(NAMESPACE)[PROFILE_KEY]].compact
        end
      end
    end
  end
end
