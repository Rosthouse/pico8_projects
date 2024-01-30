pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- Breakout
-- by Rosthouse
#include include/collision.lua
#include include/fsm.lua
#include include/particles.lua
#include include/table.lua
#include include/camera.lua

blk = 33

pwr_s = 2
scene = 0

intensity = 2

blocks = {}
paddle = {}
ball = {}
scenes = {}
powerups = {}

ss = peek(0x5f57)

sel = 0
b_c = 5
b_r = 3
sp_r = 0.9

scr = 0

-- Engine Callbacks
function _init()
		cartdata("ch_rosthouse_breakoutplus")

  fsm:add("start",  start_update, start_draw)
  fsm:add("game", game_update, game_draw, init_game)
  fsm:add("score",  score_update, score_draw, init_score, exit_score)
  fsm:next("start")
end

function _update()
  fsm:current().update()
end

function _draw()
  fsm:current().draw()
end

-- Initialization
function init_game()
  local b_w = ss / b_c * 0.75

  setup_blocks(b_c, b_r, b_w, b_w / 3)
  setup_paddle()
  setup_ball(ss)
end

function setup_blocks(col, row, w, h)
  cls(0)

  for  y = 0, row - 1  do
    for  x = 0, col -1 do
      local i = x + y * col
      blocks[i] = {
        x =  25 * x, y = 10 * y, w = 24, h = 8, c = color(i % 14 + 1), a = true
      }
      print(i .. ": " .. blocks[i].x .. " " .. blocks[i].y)
    end
  end
end

function setup_paddle()
  -- Set up paddle
  paddle.xs = 20
  paddle.ys = 5
  paddle.x = 128 / 2 - paddle.xs / 2
  paddle.y = 128 - 10 - paddle.ys / 2
  paddle.w = 24
  paddle.h = 8
  paddle.sp = 1
end

function setup_ball(size)
  ball.x = paddle.x + 12
  ball.y = paddle.y - 10
  ball.r = 2
  ball.v_x = 1
  ball.v_y = -0.5
  ball.col = color(12)
  ball.sp = 1
end

-- Start Scene
function start_update()
  if btnp(2) or btnp(3) then
  	sel = (sel+1)%3
    sfx(1)
  end
  
  if btnp(❎) and sel == 0 then
  	fsm:next("game")
  end

  if btnp(❎) and sel == 1 then
  	fsm:next("score")
  end
end

function start_draw()
  cls(0)
  
  spr(5, 35, 20, 10, 10)
  print("➡️", ss / 2 - 25, ss/2+8*sel)
  print("start", ss/2 - 15, ss/2)
  print("high score", ss/2 - 15, ss / 2 + 8)
  print("options", ss / 2 - 15, ss/2 + 16)
end

-- Game Scene
function game_update()
  update_paddle()
  update_powerups()
  update_ball()
  part:update()

  local bb = cbox(ball.x, ball.y, ball.r) 
  local pb = rbox(paddle.x, paddle.y, 16, 8)

  -- handle collisions
  if coll(bb, pb) then
    ball.v_y = -1
    sfx(0)
    shk_add(intensity)
    if ball.x > (paddle.x + paddle.w / 2) then
      ball.v_x = 1
    else
      ball.v_x = -1
    end
  end

  for _, p in pairs(powerups) do
    if p.a == true then
      local pwb = rbox(p.x, p.y, 8, 8)
      if coll(pb, pwb) then
        paddle.sp *= 1.1
        del(powerups, p)
        sfx(2)
      end
    end
  end

  for i = 0, #blocks, 1 do
    local b = blocks[i]
    if b.a == true then
      local bbb = rbox(b.x, b.y, b.w, b.h)

      if coll(bbb, bb) then
        shk_add(intensity)
        ball.v_y *= -1
        b.a = false
        ball.sp += 0.1
        scr += 1
        sfx(1)
        if rnd() >= sp_r then
          sp_r = 0.9
          spawn_powerup(i)
        else
          sp_r -= 0.1
        end

      end
    end
  end
end

function update_paddle()
  if btn(0) then paddle.x -= paddle.sp end
  if btn(1) then paddle.x += paddle.sp end

  if paddle.x < 0 then paddle.x = 0 end
  if paddle.x > 128 - 24 then paddle.x = 128 - 24 end
end

function update_ball()
  ball.x = ball.x + ball.v_x * ball.sp
  ball.y = ball.y + ball.v_y * ball.sp

  if ball.x < 0 then ball.v_x *= -1 end
  if ball.x > ss then ball.v_x *= -1 end
  if ball.y < 0 then ball.v_y *= -1 end
  if ball.y > ss then fsm:next("score") end

  if rnd() > 0.8 then
    part:spw(ball.x, ball.y, rnd(), ball.sp/2, 15, 10)
  end

end

function update_powerups()
  for _, p in pairs(powerups) do
    if p.a == true then
      p.y += pwr_s
    end

    if p.y > ss then
      del(powerups, p)
    end
  end
end

function game_draw()
  cls(0)
  part:draw()
  -- Draw blocks
  for i = 0, #blocks, 1 do
    local b = blocks[i]
    if b.a == true then
      pal(7, b.c)
      spr(blk, b.x, b.y, 3, 1)
      pal()
    end
  end

  for _, p in pairs(powerups) do
    if p.a == true then
      spr(p.sp,p.x,p.y)
    end
  end
  -- Draw player
  local pb = rbox(paddle.x, paddle.y, paddle.w, paddle.h)
  -- rectfill(pb.x0, pb.y0, pb.x1, pb.y1, 9)
  spr(1, paddle.x, paddle.y, 3, 1)

  -- Draw ball
  local bb = cbox(ball.x, ball.y, ball.r)
  -- rectfill(bb.x0, bb.y0, bb.x1, bb.y1, 10)
  circfill(ball.x, ball.y, ball.r, 9)

  shake()
