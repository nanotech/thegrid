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
	end
end
