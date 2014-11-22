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
local PHASE = 0
local TILE_SIZE = 16
local CAMERA_SPEED = 64
local INTRO_TIME = 2.5
local BUILD_TIME = 1
local PHASE_0_TIME = 10
local PLAYER_ANIM_TIME = 1
local SHROOMS = false

local SCALE = 4
local SCALE_x = 4
local SCALE_y = 4
local SCALE_mx = 0
local SCALE_my = 0

local player = {}
local entitie = {}
local camera = {}
local timer = love.timer.getTime()

local message = ''
local message_show = false
local message_time = 2
local message_speed = 300
local message_pos_x = -100
local progress = {}
local coin = {}
local phase_timer = love.timer.getTime()



function love.load()
    love.window.setMode( 128*8, 128*5)
    love.window.setTitle( "POOM 2 pre-alpha" )
    --love.window.setFullscreen( true ,'desktop')
    love.mouse.setVisible(false)

    love.graphics.setDefaultFilter( 'nearest', 'nearest' )
    love.graphics.setBackgroundColor( 247, 226, 107 )

    -- shaders
    canvas = love.graphics.newCanvas()
    canvas_gui = love.graphics.newCanvas()
    shader = love.graphics.newShader("shaders/SCALE4xhq.frag")    --hader:send('outputSize', {love.graphics.getWidth(), love.graphics.getHeight()})

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

    -- map variables
    map_offset_x = 0
    map_offset_y = 0
    map_display_w = math.floor(love.window.getWidth()/TILE_SIZE/SCALE)+3
    map_display_h = math.floor(love.window.getHeight()/TILE_SIZE/SCALE)+3

    center_x = math.floor(love.window.getWidth()/TILE_SIZE)
    center_y = math.floor(love.window.getHeight()/TILE_SIZE)
    center_real_x = math.floor(love.window.getWidth()*0.5)

    -- map

    map_w = 32
    map_h = 32
    map_x = 2
    map_y = 2

    map = map_create_empty()
    map = map_start(map)

    camera_target_x = 16-math.floor(map_display_w*0.5)
    camera_target_y = 16-math.floor(map_display_h*0.5)

    -- gamepad
    local joysticks = love.joystick.getJoysticks()
    joystick = joysticks[1]

    players_create()

    progress.sprite = love.graphics.newImage('assets/progress.png')
    progress.grid = anim8.newGrid(16, 16, progress.sprite:getWidth(), progress.sprite:getHeight())
    progress.animation = anim8.newAnimation(progress.grid('1-9',1), math.round(PHASE_0_TIME/9,2))

    coin.sprite = love.graphics.newImage('assets/coin.png')
    coin.grid = anim8.newGrid(16, 16, coin.sprite:getWidth(), coin.sprite:getHeight())
    coin.animation = {}
    coin.animation[0] = anim8.newAnimation(coin.grid('1-7',1), 0.1)
    coin.animation[1] = anim8.newAnimation(coin.grid('1-7',1), 0.1)
    coin.animation[2] = anim8.newAnimation(coin.grid('1-7',1), 0.1)
    coin.animation[3] = anim8.newAnimation(coin.grid('1-7',1), 0.1)
    coin.animation[4] = anim8.newAnimation(coin.grid('1-7',1), 0.1)
    coin.animation[1]:gotoFrame(2)
    coin.animation[2]:gotoFrame(3)
    coin.animation[3]:gotoFrame(4)
    coin.animation[4]:gotoFrame(6)
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

function coins_create_on_map()
  for y=0,map_h do
    for x=0,map_w do
      if map[y][x] == 1 or map[y][x] == 3 then
        coin_insert(x,y)
        for i=0,1 do
          if player[i].x == x and player[i].y == y then
            collect_coin(i)
          end
        end
      end
    end
  end
end

