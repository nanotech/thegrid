require 'gooey'

module Grid
	class Block
		extend Gooey

		def self.draw(p, s, z, color, blending=:default)
			rectangle p, s, color, z, blending
		end
	end
end

require 'grid/image_block'
require 'grid/text_block'
