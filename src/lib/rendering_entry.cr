module Teeplate
  class RenderingEntry
    # :nodoc:
    DIFF = `which diff`.chomp
    # :nodoc:
    GIT = `which git`.chomp

    # Returns the renderer.
    getter renderer : Renderer

    # Returns the data entry.
    getter data : AsDataEntry

    def initialize(@renderer : Renderer, @data : AsDataEntry)
    end

    # :nodec:
    def appends?
      @data.path.starts_with?("+")
    end

    @out_path : String?
    # Returns an output location.
    #
    # It makes an absolute location with the renderer's setting and this entry's local path.
    def out_path
      @out_path ||= File.join(@renderer.out_path, local_path).tap do |path|
        Dir.mkdir_p File.dirname(path)
      end
    end

    @local_path : String?
    # Returns an output path relative to the base location.
    #
    # It returns the data entry's path by default.
    # Override this method if this path should be different from the data entry's path.
    def local_path
      @local_path ||= if appends?
        @data.path[1..-1]
      else
        @data.path
      end
    end

    # :nodoc:
    def list_if_any(s, color)
      list s, color if @renderer.listing?
    end

    # :nodoc:
    def list(s, color)
      print s.colorize.fore(color).toggle(@renderer.colorizes?)
      puts local_path
    end

    # :nodoc:
    def render
      case action
      when :new
        prepare_and_write
        set_perm
        list_if_any "new       ", :green
      when :none
        set_perm
        list_if_any "identical ", :dark_gray
      when :modify
        prepare_and_write
        set_perm
        list_if_any "modified  ", :magenta
      when :rewrite
        prepare_and_write
        set_perm
        list_if_any "rewritten ", :red
      when :keep
        set_perm
        list_if_any "skipped   ", :yellow
      end
    end

    # :nodoc:
    def prepare_and_write
      write
    end

    # Writes data to the output location.
    #
    # Override this method if data should be written in a special way.
    def write
      File.open(out_path, appends? ? "a" : "w") do |f|
        @data.write_to f
      end
    end

    # :nodoc:
    def set_perm
      if perm = @data.perm? && File.file?(out_path)
        File.chmod(out_path, @data.perm)
      end
    end

    # :nodoc:
    def confirm
      action
    end

    # Tests if this entry forces overwriting.
    #
    # This condition is determined by the renderer's setting by default.
    # Override this method if the condition should be determined regardless of the renderer's setting.
    def forces?
      @data.forces? || @renderer.forces?
    end

    @action : Symbol?
    # :nodoc:
    def action
      @action ||= get_action
    end

    # :nodoc:
    def get_action
      return :new unless File.exists?(out_path)
      return :keep if File.directory?(out_path)
      return :rewrite if forces? || @renderer.overwrites_all?
      return :keep if !@renderer.interactive? || @renderer.keeps_all?
      return modifies?("#{local_path} is a symlink...", diff: false) if File.symlink?(out_path)
      return :modify if appends?
      return :none if identical?
      modifies?("#{local_path} already exists...", diff: true)
    end

    # :nodoc:
    def identical?
      if size = @data.size?
        return false if File.size(out_path) != size
      end
      r, w = IO.pipe
      future do
        @data.write_to w
        w.close
      end
      begin
        File.open(out_path) do |f|
          loop do
            b1 = f.read_byte
            b2 = r.read_byte
            return false if b1 != b2
            return true unless b1
          end
        end
        true
      ensure
        r.close
      end
    end

    # :nodoc:
    def make_prompt(diff)
      String.build do |sb|
        sb << "overwrite(o)/keep(k)"
        sb << "/diff(d)" if diff
        sb << "/overwrite all(a)/keep all(n)"
        sb << "/quit(q)" if @renderer.quittable?
        sb << " ? "
      end
    end

    # :nodoc:
    def modifies?(message, diff)
      prompt = make_prompt(diff)
      STDOUT.puts message
      loop do
        STDOUT.print prompt
        STDOUT.flush
        case input = ::STDIN.gets.to_s.strip.downcase
        when "o"
          return :modify
        when "k"
          return :keep
        when "d"
          self.diff if diff
        when "a"
          @renderer.overwrite_all!
          return :modify
        when "n"
          @renderer.keep_all!
          return :keep
        when "q"
          raise Quit.new
        end
      end
    end

    # :nodoc:
    def diff
      r, w = IO.pipe
      future do
        @data.write_to w
        w.close
      end
      begin
        if !GIT.empty?
          Process.new(GIT, ["diff", "--no-index", "--", out_path, "-"], shell: true, input: r, output: true, error: true).wait
        elsif !DIFF.empty?
          Process.new(DIFF, ["-u", out_path, "-"], shell: true, input: r, output: true, error: true).wait
        else
          STDOUT.puts "No diff command is installed."
        end
      ensure
        r.close
      end
    end
  end
end
