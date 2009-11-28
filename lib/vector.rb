#
# 2D vector class
#
class Vector
	attr_accessor :x, :y

	include Enumerable

	def initialize(x, y)
		@x = x
		@y = y
	end

	def join(other)
		x = yield @x, other.x
		y = yield @y, other.y
		Vector.new(x,y)
	end

	#def +(v); Vector.new(@x + v.x, @y + v.y) end
	def +(v); Vector.new(@x + v.x, @y + v.y) end
	def -(v); Vector.new(@x - v.x, @y - v.y) end
	def *(v); Vector.new(@x * v.x, @y * v.y) end
	def /(v); Vector.new(@x / v.x, @y / v.y) end

	def manhattan(v); (@x - v.x).abs + (@y - v.y).abs end
	def euclidean(v); Math.sqrt((@x - v.x)**2 + (@y - v.y)**2) end
	def diagonal(v); [(@x - v.x).abs, (@y - v.y).abs].max end

	def manhattan_length; @x.abs + @y.abs end

	# Like Float#to_i.
	def cutoff; map { |a| a.to_i } end
	def round; map { |a| a.round } end
	def reverse; Vector.new(@y, @x) end

	def [](index)
		case index
		when 0; @x
		when 1; @y
		end
	end

	# Enumerable stuff
	
	def each
		yield @x
		yield @y
	end

	def map
		Vector.new yield(@x), yield(@y)
	end

	# Comparable operators

	def <=>(other)
		if @x == other.x and @y == other.y
			0
		elsif @x < other.x or @y < other.y
			-1
		elsif @x > other.x or @y > other.y
			1
		end
	end

	def <(v); @x < v.x and @y < v.y end
	def >(v); @x > v.x and @y > v.y end
	def <=(v); @x <= v.x and @y <= v.y end
	def >=(v); @x >= v.x and @y >= v.y end
	def ==(v); compare(v, :==) end

	def eql?(o)
		o.is_a?(Vector) && self == o
	end

	def hash
		h = 2 # elements in vector (x and y)

		# from Ruby's Array#hash
		each do |v|
			h = (h << 1)
			h = (h<0 ? 1 : 0) if h == 0
			h ^= v.hash
		end

		h
	end

	def compare(v, with)
		if v.is_a? Vector
			@x.send(with, v.x) and
			@y.send(with, v.y)
		end
	end

	def inspect; "Vector(#{@x},#{@y})" end
	def to_s; inspect end

	# Converts a Vector to an Array, setting
	# x and y to keys 0 and 1.
	def to_a; [@x, @y] end
	def to_vector; self end

	Zero = self.new(0,0)

	def self.from_vector v
		self.new(v.x, v.y)
	end
end

# Shortcut for Vector.new
def Vector(*args); Vector.new(*args) end

require 'lib/helpers'

# Vector-related helper methods.
class Array
	def to_vector
		Vector.new(self.x, self.y)
	end

	def x; self.at(0) end
	def y; self.at(1) end
	def z; self.at(2) end

	def x=(v); self[0] = v end
	def y=(v); self[1] = v end
	def z=(v); self[2] = v end

	def group_vectors_by_dimension
		dimension = nil

		self.split_by do |a,b|
			if dimension.nil?
				if a.x == b.x
					dimension = :x
				elsif a.y == b.y
					dimension = :y
				end

				false
			else
				if (dimension == :x and a.x != b.x) or (dimension == :y and a.y != b.y)
					dimension = nil
					true
				else
					false
				end
			end
		end
	end
end

class Numeric
	# Convert a number to a vector by setting both
	# x and y to the number.
	def to_vector; Vector(self, self) end
	def x; self end
	def y; self end
end
