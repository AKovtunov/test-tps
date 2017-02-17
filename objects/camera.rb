class Camera
	def initialize(window)
		@window = window
		@clear_color = [0.5, 0.5, 0.5, 1.0]
		@perspective = [45, @window.width.to_f / @window.height.to_f, 1, 1000]		
	end

	def look
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