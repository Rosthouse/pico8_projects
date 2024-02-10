-- Implements a simple finite state machine
part = {
  c = nil,
  p = {}
}

function part:spw(x, y, d, s, t, c, ss, es)
  xd = cos(d)
  add(self.p, { x = x, y = y, xd = cos(d), yd = sin(d), s = s, tm = t, t = 0, c = c, ss = ss, es = es })
end

function part:update()
  for i in all(self.p) do
    i.t += 1
    if i.t >= i.tm then
      del(self.p, i)
      break
    end
    i.x += i.xd * i.s
    i.y += i.yd * i.s
  end
end

function part:draw()
  for i in all(self.p) do
    local s = lerp(i.ss, i.es, i.t / i.tm)
    circfill(i.x, i.y, s, i.c)
  end
end