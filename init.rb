require 'gosu'
require 'opengl'
require 'glu'
include Gl, Glu

Dir["objects/*"].each {|file| require_relative file}

$tile_size = 16

class Window < Gosu::Window
	def initialize
		super(640, 480, false)
		self.caption = "Ray test"
		@camera = Camera.new(self)
		@character = Character.new('test.png', 24, 32)
		@map = Map.new(nil)
		@font = Gosu::Font.new(24)
	end

	# def needs_cursor?; true; end

	# workaround until Gosu has the initial methods again !
	def mouse_x=(value); self.set_mouse_x(value); end
	def mouse_y=(value); self.set_mouse_y(value); end

	def button_down(id)
		super
		exit if id == Gosu::KbEscape
	end

	def update
		# WILL BE DELETED AFTER
		@ray ||= Ray.new(Vector3.new(0, 12, 0), Vector3.new(0, 12, 0))
		@ray_angle ||= 0
		lenght = 96


		@ray_angle += 2 if Gosu::button_down?(Gosu::KbRight)
		@ray_angle -= 2 if Gosu::button_down?(Gosu::KbLeft)


		
		@character.update(@camera.angles)
		@camera.update(@character.position)

		range = 96.0
		@ray.origin.x = @character.position.x
		@ray.origin.z = @character.position.z
		@ray.destination.x = @camera.target.x - range * Math::cos(@camera.angles.x.to_radians) * Math::cos(@camera.angles.y.to_radians)
		@ray.destination.y = @camera.target.y - range * Math::sin(@camera.angles.x.to_radians)
		@ray.destination.z = @camera.target.z - range * Math::cos(@camera.angles.x.to_radians) * Math::sin(@camera.angles.y.to_radians)
		@path = @ray.raytrace
	end

	def draw
		gl do
			@camera.look
			@map.draw
			@character.draw(@camera.angles)

			color = [255, 0, 0]
			@path.each {|aabb| AABB.draw(Vector3.new(aabb[0] * 16, 1, aabb[1] * 16), Vector3.new(16, 16, 16), color)}
			# @ray.draw([0, 255, 0])
		end
		@font.draw("FPS : #{Gosu::fps} X Angle : #{@camera.angles.x}", 0, 0, 0)
		@target_image ||= Gosu::Image.new('gfx/target.png', :retro=>true)
		@target_image.draw(self.width / 2 - @target_image.height / 2, self.height / 2 - @target_image.height / 2, 1, 5, 5, Gosu::Color.new(64, 255, 255, 255))
	end
end

Window.new.show