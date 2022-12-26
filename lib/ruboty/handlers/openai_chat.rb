# frozen_string_literal: true

require "ruboty"

module Ruboty
  module Handlers
    class OpenAIChat < Base
      env :OPENAI_ACCESS_TOKEN, "Pass OpenAI ACCESS TOKEN"
      env :OPENAI_ORGANIZATION_ID, "Pass OpenAI Organization ID"
      env :OPENAI_CHAT_PRETEXT, "Pretext of OpenAI prompt", optional: true
      env :OPENAI_CHAT_LANGUAGE, "Pass your primary language", optional: true
      env :OPENAI_CHAT_MEMORIZE_SECONDS, "AI remembers the past dialogs in the specified seconds", optional: true

      on(
        /(?<body>.+)/m,
        description: "OpenAI responds to your message if given message did not match any other handlers",
        missing: true,
        name: "chat"
      )

      on(
        /remember chatbot profile (?<body>.+)/,
        description: "Remembers given sentence as pretext of AI prompt",
        name: "remember_profile"
      )

      on(
        /show chatbot profile/,
        description: "Show the remembered profile",
        name: "show_profile"
      )

      def chat(message)
        Ruboty::OpenAIChat::Actions::Chat.new(message).call
      end

      def remember_profile(message)
        Ruboty::OpenAIChat::Actions::RememberProfile.new(message).call
      end

      def show_profile(message)
        Ruboty::OpenAIChat::Actions::ShowProfile.new(message).call
      end
    end
  end
end
