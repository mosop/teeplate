require "../../spec_helper"

module TeeplateOverwritingInteractiveFeature
  extend HaveFiles::Spec::Dsl
  extend Teeplate::SpecHelper

  class Template < Teeplate::FileTree
    directory "#{__DIR__}/interactive/template"

    def initialize(@face : String)
    end
  end

  it name do
    HaveFiles.tmpdir do |tmp|
      test_path = "#{tmp}/test"
      Template.new(":)").render(tmp)
      File.read(test_path).should eq ":)\n"
      Stdio.capture do |io|
        interact io, %w(o)
        Template.new(":(").render(tmp, interactive: true)
      end
      File.read(test_path).should eq ":(\n"
      Stdio.capture do |io|
        interact io, %w(k)
        Template.new(":P").render(tmp, interactive: true)
      end
      File.read(test_path).should eq ":(\n"
    end
  end
end
