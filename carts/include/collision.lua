function rbox(x,y,w,h)
  return {x0=x,y0=y,x1=x+w,y1=y+h}
end

function cbox(x,y,r)
  return {x0=x-r,y0=y-r,x1=x+r,y1=y+r}
end

function coll(a, b)
  if a.x0<b.x1
      and a.x1>b.x0
      and a.y0<b.y1
      and a.y1>b.y0 then
    return true
  else
    return false
  end
end