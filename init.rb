require 'gosu'
require 'opengl'
require 'glu'
include Gl, Glu

require_relative 'utils.rb'
require_relative 'ray.rb'

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