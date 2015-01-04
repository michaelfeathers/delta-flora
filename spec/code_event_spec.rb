

require 'code_event'

describe CodeEvent do

  it 'creates arbitrary accessors' do
     e = CodeEvent.new({ :x => "x", :y => "y"})
     e.x.should eq('x')
     e.y.should eq('y')
  end

  it 'handles method_name' do
    CodeEvent.new({ :method_name => "X::index"}).method_name.should eq('X::index')
  end

  it 'parses class names' do
    CodeEvent.new({ :method_name => "X::index"}).class_name.should eq('X')
  end

  it 'computes method length' do
    e = CodeEvent.new({ :start_line => 1, :end_line => 5})
    e.method_length.should eq(4)
  end


end
