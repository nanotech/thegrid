require 'grid'
require 'gameplay'
require 'gooey'
require 'ai'
require 'views/glow_block'

#
# The main game screen.
#
class GameGrid < Screen
	attr_reader :grid

	include Gameplay
	include Gosu
	include Gooey

	def initialize(*args)
		super

		@window.login_as 'TestUser' if DEVEL

		@font = Font.new(@window, Gosu::default_font_name, 20)
		@title = Font.new(@window, Gosu::default_font_name, 200)

		@grid = Sector.new @window, Vector(18, 8), Vector(20,20), 60, 6

		@grid.load_from_disk
		@grid.font = @font

		add_subview @grid

		@ai = AIPlayer.new 'Sparky'
		@ai.programs = [Programs::Cookie.new]

		@player = Player.current

		@grid.create :upload_nodes, [0xccffffff, 0xffffffff]
		@grid[:upload_nodes].zlevel = 10
		@grid[:upload_nodes].walkable = true
		@grid[:upload_nodes].block_class = GlowBlock
		Array.new(@player.programs.length) { @grid[:upload_nodes].turn Vector.rand(@grid.area), :on }

		activate_programs @ai.programs

		@dragged_over = nil
		@drag_mode = true
		@paused = false
		@entered_at = milliseconds
		@zoom = 1
	end

	def activate_program program, position
		program.place_on_grid_at_position @grid, position
		program.chain.zlevel = 100
		program.walkable = false
		program
	end

	def activate_programs(programs)
		programs.map { |p| activate_program p, Vector.rand(@grid.area) }
	end

	def end_turn
		@player.end_turn
		find_path
		update_movement_layer
	end

	def update_movement_layer
		@grid[:movement] = nil
		@grid.create :movement, [0x1affffff, 0x2affffff]
		@grid[:movement].walkable = true
		program = selected_program

		raise RuntimeError.new('The selected program must be walkable!') unless program.walkable?

		pathfinder = Grid::Pathfinder.new(@grid)
		path, closed = pathfinder.dijkstra(program.head, nil, {}, program.moves - program.moved)

		if closed
			closed = closed.keys.map { |a| a.to_vector }
			closed.each { |v| grid[:movement].turn(v, :on) } if path
		end
	end

	def selected_program
		@player.programs[@selected_program] if @selected_program
	end

	def selected_program=(program)
		index = @player.programs.index(program)
		raise ArgumentError.new("program must be an active program") unless index

		selected_program.walkable = false if @selected_program
		program.walkable = true
		@selected_program = index
		@selected_vect = program.head
		update_movement_layer
	end

	def select_next_program
		self.selected_program = @player.programs[(@selected_program + 1) % @player.programs.length]
	end

	def button_down(id)
		unless @paused
			case id
			when KbEscape
				leave
				@window.close
			when KbEnter, KbReturn
				end_turn
			when KbN
				select_next_program
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
			when 24 # =
				@zoom += 0.05
			when 27 # -
				@zoom -= 0.05
			end

			directions = {
				KbUp    => Vector( 0,-1),
				KbDown  => Vector( 0, 1),
				KbLeft  => Vector(-1, 0),
				KbRight => Vector( 1, 0)
			}

			direction = directions[id]

			if direction and selected_program
				new_vector = direction + selected_program.head

				if @grid[:floor][new_vector] and @grid.is_vector_walkable?(new_vector)
					if selected_program.move(direction)
						update_movement_layer
					else
						#select_next_program
					end
				end
			end
		end
	end

	def move_ai(program, path)
		path.each { |n| program.move(n - program.head) }
	end

	def find_path
		@grid[:path] = nil
		@grid.create :path, [0x66ff00ff, 0x33ff00ff]
		@grid[:path].walkable = true

		ai_program = @ai.programs[0]
		ai_program.walkable = true

		maybe_paths = @player.programs.map do |program|
			# FIXME: have the pathfinder try to get as close as possible
			#        to the target, even if it'll never get there.
			was_walkable = program.walkable?
			program.walkable = true
			pathfinder = Grid::Pathfinder.new(@grid)
			maybe_path, closed = pathfinder.astar(ai_program.head, program.vectors)
			program.walkable = was_walkable
			maybe_path
		end

		path = maybe_paths.delete_if { |o| o.nil? }.sort_by { |p| p.length }.first # select the nearest node

		if path
			path = path[0..-2] # don't collide with the target
			path.each { |v| grid[:path].turn(v, :on) }

			if path.length >= 2
				move_ai(ai_program, path)
			end
		end

		ai_program.walkable = false
		@ai.end_turn
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
				target = scale(@zoom) { @grid.grid_vect_from_world_vect mouse }

				if target
					unless @dragged_over
						is_upload_node = @grid[:upload_nodes][target]

						if is_upload_node
							program = @player.inactive_programs.first

							if program
								@grid[:upload_nodes].turn target, :off
								activate_program program, target
							end
						end

						head = @player.active_programs.find { |p| p.head == target }

						if head
							self.selected_program = head
							return # FIXME
						end

						@drag_mode = !@grid[:wall][target]
					end

					if target != @dragged_over
						@dragged_over = target
						@grid[:wall].turn(target, @drag_mode) if target
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

	def draw_contents
		scale @zoom do
			super
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

		target = @grid.grid_vect_from_world_vect mouse

		if target
			@font.draw("#{target.x}, #{target.y}", 10, @height - 30, 0)

			block_pos = @grid.position_of target
			rectangle block_pos, @grid.block_size,
					  0x33ffffff, ZOrder::UI, :additive
		end

		draw_selection_overlay

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

	def draw_selection_overlay
		return unless @selected_vect
		tl = @grid.position_of @selected_vect
		tr = tl + Vector(@grid.block_size.x, 0)
		bl = tl + Vector(0, @grid.block_size.x)
		br = tl + @grid.block_size
		o = Math::sin(milliseconds * 0.01) * 5 - 2
		f = 15 + o
		g = Vector(-f,f)
		e = Vector(-o,o)
		w = 0xffffffff

		line tl - f, tl - o, w, w, ZOrder::UI
		line br + f, br + o, w, w, ZOrder::UI
		line tr - g, tr - e, w, w, ZOrder::UI
		line bl + g, bl + e, w, w, ZOrder::UI
	end
end
