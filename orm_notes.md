InterActiveRecord!!!! 
require_relative "../config/environment.rb"
require 'active_support/inflector'
​
class InteractiveRecord
​
  def self.inherited(subclass)
    subclass.column_names.each {|c| attr_accessor c.to_sym}
    super
  end
​
  def self.table_name 
    ActiveSupport::Inflector.tableize(self.to_s)
  end
​
  def self.column_names
    sql = "PRAGMA table_info('#{table_name}');"
    DB[:conn].execute(sql).map {|c| c["name"] }
  end
​
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM #{table_name} WHERE name = ?
    SQL
    DB[:conn].execute(sql, name)
  end
​
  def self.find_by(attributes)
    conditions = attributes.keys.map{|k| "#{k.to_s} = ?" }.join(" AND ")
    sql = <<-SQL
      SELECT * FROM #{table_name} WHERE #{conditions}
    SQL
    DB[:conn].execute(sql, attributes.values)
  end
​
  def initialize(attributes = {})
    attributes.each do |attribute, value|
      self.send("#{attribute}=", value)
    end
  end
​
  def table_name_for_insert
    self.class.table_name
  end
​
  def col_names_for_insert
    self.class.column_names.delete_if{|c| c == "id"}.join(", ")
  end
​
  def values_for_insert 
    attributes = {}
    self.col_names_for_insert.split(', ').each do |attr|
      attributes[attr] = self.send(attr) if self.send(attr) #don't add key value pairs where attribute value is nil
    end
    attributes.values.map{|v| "'#{v}'"}.join(', ')
  end
​
  def save 
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})
    SQL
    DB[:conn].execute(sql)
    self.id = DB[:conn].execute("select last_insert_rowid() FROM students").first.values.first
    self
  end
end
Collapse









Message dakota, Patrick, Assan, Jen O'Hara


