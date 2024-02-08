-- Implements a simple finite state machine
part = {
    c = nil,
    p = {}
}

function part:spw(x, y, d, s, t, c)
    xd = cos(d)

    add(
        self.p, {
            x = x,
            y = y,
            xd = cos(d),
            yd = sin(d),
            s = s,
            t = t,
            c = c ~= nil and c or rnd(1, 15)
        }
    )
end

function part:update()
    for i in all(self.p) do
        i.t -= 1
        if i.t < 0 then
            del(self.p, i)
            break
        end
        i.x += i.xd * i.s
        i.y += i.yd * i.s
    end
end

function part:draw()
    for i in all(self.p) do
        circfill(i.x, i.y, 1, i.c)
    end
end