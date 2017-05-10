require "../spec_helper"

module TeeplateFilteringFileEntriesFeature
  extend HaveFiles::Spec::Dsl

  class Template < Teeplate::FileTree
    directory "#{__DIR__}/../../test/filtering_file_entries/template"

    @file : String
    @class : String
    @author : String
    @year : Int32

    def initialize(@file, @class, @author, @year)
    end

    def rendered_file_entries
      super.select{|i| !i.path.ends_with?("shard.yml")}
    end
  end

  it "filters templates by the rendered_filter_entries method" do
    HaveFiles.tmpdir do |tmp|
      Template.new("teeplate", "Teeplate", "mosop", 2016).render(tmp)
      expected_file = "#{__DIR__}/../../test/filtering_file_entries/expected/src/teeplate/version.cr"
      tmp.should_not have_files expected_file
    end
  end
end
