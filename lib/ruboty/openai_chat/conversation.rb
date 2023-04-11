# frozen_string_literal: true

module Ruboty
  module OpenAIChat
    class Conversation
      class << self
        # @param raw_messages [Array<Hash>]
        def load_from_memory(raw_messages, system_messages:)
          current = Time.now
          messages = raw_messages.map { |hash| Message.from_hash(hash) }.reject { |message| message.expired?(current) }
          new(system_messages: system_messages, messages: messages)
        end
      end

      # @return [Array<Message>]
      attr_reader :system_messages

      # @return [Array<Message>]
      attr_reader :messages

      # @param model [OpenAI::Client]
      # @param messages [Array<Message>]
      def initialize(system_messages:, messages:)
        @system_messages = system_messages
        @messages = messages
      end

      # @param messages [Array<Message>]
      # @return [Conversation]
      def with(messages:)
        self.class.new(system_messages: system_messages, messages: messages)
      end

      # @param max_tokens [Integer]
      # @return [Conversation]
      def limit_tokens(max_tokens)
        sum = system_messages.sum(&:token_length)
        messages_to_hold = messages.reverse.take_while do |message|
          sum += message.token_length
          sum < max_tokens
        end.reverse

        with(messages: messages_to_hold)
      end

      # @param message [Message]
      # @return [Conversation]
      def append(message)
        with(messages: [*messages, message])
      end

      # @return [Array<Hash>]
      def to_api_messages
        [*system_messages, *messages].map(&:to_api_message)
      end

      # @return [Array<Hash>]
      def to_raw_messages
        messages.map(&:to_h)
      end
    end
  end
end
