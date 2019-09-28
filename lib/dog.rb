class Dog
    attr_accessor :name , :breed
    attr_reader :id
    def initialize(name:, breed:, id:nil)
        @name = name 
        @breed = breed
        @id = id
    end

    def self.create_table 
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs(
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
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
        if self.id
            self.update
        else
            sql = <<-SQL
            INSERT INTO dogs (name, breed) VALUES (?,?)
            SQL
            DB[:conn].execute(sql,self.name,self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
            self
    end 

    def self.create(name:,breed:)
        dog = self.new(name: name,breed: breed)
        # binding.pry
        dog.save
        dog
    end

    def self.new_from_db(row)
        dog = self.new(id: row[0],name: row[1],breed: row[2])
        dog
    end

    def self.find_by_id(dog_id)
        sql = <<-SQL
        SELECT * FROM dogs WHERE id = ?
        SQL
        row = DB[:conn].execute(sql,dog_id)[0]
        new_from_db(row)
    end

    def self.find_or_create_by(name:,breed:)
        sql = <<-SQL
        SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1
        SQL
        dog = DB[:conn].execute(sql, name, breed)
        if !dog.empty?
            dog_data = dog[0]
            dog = Dog.new_from_db(dog_data)
        else
            dog = self.create(name:name,breed: breed)
        end
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * FROM dogs WHERE name = ?
        SQL
        dog_data = DB[:conn].execute(sql,name)[0]
        dog = new_from_db(dog_data)
    end

    def update 
        sql = <<-SQL
        UPDATE dogs
        SET name = ?
        WHERE id = ?
        SQL
        DB[:conn].execute(sql,self.name,self.id)
    end
end