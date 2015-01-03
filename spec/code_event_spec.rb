

require 'code_event'

describe CodeEvent do

  it 'creates arbitrary accessors' do
     e = CodeEvent.new({ :x => "x", :y => "y"})
     e.x.should eq('x')
     e.y.should eq('y')
  end

  it 'parses class names' do
    CodeEvent.new({ :method_name => "X::index"}).class_name.should eq('X')
  end


end
