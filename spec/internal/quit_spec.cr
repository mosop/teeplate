require "../spec_helper"

module TeeplateInternalSpecQuit
  extend HaveFiles::Spec::Dsl
  extend Teeplate::SpecHelper

  class Template < Teeplate::FileTree
    directory "#{__DIR__}/quit"

    def initialize(@test1 : String, @test2 : String)
    end
  end

  it name do
    HaveFiles.tmpdir do |tmp|
      testfile = File.join(tmp, "test")
      `touch #{testfile}`
      renderer = Stdio.capture do |io|
        interact io, %w(q)
        Template.new("change1", "change2").render(tmp, interactive: true)
      end
      File.size(testfile).should eq 0
      renderer.quitted?.should be_true
    end
  end
end