function coin_insert(x,y)
  local c = {}
  c.coin = true
  c.x = x
  c.y = y
  c.anim = math.floor(math.random()*#coin.animation)
  table.insert(entitie,c)
end

function love.keypressed(k)
    if k == 'escape' then
        love.event.push('quit') -- Quit the game.
    end
end


function players_create()
  player[0] = {}
  player[0].ready = false
  player[0].score = 0
  player[0].x = 14
  player[0].y = 16
  player[0].sx = 0
  player[0].sy = 0
  player[0].speed = 100
  player[0].standing = true
  player[0].sprite = love.graphics.newImage('assets/player0.png')
  player[0].grid = anim8.newGrid(16, 16, player[0].sprite:getWidth(), player[0].sprite:getHeight())
  player[0].anim_current = 0
  player[0].flip = false
  player[0].animation = {}
  player[0].animation[0] = anim8.newAnimation(player[0].grid('1-2',1), 0.5)
  player[0].animation[1] = anim8.newAnimation(player[0].grid('1-4',2), 0.1)
  player[0].animation[2] = anim8.newAnimation(player[0].grid('1-4',3), 0.1)
  player[0].anim_time = love.timer.getTime()
  player[0].selector = love.graphics.newImage( "assets/selector0.png" )

  player[1] = {}
  player[1].ready = false
  player[1].score = 0
  player[1].x = 17
  player[1].y = 16
  player[1].sx = 0
  player[1].sy = 0
  player[1].speed = 100
  player[1].standing = true
  player[1].sprite = love.graphics.newImage('assets/player1.png')
  player[1].grid = anim8.newGrid(16, 16, player[1].sprite:getWidth(), player[1].sprite:getHeight())
  player[1].anim_current = 0
  player[1].flip = false
  player[1].animation = {}
  player[1].animation[0] = anim8.newAnimation(player[1].grid('1-2',1), 0.5)
  player[1].animation[1] = anim8.newAnimation(player[1].grid('1-4',2), 0.1)
  player[1].animation[2] = anim8.newAnimation(player[1].grid('1-4',3), 0.1)
  player[1].animation[0]:gotoFrame(1)
  player[1].animation[1]:gotoFrame(2)
  player[1].animation[2]:gotoFrame(2)
  player[1].anim_time = love.timer.getTime()
  player[1].selector = love.graphics.newImage( "assets/selector1.png" )
end

function camera_follow(dt)
  camera_target_x = math.floor((player[0].x+player[1].x)*0.5)
  camera_target_y = math.floor((player[0].y+player[1].y)*0.5)

  if camera_target_x > map_x+math.floor(map_display_w*0.5) then
    pan_map('right',dt)
  end
  if camera_target_x < map_x+math.floor(map_display_w*0.5) then
    pan_map('left',dt)
  end
  if camera_target_y > map_y+math.floor(map_display_h*0.5) then
    pan_map('down',dt)
  end
  if camera_target_y < map_y+math.floor(map_display_h*0.5) then
    pan_map('up',dt)
  end
end

function pan_map( key, dt )
  if key == 'down' and map_y<map_h-map_display_h then
    map_offset_y = map_offset_y - (dt*CAMERA_SPEED)
    if(math.abs(map_offset_y)>16)then
      map_offset_y = 0
      map_y = math.min(map_y+1, map_h-map_display_h)
    end
   end

   if key == 'up' and map_y>0 then
    map_offset_y = map_offset_y + (dt*CAMERA_SPEED)
    if(math.abs(map_offset_y)>16)then
      map_offset_y = 0
      map_y = math.max(map_y-1, 0)
    end
   end

   if key == 'right' and map_x<map_w-map_display_w then
    map_offset_x = map_offset_x - (dt*CAMERA_SPEED)
    if(math.abs(map_offset_x)>16)then
      map_offset_x = 0
      map_x = math.min(map_x+1, map_w-map_display_w)
    end
   end

   if key == 'left' and map_x>0 then
    map_offset_x = map_offset_x + (dt*CAMERA_SPEED)
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

function collect_coin(p)
  for i=0,#entitie do
    if entitie[i] then
      if entitie[i].coin and entitie[i].x == player[p].x and entitie[i].y == player[p].y then
        entitie[i].coin = false
        player[p].score = player[p].score + 50
      end
    end
  end
end

function coin_count_all()
  local count = 0

  for i=0,#entitie do
    if entitie[i] then
       if entitie[i].coin then count = count + 1 end
    end
  end

  return count
end

function player_move(i, key, dt)
  bounds = 4

  if key=='right' and player[i].sy + bounds > 0 then
    if player[i].sx + bounds < TILE_SIZE*0.5 then
        player[i].sx = player[i].sx + player[i].speed * dt
        player[i].sy = 0
    else
      if map_proc(1,player[i].x+1, player[i].y) then
        player[i].sx = player[i].sx + player[i].speed * dt
        player[i].sy = 0
        if player[i].sx >= TILE_SIZE*0.5 then
          player[i].sx = -TILE_SIZE*0.5
          player[i].x = player[i].x + 1
          collect_coin(i)
        end
      end
    end
    player[i].flip = false
    player[i].anim_time = love.timer.getTime()
    player[i].anim_current = 1
  end

  if key=='left' and player[i].sy + bounds > 0 then
    if player[i].sx - bounds > -TILE_SIZE*0.5 then
      player[i].sx = player[i].sx - player[i].speed * dt
      player[i].sy = 0
    else
      if map_proc(3,player[i].x-1, player[i].y) then
        player[i].sx = player[i].sx - player[i].speed * dt
        player[i].sy = 0
        if player[i].sx <= -TILE_SIZE*0.5 then
          player[i].sx = TILE_SIZE*0.5
          player[i].x = player[i].x - 1
          collect_coin(i)
        end
      end
    end
    player[i].flip = true
    player[i].anim_time = love.timer.getTime()
    player[i].anim_current = 1
  end

  if key=='down' then
    if player[i].sy < 0 then
      player[i].sy = player[i].sy + player[i].speed * dt
    else
      if map_proc(2,player[i].x, player[i].y+1) then
        player[i].sy = player[i].sy + player[i].speed * dt
        if player[i].sy >= 0 then
          player[i].sy = -TILE_SIZE*0.9
          player[i].y = player[i].y + 1
          collect_coin(i)
        end
      end
    end
    player[i].anim_current = 2
    player[i].anim_time = love.timer.getTime()
    player[i].animation[2]:resume()
  end

  if key=='up' and map_proc(2,player[i].x, player[i].y) then
    if player[i].sy > -TILE_SIZE*0.5 then
      player[i].sy = player[i].sy - player[i].speed * dt
    else
      if map_proc(0,player[i].x, player[i].y-1) then
        player[i].sy = player[i].sy - player[i].speed * dt
        if player[i].sy <= -TILE_SIZE*0.9 then
          player[i].sy = 0
          player[i].y = player[i].y - 1
          collect_coin(i)
        end
      end
    end
    player[i].anim_current = 2
    player[i].anim_time = love.timer.getTime()
    player[i].animation[2]:resume()
  end

  if player[i].sy == 0 then
    player[i].standing = true
  else
    player[i].standing = false
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
            ((x*TILE_SIZE)+map_offset_x-(TILE_SIZE*2)),
            ((y*TILE_SIZE)+map_offset_y-(TILE_SIZE*2)))
        else
          love.graphics.draw(
            back_tile[2+half],
            ((x*TILE_SIZE)+map_offset_x-(TILE_SIZE*2)),
            ((y*TILE_SIZE)+map_offset_y-(TILE_SIZE*2)))
        end

        if map[y+map_y][x+map_x] > 0 then
            love.graphics.draw(
              tile[map[y+map_y][x+map_x]],
              ((x*TILE_SIZE)+map_offset_x-(TILE_SIZE*2)),
              ((y*TILE_SIZE)+map_offset_y-(TILE_SIZE*2)))
        end
      end
   end
