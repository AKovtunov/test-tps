class Character
	attr_reader :position
	def initialize(filename, frame_width, frame_height)
		@position = Vector3.new(0, 0, 0)
		@angle = Vector3.new(0, 0, 0)
		@frame_width, @frame_height = frame_width, frame_height
		@frames = Gosu::Image.new("gfx/#{filename}", {:retro=>true, :tileable=>true})
		@frame = 1
		@frame_duration, @frame_tick = 220.0, Gosu::milliseconds
		@left_foot = true
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

	def update(camera_angle)
		is_moving = false
		s = 1.0
		if (Gosu::button_down?(Gosu::KbW) or Gosu::button_down?(Gosu::KbS)) and	(Gosu::button_down?(Gosu::KbA) or Gosu::button_down?(Gosu::KbD))
			s *= 0.7
		end

		if Gosu::button_down?(Gosu::KbW)
			is_moving = true
			@position.x -= s * Math::cos(camera_angle.y.to_radians)
			@position.z -= s * Math::sin(camera_angle.y.to_radians)
		elsif Gosu::button_down?(Gosu::KbS)
			is_moving = true
			@position.x += s * Math::cos(camera_angle.y.to_radians)
			@position.z += s * Math::sin(camera_angle.y.to_radians)
		end

		if Gosu::button_down?(Gosu::KbA)
			is_moving = true
			@position.x -= s * Math::cos((camera_angle.y - 90.0).to_radians)
			@position.z -= s * Math::sin((camera_angle.y - 90.0).to_radians)
		elsif Gosu::button_down?(Gosu::KbD)
			is_moving = true
			@position.x += s * Math::cos((camera_angle.y - 90.0).to_radians)
			@position.z += s * Math::sin((camera_angle.y - 90.0).to_radians)
		end

		if is_moving
			if Gosu::milliseconds - @frame_tick >= @frame_duration
				if @frame == 0 or @frame == 2
					@frame = 1
				else
					if @left_foot
						@frame = 2
						@left_foot = false
					else
						@frame = 0
						@left_foot = true
					end
				end
				@frame_tick = Gosu::milliseconds
			end
		else
			@frame = 1
			@frame_tick = Gosu::milliseconds
		end
	end

	def draw(camera_angle)
		x_frame = (@frame * @frame_width) / @frames.width.to_f
		y_frame = 1.0 - (@orientations[@orientation] * @frame_height) / @frames.height.to_f
		frame_width = @frame_width / @frames.width.to_f 
		frame_height = @frame_height / @frames.height.to_f 
		glEnable(GL_ALPHA_TEST)
		glAlphaFunc(GL_GREATER, 0)
		glBindTexture(GL_TEXTURE_2D, @frames.gl_tex_info.tex_name)
		glPushMatrix
			glTranslate(@position.x, @position.y, @position.z)
			glRotate(90.0 - camera_angle.y, 0, 1, 0)
			glRotate(-camera_angle.x, 1, 0, 0)
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