require 'grid'
require 'gameplay'

#
# The main game screen.
#
class GameGrid < Screen
	attr_reader :grid

	include Gameplay

	def initialize(*args)
		super

		@font = Font.new(@window, Gosu::default_font_name, 20)
		@title = Font.new(@window, Gosu::default_font_name, 200)

		@grid = Sector.new @window, Vector(10, 8), Vector(20,20), 60, 6

		@grid.load
		@grid.font = Font.new(@window, Gosu::default_font_name, 20)

		@sequence = Gameplay::Sequence.new(@grid)

		@grid[:wall].walkable = false

		find_path

		@dragged_over = nil
		@drag_mode = true
		@paused = false
		@entered_at = milliseconds
	end

	def button_down(id)
		unless @paused
			case id 
			when KbEscape
				@grid.save([:wall])
				@window.close
			when KbRight
				@sequence.move Vector(1,0)
			when KbLeft
				@sequence.move Vector(-1,0)
			when KbDown
				@sequence.move Vector(0,1)
			when KbUp
				@sequence.move Vector(0,-1)
			when KbM
				@window.switch_to(:main_menu)
			when KbQ
				@window.switch_to(:main_menu, :cleanup)
			end

			find_path
		end
	end

	def find_path
		@grid[:path] = nil
		@grid.create :path, [0x66ff00ff, 0x33ff00ff]
		@pathfinder = Grid::Pathfinder.new(@grid)

		path, closed = @pathfinder.astar(Vector(0,0), @sequence.head)#Vector(9, 7))

		path.each { |v| grid[:path].turn(v, :on) } if path
	end

	def enter
		@paused = true
		@entered_at = milliseconds
	end

	def leave
		@grid.save([:wall])
	end

	def update
		if @paused
			if milliseconds - @entered_at > 1000
				@paused = false
			end
		else
			if button_down? MsLeft
				target = @grid.block_under(:mouse)

				if target
					unless @dragged_over
						@drag_mode = !@grid[:wall][target].enabled
					end

					if target != @dragged_over
						@dragged_over = target
						@grid[:wall].turn(target, @drag_mode) if target
						find_path
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

		hovering_over = @grid.block_under(:mouse)

		if hovering_over
			@font.draw("#{hovering_over.x}, #{hovering_over.y}", 10, @height - 30, 0)
		end

		@grid.draw

		if @paused
			@window.draw_quad(
				0,      0,       0x66000000, # top left
				@width, 0,       0x66000000, # top right
				0,      @height, 0x66000000, # bottom left
				@width, @height, 0x66000000,  # bottom right 
				1000 # zlevel
			)

			@title.draw_rel('The Grid', @width / 2, @height / 2,
							1001, 0.5, 0.5)
		end
	end
end
