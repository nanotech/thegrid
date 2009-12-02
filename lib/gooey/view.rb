require 'gooey/coordinates'

module Gooey
	module Viewish
		include Gooey

		attr_accessor :frame, :clips_to_bounds
		attr_reader :subviews, :superview

		# Shortcuts
		attr_accessor :x, :y, :width, :height, :origin, :size

		def init_view frame
			@frame = frame
			@subviews = []
			@superview = nil
			@clips_to_bounds = false
		end

		def bounds
			Rect.new(Point::Zero, @frame.size)
		end

		def x; @frame.x; end
		def y; @frame.y; end
		def width; @frame.width; end
		def height; @frame.height; end

		def x=(v); @frame.x = v; end
		def y=(v); @frame.y = v; end
		def width=(v); @frame.width = v; end
		def height=(v); @frame.height = v; end

		def origin; @frame.origin; end
		def size; @frame.size; end
		def origin=(v); @frame.origin = v; end
		def size=(v); @frame.size = v; end

		# Only a View's superview should call this!
		def superview= superview
			@superview = superview
		end

		def add_subview subview
			subview.superview = self
			@subviews << subview
		end

		def remove_subview subview
			if @subviews.delete subview
				subview.superview = nil
			end
		end

		# Override me.
		def draw
		end

		protected

		def draw_subviews
			translate @frame.x,@frame.y do
				@subviews.each { |v| v.draw_contents }
			end
		end

		def draw_contents
			if @clips_to_bounds
				clip(frame) { draw }
			else
				draw
			end
			draw_subviews
		end
	end

	class View
		include Viewish

		def initialize frame
			init_view frame
		end
	end
end
