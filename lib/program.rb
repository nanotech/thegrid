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
			end
		end
	end

	# Program attributes are read-only
	traits :length, :moves, :icon
end
