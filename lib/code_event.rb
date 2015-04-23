
require 'ripper'

class CodeEvent

  def initialize(hash = {})
    hash.each_pair do |attr,value|
      define_attribute(attr)
      self.send(writer_for(attr), value)
    end
  end

  def method_body
    return "" if status == :deleted
    @src ||= `#{git_local} show #{commit}:#{file_name}`.lines
                                                       .to_a[(start_line-1)..(end_line-1)]
                                                       .join
  end

  def method_tokens
    Ripper.tokenize(method_body)
  end

  def method_score tokens
    (method_tokens.uniq & tokens).count
  end

  def method_complexity
    method_score(["if","else","elsif","unless"])
  end

  def method_functional_score
    method_score(Enumerable.public_instance_methods.map(&:to_s))
  end

  def class_name
    segments = method_name.split('::')
    return segments[0..-2].join('::') if segments.count >= 2
    "Object"
  end

  def day
    [date.year, date.month, date.day].to_s
  end

  def method_length
    end_line - start_line
  end


  def inspect
    to_s
  end

  def to_s
    commit + " " + status.to_s + " " + date.to_s + " " + file_name + " " + method_name + ": " + method_length.to_s + " " + start_line.to_s + " " + end_line.to_s
  end

private
  def git_local
    "git --git-dir=#{repo_path}/.git"
  end

 def define_attribute(attr)
    singleton_class.send(:public)
    singleton_class.send(:attr_accessor, attr)
  end

  def singleton_class
    class << self; self; end
  end

  def reader_for(sym)
    sym.to_s.end_with?('=') ? sym.to_s.chop.to_sym : sym
  end

  def writer_for(sym)
    (sym.to_s + "=").to_sym
  end

  def method_missing(sym, *args, &block)
    if sym.to_s.end_with?('=')
      define_attribute(reader_for(sym))
      self.send(sym,*args)
    elsif args.count == 0
      return nil
    else
      super
    end
  end

end

