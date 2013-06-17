$:.unshift File.join(File.dirname(__FILE__),'lib')

require 'test/unit'

require 'active_record'
ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database =>  "test/db/test.sqlite3.db"

require_relative '../lib/acts_as_soft_delete_by_field'
