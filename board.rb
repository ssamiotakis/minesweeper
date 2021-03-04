require_relative "tile"
require "byebug"


class Board

    attr_accessor :grid
    
    def initialize
        @grid = create_grid

    end

    def [](pos)
        @grid[pos[0]] [pos[1]].value
    end

    def []=(pos, value)
        @grid[pos[0]][pos[1]].value = value
    end

    def bombs_locations
        bombs = []
        bombs_number = 10
        until bombs.length == 10  do
            pos = [(0..8).to_a.sample, (0..8).to_a.sample]
            bombs << pos unless bombs.include?(pos)
        end
        bombs
    end
    
    def lower(i)
        if i > 0
            lower = i - 1 
        else
            lower = 0
        end
        lower
    end

    def upper(i)
        if i < 8
            upper = i + 1 
        else
            upper = 8
        end
        upper
    end

    def create_grid
        grid_length = 9
        grid = Array.new(grid_length){Array.new(grid_length) {Tile.new}}
        bombs_locations.each {|pos| grid[pos[0]][pos[1]].value = "B"}
        (0...grid_length).each do |i|
            (0...grid_length).each do |j|
                if grid[i][j].value != "B"
                    count = 0
                    (lower(i)..upper(i)).each do |k|
                        (lower(j)..upper(j)).each do |l|
                            count += 1 if grid[k][l].value == "B" 
                        end
                    end
                     if count != 0
                        grid[i][j].value = count.to_s
                    else
                        grid[i][j].value = "_"
                    end
                end
            end
        end
        grid
    end 

    def [](pos)
        @grid[pos[0]] [pos[1]].value
    end

    def []=(pos, value)
        @grid[pos[0]][pos[1]].value = value
    end

    def first_line
        "  " + (0..8).map {|i| i.to_s}.join(" ").colorize(:blue)
    end

    def game_over?(pos)
        if grid[pos[0]][pos[1]].value == "B" && grid[pos[0]][pos[1]].flagged == false
            puts "Game over! Sorry, you stepped on a Bomb!".colorize(:red)
            return true
        end
        false
    end

    def reveal(pos)
        # debugger
        if @grid[pos[0]][pos[1]].value.to_i.between?(1, 8)
            @grid[pos[0]][pos[1]].face_up = true
            return
        end
        if @grid[pos[0]][pos[1]].value == "_"
            @grid[pos[0]][pos[1]].face_up = true
            (lower(pos[0])..upper(pos[0])).each do |k|
                (lower(pos[1])..upper(pos[1])).each do |l|
                    reveal([k, l]) unless k == pos[0] && l == pos[1] || @grid[k][l].face_up == true
                    # render
                end
            end
        end
    end

    def render
        puts "      Minesweeper"
        puts first_line
        render_string = (0...@grid.length).map do |i|
            i.to_s.colorize(:blue) + " " + @grid[i].each_with_index.map do |tile, j|
                if tile.face_up == true
                    tile.value
                elsif tile.flagged == true
                    "F".colorize(:red)
                else
                    "*"
                end
            end.join(" ")
        end.join("\n")
        puts render_string
    end

    def solution_render
        puts " Minewsweeper solution"
        puts first_line
        render_string = (0...@grid.length).map do |i|
            i.to_s.colorize(:blue) + " " + @grid[i].map do |tile|
                if ["B", "F"].include?(tile.value)
                    tile.value.colorize(:red)
                else
                    tile.value
                end
            end.join(" ")
        end.join("\n")
        puts render_string
    end

    def solved?
        (0...@grid.length).each do |i|
            (0...@grid.length).each do |j|
                return false unless @grid[i][j].face_up == true || @grid[i][j].value == "B"
            end
        end 
        true
    end

    def flag_bomb(pos)
        @grid[pos[0]][pos[1]].flagged = true
    end

    def unflag_bomb(pos)
        @grid[pos[0]][pos[1]].flagged = false
    end

    def flagged?(pos)
        @grid[pos[0]][pos[1]].flagged
    end
end



