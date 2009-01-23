require 'gosu'

class TextField < Gosu::TextInput
	attr_accessor :inactive_color, :active_color, :selection_color,
		:caret_color, :padding, :default_text,
		:x, :y, :width, :height

	def initialize(window, position, width, default_text='', font=Gosu::default_font_name, font_size=20)
		super()
		@window = window

		@font = Gosu::Font.new(@window, font, font_size)

		@x, @y = *position
		@width = width
		@height = @font.height

		@default_text = default_text
		self.text = @default_text

		@inactive_color  = 0x66000000
		@active_color    = 0x99000000
		@selection_color = 0x99000000
		@caret_color     = 0x99ffffff
		@padding = 5
	end

	def button_down(id, &block)
		# Escape key will not be 'eaten' by text fields; use for deselecting.
		if id == KbEscape and @window.text_input then
			deselect
			yield false if block

		elsif id == MsLeft then
			# Mouse click: Select text field based on mouse position.
			if under_point?(@window.mouse_x, @window.mouse_y)
				select

				if @window.text_input.text == @default_text
					@window.text_input.text = ''
				end
			else
				if @window.text_input and @window.text_input.text == ''
					@window.text_input.text = @default_text
				end

				deselect
			end
		elsif id == KbReturn
			if @window.text_input and @map_file != @window.text_input.text
				deselect
				yield true if block
			end
		end
	end

	def select
		@window.text_input = self
	end

	def deselect
		@window.text_input = nil
	end

	def draw
		# Depending on whether this is the currently selected input or not, change the
		# background's color.
		if @window.text_input == self then
			background_color = @active_color
		else
			background_color = @inactive_color
		end
		@window.draw_quad(@x - @padding,          @y - @padding,           background_color,
						  @x + @width + @padding, @y - @padding,           background_color,
						  @x - @padding,          @y + @height + @padding, background_color,
						  @x + @width + @padding, @y + @height + @padding, background_color,
						  ZOrder::UI)

		# Calculate the position of the caret and the selection start.
		pos_x = @x + @font.text_width(self.text[0...self.caret_pos])
		sel_x = @x + @font.text_width(self.text[0...self.selection_start])

		# Draw the selection background, if any; if not, sel_x and pos_x will be
		# the same value, making this quad empty.
		@window.draw_quad(sel_x, @y,          @selection_color,
						  pos_x, @y,          @selection_color,
						  sel_x, @y + @height, @selection_color,
						  pos_x, @y + @height, @selection_color,
						  ZOrder::UI)

		# Draw the caret; again, only if this is the currently selected field.
		if @window.text_input == self then
			@window.draw_line(pos_x, @y,          @caret_color,
							  pos_x, @y + @height, @caret_color,
							  ZOrder::UI)
		end

		# Finally, draw the text itself!
		@font.draw(self.text, @x, @y, ZOrder::UI)
	end

	# Hit-test for selecting a text field with the mouse.
	def under_point?(mouse_x, mouse_y)
		mouse_x > @x - @padding and mouse_x < @x + @width + @padding and
		mouse_y > @y - @padding and mouse_y < @y + @height + @padding
	end

	# Clear the text in the input field.
	def clear
		self.text = ''
	end
end

