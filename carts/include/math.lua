function lerp(l, u, t)
  return (1 - t) * l + u * t
end

function ilerp(l, u, r)
  return (r - l) / (u - l)
end

function iwrap(v, l, u)
  return l + (v - l) % (u - l)
end