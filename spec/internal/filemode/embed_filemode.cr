perm1 = File.stat(File.join(__DIR__, "template", "file1.ecr")).perm
perm2 = File.stat(File.join(__DIR__, "template", "file2")).perm
puts <<-EOS
FILE1_PERM = #{perm1}
FILE2_PERM = #{perm2}
EOS
