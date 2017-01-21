module Teeplate
  # Collects template files from a local directory.
  abstract class FileTree
    # Collects and embeds template files.
    #
    # It runs another macro process that collects template files and embeds the files as code.
    macro directory(dir)
      {{ run(__DIR__ + "/file_tree/macros/directory", dir.id) }}
    end

    @file_entries : Array(AsDataEntry)?
    # Returns collected file entries.
    def file_entries : Array(AsDataEntry)
      @file_entries ||= begin
        files = [] of AsDataEntry
        ____collect_files files
        files
      end
    end

    # Renders all collected file entries.
    #
    # For more information about the arguments, see `Renderer`.
    def render(out_dir, force : Bool = false, interactive : Bool = false, interact : Bool = false, list : Bool = false, color : Bool = false, per_entry : Bool = false, quit : Bool = true)
      renderer = Renderer.new(out_dir, force: force, interact: interactive || interact, list: list, color: color, per_entry: per_entry, quit: quit)
      renderer << file_entries
      renderer.render
      renderer
    end
  end
end
