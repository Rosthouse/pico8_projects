pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

#include include/math.lua

function _init()
  test_lerp()
  test_ilerp()
end

function test(actual, expected)
  if actual != expected then
    print("expected " .. expected .. " but got " .. actual .. " instead")
  end
end

function test_lerp()
  print("testing lerp")
  test(lerp(0, 1, 0.5), 0.5)
  test(lerp(0, 1, 0), 0)
  test(lerp(0, 1, 1), 1)
  test(lerp(500, 1000, 0.5), 750)
end

function test_ilerp()
  print("testing ilerp")
  test(ilerp(0, 1, 0.5), 0.5)
  test(ilerp(0, 1, 0), 0)
  test(ilerp(0, 1, 1), 1)
  test(ilerp(500, 1000, 750), 0.5)
  test(ilerp(500, 1000, 500), 0)
  test(ilerp(500, 1000, 1000), 1)
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000