module Grid
	class ImageBlock < Block
		def self.draw(p, s, z, color, image, blending=:default)
			super(p, s, z, color, blending)
			
			image.draw_as_quad(
				p.x,       p.y,       0xffffffff, # top left
				p.x + s.x, p.y,       0xffffffff, # top right
				p.x,       p.y + s.y, 0xffffffff, # bottom left
				p.x + s.x, p.y + s.y, 0xffffffff, # bottom right
				z + 1, blending # z-level, color blending mode
			)
		end
	end
end
