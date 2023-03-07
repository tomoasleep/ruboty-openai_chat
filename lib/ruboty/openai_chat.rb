# frozen_string_literal: true

require "ruboty"
require "openai"

require_relative "openai_chat/version"
require_relative "openai_chat/actions/base"
require_relative "openai_chat/actions/chat"
require_relative "openai_chat/actions/remember_profile"
require_relative "openai_chat/actions/show_profile"
require_relative "openai_chat/memory"
require_relative "openai_chat/message"

require_relative "handlers/openai_chat"

module Ruboty
  module OpenAIChat
    class Error < StandardError; end
    # Your code goes here...

    # @return [Boolean]
    def self.debug_mode?
      ENV["OPENAI_CHAT_DEBUG"]&.length&.positive?
    end
  end
end
