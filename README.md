# Delta Flora

## DESCRIPTION

Delta-flora is set of classes and functions which enable interactive analysis
of Ruby code histories in an interactive Ruby shell.

The primary class is named *Repository*. It builds a representation of the history
of all Ruby method changes in a repository. These changes are called *events*. 
You can access them in irb like this:

```ruby
  2.0.0p0 :001 > load 'repository.rb'
  2.0.0p0 :002 > es = Repository.new('/Users/joe-shmoe/Projects/rails').events
```

Each event describes the state of a method at a particular point in time. There 
are three types of event: *added*, *changed*, and *deleted*. 

Regardless of type, each event contains the following information:


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


The file *analytics.rb* contains a set of functions that can be used to
analyze histories. Here is function which produces a frequency histogram
of the classes by the number of methods they contain:

```ruby
  def class_method_count_freq es
    es.group_by(&:class_name)
      .map {|_,v| v.map(&:method_name).uniq.count }
      .freq
  end
```

Let's do that analysis:

```ruby
2.0.0p0 :003 > load 'analytics.rb'
2.0.0p0 :004 > class_method_count_freq(es)
```

```ruby
 => [[1, 1393], [2, 937], [3, 576], [4, 442], [5, 371], [6, 253], [7, 208], [8, 176] .. ]
```

Events are created from the repository using the *--topo-order* flag
on *git log*. This ordering puts branches one after another rather than using strict
date ordering. This allows us to do simple analyses like seeing how method lengths
have changed over time without the complications that we would have with strict
date ordering. Although branch information is disgarded in this *linear* history,
you can expect runs of events within branches to be date ordered.


## USAGE

Use of delta-flora is easy. The steps in the description should get you
started. But, it's important to note that the first time you run
delta-flora on a repo it takes considerable amount of time rip the repo and
produce method events.

To make use easier, the *Repository* class has been designed to check for
a file named *methodevents.csv* in the repository directory. If it exists
and there are no commits with a later datestamp in the repo, then
*methodevents.csv* is assumed to be current and it is loaded. If
*methodevents.csv* does not exist or it is out of date, *Repository* rips the
repo and produces a *methodevents.csv* file.


The phrase *es = Repository.new('some repostory path').events* is a bit verbose, so
delta-flora supplies a convenience method that has the same effect:

```ruby
  es = load_events('some repository path')
```

## NAMING

*Delta Flora* is the name of an album by Hughscore: a group formed by the late
[Hugh Hopper](https://en.wikipedia.org/wiki/Hugh_Hopper) of [Soft Machine](https://en.wikipedia.org/wiki/Soft_Machine). I chose the name because its literal meaning is *the
flowering/bountiful mouth of a river*. It seemed like a good name for a tool
that produces useful information from repositories. Aside from that, the pun
on the word *delta* with regard to version control systems was too good to
pass up.


## REQUIREMENTS

* Ruby 2.6 or greater

## LICENSE

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

