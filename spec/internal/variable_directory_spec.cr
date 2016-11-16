require "../spec_helper"

module TeeplateVariableDirectoryFeature
  extend HaveFiles::Spec::Dsl

  class Template < Teeplate::FileTree
    directory "#{__DIR__}/variable_directory/template"

    @var : String

    def initialize(@var)
    end
  end

  it name do
    HaveFiles.tmpdir do |tmp|
      Template.new("var").render(tmp)
      expected_dir = "#{__DIR__}/variable_directory/expected"
      tmp.should have_files expected_dir
    end
  end
end
