module Teeplate
  struct Base64Data
    include AsDataEntry

    getter path : String
    getter size : UInt64
    getter encoded : String
    getter perm : UInt32
    getter? forces : Bool

    def initialize(@path, @size, @encoded, perm : Int::Primitive = 0o644, force = false)
      @perm = perm.to_u32
      @forces = force
    end

    def size?
      @size
    end

    def perm?
      @perm
    end

    def write_to(io : IO)
      Base64.decode @encoded, io
    end
  end
end
