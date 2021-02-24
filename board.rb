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
        # bombs.each {|pos| self.@grid[pos] = "B"}
        p "bombs"
        p bombs
        bombs
    end


    def create_grid
        grid_length = 9
        grid = Array.new(grid_length){Array.new(grid_length) {Tile.new}}
        bombs_locations.each {|pos| grid[pos[0]][pos[1]].value = "B"}
        (0...grid_length).each do |i|
            (0...grid_length).each do |j|
                if grid[i][j].value != "B"
                    if i > 0
                        i_lower = i - 1 
                    else
                        i_lower = 0
                    end
                    if i < grid_length - 1
                        i_upper = i + 1 
                    else
                        i_upper = grid_length - 1
                    end
                    if j > 0
                        j_lower = j - 1 
                    else
                        j_lower = 0
                    end
                    if j < grid_length - 1
                        j_upper = j + 1  
                    else
                        j_upper = grid_length - 1
                    end
                    count = 0
                    (i_lower..i_upper).each do |k|
                        (j_lower..j_upper).each do |l|
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
        "  " + (0..8).map {|i| i.to_s}.join(" ")
    end

    def solution
        Board.from_file("sudoku1_solved.txt")
    end

    def update_value(pos, value)
        @grid[pos[0]][pos[1]].value = value if @grid[pos[0]][pos[1]].given == false
    end

    def render
        puts "      Minesweeper"
        puts first_line
        render_string = (0...@grid.length).map do |i|
            i.to_s + " " + @grid[i].each_with_index.map do |tile, j|
                if tile.given == true
                    tile.value
                else
                    tile.value.to_s.colorize(:red)
                end
            end.join(" ")
        end.join("\n")
        puts render_string
    end

    def solution_render
        puts " Minewsweeper solution"
        puts first_line
        render_string = (0...@grid.length).map do |i|
            i.to_s + " " + @grid[i].map do |tile|
                tile.value
            end.join(" ")
        end.join("\n")
        puts render_string
    end

    def solved?
        (0...@grid.length).each do |i|
            (0...@grid.length).each do |j|
                return false unless @grid[i][j].face_up == true 
            end
        end 
        true
    end

end


board = Board.new
board.solution_render
p board.solved?
