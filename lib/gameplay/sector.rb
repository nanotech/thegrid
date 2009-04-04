module Gameplay
	class Sector < Grid::Stack
		def initialize(window, area, position, block_size, padding=0)
			super
			create :wall, [0xcc0099ff, 0x660033ff]
			create :floor, [0x22ffffff, 0x16ffffff], true
		end
	end
end
