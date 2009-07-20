class Player
	attr_reader :name, :points, :programs

	@players = {}
	@current = nil

	class << self
		attr_reader :players, :current
	end

	def initialize username, password=false
		@username = username
		@password = password
	end

	def self.login username, password=false
		user_sym = username.to_sym

		unless @players[user_sym]
			@players[user_sym] = Player.new username, password
		end

		@current = @players[user_sym]
	end

	def to_s
		@username
	end
end
