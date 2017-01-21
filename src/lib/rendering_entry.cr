module Teeplate
  class RenderingEntry
    DIFF = `which diff`.chomp
    GIT = `which git`.chomp

    @renderer : Renderer
    @data : AsDataEntry

    def initialize(@renderer, @data)
    end

    @slice : Slice(UInt8)?
    def slice
      @slice ||= @sliceable.to_slice
    end

    @out_path : String?
    def out_path
      @out_path ||= File.join(@renderer.out_dir, @data.path).tap do |path|
        Dir.mkdir_p File.dirname(path)
      end
    end

    def list(s, color)
      if @renderer.listing?
        print s.colorize.fore(color).toggle(@renderer.colorizes?)
        puts @data.path
      end
    end

    def render
      case action
      when :new
        write
        list "new       ", :green
      when :none
        list "identical ", :dark_gray
      when :modify
        write
        list "modified  ", :light_red
      when :keep
        list "skipped   ", :light_yellow
      end
    end

    def write
      Dir.rmdir out_path if File.directory?(out_path)
      File.open(out_path, "w") do |f|
        @data.write_to f
      end
    end

    def confirm
      action
    end

    @action : Symbol?
    def action
      @action ||= get_action
    end

    def get_action
      return :new unless File.exists?(out_path)
      return :modify if @renderer.forces? || @renderer.overwrites_all?
      return :keep if !@renderer.interactive? || @renderer.keeps_all?
      return modifies?("#{out_path} is a symlink...", diff: false) if File.symlink?(out_path)
      return modifies?("#{out_path} is a directory...", diff: false) if File.directory?(out_path)
      return :none if identical?
      modifies?("#{@data.path} already exists...", diff: true)
    end

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

    def make_prompt(diff)
      String.build do |sb|
        sb << "overwrite(o)/keep(k)"
        sb << "/diff(d)" if diff
        sb << "/overwrite all(a)/keep all(n)"
        sb << "/quit(q)" if @renderer.quittable?
        sb << " ? "
      end
    end

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
