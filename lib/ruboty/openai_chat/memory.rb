# frozen_string_literal: true

module Ruboty
  module OpenAIChat
    class Memory
      # @return [Ruboty::Robot]
      attr_reader :robot

      # @param robot [Ruboty::Robot]
      def initialize(robot)
        @robot = robot
      end

      # @param keys [Array<String, Symbol>]
      # @return [Hash]
      def namespace(*keys)
        keys.reduce(robot.brain.data) do |data, key|
          data[key] ||= {}
        end
      end

      # @param prefix [Array<String, Symbol>]
      # @param key [String, Symbol]
      def delete(*prefix, key)
        dig(*prefix)&.delete(key)
      end

      # @param keys [Array<String, Symbol>]
      # @return [Object, nil]
      def dig(*keys)
        prefix.empty? ? robot.brain.data : robot.brain.data.dig(*prefix)
      end
    end
  end
end
