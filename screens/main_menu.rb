require 'grid'

#
# The main menu.
#
class MainMenu < Screen
	attr_reader :grid

	include Grid
	require 'grid/menu'

	def initialize(*args)
		super

		@font = Font.new(@window, Gosu::default_font_name, 30)
		@menu = Menu.new(self, @font, :horazontal,
						 Vector(2, 2), Vector(20,20),
						 Vector(400, 80), Vector(20, 20))

		@menu.add 'Play!' => :game_grid
		@menu.add 'Play Online' => :online_index
		@menu.add 'Map Editor' => :map_editor
		@menu.add 'Check for Updates' => :check_for_updates
	end

	def button_down(id)
		super
		@menu.click if id == MsLeft
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

		@menu.draw

		@font.draw "Welcome, #{Player.current}!", 24, @height - 70, ZOrder::UI
	end
end
