class Dog
	attr_accessor :id, :name, :breed

	def initialize(options = {})
		@id = options[:id]
		@name = options[:name]
		@breed = options[:breed]
	end 	

	def self.create_table
		sql = "CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)"
		DB[:conn].execute(sql)
	end 	

	def self.drop_table
		sql = "DROP TABLE dogs"
		DB[:conn].execute(sql)
	end 
	
	def save	
		if self.id
			self.update
		else 	
			sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
			DB[:conn].execute(sql, self.name, self.breed)
			@id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
		end 
		self
	end 

	def self.create(hash)
		dog = Dog.new(hash)
		dog.save
		dog
	end 

	def self.new_from_db(row)
		dog = self.new(id: row[0], name: row[1], breed: row[2])
		dog.id = row[0]
		dog.name = row[1]
		dog.breed = row[2]
		dog 
	end 

	def self.find_by_id(id)
		sql = "SELECT * FROM dogs WHERE id = ?"
		DB[:conn].execute(sql, id).map do |row|
			self.new_from_db(row)
		end.first	
	end 	

	def self.find_or_create_by(name:, breed:)
		sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
		dog_array = DB[:conn].execute(sql, name, breed)

		if dog_array.empty?
			dog = Dog.create(name: name, breed: breed)
		else
			dog_data = dog_array[0]
			dog = Dog.new_from_db(dog_data)
		end 
		dog
	end 			

	def self.find_by_name(name)
		sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"
		DB[:conn].execute(sql, name).map do |row|
			self.new_from_db(row)
		end.first
	end 		

	def update 
		sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
		DB[:conn].execute(sql, self.name, self.breed, self.id)	
	end 	
end 			
