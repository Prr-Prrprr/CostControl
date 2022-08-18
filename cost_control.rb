#!/usr/bin/ruby

require 'sqlite3'

class CostControl
	TIME_FRAZE = {
		day: "Put number of day (like '01', '12' etc.)",
		month: "Put number of month (like '01', '12' etc.)",
		year: "Put year (like '2000')"
	}

	TIME_CODES = {
		day: "%d",
		month: "%m",
		year: "%Y"
	}

	def initialize
		@db = SQLite3::Database.open "test.db"
		@db.execute "CREATE TABLE IF NOT EXISTS users(user_name TEXT)"
		@db.execute "CREATE TABLE IF NOT EXISTS costs(category TEXT, price INT, created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP)"
		@db.execute "CREATE TABLE IF NOT EXISTS categories(category_name TEXT)"
		row_counter = (@db.execute ("SELECT COUNT(*) from categories")).first.first
		if row_counter == 0
			@db.execute "INSERT INTO categories VALUES('food'), ('clothes'), ('household goods')"
		end
	end

	

	def leave
		abort "Goodbye."
	end

	def get_answer
		gets.chomp
	end

	def create_user
		puts "Hello! You are new here? Let's log in."
		puts "Say your name or put 'exit' if you don't want to do it."
		
		name_of_user = get_answer
		
		if name_of_user == 'exit'
			leave
		else
			@db.execute "INSERT INTO users VALUES ('#{name_of_user}')"
			puts "You successfully logged in!"
		end
	end

	def log_in
		find_name = ""
		loop do
			puts "Welcome, say your name"
			name_of_user = get_answer
			find_name = (@db.execute("SELECT user_name FROM users WHERE user_name = '#{name_of_user}' LIMIT 1")).first
			break if find_name != nil
		end
		if find_name != nil
			puts 'Hi!'
		end
	end

	def new_record
		loop do
			puts "Choose one category: food, clothes, household goods"
			puts "Put 'exit' to leave"
			your_choose = get_answer
			categories = ['food', 'clothes', 'household goods']
			if categories.include?("#{your_choose}")
				puts "You choosed #{your_choose} category. Now put your costs:"
				users_costs = get_answer
				@db.execute "INSERT INTO costs (category, price) VALUES('#{your_choose}', #{users_costs})"
				result = (@db.execute ("SELECT * FROM costs ORDER BY rowid DESC LIMIT 1")).first
				puts "Your note: '#{result}'"
			end
			break if your_choose == 'exit'
		end
	end

	def show_statistics_by_category
		puts "Choose category: 'food', 'clothes', 'household goods', 'all'"
		choosen_category = get_answer
		if choosen_category == 'all'
			@db.execute("SELECT * FROM costs") do |result|
				puts result.join(' | ')
			end
		else
			@db.execute("SELECT * FROM costs WHERE category = '#{choosen_category}'") do |result|
				puts result.join(' | ')
			end
		end
	end

	def delete
		@db.execute("DELETE FROM costs")
		puts "All records successfully deleted"
	end

	def statistics(piece_of_time)
		puts TIME_FRAZE[piece_of_time]
		num = get_answer
		@db.execute("SELECT * FROM costs WHERE strftime('#{TIME_CODES[piece_of_time]}', created_at) = '#{num}'") do |result|
			puts result.join(' | ')
		end
	end

	def show_statistics_per_ceratain_time
		puts "Choose which statistics you want to see: per day, month or year?"
		choosen_statistic = get_answer
		arr = [:day, :month, :year]
		if arr.include?(choosen_statistic.to_sym)
			statistics(choosen_statistic.to_sym)
		else
			puts "You can choose only day, month or year"
		end
	end

	def process
		puts "If you are a new user, put something to sign up."
		puts "If you are already registered, then put '1' for log in"

		value = get_answer
			
		if value == '1'
			log_in
		else
			create_user
		end

		puts "You can do: "
		puts "Press '1' to add new note about your costs"
		puts "Press '2' to show statistics by category"
		puts "Press '3' to delete all data"
		puts "Press '4' to view statistics per day, months or year"
		puts "Press something to Sign Out"
		answer = get_answer

		if answer == '1'
			new_record
		elsif answer == '2'
			show_statistics_by_category
		elsif answer == '3'
			delete
		elsif answer == '4'
			show_statistics_per_ceratain_time
		else
			leave
		end
	end
end

