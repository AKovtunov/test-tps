class Map
	def initialize(filename)
		to_display_list
	end

	def to_display_list
		@display_list = glGenLists(1)
		glNewList(@display_list, GL_COMPILE)
		# temp and fast implementation
		@tileset ||= Gosu::Image.new('gfx/tileset.png', {:retro=>true, :tileable=>true})
		glBindTexture(GL_TEXTURE_2D, @tileset.gl_tex_info.tex_name)
		y = 0
		glPushMatrix
		glScale($tile_size, $tile_size, $tile_size)	
		glBegin(GL_QUADS)
		for x in 0...20
			for z in 0...15
				@tileset.gl_tex_info.tex_coord_2d(0, 1); glVertex3i(x, y, z)
				@tileset.gl_tex_info.tex_coord_2d(0, 0); glVertex3i(x, y, z + 1)
				@tileset.gl_tex_info.tex_coord_2d(1, 0); glVertex3i(x + 1, y, z + 1)
				@tileset.gl_tex_info.tex_coord_2d(1, 1); glVertex3i(x + 1, y, z)
			end
		end
		glEnd
		glPopMatrix
		glEndList
	end

	def draw
		glCallList(@display_list)
	end
end
