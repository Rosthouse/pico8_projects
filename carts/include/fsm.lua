-- Implements a simple finite state machine
fsm = {
    c = nil,
    s = {}
}

function fsm:add(key, update, draw, init, exit)
    assert(update ~= nil, "No update update given")
    assert(draw ~= nil, "No draw function given")
    local s = {}
    s.update = update
    s.draw = draw
    if init ~= nil then s.init = init else s.init = empty end
    if exit ~= nil then s.exit = exit else s.exit = empty end
    self.s[key] = s
end

function fsm:next(next)
    if self.c ~= nil then self.s[self.c].exit() end
    self.c = next
    self.s[self.c].init()
end

function fsm:current()
    return self.s[self.c]
end

function empty()
end