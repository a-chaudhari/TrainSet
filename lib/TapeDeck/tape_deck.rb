require_relative 'db_connection'
require 'active_support/inflector'
require "byebug"
require_relative 'searchable'
# require_relative 'relation'
require_relative 'associatable'

# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class TapeDeck
  extend Associatable
  extend Searchable

  #silly legacy inflector rules workaround
  ActiveSupport::Inflector.inflections do |inflect|
    inflect.irregular 'human', 'humans'
  end

  def self.columns
    return @column_names unless @column_names.nil?

    result = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL
    @column_names = result.first.map do |cname|
      cname.to_sym
    end

    @column_names
  end

  def self.finalize!
    self.columns.each do |column_sym|
      define_method(column_sym) { send(:attributes)[column_sym] }
      define_method(column_sym.to_s+"=") { |var| send(:attributes)[column_sym]=var  }
    end

  end

  def self.table_name=(table_name)
      @table_name = table_name
  end

  def self.table_name
    @table_name  ||= self.name.tableize
  end

  def self.all
    res = DBConnection.execute(<<-SQL)
      SELECT
        #{self.table_name}.*
      FROM
        #{self.table_name}
    SQL

    self.parse_all(res)

  end

  def self.parse_all(results)
    results.map do |entry|
      self.new(entry)
    end

  end

  def self.find(id)
    res =  DBConnection.execute(<<-SQL, id)
      SELECT
        #{self.table_name}.*
      FROM
        #{self.table_name}
      WHERE
        #{self.table_name}.id = ?
    SQL

    return nil if res.empty?
    new res.first

  end

  def initialize(params = {})
    cols = self.class.columns
    params.each do |key, val|
      raise "unknown attribute \'#{key}\'" unless cols.include?(key.to_sym)

      send(key.to_s+"=",val)

    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map do |col|
      send(col)
    end
  end

  def insert
    column_names = "("
    question_marks = "("
    vars = []
    self.class.columns.each do |cname|
      next if cname == :id
      column_names += cname.to_s + ","
      question_marks += "?,"
      vars << send(cname)
    end
    column_names[-1]=")"
    question_marks[-1]=")"

    res = DBConnection.execute(<<-SQL, *vars)
    INSERT INTO
      #{self.class.table_name} #{column_names}
    VALUES
      #{question_marks}
    SQL

    self.id = DBConnection.last_insert_row_id

  end

  def update
    set_line = ""
    vars = []
    self.class.columns.each do |cname|
      next if cname == :id
      set_line += cname.to_s + " = ?,"
      vars << send(cname)
    end
    set_line[-1]=""
    vars << send(:id)
    # debugger
    res = DBConnection.execute(<<-SQL, *vars)
    UPDATE
      #{self.class.table_name}
    SET
      #{set_line}
    WHERE
      id = ?
    SQL
  end

  def save
    if valid?
      return (id.nil? ? insert : update)
    else
      return false
    end
  end

  def errors
    @errors ||= {}
  end


  def valid?
    true
  end
end
