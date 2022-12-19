# frozen_string_literal: true

module Ruboty
  module OpenAIChat
    class Dialog
      STOP_SEQUENCES = [">> Human: ", ">> AI: "].freeze
      STOP_SEQUENCE_PATTERN = />> (Human|AI): /.freeze

      # @return [String]
      attr_reader :human_comment, :ai_comment

      # @return [Time]
      attr_reader :expire_at

      def self.from_hash(hash)
        new(**hash.transform_keys(&:to_sym))
      end

      # @param human_comment [String]
      # @param ai_comment [String]
      # @param expire_at [Time, Integer, nil]
      def initialize(human_comment:, ai_comment:, expire_at: nil)
        @human_comment = human_comment
        @ai_comment = ai_comment
        @expire_at = expire_at&.yield_self { |t| Time.at(t) }
      end

      # @return [String]
      def to_prompt
        <<~STRING
          >> Human: #{escape(human_comment).chomp}
          >> AI: #{escape(ai_comment).chomp}
        STRING
      end

      # @return [Hash]
      def to_h
        { human_comment: human_comment, ai_comment: ai_comment, expire_at: expire_at&.to_i }
      end

      # @return [Boolean]
      def expired?
        expire_at && (expire_at <= Time.now)
      end

      private

      def escape(text)
        text.gsub(STOP_SEQUENCE_PATTERN, &:downcase)
      end
    end
  end
end
