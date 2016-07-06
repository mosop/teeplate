require "../spec_helper"

module TeeplateVariableDirectoryFeature
  extend HaveFiles::Spec::Dsl

  class Template < Teeplate::FileTree
    directory "#{__DIR__}/variable_directory/template"

    @var : String

    def initialize(out_dir, @var)
      super out_dir
    end
  end

  it name do
    HaveFiles.tmpdir do |tmp|
      Template.new(tmp, "var").render
      expected_dir = "#{__DIR__}/variable_directory/expected"
      tmp.should have_files expected_dir
    end
  end
end
