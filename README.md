# Rubyik's Cube

This repository encapsulates the Rubyik's Cube project itself. The repository is broken into a few parts which are detailed below.

### This project is a work in progress! Everything is still under active development and will thus be sub-optimal

## Parts

### Web Frontend

The 'assets' and 'src' directory hold the web frontend for emulating solving a Rubik's Cube. The frontend is written using React.js and Redux. Cube visualization is powered by a project called [Roofpig](https://github.com/larspetrus/Roofpig). Random cube generation is powered by [cubejs](https://github.com/ldez/cubejs)

To get started, run `yarn install` and then `yarn start`. Open `localhost:8080`. Note you'll also need to have the websocket server running as well.

### WebSocket Server

Super simple [em-websocket](https://github.com/igrigorik/em-websocket) based solving server. Takes random cube state string in and runs it through a solver. The socket response will contain the computation time and the solution string.

You use it, you'll need to make sure you have run `bundle install`. From there, run `ruby lib/rubyiks_cube/server.rb`.

### Cube Detector

This lives under the `scripts` directory. This is the under-development OpenCV based facelet detection code.

To run, make sure you've installed OpenCV v2:

```bash
  # MacOS w/ Homebrew
  brew install opencv@2
```

I had to also set a bundle config setting with the Homebrew OpenCV directory:

```bash
  bundle config build.ruby-opencv "--with-opencv-dir=/usr/local/Cellar/opencv@2/2.4.13.2_2"
```

From there, run `bundle install`. You can then `ruby scripts/cube_detector.rb`. A window will come up with one of the cube fixture files and the associated detection.

`scripts/cube_detector/detector.rb` is loaded dynamically during development via the `listen` gem.

### STLs

This directory holds STL files for the under-development parts of the Rubik's Cube robot.

#### Gear Mount

This part is designed to fit onto an Acrobotics 6mm mount and will hold [this](https://www.aliexpress.com/item/1-sets-0-5M60t-60-teeth-worm-gear-reduction-ratio-1-60-worm-rod-diameter-10mm/32791578952.html?spm=a2g0s.9042311.0.0.s7LLUU) worm/worm gear combination on a 6mm shaft.

#### Gripper

This is the under-development scissor gripper

#### Gear Drill Jig

A simple holder for the gears to make it easier to drill a 3.5mm hole into the face

## Other aspects

* Ruby implementation of the [Kociemba 2-Phase algorithm](http://kociemba.org/cube.htm): https://github.com/wingrunr21/kociemba
* Ruby FFI bindings to [libmpsse](https://github.com/l29ah/libmpsse): https://github.com/wingrunr21/libmpsse/tree/wip
