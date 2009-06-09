class << ActiveRecord::Base
  def acts_as_accurate_float(column_name, accuracy)
    @column_name = column_name
    @accuracy = 10**accuracy
  end

  alias_method :original_find, :find
  def find(*args)
    if args[1] and args[1][:conditions]
      if args[1][:conditions].is_a?(Hash) and args[1][:conditions].include?(@column_name)
        column_value = args[1][:conditions].delete @column_name
        new_conditions = "round(#{@column_name}*#{@accuracy})/#{@accuracy} = #{column_value}"
        args[1][:conditions].map { |k,v| new_conditions << " and #{k} = #{v}" }
        args[1][:conditions] = new_conditions
      elsif
        args[1][:conditions].is_a?(String) and args[1][:conditions].include?(@column_name)
        match = args[1][:conditions].match(/#{@column_name}(\ )?=(\ )?([\d\.]+)/)
        args[1][:conditions].gsub!(/#{@column_name}(\ )?=(\ )?([\d\.]+)/,"round(#{@column_name}*#{@accuracy})/#{@accuracy} = #{match[3]}")
      end
    end
    original_find(*args)
  end
end
