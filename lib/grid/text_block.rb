module Grid
	class TextBlock < Block
		def self.draw(p, s, z, color, contents, font, blending=:default)
			super(p, s, z, color, blending)

			pos = p + (s / Vector(2.0,2.0))

			relative_text(
				font, contents, pos.x, pos.y, z + 2,
				0.5, 0.5, 1, 1, 0xffffffff
			)
		end
	end
end
