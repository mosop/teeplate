module Teeplate
  abstract class FileTree
    macro directory(dir)
      {{ run(__DIR__ + "/file_tree/macros/directory", dir.id) }}
    end

    @____data : DataContainer?

    def ____data
      @____data ||= begin
        data = DataContainer.new
        ____collect_data data
        data
      end
    end

    def render(out_dir, force : Bool = false, interactive : Bool = false, interact : Bool = false, list : Bool = false, color : Bool = false, per_entry : Bool = false, quit : Bool = true)
      renderer = Renderer.new(out_dir, force: force, interact: interactive || interact, list: list, color: color, per_entry: per_entry, quit: quit)
      renderer << ____data
      renderer.render
      renderer
    end
  end
end
