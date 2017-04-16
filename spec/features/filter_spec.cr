require "../spec_helper"

module FilterFeature
  extend HaveFiles::Spec::Dsl

  class FilterTemplate < Teeplate::FileTree
    directory "#{__DIR__}/../../test/file_tree_template/template"

    @file : String
    @class : String
    @author : String
    @year : Int32

    def initialize(@file, @class, @author, @year)
      @skip_version = true
    end

    def filter(entries)
      entries.reject{ |entry| entry.path.includes?("version.cr") && @skip_version }
    end
  end

  it "filters templates based on options" do
    HaveFiles.tmpdir do |tmp|
      FilterTemplate.new("teeplate", "Teeplate", "mosop", 2016).render(tmp)
      expected_file = "#{__DIR__}/../../test/file_tree_template/expected/src/teeplate/version.cr"
      tmp.should_not have_files expected_file
    end
  end
end

