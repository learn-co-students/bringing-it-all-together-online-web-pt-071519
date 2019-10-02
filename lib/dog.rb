class Dog 
    attr_accessor :name, :breed, :id

    def initialize(name:, breed:, id: nil)
        @name = name 
        @breed = breed
        @id = id
    end

    
    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)
        SQL
        DB[:conn].execute(sql)
    end


    def self.drop_table
        sql = <<-SQL
        DROP TABLE dogs
        SQL
        DB[:conn].execute(sql)
    end

    def save 
        sql = <<-SQL 
        INSERT INTO dogs (name, breed, id)
        VALUES (?, ?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowId() FROM dogs")[0][0]
        self
    end


    def self.create(hash)
        dog = Dog.new(hash)
        dog.save
        dog
    end


    def self.new_from_db(row)
        Dog.new(id: row[0], name: row[1], breed: row[2])
    end


    def self.find_by_id(uniq_id)
        result = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", uniq_id).first
        Dog.new(id: result[0], name: result[1], breed: result[2])
    end


    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !dog.empty?
            dog_row = dog[0]
            dog = Dog.new(id: dog_row[0], name: dog_row[1], breed: dog_row[2])
        else
            dog = self.create(name: name, breed: breed)
        end
        dog
    end


    def self.find_by_name(name)
        result = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).first
        Dog.new(id: result[0], name: result[1], breed: result[2])
    end


    def update 
        sql = <<-SQL
        UPDATE dogs SET name = ?, breed = ? WHERE id = ?
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end