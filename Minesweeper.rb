class Game
end

class Tile
  attr_accessor :state, :adj_bombs, :has_bomb

  def initialize(state, has_bomb)
    @state, @has_bomb = state, has_bomb
  end

end

class Board
  BOMBS_COUNT = 15

  attr_accessor :board, :bomb_coords

  def initialize
    @bomb_coords = bomb_coord_array
    @board = generate
  end

  def display
    @board.map{|i| i.map {|j| j.state } }
  end

  def bomb_coord_array
    bomb_coords = []

    until bomb_coords.count == BOMBS_COUNT
      coord = [rand(9), rand(9)]
      bomb_coords << coord unless bomb_coords.include?(coord)
    end

    bomb_coords
  end

  def needs_bomb?(coord)
    @bomb_coords.include?(coord)
  end

  def generate
    board = Array.new(9) { Array.new(9, nil) }

    board.each_index do |i|
      board[0].each_index do |j|
        board[i][j] = Tile.new(:*, needs_bomb?([i, j]))
      end
    end
  end

  def []=
  end

  def []
  end
end