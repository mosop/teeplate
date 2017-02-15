module Teeplate
  struct StringData
    include AsDataEntry

    getter path : String
    getter string : String
    getter perm : Int32

    def initialize(@path, @string, @perm)
    end

    def size?
      @string.size
    end

    def perm?
      @perm
    end

    def write_to(io : IO)
      @string.to_s io
    end
  end
end
