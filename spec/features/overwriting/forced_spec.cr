require "../../spec_helper"

module TeeplateOverwritingForcedFeature
  extend HaveFiles::Spec::Dsl

  class Template < Teeplate::FileTree
    directory "#{__DIR__}/force/template"

    @face : String

    def initialize(@face)
    end
  end

  it name do
    HaveFiles.tmpdir do |tmp|
      test_path = "#{tmp}/test"
      Template.new(":)").render(tmp)
      Template.new(":(").render(tmp, force: true)
      File.read(test_path).should eq ":(\n"
      Template.new(":P").render(tmp)
      File.read(test_path).should eq ":(\n"
    end
  end
end
