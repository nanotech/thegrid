module Grid
	class Block
		attr_accessor :enabled, :worth, :cost, :parent, :location, :text, :data
		attr_reader :layer

		def initialize(layer, enabled)
			@layer = layer
			@enabled = enabled
			@worth = 1
			@cost = 0
			@parent = nil
			@location = nil
			@image = nil#Image.new(@layer.grid.window, 'box.png', false)
			@text = nil
			@data = {}
		end

		def draw(p, s, color=@layer.color, blending=@layer.blending)
			if @enabled
				@layer.grid.window.draw_quad(
					p.x,       p.y,       color[0], # top left
					p.x + s.x, p.y,       color[1], # top right
					p.x,       p.y + s.y, color[2], # bottom left
					p.x + s.x, p.y + s.y, color[3], # bottom right 
					@layer.zlevel, blending # z-level, color blending mode
				)

				@image.draw_as_quad(
					p.x,       p.y,       0xffffffff, # top left
					p.x + s.x, p.y,       0xffffffff, # top right
					p.x,       p.y + s.y, 0xffffffff, # bottom left
					p.x + s.x, p.y + s.y, 0xffffffff, # bottom right 
					1, blending # z-level, color blending mode
				) if @image

				if @text and @layer.grid.font
					pos = p + (s / Vector(2.0,2.0))

					@layer.grid.font.draw_rel(
						@text, pos.x, pos.y, @layer.zlevel, 0.5, 0.5
					)
				end
			end
		end
	end
end
