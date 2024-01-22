

FSM = {
    curr = 1,
    states = {}
}
function FSM:add_state(init, update, draw)
    add(self.states, {init=init, update=update, draw=draw})
end

function FSM:change_state(next)
    self.curr = next
    if self.states[self.curr].init ~= nil then
       self.states[self.curr].init()
    end
end

