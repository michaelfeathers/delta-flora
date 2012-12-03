
require 'ripper'
require './method'

module DeltaFlora
  class MethodFinder < Ripper

    attr_reader :line_stack, :name_stack, :methods, :src

    def initialize src, file_name
      super
      @line_stack = []
      @name_stack = []
      @methods = {}
      @src     = src.split($/)
      @at_scope_start = false
      @file_name = file_name
      parse
    end

    def on_def name, *args
      start = line_stack.pop
      method_name = full_name(name)
      methods[method_name] =  Method.new(method_name, @file_name, src[(start - 1)..lineno].join($/), start, lineno)
    end

    def on_class name, *args
      name_stack.pop
    end

    def on_module name, *args
      name_stack.pop
    end

    def on_kw kw
      line_stack << lineno if kw == 'def'
      @at_scope_start = ['class', 'module'].include? kw
    end

    def full_name method_name
      (name_stack + [method_name]).join('::')
    end

    def on_const name
      name_stack << name if @at_scope_start
      @at_scope_start = false
    end
  end
end

