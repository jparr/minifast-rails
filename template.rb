def rails_version
  @rails_version ||= Gem::Version.new(Rails::VERSION::STRING)
end

def rails_7_or_newer?
  Gem::Requirement.new(">= 7.0.0").satisfied_by? rails_version
end

def add_gems

end

unless rails_7_or_newer?
  say_error "-----------------------------", :red
  say_error "Please use Rails 7.0 or newer", :red
  say_error "-----------------------------", :red
  # raise 'hell'
end

add_gems

after_bundle do
  say "App successfully created!", :green
end
