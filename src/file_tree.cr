require "base64"
require "ecr/macros"

module Teeplate
  abstract class FileTree
    macro directory(dir)
      {{ run(__DIR__ + "/file_tree/macros/directory", dir.id) }}
    end

    @__out_dir : String

    def initialize(@__out_dir)
    end

    def render(force = false)
      __try_to_write_files force
    end

    def __try_to_write(path, sliceable, force)
      path = File.join(@__out_dir, path)
      Dir.mkdir_p path.split("/")[0..-2].join("/")
      return if File.exists?(path) && !__overwrite(path, sliceable, force)
      File.open(path, "w") do |f|
        f.write sliceable.to_slice
      end
    end

    def __overwrite(path, sliceable, force)
      force
    end
  end
end
