perm1 = File.info(File.join(__DIR__, "template", "file1.ecr")).permissions
perm2 = File.info(File.join(__DIR__, "template", "file2")).permissions
puts <<-EOS
FILE1_PERM = File::Permissions.from_value(#{perm1.value})
FILE2_PERM = File::Permissions.from_value(#{perm2.value})
EOS
