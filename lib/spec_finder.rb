
# MCF needs support for do blocks in specs

require './method'

module DeltaFlora
  class SpecFinder
    attr_reader :methods, :src

    def self.show file_name
      finder = SpecFinder.new(File.read(file_name),file_name)
      finder.methods.each do |name, m|
        puts name
        puts "===="
        puts m.body
      end
      nil
    end

    def initialize src, file_name
      @src = src.split($/)
      @file_name = file_name
      @methods = {}
      parse
    end

    def numbered_lines
      (0...src.count).zip(src)
    end

    def significant_lines
      sig_regex = /^\s*(after|before|context|describe|end|it)(\W|$)/
      numbered_lines.select { |line| line[1] =~ sig_regex }
    end

    def scoped_lines
      start_regex = /^\s*(after|before|context|describe|it)\W/
      names = []
      significant_lines.map do |line_no,line_text|
        if line_text =~ start_regex
          names << line_text.scan(/^\s*(?:after|before|context|describe|it)\s*((?:(?:\w|:)|\".*\"|\'.*')+)/)[0][0]
        else
          names.pop
        end
        [names.clone || [""], [line_no, line_text]]
      end
    end

    def specs
      scoped_lines.each_cons(2).to_a.select {|line_a,_| line_a[1][1] =~ /^\s*it\W/ }
    end

    def parse
      specs.each do |line_a,line_b|
        name_array = line_a[0]
        name = spec_name(name_array)
        methods[name] = Method.new(name, @file_name, @src.join($/), line_a[1][0], line_b[1][0])
      end
    end

    def is_quote char_as_string
      return char_as_string[0] == "'" || char_as_string == '"'
    end

    def to_ident text
      text = text[1..-1] if is_quote(text[0])
      text = text[0..-2] if is_quote(text[-1])
      text = text.gsub(/"/,"")
      text = text.gsub(/'/,"")
      text = text.gsub(/,/,"")
      text
    end

    def spec_name name_segments
      return "" if name_segments.empty?
      (['SPEC'] << name_segments.map {|seg| to_ident(seg) }).join('::')
    end
  end
end



