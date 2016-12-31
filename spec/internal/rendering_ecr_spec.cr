require "../spec_helper"

module TeeplateRenderingEcrFeature
  extend HaveFiles::Spec::Dsl

  class Template < Teeplate::FileTree
    directory "#{__DIR__}/rendering_ecr/template"
  end

  it name do
    HaveFiles.tmpdir do |tmp|
      Template.new.render(tmp)
      expected_dir = "#{__DIR__}/rendering_ecr/expected"
      tmp.should have_files expected_dir
    end
  end
end
