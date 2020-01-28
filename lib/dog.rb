class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

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
    DB[:conn].execute('INSERT INTO dogs (name, breed) VALUES (?, ?)', self.name, self.breed)
    @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
    self
  end

  def self.create(name:, breed:)
    dog = self.new(name: name, breed: breed)
    dog.save
    dog
  end

  def update
    DB[:conn].execute('UPDATE dogs SET name = ?, breed = ? WHERE id = ?', self.name, self.breed, self.id)
  end

end
