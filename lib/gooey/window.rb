require 'gosu'
require 'gooey/view'

module Gooey
	class Window < Gosu::Window
		include Viewish

		attr_accessor :cursor_view

		def initialize(width, height, *args)
			super(*[width, height, args].flatten)
			init_view Rect.new(Point::Zero, Size.new(width, height))
		end

		def superview= _
			raise ArgumentError.new("a Window can't have a superview!")
		end

		def cursor_view= view
			remove_subview @cursor_view if @cursor_view
			@cursor_view = view
			add_subview @cursor_view
		end

		def draw
			draw_subviews
		end
	end
end
