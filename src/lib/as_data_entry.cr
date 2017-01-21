module Teeplate
  module AsDataEntry
    abstract def path : String
    abstract def write_to(io : IO)
    abstract def size? : Int64?
  end
end
