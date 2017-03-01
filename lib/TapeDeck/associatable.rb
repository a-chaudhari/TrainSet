require_relative 'searchable'
require 'active_support/inflector'
require "byebug"
require_relative 'db_connection'
# require_relative '01_sql_object'
# require_relative 'relation'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key,
    :name
  )

  def model_class
    # debugger
    @class_name.constantize
  end

  def table_name
    # debugger
    @class_name.underscore.+"s"
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @name = name
    @class_name = options[:class_name] ||= name.to_s.camelcase.singularize
    @primary_key = options[:primary_key] ||= :id
    @foreign_key = options[:foreign_key] ||= (name.to_s.underscore+"_id").to_sym
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    # debugger
    @name = name
    @class_name = options[:class_name] ||= name.to_s.camelcase.singularize
    @primary_key = options[:primary_key] ||= :id
    @foreign_key = options[:foreign_key] ||= (self_class_name.to_s.underscore+"_id").to_sym
    # debugger
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})

    bt_options = BelongsToOptions.new(name, options)
    self.assoc_options[name] = bt_options
    define_method(name) do
      fk = send(bt_options.foreign_key)
      tmc = bt_options.model_class
      # debugger
      res = tmc.where(bt_options.primary_key => fk).first
    end

  end

  def has_many(name, options = {})
    # debugger
    hm_options = HasManyOptions.new(name, self.to_s, options)
    # debugger
    self.assoc_options[name] = hm_options
    define_method(name) do
      tmc = hm_options.model_class
      # debugger
      pk = send(hm_options.primary_key)
      # debugger
      res = tmc.where(hm_options.foreign_key => pk)
      # debugger
      res
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
    @assoc_options ||= {}
    @assoc_options
  end

  def has_one_through(name, through_name, source_name)
    # debugger
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      select_line = source_options.class_name.underscore.pluralize
      from_line = through_options.class_name.underscore.pluralize
      join_line = select_line
      # debugger
      on_line = (join_line + "." + source_options.primary_key.to_s +
                  " = " + through_options.class_name.to_s.underscore.pluralize +
                  "." + source_options.foreign_key.to_s)

      where_line = (through_options.class_name.to_s.underscore.pluralize +
                    "." + through_options.primary_key.to_s + "=" + self.send(through_options.foreign_key).to_s)
      # debugger
      res = DBConnection.execute(<<-SQL)
        SELECT
          #{select_line}.*
        FROM
          #{from_line}
        JOIN
          #{join_line}
        ON
          #{on_line}
        WHERE
          #{where_line}
      SQL
      # debugger
      source_options.model_class.new(res.first)
    end
  end
  def has_many_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]

      source_options = through_options.model_class.assoc_options[source_name]

      select_line = source_options.class_name.underscore.pluralize

      from_line = through_options.class_name.underscore.pluralize

      join_line = select_line

      on_line = (source_options.class_name.to_s.underscore.pluralize +
                  "." + source_options.foreign_key.to_s +
                  " = " + through_options.class_name.underscore.pluralize +
                  "." + through_options.primary_key.to_s)

      where_line = through_options.foreign_key.to_s + " = " + self.id.to_s
      res = DBConnection.execute(<<-SQL)
        SELECT
          #{select_line}.*
        FROM
          #{from_line}
        JOIN
          #{join_line}
        ON
          #{on_line}
        WHERE
          #{where_line}
      SQL

      res.map do |r|
        source_options.model_class.new(r)
      end
    end
  end

end

module Searchable
  def where(params)
    vars = []
    where_line = ""
    temp_arr = []

    params.each do |key,val|
      temp_arr << key.to_s + " = ?"
      vars << val
    end

    where_line = temp_arr.join(" AND ")


    res = DBConnection.execute(<<-SQL, *vars)
      SELECT
        #{self.table_name}.*
      FROM
        #{self.table_name}
      WHERE
        #{where_line}
    SQL
    res.map do |vars|
      self.new(vars)
    end
  end
end
