require 'grid'
require 'gameplay'
require 'gooey'

#
# The map editor
#
class MapEditor < Screen
	attr_reader :grid

	include Gameplay
	include Gooey

	def initialize(*args)
		super

		@font = Font.new(@window, Gosu::default_font_name, 20)
		@grid = Sector.new @window, Vector(18, 8), Vector(20,20), 60, 6

		@grid.load_from_disk
		@grid.font = @font

		@dragged_over = nil
		@drag_mode = true
		@paused = false
		@entered_at = milliseconds
	end

	def button_down(id)
		unless @paused
			case id
			when KbEscape
				leave
				@window.close
			when KbM
				@window.switch_to(:main_menu)
			when KbQ
				@window.switch_to(:main_menu, :cleanup)
			end
		end
	end

	def leave
		@grid.save([:floor])
	end

	def update
		if @paused
			if milliseconds - @entered_at > 1000
				@paused = false
			end
		else
			if button_down? MsLeft
				target = @grid.block_under mouse

				if target
					unless @dragged_over
						@drag_mode = !@grid[:floor][target]
					end

					if target != @dragged_over
						@dragged_over = target
						@grid[:floor].turn(target, @drag_mode) if target
					end
				end
			elsif !button_down? MsLeft and @dragged_over
				@dragged_over = nil
			end
		end
	end

	def draw
		@window.draw_quad(
			0,      @height - 500, 0xff000000, # top left
			@width, @height - 500, 0xff000000, # top right
			0,      @height,       0xff222222, # bottom left
			@width, @height,       0xff222222  # bottom right
		)

		@window.draw_line(mouse_x, mouse_y, 0xffffffff,
						  mouse_x + 20, mouse_y + 20, 0xffffffff,
						  ZOrder::UI + 10)

		hovering_over = @grid.block_under mouse

		if hovering_over
			@font.draw("#{hovering_over.x}, #{hovering_over.y}", 10, @height - 30, 0)
		end

		@grid.draw

		target = @grid.block_under mouse

		if target
			block_pos = @grid.position_of target
			rectangle block_pos.x, block_pos.y,
				      @grid.block_size.x, @grid.block_size.y,
					  0x33ffffff, ZOrder::UI, :additive
		end
	end
end
