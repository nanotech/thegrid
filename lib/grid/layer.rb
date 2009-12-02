require 'gooey'

module Grid
	class Layer < Gooey::View
		attr_reader :grid
		attr_accessor :blocks, :color, :zlevel, :blending, :fill, :helper,
		              :walkable, :block_class

		alias walkable? walkable

		include Enumerable

		def initialize(grid, color=nil, fill=false)
			super(grid.frame)
			@grid = grid
			@color = color
			@blending = :default
			@zlevel = @grid.layers.size
			@fill = fill
			@helper = nil
			@walkable = false
			@block_class = Block

			@color = @color.expand_gradient if @color
			@color ||= [0x44ffffff, 0x44ffffff, 0x33ffffff, 0x33ffffff]

			@blocks = Array.new(@grid.area.x) do
				Array.new(@grid.area.y) { @fill }
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
				@blocks[vect.x][vect.y] = true
			when false, :off
				@blocks[vect.x][vect.y] = false
			end
		end

		# Toggles the display of a block.
		def toggle(vect)
			value = !self[vect]
			turn(vect, value)
		end

		# Fills the entire layer with the given value.
		def fill(value)
			self.map! { value }
		end

		# Shortcut for @blocks.
		def [](vect)
			@blocks[vect.x][vect.y] if @blocks[vect.x]
		end

		def draw
			@blocks.each_with_index do |column, x|
				if column
					column.each_with_index do |block, y|
						vect = Vector[x,y]
						draw_block(vect, vect * @grid.increment) if block
					end
				end
			end
		end

		def draw_block(vect, pixel)
			# Check to see if the helper wants to manually
			# define a color for this block

			@block_class.draw(pixel, @grid.block_size, @zlevel, @color, @blending)
		end

		# Converts the layer into ascii art.
		def to_s
			text = ''

			@blocks.transpose.each do |row|
				row.each do |block|
					value = block ? BOOL_CHARS[1] : BOOL_CHARS[0]
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
