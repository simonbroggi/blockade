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
	return s*f, s*f
end

local function div(x,y, d)
	return x/d, y/d
end

local function eq(x1,y1, x2,y2)
	return x1 == x2 and y1 == y2
end

return {
    up      = up,
    down    = down,
    left    = left,
    right   = right,

    add = add,
    sud = sub,
    mul = mul,
    div = div,
    eq  = eq
}
