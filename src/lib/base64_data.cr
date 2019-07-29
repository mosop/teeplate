module Teeplate
  struct Base64Data
    include AsDataEntry

    getter path : String
    getter size : UInt64
    getter encoded : String
    getter perm : File::Permissions
    getter? forces : Bool

    def initialize(@path, @size, @encoded, perm : File::Permissions = File::Permissions.from_value(0o644), force = false)
      @perm = perm
      @forces = force
    end

    def size? : UInt64
      @size
    end

    def perm? : UInt16
      @perm.value.to_u16
    end

    def write_to(io : IO)
      Base64.decode @encoded, io
    end
  end
end
