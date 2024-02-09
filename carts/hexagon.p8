pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
#include include/math.lua

plr_pos = 1
spd = 0.05

function _update()
  sfx(0)
  if btnp(⬅️) then
    plr_pos = iwrap(plr_pos + 1, 1, 7)
  end

  if btnp(➡️) then
    plr_pos = iwrap(plr_pos - 1, 1, 7)
  end

  r += spd
  if r > 1 then r = 0 end
end

off = 15
r = .5
d60=60/360
d30=30/360
function _draw()
  cls()
  dhex(20, 64, 64)
  dhex(60, 64, 64)

  d = lerp(20, 60, r)
  l = lerp(10, 50, 1 - r)
  dhex(d, 64, 64)

  for i = 1, 6, 1 do
    local x1, y1 = poc(1, i * d60)
    line(64 + x1 * 60, 64 + y1 * 60, 64 + x1 * 20, 64 + y1 * 20, i)
  end
  local x,y = poc(1, (plr_pos-1) * d60 + d30)
  spr(1, 56 + x*50, 56 + y*50 , 2, 2)
end

function dhex(f, x, y)
  for i = 1, 6, 1 do
    w = iwrap(i + 1, 1, 7)
    x1, y1 = poc(1, i * 60 / 360)
    x2, y2 = poc(1, w * 60 / 360)
    line(x + x1 * f, y + y1 * f, x + x2 * f, y + y2 * f, i)
  end
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000aa00aa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000aaa0000aaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700000aaaa0000aaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000a8aaa0000aaa8a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070008a8aa0000aa8a8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000a8a8aa0000aa8a8a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000a8a8aa0000aa8a8a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000a8a8aa0000aa8a8a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000aa8aaa0000aaa8aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000aaaeeaa00aaeeaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000aaeeaaccaaeeaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000aaeeaccccaeeaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000aeeaccccaeea0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000eeaaaaaaee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000ee000000ee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000ee000000ee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
93040801182201d220182201d220182201d220182201d220182201d220182201d220182201d220182201d220182201d220182201d220182201d220182201d220182201d220182201d220182201d220182201d220
911000000e723097230e723097230e723097230e723097230e723007030e723007030e723007030e723007030e703007030e703007030e703007030e703007030070300703007030070300703007030070300703
01040801182551d255182551d255182551d255182551d255182551d255182551d255182551d255182551d255182551d255182551d255182551d255182551d255182551d255182551d255182551d255182551d255
01040801182551d255182551d255182551d255182551d255182551d255182551d255182551d255182551d255182551d255182551d255182551d255182551d255182551d255182551d255182551d255182551d255
01040801182551d255182551d255182551d255182551d255182551d255182551d255182551d255182551d255182551d255182551d255182551d255182551d255182551d255182551d255182551d255182551d255
00100000167200e750007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
__music__
00 01054344

