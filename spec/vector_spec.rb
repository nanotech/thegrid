require 'lib/vector'

describe Vector do
	it "can be grouped when in an array" do
		vects = [Vector(5,6), Vector(5,7), Vector(5,8), Vector(6,8), Vector(6,9)]
		vects.group_vectors_by_dimension.should == [[Vector(5,6), Vector(5,7), Vector(5,8)], [Vector(6,8), Vector(6,9)]]
	end
end
