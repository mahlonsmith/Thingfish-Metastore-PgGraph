#!/usr/bin/env rake
# vim: set nosta noet ts=4 sw=4:

require 'pathname'

PROJECT = 'thingfish-metastore-pggraph'
BASEDIR = Pathname.new( __FILE__ ).expand_path.dirname.relative_path_from( Pathname.getwd )
LIBDIR  = BASEDIR + 'lib'
LIBFILE = LIBDIR + ( PROJECT.gsub( '-', '/' ) + '.rb' )

if Rake.application.options.trace
    $trace = true
    $stderr.puts '$trace is enabled'
end

# parse the current library version
$version = LIBFILE.read.split(/\n/).
	select{|line| line =~ /VERSION =/}.first.match(/([\d|.]+)/)[1]

task :default => [ :spec, :docs, :package ]


########################################################################
### P A C K A G I N G
########################################################################

require 'rubygems'
require 'rubygems/package_task'
spec = Gem::Specification.new do |s|
	s.email        = 'mahlon@martini.nu'
	s.homepage     = 'https://bitbucket.org/mahlon/thingfish-metastore-pggraph'
	s.authors      = [ 'Mahlon E. Smith <mahlon@martini.nu>', 'Michael Granger <ged@faeriemud.org>' ]
	s.platform     = Gem::Platform::RUBY
	s.summary      = "Graph DDL storage for Thingfish metadata."
	s.name         = PROJECT
	s.version      = $version
	s.license      = 'BSD-3-Clause'
	s.has_rdoc     = true
	s.require_path = 'lib'
	s.bindir       = 'bin'
	s.files        = File.read( __FILE__ ).split( /^__END__/, 2 ).last.split
	# s.executables  = %w[]
	s.description  = <<-EOF
This is a metadata storage plugin for the Thingfish digital asset
manager.  It provides persistent storage for uploaded data to PostgreSQL
tables.

It is heavily based on the regular PG metastore, however it differs by
storing objects as nodes, and their relations as edges.
	EOF
	s.required_ruby_version = '>= 2.3'

	s.add_dependency 'thingfish', '~> 0.5'
	s.add_dependency 'loggability', '~> 0.11'
	s.add_dependency 'configurability', '~> 2.2'
	s.add_dependency 'sequel', '~> 4.35'
	s.add_dependency 'pg', '~> 0.19'
end

Gem::PackageTask.new( spec ) do |pkg|
	pkg.need_zip = true
	pkg.need_tar = true
end


########################################################################
### D O C U M E N T A T I O N
########################################################################

begin
	require 'rdoc/task'

	desc 'Generate rdoc documentation'
	RDoc::Task.new do |rdoc|
		rdoc.name       = :docs
		rdoc.rdoc_dir   = 'docs'
		rdoc.main       = "README.md"
		rdoc.rdoc_files = [ 'lib', *FileList['*.md'] ]

		if File.directory?( '.hg' )
			rdoc.options    = [ '-f', 'fivefish' ]
		end
	end

	RDoc::Task.new do |rdoc|
		rdoc.name       = :doc_coverage
		rdoc.options    = [ '-C1' ]
	end

rescue LoadError
	$stderr.puts "Omitting 'docs' tasks, rdoc doesn't seem to be installed."
end


########################################################################
### T E S T I N G
########################################################################

begin
    require 'rspec/core/rake_task'
    task :test => :spec

    desc "Run specs"
    RSpec::Core::RakeTask.new do |t|
        t.pattern = "spec/**/*_spec.rb"
    end

    desc "Build a coverage report"
    task :coverage do
        ENV[ 'COVERAGE' ] = "yep"
        Rake::Task[ :spec ].invoke
    end

rescue LoadError
    $stderr.puts "Omitting testing tasks, rspec doesn't seem to be installed."
end



########################################################################
### M A N I F E S T
########################################################################
__END__
data/thingfish-metastore-pggraph/migrations/20151102_initial.rb
lib/thingfish/metastore/pggraph/edge.rb
lib/thingfish/metastore/pggraph/node.rb
lib/thingfish/metastore/pggraph.rb

