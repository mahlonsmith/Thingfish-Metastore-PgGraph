# -*- encoding: utf-8 -*-
# stub: thingfish-metastore-pggraph 0.2.0.pre20161114143916 ruby lib

Gem::Specification.new do |s|
  s.name = "thingfish-metastore-pggraph"
  s.version = "0.2.0.pre20161114143916"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Michael Granger", "Mahlon E. Smith"]
  s.date = "2016-11-14"
  s.description = "This is a metadata storage plugin for the Thingfish digital asset\nmanager.  It provides persistent storage for uploaded data to a\nPostgreSQL table.\n\nIt is heavily based on the regular PG metastore, however it differs by\nstoring objects as nodes, and their relations as edges."
  s.email = ["ged@FaerieMUD.org", "mahlon@martini.nu"]
  s.extra_rdoc_files = ["History.md", "LICENSE.rdoc", "Manifest.txt", "README.md", "LICENSE.rdoc"]
  s.files = [".document", ".gems", ".simplecov", "ChangeLog", "History.md", "LICENSE.rdoc", "Manifest.txt", "README.md", "Rakefile", "data/thingfish-metastore-pggraph/migrations/20151102_initial.rb", "lib/thingfish/metastore/pggraph.rb", "lib/thingfish/metastore/pggraph/edge.rb", "lib/thingfish/metastore/pggraph/node.rb", "spec/spec_helper.rb", "spec/thingfish/metastore/pggraph_spec.rb", "thingfish-metastore-pggraph.gemspec"]
  s.homepage = "https://bitbucket.org/mahlon/thingfish-metastore-pggraph"
  s.licenses = ["BSD-3-Clause"]
  s.rdoc_options = ["-f", "fivefish", "-t", "Thingfish-Metastore-PgGraph"]
  s.required_ruby_version = Gem::Requirement.new(">= 2.3.0")
  s.rubygems_version = "2.5.1"
  s.summary = "This is a metadata storage plugin for the Thingfish digital asset manager"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<thingfish>, ["~> 0.5"])
      s.add_runtime_dependency(%q<loggability>, ["~> 0.11"])
      s.add_runtime_dependency(%q<configurability>, ["~> 2.2"])
      s.add_runtime_dependency(%q<sequel>, ["~> 4.35"])
      s.add_runtime_dependency(%q<pg>, ["~> 0.19"])
      s.add_development_dependency(%q<hoe-mercurial>, ["~> 1.4"])
      s.add_development_dependency(%q<hoe-highline>, ["~> 0.2"])
      s.add_development_dependency(%q<hoe-deveiate>, ["~> 0.8"])
      s.add_development_dependency(%q<rspec>, ["~> 3.0"])
      s.add_development_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_development_dependency(%q<hoe>, ["~> 3.15"])
    else
      s.add_dependency(%q<thingfish>, ["~> 0.5"])
      s.add_dependency(%q<loggability>, ["~> 0.11"])
      s.add_dependency(%q<configurability>, ["~> 2.2"])
      s.add_dependency(%q<sequel>, ["~> 4.35"])
      s.add_dependency(%q<pg>, ["~> 0.19"])
      s.add_dependency(%q<hoe-mercurial>, ["~> 1.4"])
      s.add_dependency(%q<hoe-highline>, ["~> 0.2"])
      s.add_dependency(%q<hoe-deveiate>, ["~> 0.8"])
      s.add_dependency(%q<rspec>, ["~> 3.0"])
      s.add_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_dependency(%q<hoe>, ["~> 3.15"])
    end
  else
    s.add_dependency(%q<thingfish>, ["~> 0.5"])
    s.add_dependency(%q<loggability>, ["~> 0.11"])
    s.add_dependency(%q<configurability>, ["~> 2.2"])
    s.add_dependency(%q<sequel>, ["~> 4.35"])
    s.add_dependency(%q<pg>, ["~> 0.19"])
    s.add_dependency(%q<hoe-mercurial>, ["~> 1.4"])
    s.add_dependency(%q<hoe-highline>, ["~> 0.2"])
    s.add_dependency(%q<hoe-deveiate>, ["~> 0.8"])
    s.add_dependency(%q<rspec>, ["~> 3.0"])
    s.add_dependency(%q<rdoc>, ["~> 4.0"])
    s.add_dependency(%q<hoe>, ["~> 3.15"])
  end
end
