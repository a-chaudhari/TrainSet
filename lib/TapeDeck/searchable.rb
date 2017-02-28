require_relative 'db_connection'
# require_relative 'sql_object'
require "byebug"

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

class SQLObject
  extend Searchable
  # Mixin Searchable here...
end
