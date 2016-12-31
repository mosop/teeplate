module Teeplate
  abstract class FileTree
    DIFF = `which diff`.strip
    GIT = `which git`.strip
    PROMPT = "overwrite(o)/keep(k)/diff(d)/overwrite all(a)/keep all(n) ? "

    macro directory(dir)
      {{ run(__DIR__ + "/file_tree/macros/directory", dir.id) }}
    end

    class Rendering
      class Entry
        alias Sliceable = Bytes | IO::Memory

        @rendering : Rendering
        @local_path : String
        @sliceable : Sliceable

        def initialize(@rendering, @local_path, @sliceable)
        end

        @slice : Slice(UInt8)?
        def slice
          @slice ||= @sliceable.to_slice
        end

        @out_path : String?
        def out_path
          @out_path ||= File.join(@rendering.out_dir, @local_path).tap do |path|
            Dir.mkdir_p path.split("/")[0..-2].join("/")
          end
        end

        def render
          return if File.exists?(out_path) && !overwrites?
          File.open(out_path, "w") do |f|
            f.write slice
          end
        end

        def overwrites?
          return true if @rendering.forces? || @rendering.overwrite_all?
          return false unless changed?
          !@rendering.keep_all? && @rendering.interactive? && confirm_overwriting
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
            when "a"
              @rendering.overwrite_all!
              return true
            when "n"
              @rendering.keep_all!
              return false
            end
          end
        end

        def new_input
          IO::Memory.new(slice, writeable: false)
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

      getter out_dir : String
      @forces : Bool
      @interactive : Bool
      @overwrite_all = false
      @keep_all = false

      def initialize(@out_dir, @forces, @interactive)
      end

      def forces?
        @forces
      end

      def interactive?
        @interactive
      end

      def overwrite_all!
        @overwrite_all = true
      end

      def overwrite_all?
        @overwrite_all
      end

      def keep_all!
        @keep_all
      end

      def keep_all?
        @keep_all
      end

      def render(local_path, sliceable)
        Entry.new(self, local_path, sliceable).render
      end
    end

    def render(out_dir, force = false, interactive = false)
      __write Rendering.new(out_dir, force, interactive)
    end
  end
end
