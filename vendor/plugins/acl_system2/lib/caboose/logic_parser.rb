module Caboose
  
  module LogicParser
    # This module holds our recursive descent parser that take a logic string
    # the logic string is tested by the enclosing Handler class' #check method
    # Include this module in your Handler class.
    
    # recursively processes an permission string and returns true or false
    def process(logicstring, context)
      # if logicstring contains any parenthasized patterns, call process recursively on them
      while logicstring =~ /\(/
        logicstring.sub!(/\(([^\)]+)\)/) {
          process($1, context)
        }
      end
      
      # process each operator in order of precedence
      #!
      while logicstring =~ /!/
        logicstring.sub!(/!([^ &|]+)/) { 
          (!check(logicstring[$1], context)).to_s
        }
      end
      
      #&
      if logicstring =~ /&/
        return (process(logicstring[/^[^&]+/], context) and process(logicstring[/^[^&]+&(.*)$/,1], context))
      end
      
      #|
      if logicstring =~ /\|/
        return (process(logicstring[/^[^\|]+/], context) or process(logicstring[/^[^\|]+\|(.*)$/,1], context))
      end
      
      # constants
      if logicstring =~ /^\s*true\s*$/i
        return true
      elsif logicstring =~ /^\s*false\s*$/i
        return false
      end
      
      # single list items
      (check(logicstring.strip, context))
    end
    
  end # LogicParser

end