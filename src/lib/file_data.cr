module Teeplate
  struct FileData
    include AsDataEntry

    getter absolute_path : String
    getter path : String
    getter size : UInt64
    getter perm : File::Permissions
    getter? forces : Bool

    def initialize(@absolute_path, @path, size : UInt64? = nil, perm : File::Permissions? = nil, force = false)
      @size = size || File.size(@absolute_path)
      @perm = perm || File.info(@absolute_path).permissions
      @forces = force
    end

    def size? : UInt64
      @size
    end

    def perm? : UInt16
      @perm.value.to_u16
    end

    def write_to(io : IO)
      File.open(@absolute_path) do |f|
        IO.copy f, io
      end
    end
  end
end
