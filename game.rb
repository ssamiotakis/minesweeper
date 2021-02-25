require_relative "board"
require "yaml"
require 'colorize'
require "remedy"

class Game

    def initialize
        @board = Board.new
    end

    def play
        timer1 = Time.now.to_i
        previous_sec = t1
        until @board.solved? do
            system("clear")
            timer2 = Time.now.to_i
            if timer2 > previous_sec
                previous_sec += 1 
                puts t2 - t1
            end
            @board.solution_render
            @board.render
            print_prompt_info
            unless valid?(prompt)
                # system("clear")
                puts "invalid input please try again!"
            end
            return unless choose_function_if_not_a_bomb?
        end
        system("clear")
        @board.solution_render
        puts "Congratulations you won!"
    end

    def print_prompt_info
        puts "Please enter a position, followed by a space and then r for reveal and f for flagging and u for unflagging" 
        puts "(e.g. '1,2 r' or '1,2 f' or '1,2 u')"
        print ">"
    end

    def choose_function_if_not_a_bomb?
        case @operation 
        when "r" 
            if @board.flagged?(@pos) 
                puts "Cannot reveal position. Position flagged as Bomb. You have to unflag first."
            else
                return false if @board.game_over?(@pos)
                @board.reveal(@pos) 
            end
        when "f"
                @board.flag_bomb(@pos)
        when "u"
                @board.unflag_bomb(@pos)
        end
        true
    end

    def prompt
        user_input = gets.chomp.split("")
        user_input
    end

    def valid?(user_input)
        @pos = [user_input[0].to_i, user_input[2].to_i]
        @operation = user_input[4]
        return false if user_input[1] != "," 
        return false if @pos.any? {|n| !(0..8).include?(n)}
        ["r", "f", "u"].include?(@operation)
    end
end

game = Game.new
game.play
