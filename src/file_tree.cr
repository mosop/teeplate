module Teeplate
  abstract class FileTree
    DIFF = `which diff`.strip
    GIT = `which git`.strip
    PROMPT = "overwrite(o)/keep(k)/diff(d) ? "

    macro directory(dir)
      {{ run(__DIR__ + "/file_tree/macros/directory", dir.id) }}
    end

    class Entry
      alias Sliceable = Bytes | MemoryIO

      @tree : FileTree
      @local_path : String
      @sliceable : Sliceable
      @force : Bool
      @interactive : Bool

      def initialize(@tree, @local_path, @sliceable, @force, @interactive)
      end

      @slice : Slice(UInt8)?
      def slice
        @slice ||= @sliceable.to_slice
      end

      @out_path : String?
      def out_path
        @out_path ||= File.join(@tree.__out_dir, @local_path).tap do |path|
          Dir.mkdir_p path.split("/")[0..-2].join("/")
        end
      end

      def write
        return if File.exists?(out_path) && !overwrites?
        File.open(out_path, "w") do |f|
          f.write slice
        end
      end

      def overwrites?
        changed? && (@force || @interactive && confirm_overwriting)
      end

      def changed?
        return true if File.size(out_path) != slice.size
        File.open(out_path) do |f|
          (0...(slice.size)).each do |i|
            return true if f.read_byte != slice[i]
          end
        end
        false
      end

      def confirm_overwriting
        STDOUT.puts "#{@local_path} already exists..."
        loop do
          STDOUT.print PROMPT
          STDOUT.flush
          case input = ::STDIN.gets.to_s.strip.downcase
          when "o"
            return true
          when "k"
            return false
          when "d"
            diff
          end
        end
      end

      def new_input
        MemoryIO.new(slice, writeable: false)
      end

      def diff
        if !GIT.empty?
          Process.new(GIT, ["diff", "--no-index", "--", out_path, "-"], shell: true, input: new_input, output: true, error: true).wait
        elsif !DIFF.empty?
          Process.new(DIFF, ["-u", out_path, "-"], shell: true, input: new_input, output: true, error: true).wait
        else
          STDOUT.puts "No diff command."
        end
      end
    end

    getter __out_dir : String

    def initialize(@__out_dir)
    end

    def render(force = false, interactive = false)
      __try_to_write_files force, interactive
    end

    def __try_to_write(local_path, sliceable, force, interactive)
      Entry.new(self, local_path, sliceable, force, interactive).write
    end
  end
end
