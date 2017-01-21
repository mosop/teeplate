module Teeplate
  class Renderer
    getter out_dir : String
    getter? forces : Bool
    getter? interactive : Bool
    getter? listing : Bool
    getter? colorizes : Bool
    getter? per_entry : Bool
    getter? quittable : Bool
    getter? overwrites_all = false
    getter? keeps_all = false
    getter? quitted = false
    getter data_containers = [] of AsDataContainer
    getter data_entries = [] of AsDataEntry
    getter entries = [] of RenderingEntry

    def initialize(@out_dir, force, interact, list, color, @per_entry, quit)
      @forces = force
      @interactive = interact
      @listing = list
      @colorizes = color
      @quittable = quit
    end

    def overwrite_all!
      @overwrites_all = true
    end

    def keep_all!
      @keeps_all = true
    end

    def <<(data_container : AsDataContainer)
      data_container.each do |data|
        @data_entries << data
        @entries << RenderingEntry.new(self, data)
      end
      @data_containers << data_container
    end

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
  end
end
