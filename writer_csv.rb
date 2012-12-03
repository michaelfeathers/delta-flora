
def write_events file_name, field_names, events
  header = field_names.join( ',') + "\n"
  rows = events.map { |e| field_names.map { |name| e.send(name).to_s  }.join(',') }.join($/)
  File.open(file_name + ".csv", 'w') { |f| f.write(header + rows) }
end
