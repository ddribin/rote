#--
# Require all formats
# (c)2005 Ross Bamford (and contributors)
#
# See 'rote.rb' or LICENSE for licence information.
# $Id: format.rb 128 2005-12-12 02:45:24Z roscopeco $
#++

Dir[File.join(File.dirname(__FILE__), 'format/*.rb')].each { |f| require f }
