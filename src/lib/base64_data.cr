module Teeplate
  struct Base64Data
    getter size : Int64
    getter encoded : String

    def initialize(@size : Int64, @encoded)
    end

    def to_s(io : IO)
      Base64.decode @encoded, io
    end
  end
end
