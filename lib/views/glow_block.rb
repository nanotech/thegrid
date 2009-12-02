require 'views/radial_glow'

class GlowBlock < Grid::Block
	def self.draw(origin, size, z, color, blending=:additive)
		@view ||= @radial_glow = RadialGlow.new(Gooey::Size.from_vector(size), color.first, 2)
		@view.origin = origin
		@view.size = Gooey::Size.from_vector(size)
		@view.color = color.first

		clip @view.frame do # NOTE: doesn't seem to clip properly without this
			@view.draw
		end
	end
end
