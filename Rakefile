#!/usr/bin/env rake

begin
	require 'hoe'
rescue LoadError
	abort "This Rakefile requires hoe (gem install hoe)"
end

GEMSPEC = 'thingfish-metastore-pggraph.gemspec'


Hoe.plugin :mercurial
Hoe.plugin :signing
Hoe.plugin :deveiate
Hoe.plugin :bundler

Hoe.plugins.delete :rubyforge

hoespec = Hoe.spec 'thingfish-metastore-pggraph' do |spec|
	spec.readme_file = 'README.md'
	spec.history_file = 'History.md'
	spec.extra_rdoc_files = FileList[ '*.rdoc' ]
	spec.license 'BSD-3-Clause'
	spec.urls = {
		home: 'https://bitbucket.org/mahlon/thingfish-metastore-pggraph',
		code: 'https://bitbucket.org/mahlon/thingfish-metastore-pggraph'
	}

	if File.directory?( '.hg' )
		spec.spec_extras[:rdoc_options] = ['-f', 'fivefish', '-t', 'Thingfish-Metastore-PgGraph']
	end

	spec.developer 'Michael Granger', 'ged@FaerieMUD.org'
	spec.developer 'Mahlon E. Smith', 'mahlon@martini.nu'

	spec.dependency 'thingfish', '~> 0.5'
	spec.dependency 'loggability', '~> 0.11'
	spec.dependency 'configurability', '~> 2.2'
	spec.dependency 'sequel', '~> 4.35'
	spec.dependency 'pg', '~> 0.19'

	spec.dependency 'hoe-deveiate', '~> 0.8',  :development
	spec.dependency 'rspec', '~> 3.0', :development

	spec.require_ruby_version( '>=2.3.0' )
	spec.hg_sign_tags = true if spec.respond_to?( :hg_sign_tags= )
end


ENV['VERSION'] ||= hoespec.spec.version.to_s

# Run the tests before checking in
task 'hg:precheckin' => [ :check_history, :check_manifest, :spec ]

# Rebuild the ChangeLog immediately before release
task :prerelease => 'ChangeLog'
CLOBBER.include( 'ChangeLog' )

desc "Build a coverage report"
task :coverage do
	ENV["COVERAGE"] = 'yes'
	Rake::Task[:spec].invoke
end


task :gemspec => GEMSPEC
file GEMSPEC => __FILE__ do |task|
	spec = $hoespec.spec
	spec.files.delete( '.gemtest' )
	spec.signing_key = nil
	spec.version = "#{spec.version.bump}.0.pre#{Time.now.strftime("%Y%m%d%H%M%S")}"
	File.open( task.name, 'w' ) do |fh|
		fh.write( spec.to_ruby )
	end
end

task :default => :gemspec
CLOBBER.include( GEMSPEC.to_s )

