module Gameplay
	class Sequence < Grid::Chain
		attr_accessor :sector, :chain

		def initialize(sector)
			@sector = sector

			random_vector = Vector(rand(@sector.area.x),rand(@sector.area.y))
			# head_image = Image.new(@sector.window, 'icon.png', false)

			super(@sector, random_vector, 5, :animated,
				  [0xcc00ff00, 0x99009900],
				  [0xffcc9900, 0xff990000]) #, head_image)

			@sector.manage :chain => self
			@zlevel = 100
		end
	end
end
