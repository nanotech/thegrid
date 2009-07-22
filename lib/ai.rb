require 'player'

class AIPlayer < Player
	attr_accessor :programs

	def initialize username
		super username, false
	end
end
