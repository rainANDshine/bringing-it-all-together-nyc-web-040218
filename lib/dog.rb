class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id=nil, attributes)
    @id = id
    attributes.each {|key, value| self.send("#{key}=", value)}
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT)
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
     if self.id != nil
       self.update
     else
       sql = <<-SQL
         INSERT INTO dogs(name, breed)
         VALUES (?, ?)
         SQL
       DB[:conn].execute(sql, self.name, self.breed)
       @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
     end
   end

  def self.create(name:, breed:)
    Dog.new(name, grade).save
  end

  def self.new_from_db(row)
    Dog.new(row[0], row[1], row[2])
  end

  def find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ? LIMIT 1
      SQL
    self.new_from_db(DB[:conn].execute(sql, id).first)
  end
    
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? LIMIT 1
      SQL
    self.new_from_db(DB[:conn].execute(sql, name).first)
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?, breed = ?
      SQL
    dog = DB[:conn].execute(sql, name, breed)

    if !dog.empty?
      dog.first
    else
      sql = <<-SQL
        INSERT INTO dogs(name, breed) VALUES (?, ?)
        SQL
      DB[:conn].execute(sql, name, breed)
      dog = Dog.new(name, breed)
      dog.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      dog
    end
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, grade = ?
      WHERE id = ?
      SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

   

  