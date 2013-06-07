require_relative './associatable'
require_relative './db_connection'
require_relative './mass_object'
require_relative './searchable'

class SQLObject < MassObject
  extend Searchable
  extend Associatable

  def self.set_table_name(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name
  end

  def save
    id ? update : create
  end

  def attribute_values
    self.class.attributes.map do |attr_name|
      send(attr_name)
      # value unless value.nil?
    end
  end

  private
  def create
    attributes = attribute_values

    col_names = self.class.attributes.join(", ")
    value_count = attributes.count 
    q_marks = (['?'] * value_count).join(", ")

    DBConnection.execute(<<-SQL, *attributes)
      INSERT INTO #{self.class.table_name} (#{col_names})
      VALUES (#{q_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
    self
  end

  def update
    attributes = attribute_values

    set_line = self.class.attributes.map { |attr_name| "#{attr_name} = ?" }
    set_line = set_line.join(", ")

    query = <<-SQL
      UPDATE #{self.class.table_name}
      SET #{set_line}
      WHERE id = #{self.id}
    SQL

    DBConnection.execute(query, *attributes)

    self
  end
end
