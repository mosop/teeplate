module Teeplate
  struct StringData
    include AsDataEntry

    getter path : String
    getter string : String

    def initialize(@path, @string)
    end

    def size?
      @string.size
    end

    def write_to(io : IO)
      @string.to_s io
    end
  end
end
