require_relative './db_connection'

module Searchable
  def all
    results = DBConnection.execute(<<-SQL)
      SELECT * 
      FROM #{table_name}
    SQL

    parse_all(results)
  end

  def find(id)
    result = DBConnection.execute(<<-SQL, id)
      SELECT * 
      FROM #{table_name}
      WHERE id = ?
    SQL

    self.new(result[0])
  end

  def where(params)
    # raise error if not included in attributes
    where = []
    values = []
    params.each do |col, value| 
      where << #{col} = ?
      values << value
    end

    where_string = where.join(" AND ")

    results = DBConnection.execute(<<-SQL, *values)
      SELECT * 
      FROM #{table_name}
      WHERE #{where_string}
    SQL

    parse_all(results)
  end
end