require 'pry'
class Dog
  attr_accessor :name, :breed
  attr_reader :id
  def initialize(id: nil, name:, breed: )
    @id = id
    @name = name
    @breed = breed
  end
  def self.create_table
    sql = <<-YOU
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    YOU
    DB[:conn].execute(sql)
  end
  def self.drop_table
    sql = <<-LOVE
    DROP TABLE dogs
    LOVE
    DB[:conn].execute(sql)
  end
  def save
    if self.id
     self.update
   else
     sql = <<-SQL
       INSERT INTO dogs (name, breed)
       VALUES (?, ?)
     SQL

     DB[:conn].execute(sql, self.name, self.breed)
     @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
     dog = DB[:conn].execute("SELECT * FROM dogs WHERE id = last_insert_rowid()")
     new_dog = Dog.new(id: dog[0], name: dog[1], breed: dog[2])
   end
  end
  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create( name:, breed:)
    new_dog = self.new({name: name, breed: breed})
    new_dog.save
    new_dog
    end
  def self.new_from_db(row)
    new_doggy = self.new(id: row[0], name: row[1], breed: row[2])

    new_doggy
  end
  def self.find_by_id(i)
      sql = <<-RANDY
      SELECT * FROM dogs WHERE id = ?
      RANDY
      dog = DB[:conn].execute(sql, i)[0]
      doggy = self.new_from_db(dog)

  end

  def self.find_or_create_by(arg)
    name = arg[:name]
    breed = arg[:breed]
    sql = <<-NEWNEW
    SELECT * FROM dogs WHERE name = ? AND breed = ?
    NEWNEW
    dog = DB[:conn].execute(sql, name, breed)

    if !(dog.count == 0)
      id = dog[0][0]
      self.find_by_id(id)
    else
      self.create(name: name, breed: breed)
  end
end
  def self.find_by_name(name)

    sql = <<-NEWNEW
    SELECT * FROM dogs WHERE name = ?
    NEWNEW
    dog = DB[:conn].execute(sql, name)[0]

    self.new_from_db(dog)
  end
end
