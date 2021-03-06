require_relative "board"
require "yaml"
require 'colorize'
require 'leaderboard'
require "redis"
require "remedy"

class Game

    include Remedy

    def initialize
        @board = Board.new
    end

    def play
        @pos = [0, 0]
        valid_prompt = true
        # system("clear")
        @timer1 = Time.now.to_i

        until @board.solved? do
            system("clear")
            new_time
            # @board.solution_render
            @board.render
            print_prompt_info
            turn 
            return if @game_over
        end
        system("clear")
        new_time
        # @board.solution_render
        puts "Congratulations you won!"
        our_leaderboard
    end

    def our_leaderboard
        highscore_lb = Leaderboard.new('highscores')
        redis = Redis.new
        begin
        redis.ping
        rescue
            puts "Redis server unavailable to save fastest players."
            return
        end
        highscore_lb.page_size = 3
        highscore_lb.reverse = true
        if highscore_lb.leaders(1).length < 3 || 
            highscore_lb.leaders(1).length == 3 && highscore_lb.leaders(1)[2][:score] > @timer
            puts "New fastest time! Please enter your name:"
            highscore_lb.rank_member(gets.chomp, @timer)
        end
        print_leaderboard(highscore_lb.leaders(1))
    end

    def print_leaderboard(leaderboard)
        # system("clear")
        puts "------------------------------------"
        puts "            FASTEST"
        puts "------------------------------------"
        puts "   Name              Rank    Time"
        puts "------------------------------------"
        (0...leaderboard.length).each do |i|
            puts "   #{leaderboard[i][:member]}  #{" " * (10 - leaderboard[i][:member].length)}      #{leaderboard[i][:rank]}       #{leaderboard[i][:score].to_i}"
        end
    end

    def print_prompt_info
        puts "Please use the arrow keys to choose a position."
        puts "Press 'Spacebar' to reveal it, 'f' to flagg and 'u' to unflagg the position."
        puts "Press 's' to save the game and continue later or 'r' to retrieve the last saved game." 
    end

    def prompt
        user_input = gets.chomp.split("")
        user_input
    end

    def turn
        user_input = Interaction.new
        user_input.loop do |key|
            if key == "\e[A"
                up
            elsif key == "\e[B"
                down
            elsif key ==  "\e[D"
                left
            elsif key == "\e[C"
                right
            elsif key == ?\s
                if @board.flagged?(@pos) 
                    puts "Cannot reveal position. Position flagged as Bomb. You have to unflag first."
                else
                    if @board.game_over?(@pos)
                        @game_over = true
                        break 
                    end
                    @board.reveal(@pos) 
                end
                break
            elsif key ==  "f"
                @board.flag_bomb(@pos)
                break
            elsif key ==  "u"
                @board.unflag_bomb(@pos)
                break
            elsif key ==  "s"
                save_game
                @game_over = true
                break
            elsif key ==  "r"
                retrieve_game
                break
            else
                puts "invalid input."
            end
            system("clear")
            new_time
            # @board.solution_render
            @board.render
            print_prompt_info
        end
        true
    end

    def save_game
        game = {timer1: @timer1, timer: @timer, board: @board, pos: @pos}
        File.open("game.yml", "w") { |file| file.write(game.to_yaml) }
        puts "Your game has been saved"
    end

    def retrieve_game
        game = YAML.load(File.read("game.yml"))
        @timer1 = game[:timer1]
        @timer = game[:timer]
        @board = game[:board]
        @pos = game[:pos]
    end

    def new_time
        timer2 = Time.now.to_i
        @timer = timer2 - @timer1
        puts "Timer: |#{@timer}|"
    end

    def up 
        if @pos[0] > 0
            @board.up(@pos)
            @pos[0] -= 1
        end
    end

    def down 
        if @pos[0] < 8
            @board.down(@pos)
            @pos[0] += 1 
        end
    end

    def right 
        if @pos[1] < 8
            @board.right(@pos)
            @pos[1] += 1
        end
    end

    def left
        if @pos[1] > 0
            @board.left(@pos)
            @pos[1] -= 1 
        end
    end
end

game = Game.new
game.play
