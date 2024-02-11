pi = 3.14159265359
tau = 2 * pi
function lerp(l, u, t)
  return (1 - t) * l + u * t
end

function ilerp(l, u, r)
  return (r - l) / (u - l)
end

function iwrap(v, l, u)
  return l + (v - l) % (u - l)
end

function r2u(r)
  return r / tau
end

function rot(x, y, r)
  return cos(r) * x - sin(r) * y, sin(r) * x + cos(r) * y
end

function poc(r, a)
  return r * cos(a), r * sin(a)
end