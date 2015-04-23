
require './git_object'
require './commit'
require './code_event'
require './method_finder'
require './spec_finder'
require './writer_csv'
require './reader_csv'

def load_events path
  Repository.new(path).events
end


class Repository < GitObject

  def events
    return @events if @events
    if cache_good?
      @events = read_events(event_file)
    else
      @events = build_events
      write
    end
    @events
  end

  def commits
    @commits ||= `#{git_local} log --reverse --topo-order --no-merges --format='%H\t%cn\t%cd'`
                   .split($/) \
                   .map { |line| Commit.new(@path, *line.split("\t")) }
  end


private

  def cache_good?
    File.exist?(event_file) &&
      commits.count > 0 &&
      File.mtime(event_file) >= commits.last.date
  end

  def event_file
    @path + "/methodevents.csv"
  end

  def build_events
    return [] if commits.empty?

    new_events = []

    new_events << methods_for_commit(commits.first, commits.first).map {|_,m| new_event(m, commits.first, :added) }
    commit_count = commits.count
    current_commit = 1

    commits.each_cons(2) do |previous, current|
      $stderr.puts "Calculating commit #{current_commit} of #{commit_count}"
      current_commit += 1
      new_events << events_for_commit_range(previous, current)
    end
    new_events.flatten
   end

   def events_for_commit_range previous, current
     previous_methods = methods_for_commit(previous, current)
     current_methods = methods_for_commit(current, current)
     delta_of(previous_methods, current_methods, current)
   end

   def make_finder src, file_name
     return DeltaFlora::MethodFinder.new(src, file_name) unless file_name =~ /_spec/
     DeltaFlora::SpecFinder.new(src, file_name)
   end

   def methods_for_commit commit, files_commit
     commit_methods = {}
     files_commit.filenames.each do |filename|
       begin
         src = `#{git_local} show #{commit.sha1}:#{filename} 2> /dev/null`
         finder = make_finder(src, filename)
         finder.methods.each do |_,method|
           method.commit = commit
           commit_methods[method.name] = method
         end
       rescue Exception
       end
     end
     commit_methods
   end

   def delta_of previous_methods, current_methods, current_commit
     added_methods = current_methods.reject { |name,_| previous_methods.has_key? name }
     changed_methods = current_methods.select {|name,_| previous_methods.has_key?(name) \
                                         && current_methods[name].changed?(previous_methods[name]) }
     deleted_methods = previous_methods.reject {|name,_| current_methods.include?(name) }

     added_methods.map {|_,m| new_event(m, current_commit, :added) } \
       + changed_methods.map{ |_,m| new_event(m, current_commit, :changed) } \
       + deleted_methods.map { |_,m| new_event(m, current_commit, :deleted) }

   end

   def new_event method, commit, status
     CodeEvent.new(method_name: method.name,
                   status: status,
                   commit: commit.sha1,
                   committer: commit.committer,
                   date: commit.date,
                   file_name: method.file_name,
                   method_length: (status == :deleted ? 0 : method.body_length),
                   start_line: method.start_line,
                   end_line: method.end_line,
                   repo_path: @path)
   end

   def write
     write_events(@path + "/methodevents", ["method_name", "commit", "committer", "date", "file_name", "status", "start_line", "end_line", "repo_path"], events)
   end

end
