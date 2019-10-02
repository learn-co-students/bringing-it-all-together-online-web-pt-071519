class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(dog_hash)
        @name = dog_hash[:name]
        @breed = dog_hash[:breed]
        if dog_hash[:id]
            @id = dog_hash[:id]
        else
            @id = nil
        end
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE dogs (
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
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)

        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
        self
    end

    def self.create(dog_hash)
        dog = self.new(dog_hash)
        dog.save
    end

    def self.new_from_db(row)
    dog_hash = {
        name: row[1],
        breed: row[2],
        id: row[0]
    }
    Dog.new(dog_hash)
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * FROM dogs WHERE id = ?
        SQL
        
        row = DB[:conn].execute(sql, id).first
        new_from_db(row)
    end

    def self.find_or_create_by(dog_hash)
        sql = <<-SQL
            SELECT * FROM dogs WHERE name = ? AND breed = ?
        SQL
        
        dog = DB[:conn].execute(sql, dog_hash[:name], dog_hash[:breed]).first
        if dog
            new_from_db(dog)
        else
            create(dog_hash)
        end
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs WHERE name = ?
        SQL
        
        row = DB[:conn].execute(sql, name).first
        new_from_db(row)
    end

    def update
        sql = <<-SQL
            UPDATE dogs
            SET id = ?, name = ?, breed = ?
            WHERE id = ?
        SQL

        DB[:conn].execute(sql, self.id, self.name, self.breed, self.id)
    end
end