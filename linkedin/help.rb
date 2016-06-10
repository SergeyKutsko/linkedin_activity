require 'capybara'
require 'capybara/dsl'
require 'headless'
require 'selenium-webdriver'


module Linkedin
  class Help
    include Capybara::DSL

     def initialize
      Capybara.default_driver = :selenium
      Capybara.app = Proc.new{ [200,{},""] }
      @headless = Headless.new
      @headless.start
    end

    def login
      visit 'https://www.linkedin.com/uas/login'
      fill_in "session_key-login", with: ENV['EMAIL']
      fill_in "session_password-login", with: ENV['PASSWORD']
      find('#btn-primary').click
    end

    def start
      visit_ask_page
      fill_up_form
      send_message
    end

    def visit_ask_page
      visit 'https://www.linkedin.com/help/linkedin/ask'
    end

    def send_message
      click_button 'Submit'
      save_and_open_page
      stop
    end

    def stop
      @headless.destroy
      exit(0)
    end

    def fill_up_form
      fill_in 'dyna-firstName', with: "Sergey"
      fill_in 'dyna-lastName', with: "Kutsko"
      fill_in 'dyna-email', with: ENV['EMAIL']

      within '#dyna-c\\$customer_classification' do
        find("option[value='743']", visible: false).click
      end

      within '#dyna-c\\$app' do
        find("option[value='1599']", visible: false).click
      end

      within '#dyna-c\\$platform' do
        find("option[value='1379']", visible: false).click
      end

      fill_in 'dyna-subject', with: "Can't access my profile."
      fill_in 'dyna-description', with: "Why i can't access my profile. Could you help me?"
    end

  end
end