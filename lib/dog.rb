class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:,breed:,id: nil) @name=name; @breed=breed; @id=id end

  def self.create_table
    DB[:conn].execute(<<~SQL
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    )
  end

  def self.drop_table() DB[:conn].execute('DROP TABLE IF EXISTS dogs') end

  def save
    self.update; return self if self.id
    DB[:conn].execute('INSERT INTO dogs(name,breed) VALUES(?,?)',self.name,self.breed)
    @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
    self
  end

  def self.create(name:, breed:)
    dog = self.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.new_from_db(row) self.new(id: row[0],name: row[1],breed: row[2]) end

  def self.find_by_name(name)
    self.db_query('SELECT * FROM dogs WHERE name = ? LIMIT 1', name)
  end

  def self.find_by_id(id)
    self.db_query('SELECT * FROM dogs WHERE id = ? LIMIT 1', id)
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute('SELECT * FROM dogs WHERE name=? AND breed=?',name,breed)
    dog = dog.empty? ? self.create(name: name,breed: breed) : self.new_from_db(dog[0])
  end

  def update
    DB[:conn].execute('UPDATE dogs SET name=?,breed=? WHERE id=?',self.name,self.breed,self.id)
  end

  def self.db_query(query, insert)
    DB[:conn].execute(query, insert).map { |row| self.new_from_db(row) }.first
  end

end
