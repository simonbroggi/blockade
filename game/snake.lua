local vector = require("vector")
local denver = require("denver")

Snake = {}
Snake.tick = 0.5
Snake.moveSound  = denver.get({waveform='pinknoise', frequency=900, length=0.04})
Snake.crashSound = denver.get({waveform='pinknoise', frequency=300, length=1.8})

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

function Snake:update(dt)
    self.timeSinceTick = self.timeSinceTick + dt
    if self.timeSinceTick >= self.tick then
        self.timeSinceTick = self.timeSinceTick - self.tick
        self:move(self.foodEaten)
        self.foodEaten = false
        self.moved = true
        love.audio.play(self.moveSound)
    end
end

function Snake:draw()
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
    if grow then
        table.insert(self.positions, nextHeadI*2-1, x)
        table.insert(self.positions, nextHeadI*2,   y)
    else
        nextHeadI = self.headI - 1
        if nextHeadI < 1 then nextHeadI = self:len() end
    end
    
    self.lastHeadingX, self.lastHeadingY = self.headingX, self.headingY
    self.positions[nextHeadI*2-1], self.positions[nextHeadI*2] = x + self.headingX, y + self.headingY
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
function Snake:steerLeft()      self:steer(vector.left())     end
function Snake:steerRight()     self:steer(vector.right())    end
function Snake:steerUp()        self:steer(vector.up())       end
function Snake:steerDown()      self:steer(vector.down())     end


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
