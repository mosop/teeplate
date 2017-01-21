module Teeplate
  class DataContainer
    include AsDataContainer

    @entries = [] of AsDataEntry

    def <<(entry : AsDataEntry)
      @entries << entry
    end

    def each
      @entries.each do |i|
        yield i
      end
    end
  end
end
