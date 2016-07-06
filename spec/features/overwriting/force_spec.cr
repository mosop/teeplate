require "../../spec_helper"

module TeeplateOverwritingForcedFeature
  extend HaveFiles::Spec::Dsl

  class Template < Teeplate::FileTree
    directory "#{__DIR__}/force/template"

    @face : String

    def initialize(out_dir, @face)
      super out_dir
    end
  end

  it name do
    HaveFiles.tmpdir do |tmp|
      test_path = "#{tmp}/test"
      Template.new(tmp, ":)").render
      Template.new(tmp, ":(").render(force: true)
      File.read(test_path).should eq ":(\n"
      Template.new(tmp, ":P").render
      File.read(test_path).should eq ":(\n"
    end
  end
end
