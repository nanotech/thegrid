require 'grid'

module Grid

	# A wrapper for Stack that provides a Grid
	# that acts like a menu.
	#
	class Menu < Stack
		attr_accessor :buttons
		attr_reader :font

		#include Enumerable

		def initialize(screen, font, direction,
					   area, position, button_size, padding)

			@screen = screen
			@window = screen.window
			@font = font
			@direction = direction
			@area = area

			super(@window, area, position, button_size, padding)

			@buttons = []

			create :buttons
		end

		def add(*buttons)
			buttons.each do |button|
				button = button.to_a[0]
				@buttons.push button

				vect = next_button_pos
				self[:buttons].turn(vect, :on)

				block = self[:buttons][vect]
				block.text = button[0]
				block.data[:action] = button[1]
			end
		end

		def next_button_pos
			case @direction
			when :vertical
				max = @area.y
			when :horazontal
				max = @area.x
			end

			num = @buttons.size - 1
			col = (num / max).to_i
			row = num - (col * max)

			vect = Vector(col, row)
			vect = vect.reverse if @direction == :horazontal
			vect
		end

		def click
			if vect = block_under(:mouse)
				action = self[:buttons][vect].data[:action]
				@screen.send(action) if action and @screen.respond_to?(action)
			end
		end

=begin
		# Called by Layer#draw
		def color(vect)
			if vect == head
				[0xffff9900, 0xffff9900, 0xccff0000, 0xccff0000]
			end
		end

		# Adds a block to the head of the chain.
		def push(vect); add_with(:push, vect) end

		# Adds a block to the tail of the chain.
		def unshift(vect); add_with(:unshift, vect) end

		# Removes a block from the head of the chain.
		def pop; remove_with(:pop) end

		# Removes a block from the tail of the chain
		def shift; remove_with(:shift) end

		def head; @vectors.last end
		def tail; @vectors.first end

		alias last head
		alias first tail

		def head_block; @layer[head] end
		def tail_block; @layer[tail] end

		def each
			@vectors.each do |block|
				yield block
			end
		end
=end
	end
end
