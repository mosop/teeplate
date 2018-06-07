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
