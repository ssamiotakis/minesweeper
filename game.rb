require_relative "board"
require "yaml"
require 'colorize'
require 'leaderboard'
require "redis"


class Game

    def initialize
        @board = Board.new
    end

    def play
        valid_prompt = true
        system("clear")
        timer1 = Time.now.to_i
        previous_sec = timer1
        until @board.solved? do
            system("clear") if valid_prompt
            timer2 = Time.now.to_i
            if timer2 > previous_sec
                previous_sec += 1 
                @timer = timer2 - timer1
                puts "Seconds since the beggining of the game: #{@timer}"
            end
            # @board.solution_render
            @board.render
            print_prompt_info
            valid_prompt = valid?(prompt)
            unless valid_prompt
                system("clear")
                puts "invalid input please try again!"
                # sleep(2)
            else
                return unless choose_function_if_not_a_bomb?
            end
        end
        system("clear")
        @board.solution_render
        puts "Congratulations you won!"
        our_leaderboard
    end

    def our_leaderboard
        highscore_lb = Leaderboard.new('highscores')
        redis = Redis.new
        p redis
        highscore_lb.page_size = 3
        highscore_lb.reverse = true
        if highscore_lb.leaders(1).length < 3 || 
            highscore_lb.leaders(1).length == 3 && highscore_lb.leaders(1)[2][:score] > @timer
            puts "New high score! Please enter your name:"
            highscore_lb.rank_member(gets.chomp, @timer)
        end
        print_leaderboard(highscore_lb.leaders(1))
    end

    def print_leaderboard(leaderboard)
        puts "------------------------------------"
        puts "            HIGH SCORES"
        puts "------------------------------------"
        puts "   Name              Rank    Time"
        puts "------------------------------------"
        (0...leaderboard.length).each do |i|
            puts "   #{leaderboard[i][:member]}  #{" " * (10 - leaderboard[i][:member].length)}      #{leaderboard[i][:rank]}       #{leaderboard[i][:score].to_i}"
        end
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
