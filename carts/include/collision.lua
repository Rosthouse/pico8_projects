function rbox(x, y, w, h)
  return { x0 = x, y0 = y, x1 = x + w, y1 = y + h }
end

function cbox(x, y, r)
  return { x0 = x - r, y0 = y - r, x1 = x + r, y1 = y + r }
end

function coll(a, b)
  if a.x0 < b.x1
      and a.x1 > b.x0
      and a.y0 < b.y1
      and a.y1 > b.y0 then
    return true
  else
    return false
  end
end

function coll_c(a, b)
  local d = (a.x - b.x) ^ 2 + (a.y - b.y) ^ 2
  if d <= (a.r - b.r) ^ 2
      or d <= (a.r + b.r) ^ 2 then
    return true
  end
  return false
end