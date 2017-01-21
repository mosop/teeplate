require "../spec_helper"

module TeeplateInternalSpecDiff
  extend HaveFiles::Spec::Dsl
  extend Teeplate::SpecHelper

  class Template < Teeplate::FileTree
    directory "#{__DIR__}/diff"

    def initialize(@test : String)
    end
  end

  it name do
    HaveFiles.tmpdir do |tmp|
      testfile = File.join(tmp, "test")
      `echo previous > #{testfile}`
      buf = IO::Memory.new
      Stdio.capture do |io|
        interact io, %w(d o), buffer: buf
        Template.new("new").render(tmp, interactive: true, list: true, color: true)
        io.out.gets_to_end.chomp.should eq <<-EOS
        #{list_mod}test
        EOS
      end
      ex = <<-EOS
      test already exists...
      overwrite(o)/keep(k)/diff(d)/overwrite all(a)/keep all(n)/quit(q) ? diff --git a#{testfile} b/-
      index fd4a3ec..0000000 100644
      --- a#{testfile}
      +++ b/-
      @@ -1 +1 @@
      -previous
      +new
      overwrite(o)/keep(k)/diff(d)/overwrite all(a)/keep all(n)/quit(q) ?#{" "}
      EOS
      buf.to_s.should eq ex
      File.read(testfile).chomp.should eq "new"
    end
  end
end
