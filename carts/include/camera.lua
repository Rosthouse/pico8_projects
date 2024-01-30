shk_int=0

function shk_add(p)
   assert(p != nil)
   shk_int += p 
end

function shake()
    if shk_int == 0 then return end
    local s_x=rnd(shk_int) - (shk_int/2)
    local s_y=rnd(shk_int) - (shk_int/2)
    camera(s_x, s_y)
    shk_int = (shk_int <= .3 and 0 or shk_int * .9)
end
