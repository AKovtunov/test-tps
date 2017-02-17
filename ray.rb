class Ray
	attr_accessor :origin, :destination
	def initialize(origin = Vector3.new(0, 0, 0), destination = Vector3.new(0, 0 ,0))
		@origin, @destination = origin, destination
	end

	def collision_line_segment?(a, b, o, p)
		ab = Vector3.new(b.x - a.x, b.y - a.y)
		ap = Vector3.new(p.x - a.x, p.y - a.y)
		ao = Vector3.new(o.x - a.x, o.y - a.y)
		if ((ab.x * ap.y - ab.y * ap.x) * (ab.x * ao.y - ab.y * ao.x) <= 0)
			return true
		else
			return false
		end
	end

	def collision_segment_segment?(a, b, o, p)
		return false if !collision_line_segment?(a, b, o, p)
		return false if !collision_line_segment?(o, p, a, b)
		return true
	end

	def collides_with_aabb?(aabb)
		a, b = Vector3.new(@origin.x, @origin.z), Vector3.new(@destination.x, @destination.z)

		# top segment
		o, p = Vector3.new(aabb.position.x, aabb.position.z), Vector3.new(aabb.position.x + aabb.size.x, aabb.position.z)
		return true if collision_segment_segment?(a, b, o, p)

		# bottom segment
		o, p = Vector3.new(aabb.position.x, aabb.position.z + aabb.size.z), Vector3.new(aabb.position.x + aabb.size.x, aabb.position.z + aabb.size.z)
		return true if collision_segment_segment?(a, b, o, p)

		# left segment
		o, p = Vector3.new(aabb.position.x, aabb.position.z), Vector3.new(aabb.position.x, aabb.position.z + aabb.size.z)
		return true if collision_segment_segment?(a, b, o, p)

		# right segment
		o, p = Vector3.new(aabb.position.x + aabb.size.x, aabb.position.z), Vector3.new(aabb.position.x + aabb.size.x, aabb.position.z + aabb.size.z)
		return true if collision_segment_segment?(a, b, o, p)

		return false
	end

	def raytrace
		x0, x1 = @origin.x / 16.0, @destination.x / 16.0
		y0, y1 = @origin.z / 16.0, @destination.z / 16.0

		dx = (x1 - x0).abs
		dy = (y1 - y0).abs

		x = x0.floor.to_i
		y = y0.floor.to_i

		n = 1
		x_inc, y_inc, error = nil, nil, nil

		if (dx == 0)
		    x_inc = 0
		    error = Float::INFINITY
		elsif (x1 > x0)
		    x_inc = 1
		    n += x1.floor.to_i - x
		    error = (x0.floor + 1 - x0) * dy
		else
		    x_inc = -1
		    n += x - x1.floor.to_i
		    error = (x0 - x0.floor) * dy
		end

		if (dy == 0)
		    y_inc = 0;
		    error -= Float::INFINITY
		elsif (y1 > y0)
		    y_inc = 1
		    n += y1.floor.to_i - y
		    error -= (y0.floor + 1 - y0) * dx
		else
		    y_inc = -1;
		    n += y - y1.floor.to_i
		    error -= (y0 - y0.floor) * dx
		end

		path = Array.new

	    while n > 0
	    	# step by step from origin tile to destination tile
	    	# to do : handle ennemies, blocks...
	        path << [x.floor, y.floor]

	        if (error > 0)
	            y += y_inc
	            error -= dx
	        else
	            x += x_inc
	            error += dy
	        end
	        n -= 1
	    end
	    return path
	end

	def draw(color)
		glColor3ub(*color)
		glLineWidth(5.0)
		glBegin(GL_LINES)
			glVertex3i(@origin.x, @origin.y, @origin.z)
			glVertex3i(@destination.x, @destination.y, @destination.z)
		glEnd
	end
end