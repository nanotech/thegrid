# Various methods that make various stuff easier.

class Numeric
	# Convenience method for converting from radians to a Vec2 vector.
	def radians_to_vec2; CP::Vec2.new(Math::cos(self), Math::sin(self)); end

	# Same as above, but converts to a plain Ruby array.
	def radians_to_cartesian; [Math::cos(self), Math::sin(self)]; end

	def radians_to_gosu; self.radians_to_degrees + 90; end;
	def gosu_to_radians; (self - 90).radians_to_degrees; end;

	def radians_to_degrees; self * (180.0 / Math::PI); end;
	def degrees_to_radians; self / (180.0 / Math::PI); end;

	def distance_to(other); Math::sqrt(self**2 + other**2); end
end

class String
	# The reverse of camelize.
	# Makes an underscored, lowercase form from the expression in the string.
	#
	# Borrowed from Rail's ActiveSupport::Inflector.
	def underscore
		self.to_s.gsub(/::/, '/').
			gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
			gsub(/([a-z\d])([A-Z])/,'\1_\2').
			tr("-", "_").
			downcase
	end

	# Converts strings to UpperCamelCase
	def camelize
		self.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
	end

	# Convert a CamelCase string to a constant
	def constantize
		names = self.camelize.split('::')

		constant = Object
		names.each do |name|
			constant = constant.const_defined?(name) ?
				constant.const_get(name) : constant.const_missing(name)
		end
		constant
	end
end

class Array
	def split_by(&block)
		previous = self.first
		active = [previous]
		split = [active]

		self[1..-1].each do |x|
			if yield(previous, x)
				active = []
				split << active
			end

			active << x
			previous = x
		end

		return split
	end
end

# Automatically require and create an object based on it's name
def create(item, *args)
	require item.to_s.underscore
	item.to_s.constantize.new(*args)
end
