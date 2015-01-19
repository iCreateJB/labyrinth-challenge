require './lib/labyrinth'
require 'pry'

@maze_runner   = Labyrinth.new(ENV['user'])
@breadcrumbs   = []

def trail(data)
  @breadcrumbs.push({roomId: data[:roomId], writing: data[:writing], order: data[:order] })
end

def navigate(roomId)
  @maze_runner.exits(roomId)['exits'].each do |i|
    room         = @maze_runner.move(roomId,i)['roomId']
    roomInfo     = @maze_runner.writing(room)
    trail({ roomId: room, writing: roomInfo['writing'], order: roomInfo['order']})
    @maze_runner.exits(room)['exits'].nil? ? next : navigate(room)
  end
end

starting_room = @maze_runner.start['roomId']
wall          = @maze_runner.writing(starting_room)
trail({ roomId: starting_room, writing: wall['writing'], order: wall['order']})

navigate(starting_room)

puts @maze_runner.submit_report(@breadcrumbs)
