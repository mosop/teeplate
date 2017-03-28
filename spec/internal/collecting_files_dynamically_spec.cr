require "../spec_helper"

module TeeplateCollectingFilesDynamicallyFeature
  extend HaveFiles::Spec::Dsl

  class Template < Teeplate::FileTree
    def initialize
    end
  end

  it name do
    HaveFiles.tmpdir do |tmp|
      template = Template.new
      template.collect_from "#{__DIR__}/../../test/collecting_files_dynamically/dynamic_template"
      template.collect_from "#{__DIR__}/../../test/collecting_files_dynamically/dynamic_template2", unique: true
      template.render tmp
      expected_dir = "#{__DIR__}/../../test/collecting_files_dynamically/expected"
      tmp.should have_files expected_dir
    end
  end
end
