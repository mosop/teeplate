module Teeplate
  struct StringData
    include AsDataEntry

    getter path : String
    getter string : String
    getter perm : UInt32
    getter? forces : Bool

    def initialize(@path, @string, perm : Int::Primitive = 0o644, force = false)
      @perm = perm.to_u32
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
