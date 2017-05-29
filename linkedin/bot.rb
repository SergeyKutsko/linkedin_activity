require 'capybara'
require 'capybara/dsl'
require 'headless'
require 'selenium-webdriver'

module Linkedin
  class Bot
    include Capybara::DSL

    def initialize
      Capybara.default_driver = :selenium
      Capybara.app = Proc.new{ [200,{},""] }
      @headless = Headless.new
    end

    def start
      @headless.start
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
      if add_contact_link = all('.mn-pymk-list__action-container').sample
        add_contact_link.click
      else
        if is_service_available?
          notify_support
          stop
        else
          visit_people_hub
        end
      end
    end

    def is_service_available?
      available = true
      find('h1', text: /\ALinkedIn is Momentarily Unavailable\z/) rescue available = false
      available
    end

    def notify_support
      Linkedin::Help.new.start
    end

    def stop
      @headless.destroy
      exit(0)
    end

    private

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