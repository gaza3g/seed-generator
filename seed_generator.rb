# Author: Gazza | gazaly(at)gmail(dot)com
# Notes:
# Simulate a variety of user-actions for Stacked ( http://code.google.com/p/stacked/ )
# Dependencies:
# $ gem install capybara faker

require 'rubygems'
require 'capybara'
require 'capybara/dsl'
require 'faker'

Capybara.run_server = false
Capybara.current_driver = :selenium
Capybara.app_host = 'http://192.168.1.101/website'
Capybara.default_wait_time = 10

module Test

    class Stacked

    include Capybara::DSL

    def create_users
    	10000.times do
    		begin
			visit '/'
			click_link 'Register'
			fill_in('cntWrp_register_register_username', :with => Faker::Internet.user_name)
			fill_in('cntWrp_register_register_password', :with => 'password')
			fill_in('cntWrp_register_register_repeatPassword', :with => 'password')
			click_button 'Register'
			click_link 'Logout'
		rescue => e
			next
		end
	end
    end

    def create_questions
    	users = retrieve_users
    	100.times do
    		begin
	    		login(users)
		    	visit '/'
		    	click_link 'Ask'
		    	fill_in('cntWrp_ask_wndAsk_header', :with => Faker::Lorem.sentence)
		    	fill_in('cntWrp_ask_wndAsk_body', :with => Faker::Lorem.paragraphs(paragraph_count=3).join(','))
		    	click_button 'Ask'
		    	visit '/'
			    click_link 'Logout'
		rescue => e
			next
		end
	end
    end

    def simulate_upvotes
	users = retrieve_users
	10000.times do
		begin
			questions = retrieve_all_questions
			login(users)
			visit '/'
			3.times do
				question_link = questions[Random.rand(questions.count-1)]
				visit question_link
				begin
					find('.up').click
				rescue => e
					puts e
				end
				visit '/'
			end
			click_link 'Logout'
		rescue => e
			puts e
			click_link 'Logout'
		end
	end
    end

    def simulate_answering_questions
    	users = retrieve_users
    	10000.times do
    		begin
		    	questions = retrieve_all_questions
    			login(users)
    			visit questions[Random.rand(questions.count-1)]
    			begin
    				fill_in('cntWrp_body_answerQuestion_answerBody', :with => Faker::Lorem.sentences(sentence_count=Random.rand(5)).join(','))
    				click_button 'Submit Answer'
    			rescue => e
    				puts e
    			end
    			visit '/'
    			click_link 'Logout'
    		rescue => e
    			puts e
    			begin
	    			click_link 'Logout'
	    		rescue => e
	    			next
	    		end
    		end
    	end
    end

    def simulate_upvoting_answered_questions
    	users = retrieve_users
    	10000.times do
    		begin
		    	questions = retrieve_all_questions
    			login(users)
    			question_link = questions[Random.rand(questions.count-1)]
    			visit question_link
    			begin
    				length = all('a.up').count
    				all('a.up')[Random.rand(length-1)].click
    			rescue => e
    				puts e
    				puts question_link
    			end
    			visit '/'
    			click_link 'Logout'
    		rescue => e
    			puts e
    			begin
	    			click_link 'Logout'
	    		rescue => e
	    			next
	    		end
    		end
    	end
    end

    def login(users)
    	visit '/'
    	click_link 'Login'
    	fill_in('cntWrp_login_login_nativeWrapper_username', :with => users[Random.rand(190)])
    	fill_in('cntWrp_login_login_nativeWrapper_password', :with => 'password')
    	find('#cntWrp_login_login_nativeWrapper_loginBtn').click
    end

    def retrieve_users
        visit '/AllUsers.ashx'
	users = find('pre').text.split(',')
	users.shift
	users.shift
	users
    end

    def retrieve_all_questions
    	visit '/'
	questions = all('.headerLink')[0..6].map { |a| a[:href] }
	questions
    end

  end
end

t = Test::Stacked.new

t.create_users
t.create_questions
t.simulate_upvotes
t.simulate_answering_questions
t.simulate_upvoting_answered_questions