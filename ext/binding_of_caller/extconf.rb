require 'mkmf'

$CFLAGS += " -O0"
$CFLAGS += " -std=c99"

case RUBY_VERSION
when /1.8.7/
  $CFLAGS += " -DRUBY_187"
  $CFLAGS += " -I./ruby_headers/187/"
when /1.9.2/
  $CFLAGS += " -DRUBY_192"  
  $CFLAGS += " -I./ruby_headers/192/"
when /1.9.3/
  $CFLAGS += " -DRUBY_193"
  $CFLAGS += " -I./ruby_headers/193/"
end

$CFLAGS += " -pedantic -Wall"
create_makefile('binding_of_caller')
