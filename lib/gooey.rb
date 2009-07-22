module Gooey
	def translate x,y
		@_gooey_x_offset ||= 0
		@_gooey_y_offset ||= 0

		ox, oy = @_gooey_x_offset, @_gooey_y_offset
		@_gooey_x_offset += x
		@_gooey_y_offset += y
		yield
		@_gooey_x_offset, @_gooey_y_offset = ox, oy
	end

	def text font, string, x, y, *args
		x += @_gooey_x_offset
		y += @_gooey_y_offset
		font.draw string, x, y, *args
	end

	def rectangle x, y, w, h, c, *args
		quad(
			x,   y,   c,
			x+w, y,   c,
			x+w, y+h, c,
			x,   y+h, c,
			*args
		)
	end

	def quad(x1, y1, c1,
				  x2, y2, c2,
				  x3, y3, c3,
				  x4, y4, c4, *args)

		@_gooey_x_offset ||= 0
		@_gooey_y_offset ||= 0

		x1,x2,x3,x4 = [x1,x2,x3,x4].map { |x| x + @_gooey_x_offset }
		y1,y2,y3,y4 = [y1,y2,y3,y4].map { |y| y + @_gooey_y_offset }

		@window.draw_quad(
			x1, y1, c1,
			x2, y2, c2,
			x3, y3, c3,
			x4, y4, c4,
			*args
		)
	end
end
