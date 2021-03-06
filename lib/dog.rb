class Dog
    attr_accessor :name, :breed, :id
    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL 
        CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
            SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE IF EXISTS dogs
            SQL
        DB[:conn].execute(sql)
    end

    def save
        if self.id
            self.update
        else
            sql = <<-SQL
                INSERT INTO dogs (name, breed) VALUES (?, ?)
                SQL
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def self.create(db)
        dog = Dog.new(db)
        dog.save
    end

    def self.new_from_db(db)
        id = db[0]
        name = db[1]
        breed = db[2]
        new_dog = Dog.new(id: id, name: name, breed: breed)
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT * 
        FROM dogs
        WHERE id = ?
        LIMIT 1
        SQL
        DB[:conn].execute(sql, id).map{|db| self.new_from_db(db)}.first
    end
    
    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * 
        FROM dogs
        WHERE name = ?
        LIMIT 1
        SQL
        DB[:conn].execute(sql, name).map{|db| self.new_from_db(db)}.first
    end

    def self.find_or_create_by(dogs)
        name = dogs[:name]
        breed = dogs[:breed]
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed).first
        if !dog.nil?
            dog = self.new_from_db(dog)
        else
            dog = self.create(dogs)
        end
        dog
    end

    def update
        sql = <<-SQL 
        UPDATE dogs 
        SET name = ?,
        breed = ?
        WHERE id = ?
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end
