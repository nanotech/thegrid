require 'gosu'
require 'gooey/view'

module Gooey
	class Image < View
		def initialize(image, hard_edges=false)
			image = Gosu::Image.new($window, image, hard_edges) if image.respond_to? :to_str
			super(Rect.new(Point::Zero, Size.new(image.height, image.width)))
			@image_data = image
		end

		def draw
			image(@image_data, self.x, self.y, 0,
				  self.width.to_f/@image_data.width,
				  self.height.to_f/@image_data.height)
		end
	end
end
