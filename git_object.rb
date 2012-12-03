

class GitObject
  def initialize path
    @path = path
  end

  def git_local
    "git --git-dir=#{@path}/.git"
  end

end
