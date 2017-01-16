require "../spec_helper"

module TeeplateInternalSpecInterative
  extend HaveFiles::Spec::Dsl
  extend Teeplate::SpecHelper

  class Template < Teeplate::FileTree
    directory "#{__DIR__}/interactive"

    def initialize(@test1 : String, @test2 : String)
    end
  end

  macro expect(answers, expected1, expected2)
    HaveFiles.tmpdir do |tmp|
      test1 = File.join(tmp, "test1")
      test2 = File.join(tmp, "test2")
      `echo test1 > #{test1}`
      `echo test2 > #{test2}`
      Stdio.capture do |io|
        interact io, {{answers}}
        Template.new("change1", "change2").render(tmp, interactive: true)
      end
      File.read(test1).chomp.should eq {{expected1}}
      File.read(test2).chomp.should eq {{expected2}}
    end
  end

  it name do
    expect %w(o o), "change1", "change2"
    expect %w(o k), "change1", "test2"
    expect %w(k o), "test1", "change2"
    expect %w(k k), "test1", "test2"
    expect %w(a), "change1", "change2"
    expect %w(n), "test1", "test2"
    expect %w(q), "test1", "test2"
  end
end
