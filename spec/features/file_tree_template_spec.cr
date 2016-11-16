require "../spec_helper"

module TeeplateFileTreeTemplateFeature
  extend HaveFiles::Spec::Dsl

  class Template < Teeplate::FileTree
    directory "#{__DIR__}/../../test/file_tree_template/template"

    @file : String
    @class : String
    @author : String
    @year : Int32

    def initialize(@file, @class, @author, @year)
    end
  end

  it name do
    HaveFiles.tmpdir do |tmp|
      Template.new("teeplate", "Teeplate", "mosop", 2016).render(tmp)
      expected_dir = "#{__DIR__}/../../test/file_tree_template/expected"
      tmp.should have_files expected_dir
    end
  end
end
