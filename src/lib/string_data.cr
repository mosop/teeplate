module Teeplate
  struct StringData
    include AsDataEntry

    getter path : String
    getter string : String
    getter perm : File::Permissions
    getter? forces : Bool

    def initialize(@path, @string, perm : File::Permissions = File::Permissions.from_value(0o644), force = false)
      @perm = perm
      @forces = force
    end

    def size? : UInt64
      @string.size.to_u64
    end

    def perm? : UInt16
      @perm.value.to_u16
    end

    def write_to(io : IO)
      @string.to_s io
    end
  end
end
