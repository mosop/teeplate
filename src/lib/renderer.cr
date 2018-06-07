module Teeplate
  class Renderer
    # Returns the base output location.
    getter out_path : String

    # Tests if overwriting should be forced.
    getter? forces : Bool

    # Tests if overwriting should be done after confirmation.
    getter? interactive : Bool

    # Tests if rendering results should be printed.
    getter? listing : Bool

    # Tests if rendering results should be colorized.
    getter? colorizes : Bool

    # Tests if files should be rendered per file.
    #
    # If true, the renderer executes writing after each time overwriting is confirmed.
    #
    # Otherwise, all files are rendered at once after all confirmations are finished.
    #
    # This condition means nothing if overwriting is not interative.
    getter? per_entry : Bool

    # Tests if rendering is quittable.
    #
    # If true, rendering can be quitted on each overwriting's confirmation.
    getter? quittable : Bool

    # :nodoc:
    getter? overwrites_all = false

    # :nodoc:
    getter? keeps_all = false

    # Tests if rendering has been quitted.
    getter? quitted = false

    # :nodoc:
    getter data_entries = [] of AsDataEntry

    # :nodoc:
    getter? pending_destroy = false

    # :nodoc:
    getter entries = [] of RenderingEntry

    def initialize(@out_path : String, force : Bool, interact : Bool, list : Bool, color : Bool, @per_entry : Bool, quit : Bool)
      @forces = force
      @interactive = interact
      @listing = list
      @colorizes = color
      @quittable = quit
    end

    # :nodoc:
    def overwrite_all!
      @overwrites_all = true
    end

    # :nodoc:
    def keep_all!
      @keeps_all = true
    end

    # Creates and returns a new rendering entry with a specified data entry.
    #
    # Overrides this method if you want to use a custom class.
    def new_rendering_entry(data)
      RenderingEntry.new(self, data)
    end

    # Appends data entries.
    def <<(entries : Array(AsDataEntry))
      entries.each do |entry|
        self << entry
      end
    end

    # Appends a data entry.
    def <<(entry : AsDataEntry)
      @data_entries << entry
      @entries << new_rendering_entry(entry)
    end

    # Starts rendering.
    def render
      begin
        @entries.each do |entry|
          if @per_entry
            entry.render
          else
            entry.confirm
          end
        end
        @entries.each(&.render) unless @per_entry
      rescue ex : Quit
        @quitted = true
      end
    end
    
    # Destroy templates.
    #
    # If passing paths as skip, these paths will be skipped in the destroy process, and thus will remain on the 
    # file system
    def destroy(skip : Array(String)?)
      @pending_destroy = true
      begin
        if @interactive
          @entries.each do |entry|
            entry.destroy(should_destroy?(entry))
          end
        elsif should_destroy_all?(@entries)
          @entries.each do |entry|
            entry.destroy(should_skip_on_destroy?(entry, skip))
          end
        end
      rescue ex : Quit
        @quitted = true
      end
    end

    # Confirm whether the user wants to destroy a singe file.
    def should_destroy?(entry : RenderingEntry)
      STDOUT.puts "Destroy #{entry.out_path}? (y/n)"

      loop do
        case input = ::STDIN.gets.to_s.strip.downcase
        when "y"
          return true
        when "n"
          return false
        end
      end
    end
  
    # Confirm whether or not the user wishes to destroy multiple files.
    def should_destroy_all?(entries : Array(RenderingEntry))
      return should_destroy?(entries.first) if entries.size == 1

      STDOUT.puts "Destroy all the following files? (y/n)"

      entries.each do |entry|
        STDOUT.puts entry.out_path
      end

      loop do
        case input = ::STDIN.gets.to_s.strip.downcase
        when "y"
          return true
        when "n"
          return false
        end
      end
    end

    # Determine whether a file should be skipped upon performing #destroy, based on the
    # provided array of paths to skip.
    def should_skip_on_destroy?(file : RenderingEntry, skip : Array(String)?) : Bool
      skip_file = false

      skip_path_parts : Array(String)?
      entry_path_parts : Array(String)?
      entry_path_parts = file.out_path.split("/")

      skip.each do |skip_path|
        skip_path_parts = skip_path.split("/")

        skip_path_parts.unshift(entry_path_parts.first)
        skip_path_parts.each_with_index do |part, i|
          if i + 1 > entry_path_parts.size
            skip_file = false
            break
          end
          skip_file = part.downcase == entry_path_parts[i].downcase
        end

        break if skip_file
      end

      skip_file
    end
  end
end
