# frozen_string_literal: true

require "ruboty"
require "ruby/openai"

require_relative "openai_chat/version"
require_relative "openai_chat/actions/base"
require_relative "openai_chat/actions/chat"
require_relative "openai_chat/dialog"
require_relative "openai_chat/memory"

require_relative "handlers/openai_chat"

module Ruboty
  module OpenAIChat
    class Error < StandardError; end
    # Your code goes here...
  end
end
