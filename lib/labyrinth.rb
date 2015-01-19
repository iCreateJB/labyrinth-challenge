require 'faraday'
require 'json'

class Labyrinth
  attr_accessor :api, :user

  def initialize(user)
    @user = user
    @api  = api
  end

  def start
    JSON.parse(api.get('/start').body)
  end

  def writing(room)
    JSON.parse(api.get('/wall', { roomId: room } ).body)
  end

  def exits(room)
    JSON.parse(api.get('/exits', { roomId: room } ).body)
  end

  def move(room,direction)
    JSON.parse(api.get('/move', { roomId: room, exit: direction } ).body)
  end

  def broken_lights(data)
    data.select{|i| i[:writing] == 'xx' }.collect{ |i| i[:roomId] }
  end

  def code(data)
    data.reject{ |i| i[:writing] == 'xx' }.sort_by{ |i| i[:order] }.collect{|i| i[:writing] }.join('')
  end

  def submit_report(data)
    report = api.post do |req|
      req.url '/report'
      req.headers['Content-Type'] = 'application/json'
      req.body = JSON({ roomIds: broken_lights(data), challenge: code(data) })
    end
    report.body
  end

private
  def api
    Faraday.new(
      url: 'http://challenge2.airtime.com:7182',
      headers: {'X-Labyrinth-Email'=> @user }
    )
  end
end
