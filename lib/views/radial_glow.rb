require 'gooey/image'

class RadialGlow < Gooey::Image
	attr_accessor :zoom, :color

	def initialize(size, color=0xccffffff, zoom=1)
		super('radial_glow.png')
		@zoom = zoom
		@color = color
		self.clips_to_bounds = true
		self.size = size
	end

	def draw
		@zoom = (Math::sin(Gosu::milliseconds*0.002) + 1) * 0.3 + 1.4
		w = self.width.to_f * @zoom
		h = self.height.to_f * @zoom
		image(@image_data,
			  self.x - ((w-self.width)*0.5),
			  self.y - ((h-self.height)*0.5),
			  1000, # z level
			  w/@image_data.width,
			  h/@image_data.height,
			  @color)
	end
end
