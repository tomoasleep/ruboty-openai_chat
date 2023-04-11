# frozen_string_literal: true

require "ruboty"
require "openai"
require "tiktoken_ruby"

require_relative "openai_chat/version"
require_relative "openai_chat/actions/base"
require_relative "openai_chat/actions/chat"
require_relative "openai_chat/actions/remember_profile"
require_relative "openai_chat/actions/show_profile"
require_relative "openai_chat/conversation"
require_relative "openai_chat/memory"
require_relative "openai_chat/message"

require_relative "handlers/openai_chat"

module Ruboty
  module OpenAIChat
    class Error < StandardError; end
    # Your code goes here...

    class << self
      # @return [Boolean]
      def debug_mode?
        ENV["OPENAI_CHAT_DEBUG"]&.length&.positive?
      end

      # @return [OpenAI::Client]
      def openai_client
        @openai_client ||= OpenAI::Client.new(
          access_token: ENV.fetch("OPENAI_ACCESS_TOKEN"),
          organization_id: ENV.fetch("OPENAI_ORGANIZATION_ID")
        )
      end

      def chat_model
        "gpt-3.5-turbo"
      end

      # @return [Tiktoken::Encoding]
      def tokenizer
        @tokenizer ||= Tiktoken.encoding_for_model(chat_model)
      end

      def setup
        # Download model for tokenizer
        tokenizer
      end
    end
  end
end
