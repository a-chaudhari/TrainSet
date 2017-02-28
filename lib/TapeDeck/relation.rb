class Relation

  attr_reader :select, :from, :where_hash
  def initialize(cls, select, from, where)
    @cls = cls
    @select = select
    @from = from
    @where_hash = where

  end


  def method_missing(name, *args, &prc)
    #oh noez. it wants data off of a relationship.
    #fire the query
    return self.where_append(*args) if name.to_s == "where"
    # debugger
    super unless ["each","map"].include?(name.to_s)
    # output = where_items.join(" AND ")


    vars = []
    where_line = ""
    temp_arr = []

    @where_hash.each do |key,val|
      temp_arr << key.to_s + " = ?"
      vars << val
    end

    where_line = temp_arr.join(" AND ")
    debugger
    res = DBConnection.execute(<<-SQL, *vars)
      SELECT
        #{@select}
      FROM
        #{@from}
      WHERE
        #{where_line}
    SQL
    items = res.map do |vars|
      @cls.constantize.new(vars)
    end

    items.each do |item|
      prc.call(item)
    end

  end

  def where_append(hash, *args)
    #append a where

      @where_hash.merge!(hash)

  end

end
