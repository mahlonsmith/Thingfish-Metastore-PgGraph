#!/usr/bin/ruby -*- ruby -*-

require 'configurability'
require 'loggability'
require 'pathname'
require 'strelka'

$LOAD_PATH.unshift( '../Thingfish/lib', 'lib' )

begin
	require 'thingfish'
	require 'thingfish/metastore/pggraph'

	Loggability.level = :debug
	Loggability.format_with( :color )

	if File.exist?( 'config.yml' )
		Strelka.load_config( 'config.yml' )
		metastore = Thingfish::Metastore.create( 'pggraph' )
	end

rescue Exception => e
	$stderr.puts "Ack! Libraries failed to load: #{e.message}\n\t" +
		e.backtrace.join( "\n\t" )
end


