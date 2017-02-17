class Character
	def initialize(filename, frame_width, frame_height)
		@position = Vector3.new(0, 0, 0)
		@angle = Vector3.new(0, 0, 0)
		@frame_width, @frame_height = frame_width, frame_height
		@frames = Gosu::Image.new("gfx/#{filename}", {:retro=>true, :tileable=>true})
		@frame = 1
		@orientations = {
			:north => 0,
			:east => 1,
			:south => 2,
			:west => 3
		}
		@orientation = :north
	end

	def set_position(position)
		@position = position
	end

	def update

	end

	def draw(camera_angle)
		x_frame = (@frame * @frame_width) / @frames.width.to_f
		y_frame = 1.0 - (@orientations[@orientation] * @frame_height) / @frames.height.to_f

		p y_frame
		frame_width = @frame_width / @frames.width.to_f 
		frame_height = @frame_height / @frames.height.to_f 
		glEnable(GL_ALPHA_TEST)
		glAlphaFunc(GL_GREATER, 0)
		glBindTexture(GL_TEXTURE_2D, @frames.gl_tex_info.tex_name)
		glPushMatrix
			glTranslate(@position.x, @position.y, @position.z)
			glRotate(90.0 - camera_angle.x, 0, 1, 0)
			glScale(@frame_width, @frame_height, 1.0)
			glBegin(GL_QUADS)
				@frames.gl_tex_info.tex_coord_2d(x_frame, y_frame - frame_height); 					glVertex3f(-0.5, 0.0, 0.0)
				@frames.gl_tex_info.tex_coord_2d(x_frame, y_frame);				 					glVertex3f(-0.5, 1.0, 0.0)
				@frames.gl_tex_info.tex_coord_2d(x_frame + frame_width, y_frame);				 	glVertex3f(0.5, 1.0, 0.0)
				@frames.gl_tex_info.tex_coord_2d(x_frame + frame_width, y_frame - frame_height);	glVertex3f(0.5, 0.0, 0.0)
			glEnd
		glPopMatrix
		glDisable(GL_ALPHA_TEST)
	end
end