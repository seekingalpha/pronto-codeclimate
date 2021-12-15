# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'pronto/codeclimate/version'
require 'English'

Gem::Specification.new do |s|
  s.name = 'pronto-codeclimate'
  s.version = Pronto::CodeclimateVersion::VERSION
  s.platform = Gem::Platform::RUBY
  s.author = 'Oleksandr Tatarnikov'
  s.summary = 'Pronto runner for Codeclimate CLI'

  s.licenses = ['MIT']
  s.required_ruby_version = '>= 2.3.0'
  s.rubygems_version = '1.8.23'

  s.files = `git ls-files`.split($RS).reject do |file|
    file =~ %r{^(?:
    |Gemfile
    |Rakefile
    |\.gitignore
    )$}x
  end
  s.test_files = []
  s.extra_rdoc_files = ['README.md']
  s.require_paths = ['lib']

  s.add_runtime_dependency('pronto', '~> 0.11.0')
  s.add_development_dependency('rake', '~> 12.0')
end
