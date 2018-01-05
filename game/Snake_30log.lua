local Vector2 = require('Vector2')

local class = require('30log')
local Snake = class("Snake")

function Snake:init(startPosition, direction, startLength)
    --direction should be 1 length and cartesian
    self.direction = direction or Vector2(1, 0)
    local startPosition = startPosition or Vector2(30, 30)
    self.positions = {}
    self.headPositionIndex = 1
    local startLength = startLength or 5
    for i = 1, startLength do
        self.positions[i] = startPosition + ( (-self.direction) * (i-1) )
        print(self.positions[i])
    end
end

function Snake:update(dt)

end

function Snake:draw()
    --local n = 0
    for i=self.headPositionIndex, #self.positions do
        love.graphics.rectangle("fill", self.positions[i].x * cellWidth-1, self.positions[i].y * cellHeight-1, 2-cellWidth, 2-cellHeight)
        --n = n+1
    end
    if self.headPositionIndex > 1 then
        for i=1, self.headPositionIndex-1 do
            love.graphics.rectangle("fill", self.positions[i].x * cellWidth-1, self.positions[i].y * cellHeight-1, 2-cellWidth, 2-cellHeight)
            --n = n+1
        end
    end
end

function Snake:cut(pos)

end

return Snake