require 'rubygems'
require 'bundler'
Bundler.setup
require 'em-websocket'
require 'kociemba'
require 'cfop'
require 'rubiks_cube'
require 'benchmark'

Kociemba::Cache.load_all

k_solver = Kociemba::Solver.new
cfop_solver = Cfop::Solver.new

EM.run {
  EM::WebSocket.run(:host => "0.0.0.0", :port => 9292) do |ws|
    puts "Solver server up and running!"

    ws.onopen { |handshake|
      puts "WebSocket connection open"
    }

    ws.onclose { puts "Connection closed" }

    ws.onmessage { |msg|
      puts "Recieved cube: #{msg}"
      solution = nil
      # results = Benchmark.measure { solution = k_solver.solve(msg, max_depth: 21) }
      # results = Benchmark.measure { solution = cfop_solver.solve(msg, parts: :top) }
      # results = Benchmark.measure { solution = cfop_solver.solve(msg, parts: :f2l) }
      results = Benchmark.measure { solution = cfop_solver.solve(msg, parts: :all) }
      puts "Solution: #{solution}"
      payload = {
        solution: solution,
        computeTime: results.real
      }
      ws.send(payload.to_json)
    }
  end
}