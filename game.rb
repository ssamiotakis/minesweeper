require_relative "board"

class Game

    def initialize
        @board = Board.new
        @pos = []
        @value = 0
    end

    def play
        until @board.solved? do
            system("clear")
            @board.render
            puts "Please enter a position and a chosen number separated with a space character (e.g. '1,2 8')"
            print ">"
            # @board.solution_render
            unless valid?(prompt) 
                system("clear")
                puts "invalid input please try again!"
                sleep(2)
                next
            end
            @board.update_value(@pos, @value)
        end
        system("clear")
        @board.render
        puts "Congratulations you won!"
    end

    def prompt
        pos_value = gets.chomp.split("")
        pos_value
    end

    def valid?(pos_value)
        @pos = [pos_value[0].to_i, pos_value[2].to_i]
        @value = pos_value[4].to_i
        return false if pos_value[1] != "," 
        return false if @pos.any? {|n| !(0..8).include?(n)}
        (1..9).include?(@value)
    end

end


game = Game.new
game.play
    def initialize
    end

    def turn
    end

    def run
        until solved?
            turn
        end
    end


end