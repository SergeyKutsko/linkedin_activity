require 'capybara'
require 'capybara/poltergeist'

module Linkedin
  class Bot
    include Capybara::DSL

    def initialize
      Capybara.default_driver = :poltergeist
      Capybara.register_driver :poltergeist do |app|
        Capybara::Poltergeist::Driver.new(app, { phantomjs_options: ['--load-images=no', '--ignore-ssl-errors=yes']})
      end
      Capybara.app = Proc.new{ [200,{},""] }
    end

    def start
      login
      visit_people_hub
      add_connection_loop
    end

    def login
      visit 'https://www.linkedin.com/uas/login'
      fill_in "session_key-login", :with => ENV['EMAIL']
      fill_in "session_password-login", :with => ENV['PASSWORD']
      find('#btn-primary').click
      sleep(5)
    end

    def visit_people_hub
      visit 'https://www.linkedin.com/people/pymk/hub'
    end

    def click_random_connection
      all('.bt-request-buffed.buffed-blue-bkg-1').sample.click
    end

    def add_connection_loop
      counter = 0
      while true
        begin
          click_random_connection
          p counter += 1
          sleep 1
          break if counter > ENV['REQUEST_COUNT'].to_i
        rescue => e
          puts "Error Message: #{e.message}"
          puts 'Retry'
          sleep(10)
          visit_people_hub
          retry
        end
      end
    end
  end
end