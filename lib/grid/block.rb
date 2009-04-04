module Grid
	class Block
		attr_accessor :enabled, :worth, :cost, :parent, :location, :text, :data
		attr_reader :layer

		def initialize(layer, enabled, location=nil)
			@layer = layer
			@enabled = enabled
			@location = location
			@worth = 1
			@cost = 0
			@parent = nil
			@image = nil
			@text = nil
			@data = {}
		end

		def draw(p, s, color=@layer.color, image=@image,
				 text=@text, blending=@layer.blending)

			if @enabled
				draw_background p, s, color, blending
				draw_image p, s, image, blending if image
				draw_text p, s, text if text
			end
		end

		def draw_background(p, s, color, blending)
			@layer.grid.window.draw_quad(
				p.x,       p.y,       color[0], # top left
				p.x + s.x, p.y,       color[1], # top right
				p.x,       p.y + s.y, color[2], # bottom left
				p.x + s.x, p.y + s.y, color[3], # bottom right
				@layer.zlevel, blending # z-level, color blending mode
			)
		end

		def draw_image(p, s, image, blending)
			image.draw_as_quad(
				p.x,       p.y,       0xffffffff, # top left
				p.x + s.x, p.y,       0xffffffff, # top right
				p.x,       p.y + s.y, 0xffffffff, # bottom left
				p.x + s.x, p.y + s.y, 0xffffffff, # bottom right
				@layer.zlevel + 1, blending # z-level, color blending mode
			)
		end

		def draw_text(p, s, text)
			if @layer.grid.font
				pos = p + (s / Vector(2.0,2.0))

				@layer.grid.font.draw_rel(
					text, pos.x, pos.y, @layer.zlevel + 2,
					0.5, 0.5, 1, 1, 0xffffffff
				)
			else
				puts @layer.grid.font
			end
		end
	end
end
