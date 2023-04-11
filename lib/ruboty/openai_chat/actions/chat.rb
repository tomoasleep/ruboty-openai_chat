# frozen_string_literal: true

require_relative "base"

module Ruboty
  module OpenAIChat
    module Actions
      class Chat < Base
        MAX_TOKENS = 4096
        TOKENS_FOR_REPLY = 512

        # @return [String]
        attr_reader :human_comment, :ai_comment

        def call
          human_comment = message[:body]
          human_message = Message.new(role: :user, content: human_comment, expire_at: expire_at)

          conversation = memorized_conversation.limit_tokens(MAX_TOKENS - TOKENS_FOR_REPLY - human_message.token_length).append(human_message)
          p conversation if Ruboty::OpenAIChat.debug_mode?
          ai_message = complete_ai_message(conversation)
          remember_conversation(conversation.append(ai_message))

          message.reply(ai_message.content)
        rescue StandardError => e
          message.reply(e.message, code: true)
          raise e if Ruboty::OpenAIChat.debug_mode?

          true
        end

        private

        def complete_ai_message(conversation)
          response = Ruboty::OpenAIChat.openai_client.chat(
            parameters: {
              model: Ruboty::OpenAIChat.chat_model,
              messages: conversation.to_api_messages,
              temperature: 0.7
            }
          )

          p response if Ruboty::OpenAIChat.debug_mode?
          raise response.body if response.code >= 400

          ai_comment = response.dig("choices", 0, "message", "content").gsub(/\A\s+/, "") || ""
          Message.new(role: :assistant, content: ai_comment, expire_at: expire_at, token_length: response.dig("usage", "completion_tokens")&.to_i)
        end

        # @return [Conversation]
        def memorized_conversation
          Conversation.load_from_memory(
            memory.namespace(NAMESPACE, message.from || "general")[:messages] ||= [],
            system_messages: system_messages
          )
        end

        # @param messages [Array<Hash>]
        def remember_conversation(conversation)
          memory.namespace(NAMESPACE, message.from || "general")[:messages] = conversation.to_raw_messages
        end

        def forget
          memory.delete(NAMESPACE, message.from || "general")
        end

        # @return [Time]
        def expire_at
          @expire_at ||= Time.now + ENV.fetch("OPENAI_CHAT_MEMORIZE_SECONDS") { 60 * 60 }.to_i
        end

        private

        # @return [Array<SystemMessages>]
        def system_messages
          settings = <<~STRING.chomp
            The following is a conversation with an AI assistant. The assistant is helpful, creative, clever, and very friendly, and the assistant's name is #{robot.name}.
          STRING

          system_messages = [Message.new(role: :system, content: settings)]
          pretexts.each do |pretext|
            system_messages << Message.new(role: :system, content: pretext.chomp)
          end

          system_messages
        end
      end
    end
  end
end
