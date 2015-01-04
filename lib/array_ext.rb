
class Array
  def freq_by &block
    group_by(&block).map {|k,v| [k, v.count] }.sort_by(&:first)
  end

  def freq
    freq_by {|e| e }
  end

  def pairs
    map {|x,y| x < y ? [x,y] : [y,x] }
  end

  def ascends?
    each_cons(2).all? {|l,r| l < r }
  end

  def descends?
    each_cons(2).all? {|l,r| l > r }
  end

  def adjusted_to len
    return self[0, len] if len <= self.length
    self + ([0] * (len - self.length))
  end

  def derivative
    each_cons(2).map { |before, after| after.to_f - before.to_f }
  end

  def mean
    self.reduce(0.0, :+) / self.length.to_f
  end

  def sorted?
    each_cons(2).all? {|x,y| x <= y }
  end

  def column n
    map {|e| e[n] }
  end

  def second
    self[1]
  end

end

