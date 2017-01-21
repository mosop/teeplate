module Teeplate
  module AsDataEntry
    # Returns a path string relative to a base location.
    abstract def path : String

    # Writes this data stream to a specified IO object.
    abstract def write_to(io : IO)

    # Returns data size.
    #
    # If the size can't be determined, returns nil.
    abstract def size? : Int64?
  end
end