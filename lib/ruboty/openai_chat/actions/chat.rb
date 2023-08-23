# frozen_string_literal: true

require_relative "base"

module Ruboty
  module OpenAIChat
    module Actions
      class Chat < Base
        # @return [String]
        attr_reader :human_comment, :ai_comment

        def call
          human_comment = message[:body]
          response = request_chat(human_comment)
          p response if Ruboty::OpenAIChat.debug_mode?
          raise response.body if response.code >= 400

          ai_comment = response.dig("choices", 0, "message", "content").gsub(/\A\s+/, "") || ""

          remember_messages(
            Message.new(role: :user, content: human_comment, expire_at: expire_at),
            Message.new(role: :assistant, content: ai_comment, expire_at: expire_at)
          )
          message.reply(ai_comment)
        rescue StandardError => e
          forget
          message.reply(e.message, code: true)
          raise e if Ruboty::OpenAIChat.debug_mode?

          true
        end

        private

        def request_chat(human_comment)
          # https://beta.openai.com/examples/default-chat
          client.chat(
            parameters: {
              model: openai_model,
              messages: build_messages(human_comment).map(&:to_api_hash),
              temperature: 0.7
            }
          )
        end

        # @return [Array<Message>]
        def build_messages(human_comment)
          settings = <<~STRING.chomp
            The following is a conversation with an AI assistant. The assistant is helpful, creative, clever, and very friendly. The AI assistant's name is #{robot.name}.
          STRING

          system_messages = [Message.new(role: :system, content: settings)]
          pretexts.each do |pretext|
            system_messages << Message.new(role: :system, content: pretext.chomp)
          end

          pre_messages = [*example_dialog, *messages_from_memory]

          [*system_messages, *pre_messages, Message.new(role: :user, content: human_comment)]
        end

        # @return [Array<Dialog>]
        def messages_from_memory
          current = Time.now
          raw_messages.reject! { |hash| Message.from_hash(hash).expired?(current) }
          raw_messages.map { |hash| Message.from_hash(hash) }
        end

        # @param messages [Array<Message>]
        def remember_messages(*messages)
          messages.each do |message|
            raw_messages << message.to_h
          end
        end

        # @return [Array<Hash>]
        def raw_messages
          memory.namespace(NAMESPACE, message.from || "general")[:messages] ||= []
        end

        def forget
          memory.delete(NAMESPACE, message.from || "general")
        end

        # @return [Time]
        def expire_at
          Time.now + ENV.fetch("OPENAI_CHAT_MEMORIZE_SECONDS") { 15 * 60 }.to_i
        end

        # @return [Array<Message>]
        def example_dialog
          case language
          when :ja
            [
              Message.new(role: :user, content: "こんにちは。あなたは誰ですか？"),
              Message.new(role: :assistant, content: "私は AI アシスタントの #{robot.name} です。なにかお手伝いできることはありますか？")
            ]
          else
            [
              Message.new(role: :user, content: "Hello, who are you?"),
              Message.new(role: :assistant, content: "I'm #{robot.name}, an AI assistant. How can I help you today?")
            ]
          end
        end

        # @return [Symbol]
        def language
          (ENV["OPENAI_CHAT_LANGUAGE"] || :en).to_sym
        end
      end
    end
  end
end
