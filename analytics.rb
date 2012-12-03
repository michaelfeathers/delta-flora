
require 'time'
require 'date'

def month_from_date date
  [date.year, date.month].to_s
end

def week_from_date date
  "\"w #{Date.parse(date.to_s).cweek}/#{date.year}\""
end

class Time
  def to_date
    Date.parse(self.to_s)
  end

  def month_start
    Time.new(year.to_i, month.to_i)
  end
end

class Array
  def freq_by &block
    group_by(&block).map {|k,v| [k, v.count] }.sort_by {|f,_| f }
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

  def column n
    map {|e| e[n] }
  end

 def second
   self[1]
 end

end

class Hash
  def hmap &block
    Hash[map &block]
  end

end


# :: String -> [String] -> [[String]] -> None
def write_rows file_name, names, values
  header = names.join(',') + "\n"
  body = values.map {|row| row.join(',') }.join($/)
  File.open(file_name + ".csv", 'w') { |f| f.write(header + body) }
end

# :: [event] -> [event]
def method_events events
  events - spec_events(events)
end

# :: [event] -> [event]
def spec_events events
  events.select {|e| e.method_name =~ /SPEC/ }
end

# :: [event] -> [String, Int, Int]
def ownership_effect events
  events.group_by(&:method_name).map do |method_name, method_events|
    [method_name,
      method_events.map(&:committer).uniq.count,
      method_events.map(&:method_length).max]
  end
end

# :: ([event] -> Int)
def same_committer
  lambda do |es|
    es.each_cons(2)
      .count {|b,a| a.method_length < b.method_length && a.committer != b.committer }
  end
end

# :: ([event] -> Int)
def different_committers
  lambda do |es|
    es.each_cons(2)
      .count {|b,a| a.method_length < b.method_length && a.committer == b.committer }
  end
end


# :: [event] -> ([event] -> Int) -> Float
def count_changes events, change_counter
  method_events(events).select {|e| e.status != :deleted }
                       .group_by(&:method_name)
                       .map {|_,es| change_counter.call(es) }
                       .reduce(0.0, :+)
end

# :: [event] -> [String, Float, Int]
def reductions_by_commit events
  events.group_by(&:method_name).map do |name, method_events|
    [name, percent_reduction(method_events), method_events.count]
  end
end

# :: [event] -> Float
def percent_reduction method_events
  non_deleted = method_events.select {|e| e.status != :deleted }
  return 0.0 if non_deleted.count == 0
  num_reductions = non_deleted.each_cons(2)
                              .count {|before, after| after.method_length < before.method_length }
  num_reductions / non_deleted.count.to_f
end

# :: [event] -> [Int]
def refactoring_reduction_profile events
  events.group_by(&:method_name)
        .map {|_,e| percent_reduction(e) }
        .freq_by {|e| (e * 100 / 10).to_i  }
end

# :: [event] -> { commit => [event] }
def commits_with_specs_and_code events
  events.group_by(&:commit).select do |commit,es|
    es.select {|e| e.file_name =~ /_spec/ }.count > 0 && es.reject {|e| e.file_name =~ /_spec/ }.count > 0
  end
end

# :: [event] -> status -> Int
def spec_count events, status = :all
  return spec_events(events).count if status == :all
  spec_events(events).select {|e| e.status == status }.count
end

# :: [event] -> status -> Int
def method_count events, status = :all
  return method_events(events).count if status == :all
  method_events(events).select {|e| e.status == status }.count
end

# :: [event] -> [Float, String]
def spec_to_method_ratios events
  events.group_by(&:committer).map do |committer,es|
      [spec_count(es).to_f / es.count, committer]
  end
end

# :: [event] -> [String, Int, Int]
def turbulence events
  events.group_by(&:method_name)
        .map {|class_name,es| [class_name, es.count, es.map(&:method_length).last || 0] }
end

# :: [event] -> [Float]
def spec_to_method_ratios_by_commit events
  events.group_by(&:commit) \
        .map {|_,es| spec_count(es).to_f / es.count }
end

# :: [event] -> [Float]
def spec_to_method_ratios_by_month events
  events.group_by {|e| month_from_date(e.date) }
        .map {|_,es| spec_count(es).to_f / es.count }
end

