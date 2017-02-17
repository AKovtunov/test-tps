# simple structure to handle coordinates
Vector3 = Struct.new(:x, :y, :z)

# hellper for trigonometry
class Float
	def to_radians
		self * Math::PI / 180.0
	end
end

class Integer
	def to_radians
		self.to_f * Math::PI / 180.0
	end
end

class GLTexture
	def initialize(filename)
		gosu_image = Gosu::Image.new(filename, {:retro=>true, :tileable=>true})
		array_of_pixels = gosu_image.to_blob
		@texture_id = glGenTextures(1)
		glBindTexture(GL_TEXTURE_2D, @texture_id[0])
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, gosu_image.width, gosu_image.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, array_of_pixels)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
		gosu_image = nil
	end

	def get_id
		return @texture_id[0]
	end
end

class ObjModel
	def initialize(filename)
		v, vt, vn, f = [], [], [], []
		File.open(filename, 'r').readlines.each do |line|
			case line.split(' ').first
			when 'v' then v << line.split(' ').drop(1).map {|e| e.to_f}
			when 'vt' then vt << line.split(' ').drop(1).map {|e| e.to_f}
			when 'vn' then vn << line.split(' ').drop(1).map {|e| e.to_f}
			when 'f' then f << line.split(' ').drop(1).map {|e| e.split('/').map {|sub_e| sub_e.to_i - 1}} # -1 stands to count from 0
			end
		end
		@display_list = glGenLists(1)
		glNewList(@display_list, GL_COMPILE)
		glBegin(GL_TRIANGLES)
		f.each do |face|
			face.each do |vertice|
				v1, vt1, vn1 = v[vertice[0]], vt[vertice[1]], vn[vertice[2]]
				glTexCoord3f(vt1[0], 1.0 - vt1[1], vt1[2]) # -1 stands for Y inversion
				glNormal(vn1[0], vn1[1], vn1[2])
				glVertex3f(v1[0], v1[1], v1[2])
			end
		end
		glEnd
		glEndList
	end

	def draw(texture)
		glBindTexture(GL_TEXTURE_2D, texture.get_id)
		glCallList(@display_list)
	end
end