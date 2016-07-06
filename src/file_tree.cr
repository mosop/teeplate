require "base64"
require "ecr/macros"

module Teeplate
  abstract class FileTree
    GIT = `which git`.strip
    PROMPT = "O(overwrite)/K(keep) ? "

    macro directory(dir)
      {{ run(__DIR__ + "/file_tree/macros/directory", dir.id) }}
    end

    @__out_dir : String

    def initialize(@__out_dir)
    end

    def render(force = false, interactive = false)
      __try_to_write_files force, interactive
    end

    def __try_to_write(local_path, sliceable, force, interactive)
      path = File.join(@__out_dir, local_path)
      Dir.mkdir_p path.split("/")[0..-2].join("/")
      return if File.exists?(path) && !__overwrite(local_path, sliceable, force, interactive)
      File.open(path, "w") do |f|
        f.write sliceable.to_slice
      end
    end

    def __overwrite(local_path, sliceable, force, interactive)
      return true if force
      !__is_changed?(local_path, sliceable) || interactive && __confirm(local_path, sliceable)
    end

    def __is_changed?(local_path, sliceable)
      path = File.join(@__out_dir, local_path)
      slice = sliceable.to_slice
      return true if File.size(path) != slice.size
      File.open(path) do |f|
        (0...(slice.size)).each do |i|
          return true if f.read_byte != slice[i]
        end
      end
      false
    end

    def __confirm(local_path, sliceable)
      ::STDOUT.puts "#{local_path} already exists..."
      __prompt(local_path)
    end

    def __prompt(local_path)
      loop do
        ::STDOUT.print PROMPT
        ::STDOUT.flush
        case input = ::STDIN.gets.to_s.strip.downcase
        when "o", "overwrite"
          return true
        when "k", "keep"
          return false
        else
          ::STDOUT.print input
        end
      end
    end
  end
end
