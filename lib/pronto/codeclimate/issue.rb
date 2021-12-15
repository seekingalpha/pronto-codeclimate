# frozen_string_literal: true

module Pronto
  class Codeclimate < Runner
    class Issue
      LEVEL_MAPPING = {
        'info' => :info,
        'minor' => :warning,
        'major' => :error,
        'critical' => :fatal,
        'blocker' => :fatal,
      }.freeze

      def initialize(patch, issue, line)
        @patch = patch
        @issue = issue
        @line = line
      end

      def message
        Message.new(path, @line, level, text, nil, Pronto::Codeclimate)
      end

      private

      def text
        message_text = @issue['description']

        return message_text unless @issue.dig('content', 'body')

        "#{message_text}\n\n```Suggestion:\n#{@issue.dig('content', 'body')}```"
      end

      def path
        @patch.new_file_path
      end

      def level
        LEVEL_MAPPING[@issue['severity']]
      end
    end
  end
end
