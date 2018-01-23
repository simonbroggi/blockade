local function up()
    return 0, -1
end

local function down()
    return 0, 1
end

local function left()
    return -1, 0
end

local function right()
    return 1, 0
end

local function add(x1,y1, x2,y2)
	return x1+x2, y1+y2
end

local function sub(x1,y1, x2,y2)
	return x1-x2, y1-y2
end

local function mul(x,y, f)
	return x*f, y*f
end

local function div(x,y, d)
	return x/d, y/d
end

local function eq(x1,y1, x2,y2)
	return x1 == x2 and y1 == y2
end

local function dot(x1,y1, x2,y2)
	return x1*x2 + y1*y2
end

local function lenSquare(x,y)
    return x*x+y*y
end

local function len(x,y)
    return math.sqrt(lenSquare(x,y))
end

local function reflect(x,y, xn,yn)
    local dot2 = 2*dot(x,y,xn,yn)
    local xnd2,ynd2 = xn*dot2,yn*dot2
    return x-xnd2,y-ynd2
end

return {
    up      = up,
    down    = down,
    left    = left,
    right   = right,

    add = add,
    sub = sub,
    mul = mul,
    div = div,
    eq  = eq,
    dot = dot,
    len = len,
    lenSquare = lenSquare,
    reflect = reflect
}
