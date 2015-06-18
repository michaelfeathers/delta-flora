
require './repository'
require './analytics'
require 'awesome_print'

def events_of repo_name
  load_events("/Users/michaelfeathers/Projects/data/" + repo_name)
end

