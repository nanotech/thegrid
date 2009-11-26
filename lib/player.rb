require 'program'
require 'programs/cookie' if DEVEL

class Player
	attr_reader :username, :points, :programs

	@players = {}
	@current = nil

	class << self
		attr_reader :players, :current
	end

	def initialize username, password=false
		@username = username
		@password = password
		@programs = []
		4.times { @programs << Programs::Cookie.new } if DEVEL
	end

	def self.login username, password=false
		user_sym = username.to_sym

		unless @players[user_sym]
			@players[user_sym] = Player.new username, password
		end

		@current = @players[user_sym]
	end

	def end_turn
		@programs.each { |p| p.reset_moves }
	end

	def to_s
		@username
	end
end
