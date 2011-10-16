require 'mkmf'

$CFLAGS += " -O0"
$CFLAGS += " -std=c99"
$CFLAGS += " -I./ruby_headers/"

create_makefile('binding_of_caller')
