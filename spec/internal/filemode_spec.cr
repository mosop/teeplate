require "../spec_helper"

module TeeplateInternalSpecs::Executable
  extend HaveFiles::Spec::Dsl
  extend Teeplate::SpecHelper

  {{ run("#{__DIR__}/filemode/embed_filemode.cr") }}

  class Template < Teeplate::FileTree
    directory "#{__DIR__}/filemode/template"
  end

  describe name do
    it "sets executable bit" do
      HaveFiles.tmpdir do |tmp|
        file1 = File.join(tmp, "file1")
        file2 = File.join(tmp, "file2")
        Template.new.render tmp, force: true
        File.info(file1).permissions.should eq FILE1_PERM
        File.info(file2).permissions.should eq FILE2_PERM
      end
    end

    it "overwrites executable bit" do
      HaveFiles.tmpdir do |tmp|
        file1 = File.join(tmp, "file1")
        file2 = File.join(tmp, "file2")
        File.write file1, ""
        File.chmod file1, 0o666
        File.write file2, ""
        File.chmod file2, 0o666
        Template.new.render tmp, force: true
        File.info(file1).permissions.should eq FILE1_PERM
        File.info(file2).permissions.should eq FILE2_PERM
      end
    end
  end
end
