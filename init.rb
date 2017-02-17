require 'gosu'
require 'opengl'
require 'glu'
include Gl, Glu

require_relative 'utils.rb'

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

class AABB
	attr_accessor :position, :size
	def initialize(position = Vector3.new(0, 0, 0), size = Vector3.new(0, 0, 0))
		@position, @size = position, size
	end

	def collides_other?(aabb)
		return false if (aabb.position.x > @position.x + @size.x or aabb.position.x + aabb.size.x < @position.x)
		return false if (aabb.position.y > @position.y + @size.y or aabb.position.y + aabb.size.y < @position.y)
		return false if (aabb.position.z > @position.z + @size.z or aabb.position.z + aabb.size.z < @position.z)
		return true
	end

	def self.draw(position, size, color)
		glColor3ub(*color)
		glPushMatrix
			glTranslate(position.x, position.y, position.z)
			glScale(size.x, size.y, size.z)
			glBegin(GL_QUADS)
				# bottom
				glVertex3i(0, 0, 0)
				glVertex3i(0, 0, 1)
				glVertex3i(1, 0, 1)
				glVertex3i(1, 0, 0)
			glEnd
		glPopMatrix
	end

	def draw(color)
		glColor3ub(*color)
		glPushMatrix
			glTranslate(@position.x, @position.y, @position.z)
			glScale(@size.x, @size.y, @size.z)
			glBegin(GL_QUADS)
				# back
				glVertex3i(0, 0, 0)
				glVertex3i(1, 0, 0)
				glVertex3i(1, 1, 0)
				glVertex3i(0, 1, 0)

				# front
				glVertex3i(0, 0, 1)
				glVertex3i(1, 0, 1)
				glVertex3i(1, 1, 1)
				glVertex3i(0, 1, 1)

				# left
				glVertex3i(0, 0, 0)
				glVertex3i(0, 0, 1)
				glVertex3i(0, 1, 1)
				glVertex3i(0, 1, 0)

				# right
				glVertex3i(1, 0, 0)
				glVertex3i(1, 0, 1)
				glVertex3i(1, 1, 1)
				glVertex3i(1, 1, 0)

				# bottom
				glVertex3i(0, 0, 0)
				glVertex3i(0, 0, 1)
				glVertex3i(1, 0, 1)
				glVertex3i(1, 0, 0)

				# top
				glVertex3i(0, 1, 0)
				glVertex3i(0, 1, 1)
				glVertex3i(1, 1, 1)
				glVertex3i(1, 1, 0)
			glEnd
		glPopMatrix
	end
end

class Map
	def initialize(filename)

	end

	def draw

	end
end

class OpenglContext
	def initialize(window)
		@window = window
		@clear_color = [0.5, 0.5, 0.5, 1.0]
		@perspective = [45, @window.width.to_f / @window.height.to_f, 1, 1000]
	end

	def setup
		glColor4f(1, 1, 1, 1)
		# glEnable(GL_TEXTURE_2D)
		glEnable(GL_DEPTH_TEST)
		glClearColor(*@clear_color)
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
		glMatrixMode(GL_PROJECTION)
		glLoadIdentity
		gluPerspective(*@perspective)
		glMatrixMode(GL_MODELVIEW)
		glLoadIdentity
		gluLookAt(0, 200, 1, 0, 0, 0, 0, 1, 0)		
	end

end

class Window < Gosu::Window
	def initialize
		super(640, 480, false)
		self.caption = "Ray test"
		@opengl_context = OpenglContext.new(self)
		@font = Gosu::Font.new(24)
	end

	def needs_cursor?; true; end

	# workaround until Gosu has the initial methods again !
	def mouse_x=(value); self.set_mouse_x(value); end
	def mouse_y=(value); self.set_mouse_y(value); end

	def button_down(id)
		super
		exit if id == Gosu::KbEscape
	end

	def update
		@ray ||= Ray.new(Vector3.new(0, 1, 0), Vector3.new(0, 1, 0))
		@ray_angle ||= 0
		lenght = 96
		@ray.destination.x = @ray.origin.x + lenght * Math::cos(@ray_angle * Math::PI / 180.0)
		@ray.destination.z = @ray.origin.z + lenght * Math::sin(@ray_angle * Math::PI / 180.0)
		@ray_angle += 1 if Gosu::button_down?(Gosu::KbRight)
		@ray_angle -= 1 if Gosu::button_down?(Gosu::KbLeft)

		v = 1
		@ray.origin.x += v if Gosu::button_down?(Gosu::KbD)
		@ray.origin.x -= v if Gosu::button_down?(Gosu::KbA)
		@ray.origin.z -= v if Gosu::button_down?(Gosu::KbW)
		@ray.origin.z += v if Gosu::button_down?(Gosu::KbS)

		@path = @ray.raytrace
	end

	def draw
		gl do
			@opengl_context.setup
			color = [255, 0, 0]
			
			@path.each {|aabb| AABB.draw(Vector3.new(aabb[0] * 16, 0, aabb[1] * 16), Vector3.new(16, 16, 16), color)}
			@ray.draw([0, 255, 0])
		end
		@font.draw("FPS : #{Gosu::fps}", 0, 0, 0)
	end
end

Window.new.show