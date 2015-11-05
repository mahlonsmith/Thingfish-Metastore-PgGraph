#!/usr/bin/env rspec -cfd
#encoding: utf-8

require_relative '../../spec_helper'

require 'rspec'

require 'thingfish/behaviors'
require 'thingfish/metastore/pggraph'

describe Thingfish::Metastore::PgGraph, db: true do

	it_should_behave_like "a Thingfish metastore"

end

