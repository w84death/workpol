local anim8 = require 'libs.anim8'

local demo_level = love.filesystem.load('levels/level_demo.lua')()
local mx = 0
local my = 0
local pan_speed = 96
local player = {}
local debug = "?"

function love.load()
    love.window.setMode( 128*6, 128*4)
    love.window.setTitle( "i am making a game" )
    love.window.setFullscreen( true ,'desktop')
    love.mouse.setVisible(false)

    love.graphics.setNewFont(12)
    love.graphics.setColor(255,255,255)
    love.graphics.setBackgroundColor(0,0,0)

    -- load sprites
    tile = {}
    for i=1,6 do
      tile[i] = love.graphics.newImage( "assets/tile_0"..i..".png" )
      tile[i]:setFilter( 'nearest', 'nearest' )
    end

    back_tile = {}
    for i=0,2 do
      back_tile[i] = love.graphics.newImage( "assets/back_tile-"..i..".png" )
      back_tile[i]:setFilter( 'nearest', 'nearest' )
    end

    player[0] = {}
    player[0].ready = false
    player[0].x = 8
    player[0].y = 8
    player[0].sx = 0
    player[0].sy = 0
    player[0].speed = 100
    player[0].sprite = love.graphics.newImage('assets/player0.png')
    player[0].sprite:setFilter( 'nearest', 'nearest' )
    player[0].grid = anim8.newGrid(16, 16, player[0].sprite:getWidth(), player[0].sprite:getHeight())
    player[0].animation = anim8.newAnimation(player[0].grid('1-4',1), 0.1)
    player[0].selector = love.graphics.newImage( "assets/selector0.png" )
    player[0].selector:setFilter( 'nearest', 'nearest' )

    player[1] = {}
    player[1].ready = false
    player[1].x = 4
    player[1].y = 6
    player[1].sx = 0
    player[1].sy = 0
    player[1].speed = 100
    player[1].sprite = love.graphics.newImage('assets/player1.png')
    player[1].sprite:setFilter( 'nearest', 'nearest' )
    player[1].grid = anim8.newGrid(16, 16, player[1].sprite:getWidth(), player[1].sprite:getHeight())
    player[1].animation = anim8.newAnimation(player[1].grid('1-4',1), 0.1)
    player[1].selector = love.graphics.newImage( "assets/selector1.png" )
    player[1].selector:setFilter( 'nearest', 'nearest' )

    font = love.graphics.newImageFont("assets/font-0.png",
    " abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    "123456789.,!?-+/():;%&`'*#=[]\"")
    font:setFilter( 'nearest', 'nearest' )
    love.graphics.setFont(font)

    -- set cursor
    cursor = love.mouse.newCursor( "assets/pointer28.png", 8, 0 )
    love.mouse.setCursor(cursor)

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

    -- map
    map = demo_level.map
    map_w = demo_level.map_w
    map_h = demo_level.map_h
    map_x = demo_level.map_x
    map_y = demo_level.map_y

    -- gamepad
    local joysticks = love.joystick.getJoysticks()
    joystick = joysticks[1]

end

function love.keypressed(k)
    if k == 'escape' then
        love.event.push('quit') -- Quit the game.
    end
end

function pan_map( key, dt )
  if key == 'down' and map_y<map_h-map_display_h then
    map_offset_y = map_offset_y - (dt*pan_speed)
    if(math.abs(map_offset_y)>16)then
      map_offset_y = 0
      map_y = math.min(map_y+1, map_h-map_display_h)
    end
   end

   if key == 'up' and map_y>0 then
    map_offset_y = map_offset_y + (dt*pan_speed)
    if(math.abs(map_offset_y)>16)then
      map_offset_y = 0
      map_y = math.max(map_y-1, 0)
    end
   end

   if key == 'right' and map_x<map_w-map_display_w then
    map_offset_x = map_offset_x - (dt*pan_speed)
    if(math.abs(map_offset_x)>16)then
      map_offset_x = 0
      map_x = math.min(map_x+1, map_w-map_display_w)
    end
   end

   if key == 'left' and map_x>0 then
    map_offset_x = map_offset_x + (dt*pan_speed)
    if(math.abs(map_offset_x)>16)then
      map_offset_x = 0
      map_x = math.max(map_x-1, 0)
    end
   end
end

function love.update(dt)

  player[0].animation:update(dt)
  player[1].animation:update(dt)

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


  joysticks = love.joystick.getJoysticks()

  for i=1,2 do
    if joysticks[i] then
      joystick = joysticks[i]

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

function map_proc(key, x, y)
  local tile = map[y][x]
  debug = tile

  if key == 1 or key == 3 then
    if tile == 1 or tile == 4 or tile == 5 then
      return true
    else
      return false
    end
  end

  if key == 2 then
    if tile == 4 or tile == 6 then
      return true
    else
      return false
    end
  end

  if key == 0 then
    if tile == 4 or tile == 5 or tile == 6 then
      return true
    else
      return false
    end
  end

  return false
end

function player_move(i, key, dt)
  i = i - 1
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
   for y=1, map_display_h do
      for x=1, map_display_w do
        if((x+map_x+y+map_y)%2 == 0) then
          love.graphics.draw(
            back_tile[1],
            ((x*tile_size)+map_offset_x-(tile_size*2)),
            ((y*tile_size)+map_offset_y-(tile_size*2)))
        else
          love.graphics.draw(
            back_tile[2],
            ((x*tile_size)+map_offset_x-(tile_size*2)),
            ((y*tile_size)+map_offset_y-(tile_size*2)))
        end

        if map[y+map_y][x+map_x] > 0 and map[y+map_y][x+map_x] < 7 then
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
    player[i].animation:draw(player[i].sprite, ((player[i].x-map_x)*tile_size)+map_offset_x-(tile_size*2)+player[i].sx, ((player[i].y-map_y)*tile_size)+map_offset_y-(tile_size*2)+player[i].sy)
    love.graphics.draw(
      player[i].selector,
      ((player[i].x-map_x)*tile_size)+map_offset_x-(tile_size*2),
      ((player[i].y-map_y)*tile_size)+map_offset_y-(tile_size*2))
  end
end

function draw_gui()
  max_x = math.floor(love.window.getWidth()/scale)
  if not (joysticks[1] or joysticks[2]) then
    love.graphics.printf("SUPER AWESOME! GAME", center_x, center_y, math.floor(max_x*0.5), 'center')
  end

  p1_state = 'JOIN GAME'
  p2_state = 'JOIN GAME'
  p1_score = '00000000'
  p2_score = '00000000'

  if joysticks[1] then p1_state = 'READY' end
  if joysticks[2] then p2_state = 'READY' end

  love.graphics.printf(p1_score.." 1P-"..p1_state, 4, 2, 0, 'left',0,0.5)
  love.graphics.printf(p2_score.." 2P-"..p2_state, max_x-4, 2, 0, 'right',0,0.5)


  --love.graphics.printf(debug, 0, 0, 0, 'left',0,0.5)

end

function love.draw()
  love.graphics.scale(scale, scale)
  draw_map()
  draw_player()
  draw_gui()
end