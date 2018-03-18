# Trying to trigger a Travis CI build, remove this line after that :)
module Teeplate
  # Collects template files from a local directory.
  abstract class FileTree

    # Array of paths to skip when performing destroy
    @skip_on_destroy = [] of String

    # Collects and embeds template files.
    #
    # It runs another macro process that collects template files and embeds the files as code.
    macro directory(dir)
      {{ run(__DIR__ + "/file_tree/macros/directory", dir.id) }}
    end

    # Skip directory/file at the given path. The path is relative to the out_dir.
    def skip_on_destroy(path)
      @skip_on_destroy.push(path)
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
      renderer << rendered_file_entries
      renderer.render
      renderer
    end

    # Destroy the rendered files.
    def destroy(out_dir, force : Bool = false, interactive : Bool = false, interact : Bool = false, list : Bool = false, color : Bool = false, per_entry : Bool = false, quit : Bool = true)
      renderer = Renderer.new(out_dir, force: force, interact: interactive || interact, list: list, color: color, per_entry: per_entry, quit: quit)
      renderer << destroy_file_entries
      renderer.destroy(@skip_on_destroy)
      renderer
    end

    # Returns file entries to be rendered.
    #
    # This method just returns the `#file_entries` method's result. To filter entries, override this method.
    def rendered_file_entries
      file_entries
    end

    # :nodoc:
    def destroy_file_entries
      file_entries
    end

    # :nodoc:
    def ____collect_files(files)
    end

    # Collects file entries from the *dir* directory.
    def collect_from(dir, unique = false, relative_dir = nil)
      FileEntryCollector.new(File.expand_path(dir, Dir.current), relative_dir: relative_dir).entries.each do |entry|
        file_entries << entry unless file_entries.find{|i| i.path == entry.path}
      end
    end
  end
end
