class Camera
	attr_reader :angles, :target
	def initialize(window)
		@window = window
		@clear_color = [0.5, 0.5, 0.5, 1.0]		
		@position = Vector3.new(0, 0, 0)
		@target = Vector3.new(0, 0, 0)
		@straff = Vector3.new(14, 0, 0)
		@angles = Vector3.new(0, 0, 0)
		@distance = 60.0
		@altitude = 18.0

		@last_mouse_x, @last_mouse_y = @window.mouse_x, @window.mouse_y
	end

	def update(target)
		@perspective = @window.fullscreen? ? [45, Gosu::screen_width.to_f / Gosu::screen_height.to_f, 1, 1000] : [45, @window.width.to_f / @window.height.to_f, 1, 1000]

		if @window.mouse_x != @last_mouse_x
			@angles.y += (@window.mouse_x - @last_mouse_x) * 0.2
			@window.mouse_x = @window.width / 2
			@last_mouse_x = @window.mouse_x
		end
		max_angle_x = 15
		if @window.mouse_y != @last_mouse_y
			@angles.x += (@window.mouse_y - @last_mouse_y) * 0.2
			@window.mouse_y = @window.height / 2
			@last_mouse_y = @window.mouse_y
			@angles.x = max_angle_x	 if @angles.x > max_angle_x
			@angles.x = -max_angle_x if @angles.x < -max_angle_x
		end

		@target.x = target.x
		@target.y = target.y + @altitude
		@target.z = target.z

		@target.x += @straff.x * Math::cos((@angles.y - 90.0).to_radians)
		@target.z += @straff.x * Math::sin((@angles.y - 90.0).to_radians)

		@position.x = @target.x + @distance * Math::cos(@angles.x.to_radians) * Math::cos(@angles.y.to_radians)
		@position.y = @target.y + @distance * Math::sin(@angles.x.to_radians)
		@position.z = @target.z + @distance * Math::cos(@angles.x.to_radians) * Math::sin(@angles.y.to_radians)
	end

	def look
		glColor4f(1, 1, 1, 1)
		glEnable(GL_TEXTURE_2D)
		glEnable(GL_DEPTH_TEST)
		glClearColor(*@clear_color)
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
		glMatrixMode(GL_PROJECTION)
		glLoadIdentity
		gluPerspective(*@perspective)
		glMatrixMode(GL_MODELVIEW)
		glLoadIdentity
		gluLookAt(@position.x, @position.y, @position.z, @target.x, @target.y, @target.z, 0, 1, 0)	
	end
end