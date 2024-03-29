#--
# Rote page class
# (c)2005 Ross Bamford (and contributors)
#
# See 'rote.rb' or LICENSE for licence information.
# $Id: rdoc.rb 177 2006-02-26 19:59:11Z roscopeco $
#++

require 'rote/filters/base'
require 'rdoc/markup/simple_markup'
require 'rdoc/markup/simple_markup/to_html'

module Rote
  module Filters
  
    #####
    ## Page filter supporting RDoc markup.     
    class RDoc < TextFilter
      def initialize(markup = SM::SimpleMarkup.new, output = SM::ToHtml.new)
        @markup = markup
        @output = output
        self.handler_blk = proc { |text,page| @markup.convert(text, @output) }
      end      
    end
  end
end 