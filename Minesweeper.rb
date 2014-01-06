require 'yaml'
require 'time'

class Game
  def initialize
    @board = Board.new
  end

  def play

    loop do
      turn_result = turn
      break if turn_result == :Q

      if won?
        puts "You won!"
        break
      elsif lost?(turn_result)
        puts "You lost"
        @board.display_bombs
        break
      end
    end

  end

  def lost?(turn_result)
    turn_result == :B
  end

  def won?
    @board.won?
  end

  def turn
    @board.display
    puts "\nEnter F to flag a tile or R to reveal a tile.
      Then enter the row number and column (1-9). Enter S
      to save."

    letter, row, column = gets.chomp.downcase.split("")
    row, column = row.to_i - 1, column.to_i - 1

    parse_input(letter, row, column)
  end

  def parse_input(letter, row, column)
    turn_result = nil

    case letter
    when "f"
      @board.board[row][column].flag
    when "r"
      turn_result = @board.reveal(row,column)
    when "s"
      puts "Game saved. Goodbye."
      save
      turn_result = :Q
    when "l"
      load
    when "q"
      puts "Goodbye"
      turn_result = :Q
    else
      puts "Try again!"
    end

    turn_result
  end

  def load(filename = nil)
    begin
      if filename.nil?
        puts "Enter filename:"
        filename = gets.chomp.downcase
      end
      file = File.read(filename)
      @board = YAML::load(file)
    rescue
      puts "File not found"
      filename = nil
      retry
    end
  end

  private

    def save
      filename = Time.now.strftime("%y%m%d%H%M%S-minesweeper.txt")
      File.open(filename, 'w') do |file|
        file.puts(@board.to_yaml)
      end
    end
end

class Tile
  attr_accessor :state, :adj_bombs, :has_bomb

  def initialize(state, has_bomb, adj_bombs)
    @state, @has_bomb = state, has_bomb
    @adj_bombs = adj_bombs
  end

  def flagged?
    @state == :F
  end

  def has_bomb?
    @has_bomb
  end

  def reveal
    if has_bomb?
      @state = :B
    else
      @adj_bombs == 0 ? @state = :_ : @state = @adj_bombs unless flagged?
    end
    @state
  end

  def flag
    @state == :F ? @state = :* : @state = :F
    nil
  end
end

class Board
  BOMBS_COUNT = 15
  NEIGHBORS = [[-1, -1], [-1, 0], [-1, 1], [0, -1],
                  [0, 1], [1, -1], [1, 0], [1, 1]]

  attr_accessor :board

  def initialize
    @board = make_board
  end

  def reveal(row, col)
    turn_result = @board[row][col].reveal
    if turn_result == :_
      NEIGHBORS.each do |neighbor|
        n_row, n_col = row + neighbor[0], col + neighbor[1]
        next unless (0..8).include?(n_row) && (0..8).include?(n_col)
        next unless @board[n_row][n_col].state == :*
        self.reveal(n_row,n_col)
      end
    end
    turn_result
  end

  def won?
    @board.each do |row|
      row.each do |cell|
        return false if cell.state == :*
      end
    end
    true
  end

  def display
    view = @board.map do |row|
      row.map do |cell|
        cell.flagged? ? :F : cell.state
      end.join(" ")
    end.join("\n\t\t")
    puts "\t\t" + view
  end

  def display_bombs
    puts @board.map { |i| i.map {|j| j.has_bomb? ? "b" : j.adj_bombs }.join(" ") }.join("\n")
  end

  private

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
    adj_bombs = 0

    NEIGHBORS.each do |neighbor|
      bomb_coords.each do |bomb_coord|
        cell = [neighbor[0] + bomb_coord[0], neighbor[1] + bomb_coord[1]]
        adj_bombs += 1 if cell == coord
      end
    end

    adj_bombs
  end
end

if __FILE__ == $PROGRAM_NAME
  # until ARGV.empty?
  #   ARGV.pop
  # end
  # ARGV = []

  unless ARGV.empty?
    filename = ARGV.pop

    game = Game.new
    game.load(filename)
    game.play
  else
    Game.new.play
  end
end