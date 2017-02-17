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