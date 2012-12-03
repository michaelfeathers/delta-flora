

module DeltaFlora
  class Method < Struct.new(:name, :file_name, :src, :start_line, :end_line)

    attr_accessor :commit

    def body
      src.lines.to_a[start_line..end_line].join($/)
    end

    def body_length
      full_length = end_line - start_line +  1
      return full_length - 2 if full_length >= 3
      return 1
    end

    def changed? other_method
      return true if body_length != other_method.body_length
      return true if normalized(src) != normalized(other_method.src)
      false
    end

    private

    def normalized string
      string.gsub(/\s+/,' ')
    end
  end

end
