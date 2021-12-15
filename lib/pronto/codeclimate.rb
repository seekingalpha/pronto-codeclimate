# frozen_string_literal: true

require 'pronto'
require 'pronto/codeclimate/issue'

module Pronto
  class Codeclimate < Runner
    def run
      return unless File.exist?('.codeclimate.yml')

      codeclimate_config = YAML.load(File.read('.codeclimate.yml'))

      codeclimate_config['exclude_paths'] << '*'

      positive_additions.flat_map do |patch|
        codeclimate_config['exclude_paths'] << "!#{patch.new_file_path}"
      end

      File.open('.codeclimate.yml', 'w') do |f|
        f.puts(codeclimate_config.to_yaml)
      end

      system('codeclimate analyze -f json >> report.json')

      result = JSON.parse(File.read('report.json'))

      messages = []
      positive_additions.each do |patch|
        added_lines = patch.added_lines

        result.each do |issue|
          messages += added_lines.select do |line|
            patch.new_file_path == issue.dig('location', 'path') && line.new_lineno == issue.dig('location', 'positions', 'begin', 'line')
          end.flat_map do |line|
            Issue.new(patch, issue, line).message
          end
        end
      end

      messages
    end

    private

    def positive_additions
      @positive_additions ||= ruby_patches.select { |patch| patch.additions.positive? }
    end
  end
end
