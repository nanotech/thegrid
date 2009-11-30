require 'grid'
require 'forwardable'

module Programs; end

class Program

	attr_reader :chain, :position

	def place_on_grid_at_position grid, position
		# head_image = Image.new($window, 'icon.png', false)
		@chain = nil unless @chain and grid == @chain.grid
		@layer_name = :"program#{grid.layers.length}"
		prepare_for_grid(grid, position) unless @chain
		grid.manage @layer_name => self
		return self
	end

	def move(vect, &callback)
		distance = vect.manhattan_length
		if @moved + distance <= @moves
			@moved += distance
			return @chain.move(vect, &callback)
		else
			return false
		end
	end

	def active?; !@chain.nil?; end

	def deactivate
		reset_moves
		@chain.grid.unmanage @layer_name
		@chain = nil
		@layer_name = nil
	end

	def reset_moves
		@moved = 0
	end

	def to_s
		self.class.name
	end

	private

	# Metaprogramming stuff originally from:
	# why's (poignant) guide to ruby, chapter 6

	# Get a metaclass for this class
	def self.metaclass; class << self; self; end; end

	# Advanced metaprogramming code for nice, clean traits
	def self.traits *arr
		return @traits if arr.empty?

		# 1. Set up accessors for each variable
		attr_accessor *arr

		# 2. Add a new class method to for each trait.
		arr.each do |a|
			metaclass.instance_eval do
				define_method(a) do |val|
					@traits ||= {}
					@traits[a] = val
				end
			end
		end

		# 3. For each program, the `initialize' method
		#    should use the default number for each trait.
		class_eval do
			define_method :initialize do
				self.class.traits.each do |k,v|
					instance_variable_set("@#{k}", v)
				end

				reset_moves
			end
		end
	end

	# Program attributes are read-only
	traits :length, :moves, :moved, :icon

	private

	def prepare_for_grid grid, position
		@chain = Grid::Chain.new(grid, position, @length, :animated,
								 [0xcc00ff00, 0x99009900],
								 [0xffcc9900, 0xff990000]) #, head_image)

		method_syms = @chain.methods - self.methods
		method_syms.map! { |s| s.to_sym }

		extend SingleForwardable
		def_delegators :@chain, *method_syms
		return self
	end
end
