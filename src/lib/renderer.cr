module Teeplate
  class Renderer
    getter out_dir : String
    getter? forces : Bool
    getter? interactive : Bool
    getter? listing : Bool
    getter? colorizes : Bool
    getter? quittable : Bool
    getter? overwrites_all = false
    getter? keeps_all = false
    getter? quitted = false

    def initialize(@out_dir, force, @interactive, list, color, quit)
      @forces = force
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

    def quit!
      @quitted = true
    end

    def new_entry(local_path, data)
      RenderingEntry.new(self, local_path, data)
    end
  end
end
