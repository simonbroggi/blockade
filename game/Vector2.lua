local class = require('30log')
local Vector2 = class("Vector2")

-- Vector class constructor
function Vector2:init(x, y)
  self.x, self.y = x or 0, y or 0
end

-- Custom tostring function, to display vector instance components x and y
function Vector2.__tostring(v)
  return ("Vector2 <%.2f, %.2f>"):format(v.x, v.y)
end

-- Adds two vectors, component-wise
function Vector2.__add(v1, v2)
  local v = Vector2()
  v.x = v1.x + v2.x
  v.y = v1.y + v2.y
  return v
end

-- Substracts two vectors, component-wise
function Vector2.__sub(v1, v2)
  local v = Vector2()
  v.x = v1.x - v2.x
  v.y = v1.y - v2.y
  return v
end

-- Multiplies two vectors, component-wise
function Vector2.__mul(v1, v2)
  local v = Vector2()
  if type(v2) == "number" then
    v.x = v1.x * v2
    v.y = v1.y * v2
  else
    v.x = v1.x * v2.x
    v.y = v1.y * v2.y
  end
  return v
end

-- Divides two vectors, component-wise
function Vector2.__div(v1, v2)
  local v = Vector2()
  if type(v2) == "number" then
    v.x = v1.x / v2
    v.y = v1.y / v2
  else
    v.x = v1.x / v2.x
    v.y = v1.y / v2.y
  end
  return v
end

-- Unary minus vector (similar to vector multiplied by -1)
function Vector2.__unm(v1)
  local v = Vector2()
  v.x = - v1.x
  v.y = - v1.y
  return v
end

-- Vector raised to power n, component-wise
function Vector2.__pow(v1, n)
  local v = Vector2()
  v.x = v1.x ^ n
  v.y = v1.y ^ n
  return v
end

return Vector2