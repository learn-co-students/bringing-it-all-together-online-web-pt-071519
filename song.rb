class Songs
  attr_accessor :name, :album, :length
  attr_reader :id

  def self.new_from_db(row)

    new_song = self.new
    new_song.id = row[0]
    new_song.name = row[1]
    new_song.length = row[2]
    new_song

  end

def self.find_or_create_by(name:, album:, length:)
  query_song = DB[:conn].execute("SELECT * FROM songs WHERE name = ? and album = ?;", name, album)
  if !song.empty?
    song_record = query_song[0]
    query_song = Song.new(song_record[0], song_record[1], song_record[2], song_record[3])
  else
    query_song = self.create(name: name, album: album, length: length)
  end
  query_song
end

  def self.all
    sql = <<-SQL
      SELECT * FROM songs
    SQL

    DB[:conn].execute(sql).map do |row|
      self.new_from_db(row)
    end
  end

  def self.find_one_by_name(name)
    sql = <<-SQL
      SELECT * FROM songs
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM songs WHERE name = ?"
    result = DB[:conn].execute(sql, name)[0]
    Song.new(result[0], result[1], result[2], result[3])

  end

  def self.create(name:, album:, length:)
    song = Song.new(name, album, length)
    song.save
    song
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS songs (
        id INTEGER PRIMARY KEY
        name TEXT
        album TEXT
        length INT
      )
    SQL

    DB[:conn].execute(sql)
  end


  def initialize(id=nil, name, album)
    @id = id
    @name = name
    @album = album
    @length = length
  end

  def save
    if self.id
      self.update
    else

      sql = <<-SQL
        INSERT INTO songs(name, album, length)
        VALUES (?, ?, ?)
      SQL

      DB[:conn].execute(sql.name, sql.album, sql.length)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM songs")[0][0]
    end
  end

  def update
    sql = <<-SQL
      UPDATE songs
      SET name = ?, album = ?, length = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.album, self.length, self.id)

  end


end

<<-NOTES
ninety_nine_problems = Song.create(name: "99 Problems", album: "The Blueprint")
 
Song.find_by_name("99 Problems")
# => #<Song:0x007f94f2c28ee8 @id=1, @name="99 Problems", @album="The Blueprint">

ninety_nine_problems = Song.find_by_name("99 Problems")
 
ninety_nine_problems.album
# => "The Blueprint"

ninety_nine_problems.album = "The Black Album"
 
ninety_nine_problems.album
# => "The Black Album"

UPDATE songs
SET album="The Black Album"
WHERE name="99 Problems";

sql = "UPDATE songs SET album = ? WHERE name = ?"
 
DB[:conn].execute(sql, ninety_nine_problems.album, ninety_nine_problems.name)
Song.create(name: "Hella", album: "25")

hello = Song.find_by_name("Hella")
 
sql = "UPDATE songs SET name='Hello' WHERE name = ?"
 
DB[:conn].execute(sql, hello.name)


NOTES