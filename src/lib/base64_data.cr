module Teeplate
  struct Base64Data
    include AsDataEntry

    getter path : String
    getter size : Int64
    getter encoded : String

    def initialize(@path, @size : Int64, @encoded)
    end

    def size?
      @size
    end

    def write_to(io : IO)
      Base64.decode @encoded, io
    end
  end
end
