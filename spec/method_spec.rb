

require 'method'

describe Method do

  def with_source body, start_line, end_line
    DeltaFlora::Method.new('','', body, start_line, end_line)
  end


  it 'returns a simple body' do
    with_source("x", 0, 1).body.should eq('x')
  end

  it 'cuts trailer from source' do
    with_source("\n\nx", 2, 2).body.should eq('x')
  end

end