end

function spawn_powerup(bi)
  b = blocks[bi]
  add(powerups, {x=b.x +16, y = b.y,sp=49, t=0, a=true})
end

-- score scene
scr_t = {}
scr_i = 0
ed=0
function init_score()
  scr_t = {}
  scr_i = 0
  ed=0
  if dget(0) == 0 then
    -- initialize scoring system
    for i = 1, 5, 1 do
      write_score(i, i * 100, "aaa")
    end
  end

  for i = 1, 5, 1 do
    add(scr_t, read_score(i))
  end

  if scr > 0 then
    for i = 1, 5, 1 do
      if scr > scr_t[i].score then
        scr_i = i
        ed = 1
        insert(scr_t, {name="aaa",score=scr}, i)
        return
      end
    end
  end
end

function read_score(i)
  return {
    name=chr(dget(i*4+1), dget(i*4+2), dget(i*4+3)),
    score = dget(i)
  }
end

function write_score(i, n, v)
  dset(i * 4, v)
  dset(i * 4 + 1, ord(v, 1))
  dset(i * 4 + 2, ord(v, 2))
  dset(i * 4 + 3, ord(v, 3))
end

function score_update()

  if scr_i == 0 then
    if btnp(❎) then
      fsm:next("start")
      return
    end
  end

  if scr_i <= 3 then
    local s_e = scr_t[scr_i]
  end
end

function score_draw()
  cls()
  for i = 1, 5, 1 do
    v=scr_t[i].score
    n=scr_t[i].name
    -- check if we are on a line to edit
    if ed == i then
      n = sub(n, 1, i) .. "\#2" sub(n, i, #n)
    end

    -- if yes, anotate the current character with the corresponding background
    print(i .. ". " .. n .. ": ".. scr_t[i].score, ss/2 - 24, ss/2 + i * 8 - 32)
  end
end

function exit_score()
  for i=1,5,1 do
    write_score(i,scr_t[i].name, scr_t[i].score)
  end
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008888888888888888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700081111111111111111111180000000000003333000000333300000033333300000033000000300003000000000000000000000000000000000000000
00077000811111111111111111111118000000000036666300003666630000366666630000366300003630036300000000000000000000000000000000000000
00077000811111111111111111111118000000000036333630003633363000366333300003633630003630036300000000000000000000000000000000000000
00700700081111111111111111111180000000000036300363003630036300363000000036300363003630363000000000000000000000000000000000000000
00000000008888888888888888888800000000000036300363003630036300363000000036300363003633630000000000000000000000000000000000000000
00000000000000000000000000000000000000000036333630003633363000363333000036333363003636300000000000000000000000000000000000000000
00000000000770000007700000077000000000000036666300003666630000366666300036666663003666300000000000000000000000000000000000000000
00000000000770000007700000077000000000000036333630003633363000363333000036333363003636300000000000000000000000000000000000000000
00000000000700000007000000070000000000000036300363003630036300363000000036300363003633630000000000000000000000000000000000000000
00000000007800000078700000787000000000000036300363003630036300363000000036300363003630363000000000000000000000000000000000000000
00000000087888000078700008887800000000000036333630003630036300366333300036300363003630036300000000000000000000000000000000000000
00000000007770000008700008077000000000000036666300003630036300366666630036300363003630036300000000000000000000000000000000000000
00000000077070000008700007707000000000000003333000000300003000033333300003000030000300003000000000000000000000000000000000000000
00000000070070000007700007007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777777777777777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777777777777777777777000000000000000000000003300000030000300003333330000000000000000000000000000000000000000000000000
00000000777777777777777777777777000000000000000000000036630000363003630036666663000000000000000000000000000000000000000000000000
00000000777777777777777777777777000000000000000000000363363000363003630003366330000000000000000000000000000000000000000000000000
00000000777777777777777777777777000000000000000000003630036300363003630000366300000000000000000000000000000000000000000000000000
00000000777777777777777777777777000000000000000000003630036300363003630000366300000000000000000000000000000000000000000000000000
00000000777777777777777777777777000000000000000000003630036300363003630000366300000000000000000000000000000000000000000000000000
00000000777777777777777777777777000000000000000000003630036300363003630000366300000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000003630036300363003630000366300000000000000000000000000000000000000000000000000
000000000000aa000000000000000000000000000000000000003630036300363003630000366300000000000000000000000000000000000000000000000000
00000000000aa0000000000000000000000000000000000000003630036300363003630000366300000000000000000000000000000000000000000000000000
0000000000aa00000000000000000000000000000000000000000363363000036336300000366300000000000000000000000000000000000000000000000000
000000000000aa000000000000000000000000000000000000000036630000003663000000366300000000000000000000000000000000000000000000000000
00000000000aa0000000000000000000000000000000000000000003300000000330000000033000000000000000000000000000000000000000000000000000
0000000000aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000605008050090500b05000000000000700006000050000500005000060000000001000020000200003000030000300000000000000000000000020000300000000000000000000000000000000000000
000100000b05008050070500705033000360002e000200001b0003400032000340000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000d0500e0501005010050100501105012050130501405014050160501605018050190501a0501c0501e0502105023050250502b05031050360503f0500d0000f000120001300000000000000000000000
