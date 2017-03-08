module Teeplate
  struct StringData
    include AsDataEntry

    getter path : String
    getter string : String
    getter perm : Int32
    getter? forces : Bool

    def initialize(@path, @string, @perm = 0o644, force = false)
      @forces = force
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
