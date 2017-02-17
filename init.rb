require 'gosu'
require 'opengl'
require 'glu'
include Gl, Glu

require_relative 'opengl_context.rb'
require_relative 'utils.rb'
require_relative 'aabb.rb'
require_relative 'ray.rb'
require_relative 'map.rb'

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