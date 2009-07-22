module Gooey
	def translate x,y
		$_gooey_x_offset ||= 0
		$_gooey_y_offset ||= 0

		ox, oy = $_gooey_x_offset, $_gooey_y_offset
		$_gooey_x_offset += x
		$_gooey_y_offset += y
		yield
		$_gooey_x_offset, $_gooey_y_offset = ox, oy
	end

	def scale factor
		$_gooey_scale_factor ||= 1

		original_factor = $_gooey_scale_factor
		$_gooey_scale_factor *= factor
		yield
		$_gooey_scale_factor = original_factor
	end

	def text font, string, x, y, *args
		x = (x + $_gooey_x_offset) * $_gooey_scale_factor
		y = (y + $_gooey_y_offset) * $_gooey_scale_factor
		font.draw string, x, y, *args
	end

	#def rectangle x, y, w, h, c, *args
	def rectangle *args
		if args[0].is_a? Vector
			v, s, c, *args = args
			x = v.x
			y = v.y
			w = s.x
			h = s.y
		else
			x, y, w, h, c, *args = args
		end

		c1, c2, c3, c4 = c.expand_gradient

		quad(
			x,   y,   c1,
			x+w, y,   c2,
			x+w, y+h, c3,
			x,   y+h, c4,
			*args
		)
	end

	def quad(x1, y1, c1,
			 x2, y2, c2,
			 x3, y3, c3,
			 x4, y4, c4, *args)

		$_gooey_x_offset ||= 0
		$_gooey_y_offset ||= 0
		$_gooey_scale_factor ||= 1

		x = [x1,x2,x3,x4]
		y = [y1,y2,y3,y4]
		x.map! { |n| n + $_gooey_x_offset }
		y.map! { |n| n + $_gooey_y_offset }
		x, y = [x,y].map { |d| d.map { |n| n * $_gooey_scale_factor } }

		@window.draw_quad(
			x[0], y[0], c1,
			x[1], y[1], c2,
			x[2], y[2], c3,
			x[3], y[3], c4,
			*args
		)
	end
end

# Helper methods

class Array
	# Create a 4-node linear gradient from two values.
	def expand_gradient
		if self.size == 2
			*gradient = self[0], self[0], self[1], self[1]
		else
			self
		end
	end
end

class Numeric
	def expand_gradient
		Array.new(4) { self }
	end
end
