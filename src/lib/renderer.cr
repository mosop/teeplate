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
        sorted_entries = @entries.sort{|a, b| a.local_path <=> b.local_path}
        sorted_entries.each do |entry|
          if @per_entry
            entry.render
          else
            entry.confirm
          end
        end
        sorted_entries.each(&.render) unless @per_entry
      rescue ex : Quit
        @quitted = true
      end
    end
  end
end
