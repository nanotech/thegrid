require 'grid'
require 'gameplay'
require 'gooey'

#
# The main game screen.
#
class GameGrid < Screen
	attr_reader :grid

	include Gameplay
	include Gooey

	def initialize(*args)
		super

		@window.login_as 'TestUser' if DEVEL

		@font = Font.new(@window, Gosu::default_font_name, 20)
		@title = Font.new(@window, Gosu::default_font_name, 200)

		@grid = Sector.new @window, Vector(18, 8), Vector(20,20), 60, 6

		@grid.load
		@grid.font = @font

		@programs = []

		Player.current.programs.each_with_index do |p,i|
			p.gridize @grid
			@grid.manage :"program#{i}" => p
			p.chain.zlevel = 100
			p.walkable = false
			@programs << p
		end

		@selected_program = 0

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
				leave
				@window.close
			when KbRight
				direction = Vector(1,0)
			when KbLeft
				direction = Vector(-1,0)
			when KbDown
				direction = Vector(0,1)
			when KbUp
				direction = Vector(0,-1)
			when KbM
				@window.switch_to(:main_menu)
			when KbQ
				@window.switch_to(:main_menu, :cleanup)
			end

			directions = {
				KbUp    => Vector( 0,-1),
				KbDown  => Vector( 0, 1),
				KbLeft  => Vector(-1, 0),
				KbRight => Vector( 1, 0)
			}

			if directions[id] and @grid[:floor][directions[id]+current_program.head]
				current_program.move directions[id]
			end

			find_path
		end
	end

	def current_program
		@programs[@selected_program]
	end

	def find_path
		@grid[:path] = nil
		@grid.create :path, [0x66ff00ff, 0x33ff00ff]
		@pathfinder = Grid::Pathfinder.new(@grid)

		path, closed = @pathfinder.astar(Vector(0,0), current_program.vectors)
		path.each { |v| grid[:path].turn(v, :on) } if path
	end

	def enter
		@paused = true
		@paused = false if DEVEL
		@entered_at = milliseconds
	end

	def leave
		@grid.save([:wall,:floor])
	end

	def update
		if @paused
			if milliseconds - @entered_at > 1000
				@paused = false
			end
		else
			if button_down? MsLeft
				target = @grid.block_under :mouse

				if target
					unless @dragged_over
						head = @programs.find_all { |p| p.head == target }.first

						if head
							current_program.walkable = false
							head.walkable = true
							@selected_program = @programs.index(head)
							find_path
							return # FIXME
						end

						@drag_mode = !@grid[:wall][target]
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

	def draw_hud
		h = 200 # height
		m = 25  # margin

		translate m, @height - h - m do
			rectangle 0, 0, @width - m*2, h, 0xff333333

			translate 15, 10 do
				Player.current.programs.each_with_index do |x,i|
					text @font, x, 0, 25 * i, ZOrder::UI + 1
				end
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

		draw_hud

		@window.draw_line(mouse_x, mouse_y, 0xffffffff,
						  mouse_x + 20, mouse_y + 20, 0xffffffff,
						  ZOrder::UI + 10)

		hovering_over = @grid.block_under(:mouse)

		if hovering_over
			@font.draw("#{hovering_over.x}, #{hovering_over.y}", 10, @height - 30, 0)
		end

		@grid.draw

		target = @grid.block_under :mouse

		if target
			block_pos = @grid.position_of target
			rectangle block_pos.x, block_pos.y,
				      @grid.block_size.x, @grid.block_size.y,
					  0x33ffffff, ZOrder::UI, :additive
		end

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
