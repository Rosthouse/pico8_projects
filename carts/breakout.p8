pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

-- breakout+
-- by rosthouse
#include include/collision.lua
#include include/fsm.lua
#include include/particles.lua
#include include/table.lua
#include include/camera.lua
#include include/math.lua

-- Variables
ss = peek(0x5f57) -- screen size
sel = 0 -- menu selection

scr = 0 -- current score

-- Engine Callbacks
function _init()
  cartdata("ch_rosthouse_breakoutplus")

  if dget(0) == 0 then
    dset(0, 1)
    reset_score()
  end

  fsm:add("start", start_update, start_draw, start_init)
  fsm:add("game", game_update, game_draw, game_init)
  fsm:add("score", score_update, score_draw, score_init, score_exit)
  fsm:add("options", options_update, options_draw, options_init)
  fsm:next("start")
end

function _update()
  fsm:current().update()
end

function _draw()
  fsm:current().draw()
end

-- Initialization
b_c = 5 -- block columns
b_r = 3 -- block rows

function setup_blocks(col, row, w, h)
  cls(0)

  for y = 0, row - 1 do
    for x = 0, col - 1 do
      local i = x + y * col
      blocks[i] = {
        x = 25 * x, y = 10 * y, w = 24, h = 8, c = y % 5 + 1, a = true
      }
      print(i .. ": " .. blocks[i].x .. " " .. blocks[i].y)
    end
  end
end

-- general functionality
function read_score(i)
  return {
    score = dget(i*4),
    name = {
      dget(i*4+1), 
      dget(i*4+2), 
      dget(i*4+3)
    }
  }
end

function write_score(i, n, v)
  dset(i*4, v)
  dset(i*4+1, n[1])
  dset(i*4+2, n[2])
  dset(i*4+3, n[3])
end

function reset_score()
  local a = ord("a")
  for i = 1, 5, 1 do
    write_score(i, {a, a, a},  (6 - i) * 10)
  end
end

-- scenes
-- start scene
function start_init()
  sel = 0
end

function start_update()
  if btnp(2) then
    sel = (sel - 1) % 3
    sfx(1)
  elseif btnp(2) or btnp(3) then
    sel = (sel + 1) % 3
    sfx(1)
  end

  if btnp(❎) then
    if sel == 0 then
      fsm:next("game")
    elseif sel == 1 then
      fsm:next("score")
    elseif sel == 2 then
      fsm:next("options")
    end
  end
end

function start_draw()
  cls(0)

  spr(5, 35, 20, 10, 10)
  print("➡️", ss / 2 - 25, ss / 2 + 8 * sel)
  print("start", ss / 2 - 15, ss / 2)
  print("high score", ss / 2 - 15, ss / 2 + 8)
  print("options", ss / 2 - 15, ss / 2 + 16)
end

-- game scene
blocks = {}
paddle = {}
ball = {}
powerups = {}

pwr_s = 2 -- powerup speed
blk = 33 -- block sprite

shki = 2 -- shake intensity
sp_r = 0.9 -- item spawn rate

gm = 0 -- game mode

function game_init()
  local b_w = ss / b_c * 0.75

  setup_blocks(b_c, b_r, b_w, b_w / 3)
  setup_paddle()
  setup_ball(ss)
  gm = 0
end

function setup_paddle()
  -- Set up paddle
  paddle = {
    x = 52,
    y = 112,
    w = 24,
    h = 8,
    sp = 1
  }
end

function setup_ball(size)
  ball = {
    x = paddle.x + 12,
    y = paddle.y - 10,
    r = 2,
    v_x = 1,
    v_y = -0.5,
    c = 13,
    sp = 1
  }
end

function game_update()
  update_paddle()
  update_powerups()
  update_ball()
  part:update()

  if gm == 0 and btnp(5) then
    sfx(3)
    gm = 1
    if btn(0) then
      ball.v_x = -1
    elseif btn(1) then
      ball.v_x = 1
    else
      ball.v_x = 0
    end
  end

  if gm == 0 then return end

  local bb = cbox(ball.x, ball.y, ball.r)
  local pb = rbox(paddle.x, paddle.y, paddle.w, paddle.h)

  -- handle collisions
  if coll(bb, pb) then
    ball.v_y = -1
    sfx(0)
    shk_set(shki)
    ball.v_x = lerp(-1, 1, ilerp(paddle.x, paddle.x + paddle.w, ball.x))
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
        shk_set(shki)
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
  if gm == 0 then
    ball.x = paddle.x + paddle.w / 2
    ball.y = paddle.y - 5
  elseif gm == 1 then
    ball.x = ball.x + ball.v_x * ball.sp
    ball.y = ball.y + ball.v_y * ball.sp
  end

  if ball.x < 0 then ball.v_x *= -1 end
  if ball.x > ss then ball.v_x *= -1 end
  if ball.y < 0 then ball.v_y *= -1 end
  if ball.y > ss then fsm:next("score") end

  if rnd() > 0.8 then
    part:spw(ball.x, ball.y, rnd(), ball.sp / 2, 15)
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

