module Grid
	class Block
		def self.draw(window, p, s, z, color, blending=:default)
			window.draw_quad(
				p.x,       p.y,       color[0], # top left
				p.x + s.x, p.y,       color[1], # top right
				p.x,       p.y + s.y, color[2], # bottom left
				p.x + s.x, p.y + s.y, color[3], # bottom right
				z, blending # z-level, color blending mode
			)
		end
	end
end

require 'grid/image_block'
require 'grid/text_block'
