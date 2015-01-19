require 'spec_helper'
require './lib/labyrinth.rb'

describe 'Labyrinth' do
  let(:user){ 'developer@example.com' }
  let(:data){
    [
      {roomId: 'a', writing: 'the', order: 5 },
      {roomId: 'b', writing: 'writing', order: 5 },
      {roomId: 'c', writing: 'on', order: 5 },
      {roomId: 'd', writing: 'wall', order: 5 },
      {roomId: 'e', writing: 'xx', order: -1 },
    ]
  }

  subject { Labyrinth.new(user) }

  it { should respond_to(:start) }
  it { should respond_to(:writing) }
  it { should respond_to(:exits) }
  it { should respond_to(:move) }
  it { should respond_to(:broken_lights) }
  it { should respond_to(:code) }

  context '.start' do
    before(:each) do
      stub_request(:any, '/challenge2.airtime.com:7182/start').
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.1', 'X-Labyrinth-Email'=>user}).
        to_return(status: 200, body: JSON({ roomId: 123 }) )
    end

    it { expect(subject.start.include?('roomId')).to  equal(true) }
  end

  context '.writing' do
    before(:each) do
      stub_request(:any, '/challenge2.airtime.com:7182/wall?roomId=123').
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.1', 'X-Labyrinth-Email'=>user}).
        to_return(status: 200, body: JSON({ writing: 'a', order: 1 }) )
    end

    it { expect(subject.writing(123).include?('writing')).to equal(true) }
    it { expect(subject.writing(123).include?('order')).to equal(true) }
  end

  context '.exits' do
    before(:each) do
      stub_request(:any, '/challenge2.airtime.com:7182/exits?roomId=123').
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.1', 'X-Labyrinth-Email'=>user}).
        to_return(status: 200, body: JSON({ exits: ['north','south'] }) )
    end

    it { expect(subject.exits(123).include?('exits')).to equal(true) }
  end

  context '.move' do
    before(:each) do
      stub_request(:any, '/challenge2.airtime.com:7182/move?roomId=123&exit=west').
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.1', 'X-Labyrinth-Email'=>user}).
        to_return(status: 200, body: JSON({ roomId: 456 }) )
    end

    it { expect(subject.move(123,'west').include?('roomId')).to equal(true) }
  end

  context '.broken_lights' do
    it 'should return an array of roomIds' do
      expect(subject.broken_lights(data)).to eq(['e'])
    end
  end

  context '.code' do
    it 'should return the challenge code' do
      expect(subject.code(data)).to eq(data.reject{ |i| i[:writing] == 'xx' }.sort_by{ |i| i[:order] }.collect{|i| i[:writing] }.join(''))
    end

    it 'should not include writings of xx' do
      expect(subject.code(data)).not_to include('xx')
    end
  end
end
