--  P1X, Krzysztof Jankowski
--  (codename) POOM 2
--
--  abstract: two small creatures builds massive
--            constructions because of reasons
--  created: 13-11-2014
--  license: do what you want and dont bother me
--
--  webpage: http://p1x.in
--  twitter: @w84death
--
------------------------------------------------------------

local anim8 = require 'libs.anim8'

local STATE = 'intro'
local camera_speed = 96
local player = {}
local debug = "?"

function love.load()
    love.window.setMode( 128*6, 128*4)
    love.window.setTitle( "POOM 2 pre-alpha" )
    love.window.setFullscreen( true ,'desktop')
    love.mouse.setVisible(false)

    love.graphics.setDefaultFilter( 'nearest', 'nearest' )

    -- load sprites
    tile = {}
    for i=1,7 do
      tile[i] = love.graphics.newImage( "assets/tile_"..i..".png" )
    end

    back_tile = {}
    for i=1,4 do
      back_tile[i] = love.graphics.newImage( "assets/back_tile_"..i..".png" )
    end

    font = love.graphics.newImageFont("assets/font-0.png",
    " abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    "123456789.,!?-+/():;%&`'*#=[]\"")
    love.graphics.setFont(font)

    -- set cursor
    --cursor = love.mouse.newCursor( "assets/pointer28.png", 8, 0 )
    --love.mouse.setCursor(cursor)

    -- sprite vars
    tile_size = 16
    scale = 4

    -- map variables
    map_offset_x = 0
    map_offset_y = 0
    map_display_w = math.floor(love.window.getWidth()/tile_size/scale)+2
    map_display_h = math.floor(love.window.getHeight()/tile_size/scale)+3

    center_x = math.floor(love.window.getWidth()/tile_size)
    center_y = math.floor(love.window.getHeight()/tile_size)
    center_real_x = math.floor(love.window.getWidth()*0.5)

    -- map

    map_w = 32
    map_h = 32
    map_x = 16-math.floor(map_display_w*0.5)
    map_y = 16-math.floor(map_display_h*0.5)-2

    map = map_create_empty()
    map = map_start(map)

    -- gamepad
    local joysticks = love.joystick.getJoysticks()
    joystick = joysticks[1]

    players_create()

end

function map_create_empty()
  local db = {}
  for y=0,map_h do
    db[y] = {}
    for x=0,map_w do
      db[y][x] = 0
    end
  end
  return db
end

function map_start(map)
  map[14][15] = 1
  map[14][16] = 3
  map[14][17] = 1
  map[15][16] = 4
  map[16][13] = 1
  map[16][14] = 1
  map[16][15] = 1
  map[16][16] = 2
  map[16][17] = 1
  map[17][13] = 5
  map[17][14] = 5
  map[17][15] = 5
  map[17][16] = 5
  map[17][17] = 5
  map[18][14] = 5
  map[18][15] = 5
  map[18][16] = 5
  return map
end

function love.keypressed(k)
    if k == 'escape' then
        love.event.push('quit') -- Quit the game.
    end
end


function players_create()
  player[0] = {}
    player[0].ready = false
    player[0].x = 14
    player[0].y = 16
    player[0].sx = 0
    player[0].sy = 0
    player[0].speed = 100
    player[0].sprite = love.graphics.newImage('assets/player0.png')
    player[0].grid = anim8.newGrid(16, 16, player[0].sprite:getWidth(), player[0].sprite:getHeight())
    player[0].animation = anim8.newAnimation(player[0].grid('1-4',1), 0.1)
    player[0].selector = love.graphics.newImage( "assets/selector0.png" )

    player[1] = {}
    player[1].ready = false
    player[1].x = 17
    player[1].y = 16
    player[1].sx = 0
    player[1].sy = 0
    player[1].speed = 100
    player[1].sprite = love.graphics.newImage('assets/player1.png')
    player[1].grid = anim8.newGrid(16, 16, player[1].sprite:getWidth(), player[1].sprite:getHeight())
    player[1].animation = anim8.newAnimation(player[1].grid('1-4',1), 0.1)
    player[1].selector = love.graphics.newImage( "assets/selector1.png" )
end

function pan_map( key, dt )
  if key == 'down' and map_y<map_h-map_display_h then
    map_offset_y = map_offset_y - (dt*camera_speed)
    if(math.abs(map_offset_y)>16)then
      map_offset_y = 0
      map_y = math.min(map_y+1, map_h-map_display_h)
    end
   end

   if key == 'up' and map_y>0 then
    map_offset_y = map_offset_y + (dt*camera_speed)
    if(math.abs(map_offset_y)>16)then
      map_offset_y = 0
      map_y = math.max(map_y-1, 0)
    end
   end

   if key == 'right' and map_x<map_w-map_display_w then
    map_offset_x = map_offset_x - (dt*camera_speed)
    if(math.abs(map_offset_x)>16)then
      map_offset_x = 0
      map_x = math.min(map_x+1, map_w-map_display_w)
    end
   end

   if key == 'left' and map_x>0 then
    map_offset_x = map_offset_x + (dt*camera_speed)
    if(math.abs(map_offset_x)>16)then
      map_offset_x = 0
      map_x = math.max(map_x-1, 0)
    end
   end
end

function map_proc(key, x, y)
  local tile = map[y][x]
  debug = tile

  if key == 1 or key == 3 then
    if tile == 1 or tile == 2 or tile == 3 then
      return true
    else
      return false
    end
  end

  if key == 2 then
    if tile == 2 or tile == 4 then
      return true
    else
      return false
    end
  end

  if key == 0 then
    if tile == 2 or tile == 3 or tile == 4 then
      return true
    else
      return false
    end
  end

  return false
end

function player_move(i, key, dt)
  bounds = 4

  if key=='right' and player[i].sy + bounds > 0 then
    if player[i].sx + bounds < tile_size*0.5 then
        player[i].sx = player[i].sx + player[i].speed * dt
        player[i].sy = 0
    else
      if map_proc(1,player[i].x+1, player[i].y) then
        player[i].sx = player[i].sx + player[i].speed * dt
        player[i].sy = 0
        if player[i].sx >= tile_size*0.5 then
          player[i].sx = -tile_size*0.5
          player[i].x = player[i].x + 1
        end
      end
    end
  end

  if key=='left' and player[i].sy + bounds > 0 then
    if player[i].sx - bounds > -tile_size*0.5 then
      player[i].sx = player[i].sx - player[i].speed * dt
      player[i].sy = 0
    else
      if map_proc(3,player[i].x-1, player[i].y) then
        player[i].sx = player[i].sx - player[i].speed * dt
        player[i].sy = 0
        if player[i].sx <= -tile_size*0.5 then
          player[i].sx = tile_size*0.5
          player[i].x = player[i].x - 1
        end
      end
    end
  end

  if key=='down' then
    if player[i].sy < 0 then
      player[i].sy = player[i].sy + player[i].speed * dt
    else
      if map_proc(2,player[i].x, player[i].y+1) then
        player[i].sy = player[i].sy + player[i].speed * dt
        if player[i].sy >= 0 then
          player[i].sy = -tile_size*0.9
          player[i].y = player[i].y + 1
        end
      end
    end
  end

  if key=='up' and map_proc(2,player[i].x, player[i].y) then
    if player[i].sy > -tile_size*0.9 then
      player[i].sy = player[i].sy - player[i].speed * dt
    else
      if map_proc(0,player[i].x, player[i].y-1) then
        player[i].sy = player[i].sy - player[i].speed * dt
        if player[i].sy <= -tile_size*0.9 then
          player[i].sy = 0
          player[i].y = player[i].y - 1
        end
      end
    end
  end

end

function draw_map()
  local half = 0
   for y=1, map_display_h do
      for x=1, map_display_w do
        if(y+map_y>map_h*0.5) then half = 2 else half = 0 end
        if((x+map_x+y+map_y)%2 == 0) then
          love.graphics.draw(
            back_tile[1+half],
            ((x*tile_size)+map_offset_x-(tile_size*2)),
            ((y*tile_size)+map_offset_y-(tile_size*2)))
        else
          love.graphics.draw(
            back_tile[2+half],
            ((x*tile_size)+map_offset_x-(tile_size*2)),
            ((y*tile_size)+map_offset_y-(tile_size*2)))
        end

        if map[y+map_y][x+map_x] > 0 then
            love.graphics.draw(
              tile[map[y+map_y][x+map_x]],
              ((x*tile_size)+map_offset_x-(tile_size*2)),
              ((y*tile_size)+map_offset_y-(tile_size*2)))
        end
      end
   end
end

function draw_player()
  for i=0,1 do
    if joysticks[i+1] then
      player[i].animation:draw(player[i].sprite, ((player[i].x-map_x)*tile_size)+map_offset_x-(tile_size*2)+player[i].sx, ((player[i].y-map_y)*tile_size)+map_offset_y-(tile_size*2)+player[i].sy)
      love.graphics.draw(
        player[i].selector,
        ((player[i].x-map_x)*tile_size)+map_offset_x-(tile_size*2),
        ((player[i].y-map_y)*tile_size)+map_offset_y-(tile_size*2))
    end
  end
end

function draw_intro()
  love.graphics.setBackgroundColor( 255, 255, 255 )
    --love.graphics.clear()
  local half_x = math.floor(love.window.getWidth()/scale)*0.5
  love.graphics.printf("POOM 2 pre-alpha", center_x, center_y, half_x, 'center')
  love.graphics.printf("(c)2014 P1X", center_x, center_y+64, half_x*2, 'center',0,0.5)
end

function draw_gui()
  local half_x = math.floor(love.window.getWidth()/scale)*0.5

  p1_state = 'JOIN GAME'
  p2_state = 'JOIN GAME'
  p1_score = '00000000'
  p2_score = '00000000'

  if joysticks[1] then p1_state = 'READY' end
  if joysticks[2] then p2_state = 'READY' end

  love.graphics.printf(p1_score, half_x-64-8, 2, 128,'right',0,0.5)
  love.graphics.printf(p2_score, half_x+8, 2, 128, 'left',0,0.5)

  love.graphics.printf('1P '..p1_state, half_x-96-8, 10, 192,'right',0,0.5)
  love.graphics.printf('2P '..p2_state, half_x+8, 10, 192, 'left',0,0.5)

  --love.graphics.printf(debug, 0, 0, 0, 'left',0,0.5)
end

function draw_game_over()
  -- body
end

function love.draw()
  love.graphics.scale(scale, scale)

  if STATE == 'intro' then draw_intro() end
  if STATE == 'game' then
    draw_map()
    draw_player()
    draw_gui()
  end
  if STATE == 'game_over' then draw_game_over() end
end

function love.update(dt)
  joysticks = love.joystick.getJoysticks()

  if STATE == 'intro' then
    if love.keyboard.isDown('return') then
      STATE = 'game'
    end
  end
  if STATE == 'game' then

    if love.keyboard.isDown('down') then
      pan_map('down',dt)
    end

     if love.keyboard.isDown('up') then
      pan_map('up',dt)
     end

     if love.keyboard.isDown('right') then
      pan_map('right',dt)
     end

     if love.keyboard.isDown('left') then
      pan_map('left',dt)
     end

    for i=0,1 do
      if joysticks[i+1] then
        joystick = joysticks[i+1]

        player[i].animation:update(dt)

        if joystick:getAxis(5)>0 then
          player_move(i,'down',dt)
        end

        if joystick:getAxis(5)<0 then
          player_move(i,'up',dt)
        end

        if joystick:getAxis(4)>0 then
          player_move(i,'right',dt)
        end

        if joystick:getAxis(4)<0 then
          player_move(i,'left',dt)
        end
      end
    end

  end
end