require 'text_field'

#
# The login screen.
#
class LoginScreen < Screen
	attr_reader :grid

	def initialize(*args)
		super

		@font = Font.new(@window, Gosu::default_font_name, 30)

		@input_field = TextField.new(
			@window, [25,(@window.height/2)-65], @window.width - 50,
			'', Gosu::default_font_name, 40
		)

		@input_field.focus
	end

	def button_down(id)
		@input_field.on_change(id) do |username|
			@window.switch_to :main_menu
			@input_field.deselect
			@window.login_as username
		end
		super # close on escape
	end

	def play
		switch_to :game_grid
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

		@input_field.draw

		@font.draw 'Login:', 25, (@window.height/2)-120, ZOrder::UI
	end
end
