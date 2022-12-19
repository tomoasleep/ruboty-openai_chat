# frozen_string_literal: true

module Ruboty
  module OpenAIChat
    module Actions
      # @abstract
      class Base
        attr_reader :message

        # @param message [Ruboty::Message]
        def initialize(message)
          @message = message
        end

        # @return [OpenAI::Client]
        def client
          @client ||= OpenAI::Client.new(access_token: ENV.fetch("OPENAI_ACCESS_TOKEN"),
                                         organization_id: ENV.fetch("OPENAI_ORGANIZATION_ID"))
        end

        # @return [Ruboty::Robot]
        def robot
          message.robot
        end

        # @return [Memory]
        def memory
          @memory ||= Memory.new(robot)
        end
      end
    end
  end
end
