-- Implements a simple finite state machine
fsm = {
    c = 0,
    s = {}
}

function fsm:add(key, init, update, draw, exit)
    self.s[key] = {init=init, update=update, draw=draw, exit}
end

function fsm:next(next)
    if self.s[self.c] ~= nil and self.s[self.c].exit ~= nil then
        self.s[self.c].exit()
    end
    self.c = next
    if self.s[self.c].init ~= nil then
       self.s[self.c].init()
    end
end

function fsm:current()
    return self.s[self.c]
end