# :: [event] -> [String, Float]
def spec_percent_by_week events
  events.group_by {|e| week_from_date(e.date) }
        .map {|week,es| [week, spec_count(es).to_f / es.count] }
end

# :: [event] -> [String, Int, Int]
def methods_and_specs_added_by_week events
  events.select {|e| e.status == :added }
        .group_by {|e| week_from_date(e.date) }
        .map {|week,es| [week, method_count(es), spec_count(es)] }
end

# :: [event] -> [String, Int, Int]
def methods_and_specs_changed_by_week events
  events.select {|e| e.status == :changed }
        .group_by {|e| week_from_date(e.date) }
        .map {|week,es| [week, method_count(es), spec_count(es)] }
end

# :: [event] -> [String, Int, Int]
def methods_and_specs_deleted_by_week events
  events.select {|e| e.status == :deleted }
        .group_by {|e| week_from_date(e.date) }
        .map {|week,es| [week, method_count(es), spec_count(es)] }
end

# :: [event] -> [String, Int, Int, Int]
def methods_profile events
  events.group_by {|e| week_from_date(e.date) }
        .map {|week,es| [week, method_count(es, :added), method_count(es, :changed), method_count(es, :deleted)] }
end

# :: [event] -> Int
def c_count events
  events.map(&:committer).uniq.count
end

# :: [event] -> [String, Float, Float, Float]
def methods_profile_norm_committer events
  events.group_by {|e| week_from_date(e.date) }
        .map {|week,es| [week, method_count(es, :added) / c_count(es).to_f, method_count(es, :changed) / c_count(es).to_f, method_count(es, :deleted) / c_count(es).to_f] }
end

# :: [String] -> [event] -> None
def life_lines method_names, events
  method_groups = events.group_by(&:method_name)
  values = method_names.map { |name| method_groups[name].map(&:method_length) }
  max = values.map(&:count).max
  chart(method_names, values.map {|v| v.adjusted_to(max) }.transpose)
end

# :: [date,int]
def lines_added_per_commit events
  events.group_by(&:commit).map {|_, es| [es.first.date, es.map(&:method_length).reduce(:+)] }
end

# :: [event] -> [Float]
def avg_lines_per_commit_by_month events
  cls_by_month = lines_added_per_commit(events).group_by {|date,_| month_from_date(date) }
  cls_by_month.map {|_,cls| cls.map {|cl| cl[1]}.mean }.flatten
end

# :: [event] -> [Float]
def avg_lines_per_commit_by_week events
  cls_by_month = lines_added_per_commit(events).group_by {|date,_| week_from_date(date) }
  cls_by_month.map {|_,cls| cls.map {|cl| cl[1]}.mean }.flatten
end

# :: [event] -> [days]
def commit_time_line events
  events.map(&:date).uniq.sort.each_cons(2).map {|before,after| [before, (after.to_i - before.to_i) / (60 * 60 * 24)] }
end

# :: [event] -> [date, date]
def event_range events
  [events.map(&:date).min.to_date, events.map(&:date).max.to_date]
end

# :: String -> [event] -> [Int, Int]
def class_volume class_name, events
  class_events = method_events(events).select { |e| e.class_name == class_name }
  method_count = class_events.map(&:method_name).uniq.count
  [method_count, class_events.count ]
end

# :: [event] -> { symbol => Int, symbol => Int, symbol => Float }
def adds_to_changes events
  adds = events.select {|e| e.status == :added }.count
  changes =  events.select {|e| e.status == :changed }.count
  { :adds => adds, :changes => changes, :ratio => (adds/changes.to_f) }
end

# :: [String] -> [event] -> None
def life_lines_tt method_names, events
  method_groups = events.group_by(&:method_name)
  values = method_names.map {|name| spread(method_groups[name], event_range(events)) }
  chart(method_names, values.transpose)
end

# :: String -> [event] -> None
def chart_life_lines class_name, events
  es = method_events(events).select {|e| e.class_name == class_name }
  names = es.map(&:method_name).uniq
  life_lines_tt names, es
end

# :: [event] -> None
def chart_turbulence events
  chart(['method name','commits','complexity'], turbulence(events))
end

# :: String -> [event] -> None
def chart_complexity_tolerance committer, events
  chart_turbulence(events.select {|e| e.committer == committer })
end

# :: String -> String
def dir_name string
  string.split('/')[0..-2].join('/')
