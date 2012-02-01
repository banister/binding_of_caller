require 'mkmf'

$CFLAGS += " -O0"
$CFLAGS += " -std=c99"

case RUBY_VERSION
when /1.9.2/
  $CFLAGS += " -I./ruby_headers/192/ -DRUBY_192"
when /1.9.3/
  $CFLAGS += " -I./ruby_headers/193/ -DRUBY_193"
end

create_makefile('binding_of_caller')
