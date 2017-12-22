module Teeplate
  class FileEntryCollector
    @dir : String
    @relative_dir : String?

    def initialize(@dir, @relative_dir)
    end

    def each_file(abs, rel, &block : String, String ->)
      Dir.open(abs) do |d|
        d.each_child do |entry|
          each_file abs, rel, entry, &block
        end
      end
    end

    def each_file(abs, rel, entry, &block : String, String ->)
      rel = rel ? File.join(rel, entry) : entry
      abs = File.join(abs, entry)
      if Dir.exists?(abs)
        each_file abs, rel, &block
      else
        block.call abs, rel
      end
    end

    @entries : Array(AsDataEntry)?

    def entries
      @entries ||= begin
        a = [] of AsDataEntry
        each_file(@dir, @relative_dir) do |abs, rel|
          a << FileData.new(abs, rel)
        end
        a
      end
    end
  end
end
