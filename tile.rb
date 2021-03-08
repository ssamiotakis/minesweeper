class Tile

    attr_accessor :value, :face_up, :flagged, :current

    def initialize
        @value = value
        @face_up = false
        @flagged = false 
        @current = false
    end

end