require 'vector'

module Gooey
	class Point < Vector; end
	class Size < Vector
		attr_accessor :width, :height
		alias width x
		alias height y
		alias width= x=
		alias height= y=
	end

	class Rect
		attr_accessor :origin, :size

		# Shortcuts
		attr_accessor :x, :y, :width, :height
		
		# Point, Size
		def initialize origin, size
			@origin = origin
			@size = size
		end

		def x; @origin.x; end
		def y; @origin.y; end
		def x=(v); @origin.x = v; end
		def y=(v); @origin.y = v; end

		def width; @size.width; end
		def height; @size.height; end
		def width=(v); @size.width = v; end
		def height=(v); @size.height = v; end

		Zero = Rect.new(Point::Zero, Size::Zero)
	end
end
