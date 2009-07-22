require 'grid'
require 'forwardable'

module Programs; end

class Program

	attr_reader :chain

	def gridize sector
		random_vector = Vector(rand(sector.area.x),rand(sector.area.y))
		# head_image = Image.new(@sector.window, 'icon.png', false)

		@chain = Grid::Chain.new(sector, random_vector, 5, :animated,
								 [0xcc00ff00, 0x99009900],
								 [0xffcc9900, 0xff990000]) #, head_image)

		method_syms = @chain.methods - Object.new.methods
		method_syms.map! { |s| s.to_sym }

		extend SingleForwardable
		def_delegators :@chain, *method_syms
		self
	end

	def to_s
		self.class.name
	end

	private

	def self.length n; @length = n end
	def self.moves n; @moves = n end
end
