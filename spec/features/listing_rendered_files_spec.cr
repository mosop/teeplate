require "../spec_helper"

module TeeplateListingRenderedFilesFeature
  extend Teeplate::SpecHelper

  class Template < Teeplate::FileTree
    directory "#{__DIR__}/../../test/listing_rendered_files/template"

    def initialize(@file : String, @class : String, @author : String, @year : Int32)
    end
  end

  if ENV["TRAVIS"]? == "true"
    pending name do
    end
  else
    it name do
      HaveFiles.tmpdir do |tmp|
        Stdio.capture do |io|
          Template.new("teeplate", "Teeplate", "mosop", 2016).render(tmp, list: true, color: true)
          io.out.gets_to_end.should eq <<-EOS
          #{list_new}.gitignore
          #{list_new}.travis.yml
          #{list_new}LICENSE
          #{list_new}README.md
          #{list_new}shard.yml
          #{list_new}spec/spec_helper.cr
          #{list_new}spec/teeplate_spec.cr
          #{list_new}src/teeplate.cr
          #{list_new}src/teeplate/version.cr\n
          EOS
        end
        Stdio.capture do |io|
          interact io, %w(k o o)
          Template.new("teeplate", "Teeplate", "usop", 2016).render(tmp, interactive: true, list: true, color: true)
          io.out.gets_to_end.should eq <<-EOS
          #{list_ide}.gitignore
          #{list_ide}.travis.yml
          #{list_ski}LICENSE
          #{list_mod}README.md
          #{list_mod}shard.yml
          #{list_ide}spec/spec_helper.cr
          #{list_ide}spec/teeplate_spec.cr
          #{list_ide}src/teeplate.cr
          #{list_ide}src/teeplate/version.cr\n
          EOS
        end
      end
    end
  end
end
