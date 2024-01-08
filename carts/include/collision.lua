

function rbox(x, y, w, h)
    return {x1= x, y1= y, x2=x+w, y2=y+h}
end


function cbox(x, y, r)
    return {x1= x-r, y1=y-r, x2=x+r, y2=y+r}
end

function coll(a, b)
    
    if a.x1 < b.x2 and
    a.x2  > b.x1 and
    a.y1 < b.y2 and
    a.y2 > b.y1 then
        return true
    else
        return false
    end

end