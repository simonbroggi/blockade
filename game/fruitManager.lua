-- holds a group of fruit and where they swawn etc

local vector = require("vector")

local FruitManager = {}

function FruitManager:new()
    local inst = {
        positions = {} --odd:x  even:y
    }
    self.__index = self
    setmetatable(inst, self)
    return inst
end

-- it's a Level item, but has no update..
function FruitManager:setLevel(level)
    self.level = level
end

-- spawn at random location fruit where it's allowed.
-- don't spawn fruit on walls, snakes etc.
-- check level:getP(x, y) if there's something there
function FruitManager:spawn(x,y)
    x = x or math.random(self.level.width)
    y = y or math.random(self.level.height)
    local p = self.level:getP(x,y)
    local numGO = 0
    if p.go then
        for _ in pairs(p.go) do
            numGO = numGO + 1
        end
    end
    while p.go and numGO > 0 do
        x = math.random(self.level.width)
        y = math.random(self.level.height)
        p = self.level:getP(x,y)
        numGO = 0
        if p.go then
            for _ in pairs(p.go) do
                numGO = numGO + 1
            end
        end
    end
    table.insert(self.positions, x)
    table.insert(self.positions, y)
    p.body:setActive(true)
    p.go[self] = true
end

-- remove from positions list, but not from levels pGrid.
-- ok because it's removed by a snake that eats it and then takes its position on the pGrid.
-- not ok if it would be removed by a laser or something else that dosn't override the pGrid pos.
function FruitManager:remove(x,y)
    local toRemoveIndex = 0
    for i=1, #self.positions, 2 do
        if self.positions[i] == x and self.positions[i+1] == y then
            toRemoveIndex = i
            break
        end
    end
    if toRemoveIndex > 0 then
        table.remove(self.positions, toRemoveIndex)
        table.remove(self.positions, toRemoveIndex)
    end
    local p = self.level:getP(x,y)
    p.body:setActive(false)
    p.go[self] = nil
end

function FruitManager:update(dt)
    -- not needed?? 
end

function FruitManager:draw(cellWidth, cellHeight)
    love.graphics.setColor(0, 255, 0, 255)
    for i=1, #self.positions, 2 do
        love.graphics.rectangle("fill", self.positions[i] * cellWidth-1, self.positions[i+1] * cellHeight-1, 2-cellWidth, 2-cellHeight)
    end
end

return FruitManager