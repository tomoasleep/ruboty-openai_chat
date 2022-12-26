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
          response = complete(human_comment)
          p response if ENV["OPENAI_CHAT_DEBUG"]
          raise response.body if response.code >= 400

          ai_comment = response.dig("choices", 0, "text").gsub(/\A\s+/, "") || ""

          remember_dialog(Dialog.new(human_comment: human_comment, ai_comment: ai_comment, expire_at: expire_at))
          message.reply(ai_comment)
        rescue StandardError => e
          forget
          message.reply(e.message, code: true)
          raise e if ENV["OPENAI_CHAT_DEBUG"]

          true
        end

        private

        def complete(human_comment)
          # https://beta.openai.com/examples/default-chat
          client.completions(
            parameters: {
              model: "text-davinci-003",
              temperature: 0.9,
              max_tokens: 512,
              top_p: 1,
              frequency_penalty: 0,
              presence_penalty: 0.6,
              stop: Dialog::STOP_SEQUENCES,
              prompt: build_prompt(human_comment)
            }
          )
        end

        def build_prompt(human_comment)
          prefix = [prompt_prefix]
          prefix += [pretext].compact

          dialogs = [example_dialog, *dialogs_from_memory,
                     Dialog.new(human_comment: human_comment, ai_comment: "")].map do |dialog|
            dialog.to_prompt.chomp
          end.join("\n")

          <<~STRING.chomp
            #{prefix.join(" ")}

            #{dialogs}
          STRING
        end

        # @return [Array<Dialog>]
        def dialogs_from_memory
          raw_dialogs.reject! { |hash| Dialog.from_hash(hash).expired? }
          raw_dialogs.map { |hash| Dialog.from_hash(hash) }
        end

        # @param dialog [Dialog]
        def remember_dialog(dialog)
          raw_dialogs << dialog.to_h
        end

        # @return [Array<Hash>]
        def raw_dialogs
          memory.namespace(NAMESPACE, message.from || "general")[:dialogs] ||= []
        end

        def forget
          memory.delete(NAMESPACE, message.from || "general")
        end

        # @return [Time]
        def expire_at
          Time.now + ENV.fetch("OPENAI_CHAT_MEMORIZE_SECONDS") { 5 * 60 }.to_i
        end

        # @return [String]
        def prompt_prefix
          "The following is a conversation with an AI assistant. The assistant is helpful, creative, clever, and very friendly. The AI assistant's name is #{robot.name}."
        end

        def example_dialog
          case language
          when :ja
            Dialog.new(
              human_comment: "こんにちは。あなたは誰ですか？",
              ai_comment: "私は OpenAI 製の AI アシスタントの #{robot.name} です。なにかお手伝いできることはありますか？"
            )
          else
            Dialog.new(
              human_comment: "Hello, who are you?",
              ai_comment: "I'm #{robot.name}, an AI assistant created by OpenAI. How can I help you today?"
            )
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
