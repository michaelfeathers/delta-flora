# delta-flora


## DESCRIPTION

Delta-flora is set of classes and functions which enable interactive analysis
of Ruby code histories in an interactive Ruby shell.

It consists of a class named Repository which builds up an intermediate
representation of all of the histories of all Ruby class and method changes
in a git repo.

Here is an example use of delta-flora in irb:

```ruby
  2.0.0p0 :001 > load 'repository.rb'
  2.0.0p0 :002 > es = Repository.new('/Users/joe-shmoe/Projects/rails').events
```

The value held in es after this call is an array of `method events'. Each method
event describes an occurrence in the lifetime of a method. There are three types
of method event: added, changed, deleted. Regardless of their type, each event
contains the following information:


field | description
------|------------
type | added, changed, or deleted
commit | sha1 of the git commit for the code change
date | date of the commit
file_name | name of the file containing the method
committer | author of the commit
class_name | name of the class containing the method
method_name | name of the method (fully-qualified by class and module name)
start_line | start line of the method at that commit
end_line | end line of the method at that commit


The file analytics.rb contains a set of functions that can be used to
analyze histories. Here is function which produces a frequency histogram
of the classes by the number of methods they contain:

```ruby
  def class_method_count_freq es
    es.group_by(&:class_name)
      .map {|_,v| v.map(&:method_name).uniq.count }
      .freq
  end
```

The method takes the list of method events and groups them into bins by the names
of the classes they reside upon. It then takes the names of all of the methods
that have existed over the history of that class and counts them. Afterward, it
uses an array extension method named 'freq' to produce frequencies of those counts.

Let's do that analysis:

``ruby
2.0.0p0 :003 > load 'analytics.rb'
2.0.0p0 :004 > class_method_count_freq(es)
```

Here are the results for Rails at the time of this writing. The format for
the histogram is bin-number followed by frequency:

```ruby
 => [[1, 1393], [2, 937], [3, 576], [4, 442], [5, 371], [6, 253], [7, 208], [8, 176], [9, 149], [10, 115], [11, 101], [12, 86], [13, 84], [14, 74], [15, 51], [16, 42], [17, 43], [18, 51], [19, 37], [20, 35], [21, 40], [22, 24], [23, 24], [24, 17], [25, 20], [26, 20], [27, 19], [28, 18], [29, 13], [30, 17], [31, 15], [32, 20], [33, 18], [34, 10], [35, 12], [36, 7], [37, 7], [38, 14], [39, 12], [40, 10], [41, 9], [42, 4], [43, 4], [44, 5], [45, 11], [46, 1], [47, 7], [48, 6], [49, 4], [50, 3], [51, 4], [52, 5], [53, 3], [54, 5], [55, 4], [56, 4], [57, 6], [58, 6], [59, 4], [60, 2], [61, 4], [62, 1], [63, 1], [64, 2], [67, 3], [68, 1], [71, 3], [72, 1], [73, 2], [74, 3], [75, 2], [76, 1], [78, 1], [79, 1], [80, 2], [81, 1], [82, 2], [83, 3], [84, 2], [87, 3], [88, 2], [90, 2], [91, 1], [92, 3], [94, 1], [95, 1], [96, 1], [98, 2], [101, 2], [103, 1], [105, 1], [109, 1], [111, 2], [112, 3], [115, 2], [116, 2], [117, 1], [118, 1], [119, 1], [122, 1], [125, 1], [129, 2], [131, 1], [132, 1], [135, 1], [137, 1], [138, 1], [139, 1], [144, 1], [146, 1], [155, 1], [156, 1], [166, 1], [181, 1], [192, 2], [196, 1], [199, 1], [208, 1], [210, 1], [235, 1], [253, 1], [268, 1], [311, 1], [342, 1], [410, 1]]
```

Method events are created from the repository using the --topo-order flag
on git log. This ordering puts branches one after another rather than using strict
date ordering. This allows us to do simple analyses like seeing how method lengths
have changed over time without the complications that we would have with strict
date ordering. Although branch information is disgarded in this 'linear' history,
you can expect 'runs' of events within branches to be date ordered.


# USAGE:

Use of delta-flora is easy. The steps in the description should get you
started. But, it's important to note that the first time you run
delta-flora on a repo it takes considerable amount of time rip the repo and
produce method events.

To make use easier, the Repository class has been designe to check for
a file named methodevents.csv in the repository directory. If it exists
and there are no commits with a later datestamp in the repo, then
methodevents.csv is assumed to be current and it is loaded. If
methodevents.csv does not exist or it is out of date, Repository rips the
repo and produces a methodevents.csv file.

Since 'es = Repository.new('some repostory path').events is a bit of a mouthful,
delta-flora supplies a convenience method that has the same effect:

```ruby
  es = load_events('some repository path')
```

# NAMING:

`Delta Flora' is the name of an album by Hughscore - a group formed by the late
Hugh Hopper of Soft Machine. The name struck me because it literally means the
flowering/bountiful mouth of a river. That seemed like a good name for a tool
that produces useful information from repositories. Aside from that, the pun
on the word `delta' with regard to version control systems was too good to
pass up.


# REQUIREMENTS:

* Ruby 2.0

# LICENSE:

(The MIT License)

Copyright(c) 2015-2020 Michael Feathers

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

