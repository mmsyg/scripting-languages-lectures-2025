require 'ruby2d'
require_relative 'components/player'
require_relative 'components/platform'

# window settings
set title: "Mario Ruby2D - Level 1 + Exit"
set width: 800, height: 600
set background: 'blue'

# init player
player = Player.new(x: 50, y: 50)
start_x, start_y = 50, 50

#platforms
platforms = []
platforms << Platform.new(x:   0,   y:   0, width:  10, height: 800, tile_path: 'assets/block.png')
platforms << Platform.new(x:   0,   y: 550, width: 850, height:  50, tile_path: 'assets/floor.png')
platforms << Platform.new(x: 300,  y: 450, width: 200, height:  32)

platforms << Platform.new(x: 605,  y: 520, width:  32, height:  31, tile_path: 'assets/pipe.png')
platforms << Platform.new(x: 703,  y: 470, width:  32, height:  80)
platforms << Platform.new(x: 800,  y: 437, width:  32, height: 113)

platforms << Platform.new(x:1010,  y: 384, width: 132, height:  32)
platforms << Platform.new(x:1350,  y: 466, width: 132, height:  207)
platforms << Platform.new(x:1700,  y: 400, width: 132, height:  32)
platforms << Platform.new(x:2000,  y: 300, width: 132, height:  32)
platforms << Platform.new(x:2300,  y: 280, width: 132, height:  32)



platforms << Platform.new(x:   1750,   y: 550, width: 450, height:  50, tile_path: 'assets/floor.png')
platforms << Platform.new(x:   2400,   y: 550, width: 132, height:  32)
platforms << Platform.new(x:   2650,   y: 550, width: 450, height:  50, tile_path: 'assets/floor.png')
platforms << Platform.new(x:   3100,   y: 0, width: 1000, height:  1000)




#define destiny point 
ExitPt      = Struct.new(:x, :y, :width, :height)
exit_point  = ExitPt.new(2900, 500, 32, 48)
exit_img    = Image.new(
  'assets/peach.png',
  x:      exit_point.x,
  y:      exit_point.y,
  width:  exit_point.width,
  height: exit_point.height
)

camera_x        = 0
game_over       = false
game_over_text  = nil
game_win        = false
game_win_text   = nil

#handle input
on :key_down do |evt|
  case evt.key
  when 'left'  then player.moveLeft  unless game_over || game_win
  when 'right' then player.moveRight unless game_over || game_win
  when 'up'    then player.jump      unless game_over || game_win
  # reset by pressing r
  when 'r'
    if game_over || game_win
      # clear texts
      game_over_text&.remove
      game_win_text&.remove
      # reset player
      player.instance_variable_set(:@x, start_x)
      player.instance_variable_set(:@y, start_y)
      player.sprite.x = start_x
      player.sprite.y = start_y
      player.instance_variable_set(:@vx, 0)
      player.instance_variable_set(:@vy, 0)
      player.instance_variable_set(:@on_ground, false)
      player.sprite.play(animation: :cheer)
      #reset state
      camera_x   = 0
      game_over  = game_win = false
    end
  end
end

on :key_up do |evt|
  case evt.key
  when 'left', 'right'
    player.stopH unless game_over || game_win
  end
end

#main game loop
update do
  next if game_over || game_win

  #update player physics and collisions
  player.update(platforms)

  # check lose condition
  if player.y > Window.height
    game_over      = true
    game_over_text = Text.new(
      "GAME OVER",
      x: Window.width/2 - 150, y: Window.height/2 - 48,
      size: 48, color: 'white'
    )
    next
  end

  #check win condition
  exit_img.x = exit_point.x - camera_x
  exit_img.y = exit_point.y
  if player.collide_with?(exit_point)
    game_win      = true
    game_win_text = Text.new(
      "YOU WIN!",
      x: Window.width/2 - 100, y: Window.height/2 - 48,
      size: 48, color: 'lime'
    )
    next
  end

  #camera calc
  desired_cam_x = player.x - (Window.width/2 - player.width/2)
  camera_x      = [desired_cam_x, 0].max

  #draw platforms
  platforms.each { |p| p.set_screen_position(camera_x) }

  #draw player
  player.sprite.x = player.x - camera_x
  player.sprite.y = player.y
end


# start game
show
