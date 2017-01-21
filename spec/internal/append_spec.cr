require "../spec_helper"

module TeeplateInternalSpecAppend
  extend HaveFiles::Spec::Dsl
  extend Teeplate::SpecHelper

  class Template < Teeplate::FileTree
    directory "#{__DIR__}/append"

    def initialize(@test : String)
    end
  end

  it name do
    HaveFiles.tmpdir do |tmp|
      testfile = File.join(tmp, "test")
      `echo previous > #{testfile}`
      Stdio.capture do |io|
        Template.new("new").render(tmp, interactive: true, list: true, color: true)
        io.out.gets_to_end.chomp.should eq <<-EOS
        #{list_mod}test
        EOS
      end
      File.read(testfile).chomp.should eq "previous\nnew"
    end
  end
end
