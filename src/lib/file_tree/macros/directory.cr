require "base64"

def each_file(abs, rel, &block : String, String ->)
  Dir.open(abs) do |d|
    d.each_child do |entry|
      each_file abs, rel, entry, &block
    end
  end
end

def each_file(abs, rel, entry, &block : String, String ->)
  rel = rel ? File.join(rel, entry) : entry
  abs = File.join(abs, entry)
  if Dir.exists?(abs)
    each_file abs, rel, &block
  else
    block.call abs, rel
  end
end

dir = File.expand_path(ARGV[0])
raise "No directory." unless Dir.exists?(dir)

def pack_ecr(i, sb, abs, rel)
  sb << <<-EOS
  \ndef __ecr#{i}(____io)
    ::ECR.embed #{abs.inspect}, "____io"
  end
  EOS
  STDOUT << <<-EOS
  \nio = IO::Memory.new
  __ecr#{i} io
  ____files << ::Teeplate::StringData.new("#{rel}", io.to_s, File::Permissions.from_value(#{File.info(abs).permissions.value}))
  EOS
end

def pack_blob(sb, abs, rel)
  STDOUT << "\n____files << ::Teeplate::Base64Data.new(\"#{rel}\", "
  io = IO::Memory.new
  File.open(abs) { |f| IO.copy(f, io) }
  if io.size > 0
    STDOUT << "#{io.size}_u64, <<-EOS"
  else
    STDOUT << "0_u64, \"\""
  end
  STDOUT << ", File::Permissions.from_value(#{File.info(abs).permissions.value}))\n"

  if io.size > 0
    Base64.encode io, STDOUT
    STDOUT << "EOS"
  end
end

STDOUT << "def ____collect_files(____files)"
s = String.build do |sb|
  i = 0
  each_file(dir, nil) do |abs, rel|
    rel = rel.gsub(/{{([a-z_](?:[\w_0-9])*)}}/, "\#{@\\1}")
    if /^(.+)\.ecr$/ =~ rel
      pack_ecr i, sb, abs, $1
      i += 1
    else
      pack_blob sb, abs, rel
    end
    i += 1
  end
end
STDOUT << "\nend"
STDOUT << s
