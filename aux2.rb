# -*- encoding : utf-8 -*-
require 'rubygems'
require 'time_difference'


puts %x(./tribal.sh) if TimeDifference.between(Time.now, File.mtime(File.expand_path(File.dirname(__FILE__) ).to_s + '/playerbr44.txt')).in_hours > 2