def fake_makefile
  File.open(File.join(File.dirname(__FILE__), "Makefile"), "w") {|f|
    f.puts %[install:\n\techo "Nada."]
  }
end

if RUBY_ENGINE && RUBY_ENGINE =~ /rbx/
  fake_makefile
else
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
end

