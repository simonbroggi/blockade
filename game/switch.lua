local Switch = {}

function Switch:new(x,y)
    local inst = {
        x=x,
        y=y,
        pressEvent = {},
        releaseEvent = {},
        noPhysics = true --no active body on physics
    }
    self.__index = self
    setmetatable(inst, self)
    return inst
end

function Switch:setLevel(level)
    self.level = level
    local p = self.level:getP(self.x, self.y)
    p.go[self] = true
    --add to pGrid? how does the pGrid handle multiple objects on the same position?
end

function Switch:press(snake)
    for _, func in pairs(self.pressEvent) do
        func()
    end
end
function Switch:release(snake)
    for _, func in pairs(self.releaseEvent) do
        func()
    end
end

function Switch:update(dt)
    -- need non update level elements
end

function Switch:draw(cellWidth, cellHeight)
    love.graphics.setColor(0.478, 0.45, 0.219, 1)
    love.graphics.rectangle("fill", self.x * cellWidth-1, self.y * cellHeight-1, 2-cellWidth, 2-cellHeight)
end

return Switch