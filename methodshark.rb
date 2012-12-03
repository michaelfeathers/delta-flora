

require './reader_csv'
require './code_event'


REPO_PATH = ARGV[0]
METHOD_NAME = ARGV[1]
IS_SHORT = ARGV[2] && ARGV[2] == "-s"

class CodeEvent
  def git_local
    "git --git-dir=#{REPO_PATH}/.git"
  end

  def method_body
    `#{git_local} show #{commit}:#{file_name}`.lines \
                                              .to_a[(start_line-1)..(end_line-1)] \
                                              .join
  end
end

class MethodShark
  attr_reader :events

  def initialize(path, method_name)
    @method_name = method_name
    @events = read_events(path + "/methodevents")
  end

  def selected_events
    events.select {|e| e.method_name == @method_name } \
          .reject {|e| e.status == :deleted }
  end

  def run_full
    selected_events.each do |e|
      puts "#{e.method_name} #{e.date.to_s} #{e.committer}\n\n#{e.method_body}\n"
    end
  end

  def run_short
     selected_events.each do |e|
       puts "%-5d #{e.method_name} #{e.date.to_s} #{e.committer}" % e.method_body.lines.count
     end
  end

end

shark = MethodShark.new(REPO_PATH, METHOD_NAME)
IS_SHORT ? shark.run_short : shark.run_full



