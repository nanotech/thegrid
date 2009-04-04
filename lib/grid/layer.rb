module Grid
	class Layer
		attr_reader :grid
		attr_accessor :blocks, :color, :zlevel, :blending, :fill, :helper,
		              :walkable

		include Enumerable

		def initialize(grid, color=nil, fill=false)
			@grid = grid
			@color = color
			@blending = :default
			@zlevel = @grid.layers.size
			@fill = fill
			@helper = nil
			@walkable = true

			@color = @color.expand_gradient if @color

			@color ||= [0x44ffffff, 0x44ffffff, 0x33ffffff, 0x33ffffff]

			@blocks = Array.new(@grid.area.x) do
				Array.new(@grid.area.y) { Block.new(self, @fill) }
			end
		end

		# Enables or disables the display of a block.
		#
		# vect is a Vector, and value can be :on or :off.
		#
		# 	@grid[:layer].turn(Vector(0,0), :on)
		#
		def turn(vect, value)
			@blocks[vect.x] = [] unless @blocks[vect.x]

			case value
			when true, :on
				@blocks[vect.x][vect.y].enabled = true
			when false, :off
				@blocks[vect.x][vect.y].enabled = false
			end
		end

		# Toggles the display of a block.
		def toggle(vect)
			value = !self[vect].enabled
			turn(vect, value)
		end

		# Fills the entire layer with the given value.
		def fill(value)
			self.map! { |block| Block.new(self, value) }
		end

		# Shortcut for @blocks.
		def [](vect)
			@blocks[vect.x][vect.y] if @blocks[vect.x]
		end

		def draw
			pos = @grid.position.dup

			@blocks.each do |column|
				if column
					column.each do |block|

						# Check to see if the helper wants to manually
						# define a color for this block
						if @helper
							new_color = @helper.color(pos/@grid.increment) if @helper.respond_to?(:color)
							new_pos = @helper.position(pos/@grid.increment, pos) if @helper.respond_to?(:position)
						end

						new_color ||= @color
						new_pos ||= pos

						block.draw(new_pos, @grid.block_size, new_color) if block and block.enabled
						pos.y += @grid.increment.y
					end
				end

				pos.x += @grid.increment.x
				pos.y = @grid.position.y
			end
		end

		# Converts the layer to an ascii representation.
		def to_s
			text = ''

			@blocks.transpose.each do |row|
				row.each do |block|
					value = block.enabled ? BOOL_CHARS[1] : BOOL_CHARS[0]
					text << value
				end

				text << "\n"
			end

			text.chomp
		end

		def each
			@blocks.each do |column|
				column.each do |block|
					yield block
				end
			end
		end

		def map
			@blocks.map do |column|
				column.map do |block|
					yield block
				end
			end
		end

		def map!
			@blocks.map! do |column|
				column.map! do |block|
					yield block
				end
			end
		end
	end
end

# Helper methods

class Array
	# Create a 4-node linear gradient from two values.
	def expand_gradient
		if self.size == 2
			*gradient = self[0], self[0], self[1], self[1]
		end
	end
end

class Numeric
	def expand_gradient
		Array.new(4) { self.dup }
	end
end