end

function draw_player()
  for i=0,1 do
    --if joysticks[i+1] then
      player[i].animation[player[i].anim_current]:resume()
      player[i].animation[player[i].anim_current]:draw(player[i].sprite, ((player[i].x-map_x)*TILE_SIZE)+map_offset_x-(TILE_SIZE*2)+player[i].sx, ((player[i].y-map_y)*TILE_SIZE)+map_offset_y-(TILE_SIZE*2)+player[i].sy)
      player[i].animation[player[i].anim_current]:flip(player[i].flip)
      if player[i].standing and player[i].anim_time > PLAYER_ANIM_TIME then
        player[i].anim_current = 0
        player[i].anim_time = 0
      end
      if not player[i].standing and player[i].anim_time > PLAYER_ANIM_TIME then
        player[i].animation[player[i].anim_current]:pause()
        player[i].anim_time = 0
      end
      love.graphics.draw(
        player[i].selector,
        ((player[i].x-map_x)*TILE_SIZE)+map_offset_x-(TILE_SIZE*2),
        ((player[i].y-map_y)*TILE_SIZE)+map_offset_y-(TILE_SIZE*2))
    --end
  end
end

function draw_entitie()
  local ex, ey, e, i,r

  for i=0,#entitie do
    if entitie[i] then
      e = entitie[i]
      ex = ((e.x-map_x)*TILE_SIZE)+map_offset_x-(TILE_SIZE*2)
      ey = ((e.y-map_y)*TILE_SIZE)+map_offset_y-(TILE_SIZE*2)
      if e.coin then
        coin.animation[e.anim]:draw(coin.sprite, ex, ey)
      end
    end
  end
