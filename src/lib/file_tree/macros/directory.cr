require "base64"

def each_file(abs, rel, &block : String, String ->)
  Dir.open(abs) do |d|
    d.each do |entry|
      if entry != "." && entry != ".."
        each_file abs, rel, entry, &block
      end
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
raise "No dir." unless Dir.exists?(dir)

def pack_ecr(i, sb, abs, rel)
  sb << <<-EOS
  \ndef __ecr#{i}(__io)
    ::ECR.embed #{abs.inspect}, "__io"
  end
  EOS
  STDOUT << <<-EOS
  \nio = IO::Memory.new
  __ecr#{i} io
  yield "#{rel}", io.to_s
  EOS
end

def pack_blob(sb, abs, rel)
  STDOUT << "\nyield \"#{rel}\", ::Teeplate::Base64Data.new("
  io = IO::Memory.new
  File.open(abs){|f| IO.copy(f, io)}
  if io.size > 0
    STDOUT << "#{io.size}_i64, <<-EOS\n"
    Base64.encode io, STDOUT
    STDOUT << "EOS\n)"
  else
    STDOUT << "0_i64, \"\")"
  end
end

STDOUT << "def __render"
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
