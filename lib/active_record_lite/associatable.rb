require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

class AssocParams
  def other_class
  end

  def other_table
  end
end

class BelongsToAssocParams < AssocParams
  def initialize(name, params)
  end

  def type
  end
end

class HasManyAssocParams < AssocParams
  def initialize(name, params, self_class)
  end

  def type
  end
end

module Associatable
  def assoc_params
  end

  def belongs_to(name, params = {})
    # need to go back and set the defaults in case they are not passed

    defaults = {
      class_name: sdf,
      foreign_key: asdf,
      primary_key: asdf
    }
    params = defaults.merge(params)

    define_method(name) do
      other_class = params[:class_name].constantize
      other_table_name = other_class.table_name
      primary_key = params[:primary_key]
      # primary_key ||= :id
      foreign_key = params[:foreign_key]
      value = send(foreign_key)

      results = DBConnection.execute(<<-SQL, value)
        SELECT * 
        FROM #{other_table_name}
        WHERE #{primary_key} = ?
      SQL

      other_class.parse_all(results)
    end
  end

  def has_many(name, params = {})
    defaults = {
      class_name: sdf,
      foreign_key: asdf,
      primary_key: asdf
    }
    params = defaults.merge(params)

    define_method(name) do
      other_class = params[:class_name].constantize
      other_table_name = other_class.table_name
      primary_key = params[:primary_key]
      foreign_key = params[:foreign_key]
      value = self.send(primary_key)

      results = DBConnection.execute(<<-SQL, value)
        SELECT * 
        FROM #{other_table_name}
        WHERE #{foreign_key} = ?
      SQL

      other_class.parse_all(results)
    end
  end

  def has_one_through(name, assoc1, assoc2)
  end
end
