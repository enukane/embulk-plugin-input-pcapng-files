Gem::Specification.new { |gem|
  gem.name              = 'embulk-plugin-input-pcapng-files'
  gem.version           = '0.0.1'

  gem.summary           = gem.description = %q{embulk plugin for pcapng file input}
  gem.authors           = 'Naoya Kaneko'
  gem.email             = 'enukane@glenda9.org'
  gem.license           = 'Apache 2.0'
  gem.homepage          = 'https://github.com/enukane/embulk-plugin-input-pcapng-files'

  gem.files             = Dir.glob('lib/**/*') + ['README.md']
  gem.test_files        = gem.files.grep(/^test/)
  gem.require_paths     = ['lib']
  gem.has_rdoc          = false

  gem.add_development_dependency 'bundler', ['~> 1.0']
  gem.add_development_dependency 'rake', ['>= 0.9.2']
}
