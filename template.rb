require 'fileutils'
# Copied from: https://github.com/mattbrictson/rails-template
# Add this template directory to source_paths so that Thor actions like
# copy_file and template resolve against our source files. If this file was
# invoked remotely via HTTP, that means the files are not present locally.
# In that case, use `git clone` to download them to a local temporary dir.
def add_template_repository_to_source_path
  if __FILE__ =~ %r{\Ahttps?://}
    require 'tmpdir'
    source_paths.unshift(tempdir = Dir.mktmpdir('rails-template-'))
    at_exit { FileUtils.remove_entry(tempdir) }
    git clone: [
      '--quiet',
      'https://github.com/jparr/minifast-rails.git',
      tempdir
    ].map(&:shellescape).join(' ')

    if (branch = __FILE__[%r{minifast-rails/(.+)/template.rb}, 1])
      Dir.chdir(tempdir) { git checkout: branch }
    end
  else
    source_paths.unshift(File.dirname(__FILE__))
  end
end

def rails_version
  @rails_version ||= Gem::Version.new(Rails::VERSION::STRING)
end

def rails_7_or_newer?
  Gem::Requirement.new('>= 7.0.0').satisfied_by? rails_version
end

unless rails_7_or_newer?
  say_error '-----------------------------', :red
  say_error 'Please use Rails 7.0 or newer', :red
  say_error '-----------------------------', :red
  # raise 'hell'
end

add_template_repository_to_source_path

gem_group :development, :test do
  gem 'dotenv-rails'
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'

  gem 'erb_lint', require: false
  gem 'pronto', require: false, group: :pronto
  gem 'pronto-rubocop', require: false, group: :pronto
  gem 'pronto-erb_lint', require: false, group: :pronto
  gem 'rubocop-performance', require: false, group: :pronto
  gem 'rubocop-i18n', require: false, group: :pronto
  gem 'rubocop-rails', require: false, group: :pronto
  gem 'rubocop-rspec', require: false, group: :pronto
  gem 'standard', group: :pronto
end

gem_group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers', '~> 5.0'
  gem 'webdrivers'
end

gem 'view_component', '~> 3.2.0'
gem 'hotwire-livereload'

after_bundle do
  generate 'rspec:install'
  directory 'spec/support'
  copy_file '.erb-lint.yml'
  copy_file '.rubocop.yml'

  run 'bundle binstubs erb_lint'
  run 'bundle binstubs rubocop'
  run 'bundle binstubs rspec-core'

  rails_command 'livereload:install'

  inject_into_file 'config/application.rb', after: 'config.load_defaults 7.0' do
    <<-RUBY
    config.view_component.generate.sidecar = true

    config.generators do |generator|
      generator.helper false
      generator.test_framework :rspec,
        view_specs: false,
        routing_specs: false
    end
    RUBY
  end

  append_to_file '.gitignore' do
    <<-GIT
    .env
    GIT
  end
  copy_file '.env.template'
  copy_file 'config/initializers/dotenv.rb'

  # todo: better readme template

  run 'bin/rubocop -A'

  say 'App successfully created!', :green
end
