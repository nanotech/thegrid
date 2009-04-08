require 'grid'

module Grid

	# A wrapper for Stack that provides a Grid
	# that acts like a menu.
	#
	class Menu < Stack
		attr_accessor :buttons

		#include Enumerable

		def initialize(screen, font, direction,
					   area, position, button_size, padding)

			@screen = screen
			@window = screen.window
			@direction = direction
			@area = area

			super(@window, area, position, button_size, padding)

			@buttons = []
			@font = font

			@labels = {}
			@actions = {}

			create :buttons
		end

		def add(*buttons)
			buttons.each do |button|
				button = button.to_a[0]
				@buttons.push button

				vect = next_button_pos
				self[:buttons].turn(vect, :on)

				@labels[vect] = button[0]
				@actions[vect] = button[1]
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
				action = @actions[vect]
				@screen.send(action) if action and @screen.respond_to?(action)
			end
		end
	end
end
