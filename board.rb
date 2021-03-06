# http://copypastecharacter.com/emojis
# encoding: utf-8

require 'colorize'

class Board

  ROWS = 9
  COLS = 9

  PERCENT_BOMBS = 0.1

  def self.valid_pos?(pos)
    row, col = pos

    row.between?(0, ROWS - 1) && col.between?(0, COLS - 1)
  end

  attr_accessor :grid

  def initialize
     @grid = Array.new(ROWS) { Array.new(COLS) do
       Tile.new(rand < PERCENT_BOMBS)
     end }
  end

  def neighbors(pos)
    row, col = pos
    neighbors = []

    [-1,0,1].each do |d_row|
      [-1,0,1].each do |d_col|
        next if [d_row, d_col] == [0, 0]
        new_row = row + d_row
        new_col = col + d_col

        neighbors << [new_row, new_col] if Board.valid_pos?([new_row, new_col])
      end
    end

    neighbors
  end

  def neighbor_bomb_count(pos)
    count = 0

    self.neighbors(pos).each do |neighbor_pos|
      row, col = neighbor_pos
      neighbor = self.grid[row][col]
      count += 1 if neighbor.bomb == true
    end

    count
  end

  def display
    self.grid.each_with_index do |row, row_idx|
      row_str = ""

      row.each_with_index do |tile, col_idx|
        if tile.status == :hidden
          row_str << "⌷"
        elsif tile.status == :flagged
          row_str << "⚑"
        elsif tile.bomb
          row_str << "✹".colorize(:red)
        else
          num = self.neighbor_bomb_count([row_idx, col_idx])
          if num > 0
            row_str << num.to_s
          else
            row_str << "_"
          end
        end
      end

      puts row_str
    end
  end

  def show(pos)
    queue = [pos]

    until queue.empty?
      current_pos = queue.shift

      tile = self[current_pos]

      tile.show

      if self.neighbor_bomb_count(current_pos) == 0 && !tile.bomb
        self.neighbors(current_pos).each do |neighbor_pos|
          neighbor = self[neighbor_pos]
          queue << neighbor_pos if neighbor.status == :hidden
        end
      end
    end
  end

  def flag(pos)
    self[pos].toggle_flag
  end

  def [](pos)
    row, col = pos
    self.grid[row][col]
  end

  def []=(pos, value)
    row, col = pos
    self.grid[row][col] = value
  end

  def lost?
    self.tiles.each do |tile|
      return true if tile.status == :showing && tile.bomb
    end

    false
  end

  def won?
    self.tiles.each do |tile|
      return false if tile.status == :hidden && !tile.bomb
    end

    true
  end

  def tiles
    self.grid.flatten
  end
end
