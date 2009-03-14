`acts_as_solr` Rails plugin
======
This plugin adds full text search capabilities and many other nifty features from Apache's [Solr](http://lucene.apache.org/solr/) to any Rails model.
It was based on the first draft by Erik Hatcher.

Current Release
======
The current stable release is v0.9 and was released on 06-18-2007.

Changes
======
Please refer to the CHANGE_LOG

Installation
======

For Rails >= 2.1:

    script/plugin install git://github.com/mattmatt/acts_as_solr.git

For Rails < 2.1:

    cd vendor/plugins
    git clone git://github.com/mattmatt/acts_as_solr.git
    rm -rf acts_as_solr/.git

Make sure you copy `vendor/plugins/acts_as_solr/config/solr.yml` to your Rails
application's config directory, when you install via `git clone`.

Requirements
------
* Java Runtime Environment(JRE) 1.5 aka 5.0 [http://www.java.com/en/download/index.jsp](http://www.java.com/en/download/index.jsp)
* If you have libxml-ruby installed, make sure it's at least version 0.7

Configuration
======
Basically everything is configured to work out of the box. You can use `rake solr:start` and `rake solr:stop`
to start and stop the Solr web server (an embedded Jetty). If the default JVM options aren't suitable for
your environment, you can configure them in solr.yml with the option `jvm_options`. There is a default
set for the production environment to have some more memory available for the JVM than the defaults, but
feel free to change them to your liking.

Basic Usage
======
<pre><code>
# Just include the line below to any of your ActiveRecord models:
  acts_as_solr

# Or if you want, you can specify only the fields that should be indexed:
  acts_as_solr :fields => [:name, :author]

# Then to find instances of your model, just do:
  Model.find_by_solr(query) #query is a string representing your query

# Please see ActsAsSolr::ActsMethods for a complete info

</code></pre>


`acts_as_solr` in your tests
======
To test code that uses `acts_as_solr` you must start a Solr server for the test environment. You can do that with `rake solr:start RAILS_ENV=test`

However, if you would like to mock out Solr calls so that a Solr server is not needed (and your tests will run much faster), just add this to your `test_helper.rb` or similar:

<pre><code>
class ActsAsSolr::Post
  def self.execute(request)
    true
  end
end
</pre></code>

([via](http://www.subelsky.com/2007/10/actsassolr-capistranhttpwwwbloggercomim.html#c1646308013209805416))

Authors
======
Erik Hatcher: First draft<br>
Thiago Jackiw: Previous developer<br>
Luke Francl: Current developer<br>
Mathias Meyer: Current developer<br>

Release Information
======
Released under the MIT license.

More info
======
The old [acts_as_solr homepage](http://acts-as-solr.railsfreaks.com) is no more. For more up-to-date information, check out the project page of the current mainline on [GitHub](http://github.com/mattmatt/acts_as_solr/wikis).