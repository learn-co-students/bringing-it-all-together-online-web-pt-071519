require 'sqlite3'
require_relative '../lib/dog'
require 'pry'

DB = {:conn => SQLite3::Database.new("db/dogs.db")}
# DB[:conn].execute("DROP TABLE IF EXISTS('db/dogs.db')")