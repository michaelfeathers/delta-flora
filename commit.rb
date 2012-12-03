
require 'time'
require './git_object'

class Commit < GitObject
  attr_reader :sha1, :committer, :date

  def initialize path, sha1, committer, date
    super(path)
    @sha1 = sha1
    @committer = committer
    @date = Time.parse date
  end

  def filenames
    @filenames ||= `#{git_local} show #{@sha1} --name-only --oneline`
                       .split($/) \
                       .drop(1) \
                       .select {|filename| filename =~ /\.rb$/ }
  end

end
