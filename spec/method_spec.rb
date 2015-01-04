

require 'method'

describe Method do

  def with_source body, start_line, end_line
    DeltaFlora::Method.new('','', body, start_line, end_line)
  end


  it 'returns a simple body' do
    with_source("x", 0, 1).body.should eq('x')
  end

  it 'cuts leader from source' do
    with_source("\n\nx", 2, 2).body.should eq('x')
  end

  it 'cuts trailer from source' do
    with_source("\n\nx\n\n\n", 2, 2).body.should eq("x\n")
  end

  it 'calculates body length of 1' do
    with_source("", 2, 2).body_length.should eq(1)
  end

  it 'calculates body length of 2' do
    with_source("", 2, 3).body_length.should eq(1)
  end

  it 'calculates body length of 3' do
    with_source("", 2, 4).body_length.should eq(1)
  end

  it 'detects no change on equivalent text' do
    with_source("this and that", 0, 0)
      .changed?(with_source("this and that", 0, 0))
      .should be_false
  end

  # should this return changed on witespace change?
  # original idea was to do length check in body
  # as a optimzation
  it 'detects change on different sized text' do
    with_source("this and that", 0, 0)
      .changed?(with_source(" this and that", 0, 0))
      .should be_true
  end

  it 'detects no change when only whitespace is different'  do
    with_source("this and  that", 0, 0)
      .changed?(with_source("this and that", 0, 0))
      .should be_false
  end



end

