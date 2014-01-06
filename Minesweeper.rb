class Game
end

class Tile
  attr_accessor :state, :adj_bombs, :has_bomb

  def initialize(state, has_bomb, adj_bombs)
    @state, @has_bomb = state, has_bomb
    @adj_bombs = adj_bombs
  end

  def has_bomb?
    @has_bomb
  end

  def reveal

  end
end

class Board
  BOMBS_COUNT = 15

  attr_accessor :board

  def initialize
    @board = make_board
    display
  end

  def make_board
    bomb_coords = bomb_coord_array
    board = Array.new(9) { Array.new(9, nil) }

    board.each_index do |i|
      board[0].each_index do |j|
        board[i][j] = Tile.new(:*,
          needs_bomb?(bomb_coords, [i,j]),
          num_adj_bombs(bomb_coords,[i,j]))
      end
    end
    board
  end

  def bomb_coord_array
    bomb_coords = []

    until bomb_coords.count == BOMBS_COUNT
      coord = [rand(9), rand(9)]
      bomb_coords << coord unless bomb_coords.include?(coord)
    end

    bomb_coords
  end

  def needs_bomb?(bomb_coords, coord)
    bomb_coords.include?(coord)
  end

  def num_adj_bombs(bomb_coords, coord)
    neighbors = [[-1, -1], [-1, 0], [-1, 1], [0, -1],
                  [0, 1], [1, -1], [1, 0], [1, 1]]
    adj_bombs = 0
    neighbors.each do |neighbor|
      bomb_coords.each do |bomb_coord|
        cell = [neighbor[0] + bomb_coord[0], neighbor[1] + bomb_coord[1]]
        adj_bombs += 1 if cell == coord
      end
    end
    adj_bombs
  end

  def display
    @board.map do |row|
      row.map do |cell|
        cell.state
      end
    end
  end

  def test_display
    puts @board.map {|i| i.map {|j| j.has_bomb? ? "b" : j.adj_bombs }.join(" ") }.join("\n")
  end

end