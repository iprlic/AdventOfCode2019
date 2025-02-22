#!/usr/bin/env ruby
# frozen_string_literal: true
Command = Struct.new(:type, :args)
Result = Struct.new(:intcode, :pos, :base, :halt, :values)

def command(cmd)
  cmd_s = cmd.to_s

  Command.new((cmd_s[-2..-1] || cmd_s).to_i, cmd_s[0..-3].rjust(3, '0').scan(/\d/).reverse.map(&:to_i))
end

def loc(intcode, type, pos, offset, base)
  address = pos + offset
  case type
  when 0
    intcode[address]
  when 1
    address
  when 2
    intcode[address] + base
  end
end

def compute(intcode, cmd_inputs, pos, base)
  move = 2
  values = []

  loop do
    arg1, arg2, arg3 = nil
    cmd = command(intcode[pos])

    arg1 = loc(intcode, cmd.args[0], pos, 1, base) if cmd.type != 99
    arg2 = loc(intcode, cmd.args[1], pos, 2, base) if [1, 2, 5, 6, 7, 8].include?(cmd.type)
    arg3 = loc(intcode, cmd.args[2], pos, 3, base) if [1, 2, 7, 8].include?(cmd.type)

    case cmd.type
    when 1
      intcode[arg3] = intcode[arg1] + intcode[arg2]
      move = 4
    when 2
      intcode[arg3] = intcode[arg1] * intcode[arg2]
      move = 4
    when 3
      cmd_input = cmd_inputs if cmd_inputs.is_a?(Integer)
      cmd_input = cmd_inputs.shift if cmd_inputs.is_a?(Array)
      intcode[arg1] = cmd_input
      move = 2
    when 4
      values << intcode[arg1]

      return Result.new(intcode, pos + 2, base, false, values) if values.length == 1

      move = 2
    when 5
      unless intcode[arg1].zero?
        pos = intcode[arg2]
        next
      end
      move = 3
    when 6
      if intcode[arg1].zero?
        pos = intcode[arg2]
        next
      end
      move = 3
    when 7
      intcode[arg3] = intcode[arg1] < intcode[arg2] ? 1 : 0
      move = 4
    when 8
      intcode[arg3] = intcode[arg1] == intcode[arg2] ? 1 : 0
      move = 4
    when 9
      base += intcode[arg1]
      move = 2
    when 99
      return Result.new(intcode, pos, base, true, nil)
    else
      puts "Unknown intcode #{cmd.type}"
      abort
    end

    pos += move
  end
end

file_path = File.expand_path('input.txt', __dir__)
input = File.read(file_path).strip

intcode = Hash.new(0)

input.split(',').each_with_index do |code, i|
  intcode[i] = code.to_i if i != 0
  intcode[i] = 2 if i == 0
end

pos = 0
base = 0
result = nil
grid = []
loop do
  result = compute(intcode, 0, pos, base)

  break if result.halt

  grid << "#" if result.values[0] == 35
  grid << "." if result.values[0] == 46
  grid << "\n" if result.values[0] == 10
  grid << "^" if result.values[0] == 94
  grid << "<" if result.values[0] == 60
  grid << ">" if result.values[0] == 62
  grid << "v" if result.values[0] == 118

  pos = result.pos
  base = result.base
end

grid = grid.join.split("\n").map(&:chars)

a = ["L", "6", "L", "4", "R", "8"].join(",")
b = ["R", "8", "L", "6", "L", "4", "L", "10", "R", "8"].join(",")
c = ["L", "4", "R", "4", "L", "4", "R", "8"].join(",")

seq = [a,b,a,c,b,c,b,c,a,b]
seq = ["A", "B", "A", "C", "B", "C", "B", "C", "A", "B"].join(",")


a += "\n"
b +="\n"
c += "\nn\n"
seq += "\n"


code = seq.chars.map(&:ord) + a.chars.map(&:ord) + b.chars.map(&:ord) + c.chars.map(&:ord)



#L 6 L 4 R 8 R 8 L 6 L 4 L 6 4 R 8 L 6 L 4 R 8 L 4 R 4 L 4 R 8 R 8 L 6 L 4 L 6 4 R 8 L4 R 4 L 4 R 8 R 8 L 6 L 4 L 6 4 R 8 L 4 R 4 L 4 R 8 L 6 L 4 R 8 R 8 L 6 L 4 L 6 4 R 8

# L 6 L 4 R 8
# R 8 L 6 L 4 L 6 4 R 8

#      1                              2                        here
#L6 L4 R8 R8 L6 L4 L10 R8 L6 L4 R8 L4 R4 L4 R8 R8 L6 L4 L10 R8 L4 R4 L4 R8 R8 L6 L4 L10 R8 L4 R4 L4 R8 L6 L4 R8 R8 L6 L4 L10 R8

#  L6 L4 R8 R8 L6
#  L4 L10 R8
#  L4 R4 L4 R8

# a b

#  L6 L4 R8 R8
#  L6 L4 L10 R8
#  L4 R4 L4 R8

# L6 L4 R8           a
# R8 L6 L4 L10 R8    b
# L4 R4 L4 R8        c

# L6 L4 R8           a
# R8 L6 L4 L10 R8    b
# L4 R4 L4 R8        c


# a, b, a, c, b, c, b, c, a, b

#code = code.join.chars.map(&:to_i)

# L6 L4 R8           a
# R8 L6 L4 L10 R8    b
# L6 L4 R8           a
# L4 R4 L4 R8        c
# R8 L6 L4 L10 R8    b
# L4 R4 L4 R8        c
# R8 L6 L4 L10 R8    b
# L4 R4 L4 R8        c
# L6 L4 R8           a
# R8 L6 L4 L10 R8    b

# L 6 L 4 R 8 R 8 L 6 L 4 L 10 R 8 L 6 L 4 R 8 L 4 R 4 L 4 R 8 R 8 L 6 L 4 L 10 R 8 L 4 R 4 L 4 R 8 R 8 L 6 L 4 L 10 R 8 L 4 R 4 L 4 R 8 L 6 L 4 R 8 R 8 L 6 L 4 L 10 R 8

#  L 6 L 4 R 8
#  R 8 L 6 L 4 L 10
#  L 4 R 4 L 4 R 8


non_ascii_output = false

while !code.empty?
  pos = 0
  base = 0
  result = nil

  intcode = Hash.new(0)

  input.split(',').each_with_index do |code, i|
    intcode[i] = code.to_i if i != 0
    intcode[i] = 2 if i == 0
  end

  loop do
    result = compute(intcode, code, pos, base)

    break if result.halt


    puts result.values[0] if result.values[0] > 127


    pos = result.pos
    base = result.base
  end
end

