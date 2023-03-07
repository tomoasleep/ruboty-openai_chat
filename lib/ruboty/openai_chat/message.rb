# frozen_string_literal: true

module Ruboty
  module OpenAIChat
    class Message
      ROLES = %i[system user assistant].freeze

      # @return [:system, :user, :assistant]
      attr_reader :role

      # @return [String]
      attr_reader :content

      # @return [Time]
      attr_reader :expire_at

      def self.from_hash(hash)
        new(**hash.transform_keys(&:to_sym))
      end

      # @param role [:system, :user, :assistant]
      # @param content [String]
      # @param expire_at [Time, Integer, nil]
      def initialize(role:, content:, expire_at: nil)
        @role = role.to_sym
        raise ArgumentError, "role must be :system, :user, or :assistant" unless ROLES.include?(@role)

        @content = content
        @expire_at = expire_at&.yield_self { |t| Time.at(t) }
      end

      # @return [Hash]
      def to_h
        { role: role, content: content, expire_at: expire_at&.to_i }
      end

      def to_api_hash
        { role: role, content: content }
      end

      # @return [Boolean]
      def expired?(from = Time.now)
        expire_at && (expire_at <= from)
      end
    end
  end
end
