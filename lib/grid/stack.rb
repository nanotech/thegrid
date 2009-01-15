require 'yaml'

module Grid
	YAML_TYPE = 'thegrid.nanotechcorp.net,2009-01-08'
	BOOL_CHARS = ['.', 'x']

	class Stack
		attr_reader :width, :height, :increment
		attr_accessor :window, :layers, :block_size, :padding, :position, :area,
		              :exclude

		include Enumerable

		def initialize(window, area, position, block_size, padding=0)
			@window = window

			@area = area
			@block_size = block_size.to_vector
			@padding = padding.to_vector

			calculate_position_from position.to_vector
			calculate_increment

			@save_exclude = []
			@exclude = []

			@layers = {}
		end

		def calculate_increment
			@increment = @block_size + @padding
		end

		def calculate_position_from(vect)
			@position = vect + @padding.dup
		end

		def padding=(value)
			old_padding = @padding
			@padding = value.to_vector
			calculate_increment
			calculate_position_from(@position - old_padding)
		end

		def block_size=(value)
			@block_size = value
			calculate_increment
		end

		# Call each layer's draw method.
		def draw
			@layers.each_value { |l| l.draw }
		end

		def create(name, *args)
			@layers[name] = Layer.new(self, *args) unless @layers[name]
		end

		# Get a grid vector from a world vector.
		def block_under(vect)
			if vect == :mouse
				vect = Vector(@window.mouse_x, @window.mouse_y)
			end

			area = @area
			total_padding = (@padding * (area - 1)) 
			area *= @block_size
			area += total_padding
			top_left = @position
			bottom_right = @position + area

			if vect >= top_left and vect <= bottom_right
				((vect - top_left) / @increment).cutoff
			end
		end

		def each
			@layers.each do |name, layer|
				yield name, layer unless @exclude.include? name
			end
		end

		# Save the Stack to a YAML file.
		def save(these, exclusive=false)
			if exclusive
				@save_these = []
				each do |n, l|
					@save_these << n unless these.include? n
				end
			else
				@save_these = these
			end

			File.open('save.yml', 'w') { |f| f.write(self.to_yaml) }
		end

		# Load a Stack from a YAML file.
		def load
			if File.exists? 'save.yml'
				layers = File.open('save.yml') { |yml| YAML.load(yml) }

				if layers
					layers.each do |name, blocks|
						create(name)

						blocks.map! do |line|
							line.map do |block|
								Block.new(self[name], block)
							end
						end

						self[name].blocks = blocks
					end
				end
			end
		end

		def to_yaml(opts={})
			YAML::quick_emit(self, opts) do |out|
				out.map(taguri, to_yaml_style) do |stack|
					@layers.each do |name, layer|
						next unless @save_these.include? name
						stack.add(name, layer.to_s)
					end
				end
			end
		end

		YAML::add_domain_type(YAML_TYPE, 'stack') do |type, stack|
			stack.each do |name, layer|
				blocks = layer.split("\n")

				blocks.map! do |line|
					line.split(//).map do |char|
						(char == BOOL_CHARS[1]) # x == true
					end
				end

				stack[name] = blocks.transpose
			end
		end

		def to_yaml_type; "!#{YAML_TYPE}/stack"; end

		# Shortcuts
		def [](layer); @layers[layer] end
		def []=(layer, value); @layers[layer] = value end
	end
end