end

# :: [event] -> [String]
def event_folders events
  events.group_by {|e| dir_name(e.file_name) }.keys.sort.uniq
end

# :: [event] -> [String]
def trending_methods events
  method_events(events).select {|e| e.status == :changed }
                       .group_by {|e| month_from_date(e.date) }
                       .to_a
                       .last[1]
                       .freq_by(&:method_name)
                       .sort_by {|_,count| -count }
                       .take(10)
end

# :: [event] -> Enumerator(event)
def methods_by events
  events.group_by(&:method_name).select {|_,es| yield(es) }
end

# :: [event] -> Int -> [String]
def methods_ascending_last_n events, n
  methods_by(method_events(events)) do |es|
    es.count >= n && es.last(n).map(&:method_length).ascends?
  end.keys
end

# :: [event] -> [String, Int]
def temporal_correlation_of_classes events
  events.group_by {|e| [e.day,e.committer]}
        .values
        .map {|e| e.map(&:class_name).uniq.combination(2).to_a }
        .flatten(1)
        .pairs
        .freq_by {|e| e }
        .sort_by {|p| p[1] }
end

# :: [event] -> { String => date }
def classes_by_closure events
  class_names = method_events(events).map(&:class_name).uniq
  classes = Hash[class_names.zip([Time.now] * class_names.length)]
  method_events(events).each {|e| classes[e.class_name] = e.date }
  classes.to_a.sort_by {|_,date| date }
end

# :: [event] -> { String => date }
def classes_by_addition_date events
  class_names = method_events(events).map(&:class_name).uniq
  classes = Hash[class_names.zip([Time.now] * class_names.length)]
  method_events(events).reverse.each {|e| classes[e.class_name] = e.date }
  classes.to_a.sort_by {|_,date| date }
end

# :: [event] -> { date => Int }
def classes_added_by_month events
  classes_by_addition_date(events).group_by {|_,date| date.month_start }
                                  .hmap {|date,es| [date, es.map(&:first).uniq.count] }
end

# :: [event] -> { date => Int }
def classes_closed_by_month events
  classes_by_closure(events).group_by {|_,date| date.month_start }
                            .hmap {|date,es| [date, es.map(&:first).uniq.count] }
end

# :: { a => b } -> { a => b } -> b -> { a => [b, b] }
def zip_hash hash_a, hash_b, missing_element = nil
  all_keys = (hash_a.keys + hash_b.keys).uniq
  result = {}
  all_keys.each do |key|
    result[key] = [hash_a[key] || missing_element, hash_b[key] || missing_element]
  end
  result
end

# :: [event] -> { date -> [Int, Int] }
def classes_lifetime events
  added = classes_added_by_month(events)
  closed = classes_closed_by_month(events)
  zip_hash(added, closed, 0)
end


# :: [event] -> [Int]
def active_classes_by_month events
  event_list = method_events(events)
  event_list.group_by {|e|  month_from_date(e.date) }
            .map {|_, es| es.map {|e| e.class_name }.uniq.count }
end

# :: [event] -> Float
def reduction_multiple events
  event_list = method_events(events)
  event_list.group_by {|e| e.method_name }
            .select {|_,es| es.map(&:committer).uniq.count != 1 }
            .map {|n,es| percent_reduction(es) }
            .mean
end

# :: [event] -> Float
def reduction_single events
  event_list = method_events(events)
  event_list.group_by {|e| e.method_name }
            .select {|_,es| es.map(&:committer).uniq.count == 1 }
            .map {|n,es| percent_reduction(es) }
            .mean
end


# :: [event] -> [Int]
def freq_intercommit_durations events
  events.map(&:date).sort
                    .uniq
                    .each_cons(2)
                    .map {|before,after| (after.to_i - before.to_i) / 60 }
                    .freq_by { |e| e / 5}
                    .select {|e| e[0] <= 12 * 8 }
end

# :: String -> [event] -> None
def write_code_events file_name, events
  write_events(file_name,["commit","committer","status","date","file_name","method_name","method_length"], events)
end

# :: [String] -> * -> None
def chart names, values
  normalized_values = values
  normalized_values = values.map {|v| [v] } if (values.count > 0 && (not values[0].is_a?(Array)))
  write_rows('temp', names, normalized_values)
  `open temp.csv`
end