c_t = {
  { 14, 2 },
  { 12, 1 },
  { 10, 9 },
  { 11, 3 },
  { 15, 4 }
}

function game_draw()
  cls()
  part:draw()
  -- Draw blocks
  for i = 0, #blocks, 1 do
    local b = blocks[i]
    if b.a == true then
      pal(c_t[1][1], c_t[b.c][1])
      pal(c_t[1][2], c_t[b.c][2])
      spr(blk, b.x, b.y, 3, 1)
    end
  end
  -- pal()

  for _, p in pairs(powerups) do
    if p.a == true then
      spr(p.sp, p.x, p.y)
    end
  end
  -- Draw player
  local pb = rbox(paddle.x, paddle.y, paddle.w, paddle.h)
  -- rectfill(pb.x0, pb.y0, pb.x1, pb.y1, 9)
  spr(1, paddle.x, paddle.y, 3, 1)

  -- Draw ball
  local bb = cbox(ball.x, ball.y, ball.r)
  circfill(ball.x, ball.y, ball.r, ball.c)

  shake()
end

function spawn_powerup(bi)
  b = blocks[bi]
  add(powerups, { x = b.x + 16, y = b.y, sp = 49, t = 0, a = true })
end

-- score scene
function score_init()
  scr_t = {}
  scr_i = 0
  scr_e = 0

function score_init()
  for i = 1, 5, 1 do
    add(scr_t, read_score(i))
  end

  if scr > 0 then
    for i = 1, 5, 1 do
      if scr > scr_t[i].score then
        scr_i = i
        scr_e = 1
        insert(scr_t, {name={97, 97, 97},score=scr}, i)
        return
      end
    end
    if #scr_t > 5 then
      deli(scr_t, 6)
    end
  end

end

function score_update()
  if scr_e == 0 then
    if btnp(❎) then
      fsm:next("start")
    end
    return
  end
    
  if scr_e > 0 then
    if btnp(❎) then
      scr_e = (scr_e + 1) % 4 
    end

    if btnp(⬆️) then
      scr_t[scr_i].name[scr_e] += 1
    end

  end
end

function score_draw()
  cls()
  print( scr_i .. ", " .. scr_e)
  for i = 1, 5, 1 do
    local v=scr_t[i].score
    local n=scr_t[i].name
    -- check if we are on a line to edit
    -- if ed == i then
    --   n = sub(n, 1, i) .. "\#2" .. sub(n, i+1, #n)
    -- end
    local name = ""
    for j=1,#n,1 do
      if j == scr_e then
        name = name .. "\#2" 
      end
      name = name .. chr(n[j]) .. "\#0"

    end
    -- if yes, anotate the current character with the corresponding background
    print(i .. ". " .. name .. ": ".. scr_t[i].score, ss/2 - 24, ss/2 + i * 8 - 32)
  end
end

function score_exit()
  for i = 1, 5, 1 do
    write_score(i, scr_t[i].name, scr_t[i].score)
  end
  scr = 0
end

-- options screen
function options_init()
  sel = 0
end

function options_update()
  if btnp(2) then
    sel = (sel - 1) % 2
    sfx(1)
  elseif btnp(3) then
    sel = (sel + 1) % 2
    sfx(1)
  end

  if btnp(❎) then
    if sel == 0 then
      reset_score()
      sfx(3)
    else
      fsm:next("start")
    end
  end
end

function options_draw()
  cls(0)
  print("➡️", ss / 2 - 25, ss / 2 + 8 * sel)
  print("clear score", ss / 2 - 15, ss / 2)
  print("back", ss / 2 - 15, ss / 2 + 8)
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
00000000677777777777777777777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000002eeeeeeeeeeeeeeeeeeeeee7000000000000000000000003300000030000300003333330000000000000000000000000000000000000000000000000
000000002eeeeeeeeeeeeeeeeeeeeee7000000000000000000000036630000363003630036666663000000000000000000000000000000000000000000000000
000000002eeeeeeeeeeeeeeeeeeeeee7000000000000000000000363363000363003630003366330000000000000000000000000000000000000000000000000
000000002eeeeeeeeeeeeeeeeeeeeee7000000000000000000003630036300363003630000366300000000000000000000000000000000000000000000000000
000000002eeeeeeeeeeeeeeeeeeeeee7000000000000000000003630036300363003630000366300000000000000000000000000000000000000000000000000
000000002eeeeeeeeeeeeeeeeeeeeee7000000000000000000003630036300363003630000366300000000000000000000000000000000000000000000000000
00000000222222222222222222222226000000000000000000003630036300363003630000366300000000000000000000000000000000000000000000000000
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
00050000160502a0502a0502605015000000000000000000000002600026000240002400023000230002300000000000000000000000000000000000000000000000000000000000000000000000000000000000
