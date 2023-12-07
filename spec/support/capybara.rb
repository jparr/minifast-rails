require 'capybara/cuprite'
require 'capybara/rspec'

Capybara.default_driver = :rack_test
Capybara.javascript_driver = :cuprite
Capybara.server = :puma, {Silent: true}

Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(
    app,
    window_size: [1920, 1080],
    headless: false
  )
end

module FakeCapybaraPage
  def page
    Nokogiri::HTML::DocumentFragment.parse(response.body)
  end
end

RSpec.configure do |config|
  config.include FakeCapybaraPage, type: :request
  config.include Capybara::RSpecMatchers, type: :request
  config.include ActionView::RecordIdentifier, type: :request
  config.include Capybara::RSpecMatchers, type: :component
  config.before(:each, type: :system) { driven_by(:rack_test) }
  config.before(:each, js: true, type: :system) { driven_by(:cuprite) }
end
