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

    def filter(entries)
      entries.reject{ |entry| entry.path.includes? "version.cr" }
    end
  end

  it name do
    HaveFiles.tmpdir do |tmp|
      Template.new("teeplate", "Teeplate", "mosop", 2016).render(tmp)
      expected_file = "#{__DIR__}/../../test/file_tree_template/expected/src/teeplate/version.cr"
      tmp.should_not have_files expected_file
    end
  end
end

