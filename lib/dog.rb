class Dog
# attributes

  attr_accessor :id, :name, :breed
# has a name and a breed 1
# has an id that defaults to `nil` on initialization 2
# accepts key value pairs as arguments to initialize 3

  def initialize(id: id = nil, name: name, breed: breed)
    @id = id
    @name = name
    @breed = breed
  end



  def self.create_table
    sql_drop = "DROP TABLE IF EXISTS dogs;"
    DB[:conn].execute(sql_drop)
    sql_create = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT, 
        breed TEXT
        );
    SQL
    DB[:conn].execute(sql_create)
  # creates the dogs table in the database 4
  end

  def self.drop_table
  # drops the dogs table from the database 5
    sql = ("DROP TABLE IF EXISTS dogs")
    DB[:conn].execute(sql)
  end


  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
    # takes in a hash of attributes
    # uses metaprogramming to create a new dog object.
    # Then it uses the def save method to save that dog to the database 8
    # returns a new dog object 9
  end

  def self.new_from_db(row)
    # creates an instance with corresponding attribute values 10
    new_dog = self.new()
    new_dog.id = row[0]
    new_dog.name = row[1]
    new_dog.breed = row[2]
    new_dog
  end

  def self.find_by_id(id)
    sql =  <<-SQL
      SELECT * 
      FROM dogs
      WHERE id = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, id).map do |row|
      Dog.new_from_db(row)
    end.first
    # returns a new dog object by id 11
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ? AND breed = ?
      LIMIT 1
    SQL
    dog = DB[:conn].execute(sql, name, breed)

    if !dog.empty?
      query_dog = dog[0]
      dog = Dog.new(id: query_dog[0], name: query_dog[1], breed: query_dog[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
    # creates an instance of a dog if it does not already exist 12
    # when two dogs have the same name and different breed, it returns the correct dog 13
    # when creating a new dog with the same name as persisted dogs, it returns the correct dog 14
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL
  # returns an instance of dog that matches the name from the DB 15
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def save  # (name, breed)
    if self.id
      self.update
    else
      sql = ("INSERT INTO dogs (name, breed) VALUES (?, ?)")
      record = DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      # binding.pry
    end
    
    Dog.new(id: id, name: name, breed: breed)
      # saves an instance of the dog class to the database
      # sets the given dogs `id` attribute 7
      # returns an instance of the dog class 6

  end
  
  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL
  # updates the record associated with a given instance 16
  DB[:conn].execute(sql, self.name, self.breed, self.id)

  end


end