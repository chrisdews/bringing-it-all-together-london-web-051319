require "pry"

class Dog
	attr_accessor :id, :name, :breed

	def initialize(id: nil, name:, breed:)
		@id = id
		@name = name
		@breed = breed	
	end

	def self.create_table
		sql = <<-SQL 
			CREATE TABLE IF NOT EXISTS dogs(
				id INTEGER PRIMARY KEY,
				name TEXT,
				breed TEXT
				);
			SQL

		DB[:conn].execute(sql)
	end

	def self.drop_table
		sql = <<-SQL 
			DROP TABLE IF EXISTS dogs;
			SQL

		DB[:conn].execute(sql)
	end

	def save
		# Dog.new(name, breed)

		sql = <<-SQL
      	INSERT INTO dogs (name, breed) 
      	VALUES (?, ?)
    	SQL
 
    	DB[:conn].execute(sql, name, breed)
		@id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
		self
	end

	def self.create(name:, breed:)
		doggie = self.new(name: name, breed: breed)
		doggie.save
		doggie
	end

	def self.new_from_db(row)
		new_doggie = self.new(id: row[0], name: row[1], breed: row[2])
		
	end

	def self.find_by_id(id)
		sql = <<-SQL
      	SELECT *
      	FROM dogs
      	WHERE id = ?
      	LIMIT 1
    	SQL

    	DB[:conn].execute(sql, id).map { |row| self.new_from_db(row) }[0]
		
	end

	def self.find_by_name(name)
		sql = <<-SQL
      	SELECT *
      	FROM dogs
      	WHERE name = ?
      	LIMIT 1
    	SQL

    	DB[:conn].execute(sql, name).map { |row| self.new_from_db(row) }[0]
		
	end

	def self.find_or_create_by(name:, breed:)
		sql = "SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1"


			doggie = DB[:conn].execute(sql, name, breed)
    	if !doggie.empty?
      		doggie_data = doggie[0]
     		doggie = self.new(id: doggie_data[0], name: doggie_data[1], breed: doggie_data[2])
    	else
      		doggie = self.create(name: name, breed: breed)
    	end
    doggie
			
	end

	def update
		sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
		
		
	end


end