require 'gooey/window'
require 'gooey/view'

module Gooey
	def mouse
		$_gooey_x_offset ||= 0
		$_gooey_y_offset ||= 0
		$_gooey_scale_factor ||= 1

		Point.new(($window.mouse_x + $_gooey_x_offset) / $_gooey_scale_factor,
				  ($window.mouse_y + $_gooey_y_offset) / $_gooey_scale_factor)
	end

	def translate x,y
		$_gooey_x_offset ||= 0
		$_gooey_y_offset ||= 0

		ox, oy = $_gooey_x_offset, $_gooey_y_offset
		$_gooey_x_offset += x
		$_gooey_y_offset += y
		val = yield
		$_gooey_x_offset, $_gooey_y_offset = ox, oy
		return val
	end

	def scale factor
		$_gooey_scale_factor ||= 1

		original_factor = $_gooey_scale_factor
		$_gooey_scale_factor *= factor
		val = yield
		$_gooey_scale_factor = original_factor
		return val
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

		x, y = translate_points [x1,x2,x3,x4], [y1,y2,y3,y4]

		$window.draw_quad(
			x[0], y[0], c1,
			x[1], y[1], c2,
			x[2], y[2], c3,
			x[3], y[3], c4,
			*args
		)
	end

	# start, end, start color, end color
	def line *args
		if args[0].is_a? Vector
			a, b, c1, c2, *args = args
			x1 = a.x
			y1 = a.y
			x2 = b.x
			y2 = b.y
		else
			x1, y1, x2, y2, c1, c2, *args = args
		end

		xs, ys = translate_points [x1, x2], [y1, y2]

		$window.draw_line(
			xs[0], ys[0], c1,
			xs[1], ys[1], c2,
			*args
		)
	end

	private

	def translate_points xs, ys
		$_gooey_x_offset ||= 0
		$_gooey_y_offset ||= 0
		$_gooey_scale_factor ||= 1

		xs.map! { |n| n + $_gooey_x_offset }
		ys.map! { |n| n + $_gooey_y_offset }
		return [xs,ys].map { |d| d.map { |n| n * $_gooey_scale_factor } }
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
