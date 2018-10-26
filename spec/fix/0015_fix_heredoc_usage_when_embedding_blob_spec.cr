require "../spec_helper"

module TeeplateFixSpec0015
  macro test
    {{ run(system("cd #{__DIR__}/../../src/lib/file_tree/macros && pwd").strip + "/directory", __DIR__ + "/0015_fix_heredoc_usage_when_embedding_blob").stringify }}
  end

  it name do
    test.should eq "def ____collect_files(____files)\n____files << ::Teeplate::Base64Data.new(\"blob\", 1_u64, <<-EOS, File::Permissions.from_value(420))\nMA==\nEOS\nend"
  end
end
