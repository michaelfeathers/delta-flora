

require 'git_object'

describe GitObject do

  it 'creates a git local command prefix' do
    GitObject.new('projects/boo').git_local.should eq("git --git-dir=projects/boo/.git")
  end

end