end

function draw_intro()
  -- love.graphics.setBackgroundColor( 255, 255, 255 )
  --love.graphics.clear()
  local half_x = math.floor(love.window.getWidth()/SCALE)*0.5
  love.graphics.printf("POOM 2 pre-alpha", center_x, center_y, half_x, 'center')
  love.graphics.printf("(c)2014 P1X", center_x, center_y+64, half_x*2, 'center',0,0.5)
end

math.round = function(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function show_message( msg )
  message = msg
  message_show = true
  timer = love.timer.getTime()
  message_pos_x = -100
  message_speed = 300
end

function draw_gui()
  local half_x = math.floor(love.window.getWidth()/SCALE)*0.5
  local half_y = math.floor(love.window.getHeight()/SCALE)*0.5

  p1_state = 'JOIN GAME'
  p2_state = 'JOIN GAME'
  p1_score = '00000000'
  p2_score = '00000000'

  if joysticks[1] then p1_state = 'READY' end
  if joysticks[2] then p2_state = 'READY' end

  love.graphics.printf(player[0].score, half_x-64-8, 2, 128,'right',0,0.5)
  love.graphics.printf(player[1].score, half_x+8, 2, 128, 'left',0,0.5)

  love.graphics.printf('1P '..p1_state, half_x-96-8, 10, 192,'right',0,0.5)
  love.graphics.printf('2P '..p2_state, half_x+8, 10, 192, 'left',0,0.5)

  if PHASE == 0 then
    progress.animation:draw(progress.sprite, half_x-8, 2)
  end

  if message_show then
    if love.timer.getTime()-timer < message_time then
      love.graphics.printf(message, message_pos_x, half_y-24, 0, 'center',0,1.5)
    else
      message_show = false
    end
  end

  --love.graphics.printf(math.floor(10*SCALE_x) .. ' ' .. math.floor(10*SCALE_y), half_x, 14, 0, 'center',0,0.5)
end

function draw_game_over()
  -- body
end

function love.draw()
  love.graphics.scale(SCALE*0.5, SCALE*0.5)
  canvas_gui:clear()
  love.graphics.setCanvas(canvas)

  -- if SHROOMS then
  --   love.graphics.translate(-100*SCALE_mx,100*SCALE_my)
  --   love.graphics.SCALE(SCALE_x, SCALE_y)
  -- else
  --   love.graphics.SCALE(2, 2)
  -- end

  if STATE == 'game' then
    draw_map()
    if PHASE == 1 then
      draw_entitie()
    end
    draw_player()
    -- draw_gui()
  end
  if STATE == 'game_over' then draw_game_over() end

  love.graphics.setCanvas(canvas_gui)

  if STATE == 'intro' then draw_intro() end
  if STATE == 'game' then draw_gui() end

  love.graphics.setCanvas()
  love.graphics.setShader(shader)
  love.graphics.draw(canvas)
  love.graphics.setShader()
  love.graphics.draw(canvas_gui)
end

function build_terrain(type,x,y)
  local new_terrain = -1

  if x > 1 and y > 1 and x <= map_w - 1 and y <= map_w - 1 then

    if type == 'platform' then
      if map[y][x] == 0 then
        new_terrain = 1
      end
      if map[y][x] == 4 then
        new_terrain = 3
      end
      if map[y][x] == 4 and ( map[y-1][x] == 4 or map[y-1][x] == 1 or map[y-1][x] == 3 ) then
        new_terrain = 2
      end

    end

    if type == 'ladder' then
      if map[y][x] == 0 then
        new_terrain = 4
        if map[y-1][x] == 1 then
          map[y-1][x] = 3
        end
      end
      if map[y][x] == 1 or map[y][x] == 3 then
        new_terrain = 2
      end
    end

      if new_terrain > 0 then
        if map[y][x] == 4 and new_terrain == 3 then
          for i=0,1 do
            if player[i].x == x and player[i].y == y then
              player[i].sy = 0
            end
          end
        end
      map[y][x] = new_terrain
    end
  end
end


function love.update(dt)
  local can_move = true
  joysticks = love.joystick.getJoysticks()

  if SHROOMS then
    SCALE_mx = math.sin(love.timer.getTime())*0.25
    SCALE_my = math.sin(love.timer.getTime())*0.25
    SCALE_x = 4 + SCALE_mx
    SCALE_y = 4 - SCALE_my
  end

  if STATE == 'intro' then
    if love.timer.getTime() - timer > INTRO_TIME then
      STATE = 'game'
      phase_timer = love.timer.getTime()
      show_message('BUILD PHASE STARTED')
    end
  end
  if STATE == 'game' then
    camera_follow(dt)
    progress.animation:update(dt)

    if PHASE == 0 then
      if love.timer.getTime() - phase_timer > PHASE_0_TIME then
        PHASE = 1
        phase_timer = love.timer.getTime()
        coins_create_on_map()
        show_message('SURVIVAL PHASE STARTED')
      end
    end

    if PHASE == 1 then
      for i=0,#coin.animation do
       coin.animation[i]:update(dt)
      end
      if coin_count_all() == 0 then
        PHASE = 0
        progress.animation:gotoFrame(1)
        phase_timer = love.timer.getTime()
        show_message('BUILD PHASE STARTED')
      end
    end

    -- KEYBOARD
    can_move = true

    if PHASE == 0 then
      -- build platform
      if love.keyboard.isDown('z') then
        if love.keyboard.isDown('right') then
          build_terrain('platform', player[0].x+1,player[0].y)
        elseif love.keyboard.isDown('left') then
          build_terrain('platform', player[0].x-1,player[0].y)
        else
          build_terrain('platform', player[0].x,player[0].y)
        end
        can_move = false
      end

      -- build ladder
      if love.keyboard.isDown('x') then
        if love.keyboard.isDown('down') then
          build_terrain('ladder', player[0].x,player[0].y+1)
        elseif love.keyboard.isDown('up') then
          build_terrain('ladder', player[0].x,player[0].y-1)
        else
          build_terrain('ladder', player[0].x,player[0].y)
        end
        can_move = false
      end
    end

    if can_move then
      if love.keyboard.isDown('down') then
        player_move(0,'down',dt)
      end

      if love.keyboard.isDown('up') then
        player_move(0,'up',dt)
      end

      if love.keyboard.isDown('right') then
        player_move(0,'right',dt)
      end

      if love.keyboard.isDown('left') then
        player_move(0,'left',dt)
      end
    else
      player[0].px = player[0].x
      player[0].py = player[0].y
    end

    for i=0,1 do
      can_move = true
      player[i].animation[player[i].anim_current]:update(dt)

      -- JOYSTICK
      if joysticks[i+1] then
        joystick = joysticks[i+1]

        --player[i].animation[player[i].anim_current]:update(dt)

        if PHASE == 0 then
          -- build platform
          if joystick:isDown(1) then
            if joystick:getAxis(4)>0 then
              build_terrain('platform', player[i].x+1,player[i].y)
            elseif joystick:getAxis(4)<0 then
              build_terrain('platform', player[i].x-1,player[i].y)
            else
              build_terrain('platform', player[i].x,player[i].y)
            end
            can_move = false
          end

          -- build ladder
          if joystick:isDown(2) then
            if joystick:getAxis(5)>0 then
              build_terrain('ladder', player[i].x,player[i].y+1)
            elseif joystick:getAxis(5)<0 then
              build_terrain('ladder', player[i].x,player[i].y-1)
            else
              build_terrain('ladder', player[i].x,player[i].y)
            end
            can_move = false
          end
        end

        if joystick:isDown(3) then
          SHROOMS = not SHROOMS
          return
        end

        -- move
        if can_move then
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
        else
          player[i].px = player[i].x
          player[i].py = player[i].y
        end
      end
    end

    if message_show then
      message_pos_x = message_pos_x + (message_speed*dt)
      if message_pos_x > love.window.getWidth()/SCALE*0.4 then message_speed = 24 end
      if love.timer.getTime()-timer > message_time*0.8 then message_speed = 400 end
    end

  end
end