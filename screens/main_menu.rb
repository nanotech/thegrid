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

		@menu.add 'Play!' => :play
	end

	def button_down(id)
		super
		case id
		when MsLeft
			@menu.click
		end
	end

	def play
		@window.switch_to(:game_grid)# { destory! }
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
	end
end
