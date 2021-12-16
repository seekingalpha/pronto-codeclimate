# frozen_string_literal: true

module Pronto
  class Codeclimate < Runner
    class Issue
      REMEDIATION_GRADES = {
        (0..2_000_000) => 'A',
        (2_000_000..4_000_000) => 'B',
        (4_000_000..8_000_000) => 'C',
        (8_000_000..16_000_000) => 'D',
        (16_000_000..) => 'F',
      }.freeze

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
        message_text = "#{@issue['description']}\n\n"

        message_text += "\n```ruby\n#{@issue.dig('content', 'body')}\n```" if @issue.dig('content', 'body')

        message_text +=
          "\n\n" \
          "| #{@issue['engine_name'].capitalize} |                                  |\n"\
          "| ----------------------------------- | -------------------------------- |\n"\
          "| Cop                                 | #{@issue['check_name']}          |\n"\
          "| Complexity                          | [#{remediation_grade}](https://docs.codeclimate.com/docs/code-climate-glossary#section-remediation)             |\n"\
          "| Severity                            | #{@issue['severity'].capitalize} |\n"

        message_text
      end

      def remediation_grade
        REMEDIATION_GRADES.select do |range, grade|
          range.include?(@issue['remediation_points'])
        end.values.first
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
