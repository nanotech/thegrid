module Grid
	class TextBlock < Block
		def self.draw(window, p, s, z, color, text, font, blending=:default)
			super(window, p, s, z, color, blending)

			pos = p + (s / Vector(2.0,2.0))

			font.draw_rel(
				text, pos.x, pos.y, z + 2,
				0.5, 0.5, 1, 1, 0xffffffff
			)
		end
	end
end
