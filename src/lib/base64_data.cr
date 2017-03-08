module Teeplate
  struct Base64Data
    include AsDataEntry

    getter path : String
    getter size : Int64
    getter encoded : String
    getter perm : Int32
    getter? forces : Bool

    def initialize(@path, @size : Int64, @encoded, @perm = 0o644, force = false)
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
