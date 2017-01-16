module Teeplate
  abstract class FileTree
    DIFF = `which diff`.chomp
    GIT = `which git`.chomp
    PROMPT = "overwrite(o)/keep(k)/diff(d)/overwrite all(a)/keep all(n) ? "

    macro directory(dir)
      {{ run(__DIR__ + "/file_tree/macros/directory", dir.id) }}
    end

    @__rendering_entries = [] of RenderingEntry

    def new_renderer(out_dir, force, interactive, list, color, quit)
      Renderer.new(out_dir, force: force, interactive: interactive, list: list, color: color, quit: quit)
    end

    def render(out_dir, force : Bool = false, interactive : Bool = false, list : Bool = false, color : Bool = false, per_entry : Bool = false)
      renderer = new_renderer(out_dir, force: force, interactive: interactive, list: list, color: true, quit: !per_entry)
      begin
        __render do |local_dir, data|
          entry = renderer.new_entry(local_dir, data)
          @__rendering_entries << entry
          if per_entry
            entry.render
          else
            entry.confirm
          end
        end
        @__rendering_entries.each(&.render) unless per_entry
        renderer
      rescue ex : Quit
        renderer
      end
    end
  end
end
