ENV["RAILS_ENV"] ||= 'test'

RSpec.configure do |config|
  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end


  # required to test formbuilder outside of rails... sigh...
  require 'active_support/concern'
  require 'action_view/helpers/capture_helper'
  require 'action_view/helpers/url_helper'
  require 'action_view/helpers/sanitize_helper'
  require 'action_view/helpers/text_helper'
  require 'action_view/helpers/tag_helper'
  require 'action_view/helpers/form_helper'
  require 'action_view/helpers/form_options_helper'
  require 'action_view/buffers'

  # required to pull in mock objects
  require 'rspec/rails/mocks'

  # rspec matchers for capybara
  require 'capybara/rspec'

  # actually include the lib
  require 'bootstrap_form_builder'
end