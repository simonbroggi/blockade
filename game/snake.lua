local vector = require("vector")
local denver = require("denver")

local Snake = {}
Snake.tick = 0.1
Snake.moveSound  = denver.get({waveform='pinknoise', frequency=900, length=0.04})
Snake.crashSound = denver.get({waveform='pinknoise', frequency=300, length=.7})

function Snake:new(x, y, len)
    local headingX, headingY = vector.right()
    local inst = {
        headingX = headingX,
        headingY = headingY,
        lastHeadingX = headingX,
        lastHeadingY = headingY,
        timeSinceTick = 0,
        headI = 1,
        foodEaten = false,
        moved = false, -- true if the snake has moved this frame
        dead = false,
        positions = {} -- odd:x even:y
    }
    self.__index = self
    setmetatable(inst, self)

    inst:initPositions(x, y, len)
    
    return inst
end

function Snake:setLevel(level)
    self.level = level
    for i=1, self:len() do
        local x, y = self.positions[i*2-1], self.positions[i*2]
        local p = self.level:getP(x, y)
        if p.body:isActive() or p.go then
            print("initializing snake over level conflict!!")
        end
        p.go = self
        p.body:setActive(true)
    end
end

function Snake:update(dt)
    self.timeSinceTick = self.timeSinceTick + dt
    if self.timeSinceTick >= self.tick then
        self.timeSinceTick = self.timeSinceTick - self.tick
        if self.dead then

        else
            self:move(self.foodEaten)
            self.foodEaten = false
            self.moved = true
        end
    end
end

function Snake:draw(cellWidth, cellHeight)
    love.graphics.setColor(222, 222, 222, 255)
    for i=self.headI, self:len() do
        love.graphics.rectangle("fill", self.positions[i*2-1] * cellWidth-1, self.positions[i*2] * cellHeight-1, 2-cellWidth, 2-cellHeight)
        --n = n+1
    end
    if self.headI > 1 then
        for i=1, self.headI-1 do
            love.graphics.rectangle("fill", self.positions[i*2-1] * cellWidth-1, self.positions[i*2] * cellHeight-1, 2-cellWidth, 2-cellHeight)
            --n = n+1
        end
    end
end

function Snake:move(grow)
    --self:printPositions()
    local nextHeadI = self.headI
    local x,y = self:headPos()
    local nextX, nextY = x + self.headingX, y + self.headingY

    if self.level then -- check collisions
        if nextX <= 0 or nextY <= 0 or nextX >= self.level.width or nextY >= self.level.height then
            print("out of level")
            love.audio.play(self.crashSound)
            self.dead = true
            return
        end
        local p = self.level:getP(nextX, nextY)
        if p.go then
            print("collision!! or is it eatable??")
            love.audio.play(self.crashSound)
            self.dead = true
            return
        else
            p.go = self
            p.body:setActive(true)
        end
    end

    if grow then
        table.insert(self.positions, nextHeadI*2-1, x)
        table.insert(self.positions, nextHeadI*2,   y)
    else
        nextHeadI = self.headI - 1
        if nextHeadI < 1 then nextHeadI = self:len() end
    end
    love.audio.play(self.moveSound)
    
    self.lastHeadingX, self.lastHeadingY = self.headingX, self.headingY

    if self.level and not grow then
        local tailP = self.level:getP(self.positions[nextHeadI*2-1], self.positions[nextHeadI*2])
        tailP.go = nil
        tailP.body:setActive(false)
    end

    self.positions[nextHeadI*2-1], self.positions[nextHeadI*2] = nextX, nextY
    self.headI = nextHeadI
end

-- returns i of positions where positions[i*2-1] = x
function Snake:checkCollision(x,y)
    for i=1, self:len() do
        local sx, sy = self.positions[i*2-1], self.positions[i*2]
        if sx == x and sy == y then
            return i
        end
    end
    return false
end

function Snake:cutAtIndex(cutI)
    if cutI == self.headI then
        self.dead = true
        return
    elseif cutI > self.headI then -- cut on the right of head
        for i=cutI, self:len() do
            self.positions[i*2-1] = nil
            self.positions[i*2] = nil
        end
    else -- cut on the left requires change of headI and shifting positions
        local removeBeforeHead = self.headI - cutI
        for i=1, removeBeforeHead do
            table.remove(self.positions, cutI*2-1)
            table.remove(self.positions, cutI*2-1)
        end
        self.headI = self.headI - removeBeforeHead
    end
end

function Snake:headPos()
    return self.positions[self.headI*2-1], self.positions[self.headI*2]
end

-- set heading but avoid going backwards and colliding
function Snake:steer(x, y)
    if (x == 0 or self.lastHeadingX ~= -x) and (y == 0 or self.lastHeadingY ~= -y) then
        self.headingX, self.headingY = x,y
    end
end
function Snake:steerUp()        self:steer(vector.up())       end
function Snake:steerDown()      self:steer(vector.down())     end
function Snake:steerLeft()      self:steer(vector.left())     end
function Snake:steerRight()     self:steer(vector.right())    end


function Snake:initPositions(x, y, len)
    for i=1, len do
        self.positions[i*2-1], self.positions[i*2] = x - self.headingX*(i-1), y - self.headingY*(i-1)
    end
end

function Snake:len()
    return #self.positions / 2
end

function Snake:printPositions(actualList)
    s = "snake positions: "
    if actualList then
        for i=1, self:len() do
            if i == self.headI then
                s = s.."*"
            end
            s = s .. "(" ..tostring(self.positions[i*2-1]) .. "/" .. tostring(self.positions[i*2]) .. "), "
        end
    else
        s = s.."*"
        for i=self.headI, self:len() do
            s = s .. "(" .. tostring(self.positions[i*2-1]) .. "/" .. tostring(self.positions[i*2]) .. "), "
        end
        if self.headI > 1 then
            for i=1, self.headI-1 do
                s = s .. "(" .. tostring(self.positions[i*2-1]) .. "/" .. tostring(self.positions[i*2]) .. "), "
            end
        end
    end
    print(s)
end

return Snake
