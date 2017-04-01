module Teeplate
  struct FileData
    include AsDataEntry

    getter absolute_path : String
    getter path : String
    getter size : UInt64
    getter perm : UInt32
    getter? forces : Bool

    def initialize(@absolute_path, @path, size : UInt64? = nil, perm : Int::Primitive? = nil, force = false)
      @size = size || File.size(@absolute_path)
      @perm = if perm
        perm.to_u32
      else
        File.stat(@absolute_path).perm.to_u32
      end
      @forces = force
    end

    def size?
      @size
    end

    def perm?
      @perm
    end

    def write_to(io : IO)
      File.open(@absolute_path) do |f|
        IO.copy f, io
      end
    end
  end
end
