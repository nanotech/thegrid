require 'gooey'

module Grid
	class Block
		extend Gooey

		def self.draw(window, p, s, z, color, blending=:default)
			@window = window
			rectangle p, s, color, z, blending
		end
	end
end

require 'grid/image_block'
require 'grid/text_block'
