module Grid
	class MenuLayer < Layer
		def draw_block(vect, pixel)
			TextBlock.draw(
				pixel, @grid.block_size, @zlevel,
				@color, @grid.labels[vect], @grid.font, @blending
			)
		end
	end
end
