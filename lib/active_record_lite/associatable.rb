require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

class AssocParams
  def other_class
    @other_class_name.constantize
  end

  def other_table_name
    other_class.table_name
  end
end

class BelongsToAssocParams < AssocParams
  attr_reader :primary_key, :foreign_key

  def initialize(name, params)
    @primary_key = params[:primary_key] || :id
    @foreign_key = params[:foreign_key] || "#{name}_id".to_sym
    @other_class_name = params[:class_name] || name.to_s.camelize
  end

  def type
    :belongs_to
  end
end

class HasManyAssocParams < AssocParams
  attr_reader :primary_key, :foreign_key

  def initialize(name, params, self_class)
    @primary_key = params[:primary_key] || :id
    @foreign_key = params[:foreign_key] || name.to_s.singularize.camelize.constantize.to_s.underscore.foreign_key
    @other_class_name = params[:class_name] || name.to_s.singularize.camelize
  end

  def type
    :has_many
  end
end

module Associatable
  def assoc_params   
    @assoc_params ||= {}
  end

  def belongs_to(name, params = {})
    aps = BelongsToAssocParams.new(name, params)
    assoc_params[name] = aps

    define_method(name) do
      
      value = send(aps.foreign_key)

      results = DBConnection.execute(<<-SQL, value)
        SELECT * 
          FROM #{aps.other_table_name}
         WHERE #{aps.other_table_name}.#{aps.primary_key} = ?
         LIMIT 1
      SQL

      aps.other_class.parse_all(results).first
    end
  end

  def has_many(name, params = {})
    aps = HasManyAssocParams.new(name, params, self.class)
    assoc_params[name] = aps   

    define_method(name) do
      value = self.send(aps.primary_key)

      results = DBConnection.execute(<<-SQL, value)
        SELECT * 
        FROM #{aps.other_table_name}
        WHERE #{aps.foreign_key} = ?
      SQL

      aps.other_class.parse_all(results)
    end
  end

  def has_one_through(name, through, source)
    define_method(name) do
      tps = self.class.assoc_params[through]
      sps = tps.other_class.assoc_params[source]
      value = self.send(tps.foreign_key)

      results = DBConnection.execute(<<-SQL, value)
        SELECT #{sps.other_table_name}.* 
          FROM #{sps.other_table_name} 
            JOIN #{tps.other_table_name} 
              ON #{sps.other_table_name}.#{sps.primary_key} =
                 #{tps.other_table_name}.#{sps.foreign_key}
        WHERE #{tps.other_table_name}.#{tps.primary_key} = ?
      SQL

      sps.other_class.parse_all(results).first
    end
  end
end