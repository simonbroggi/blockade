local vector = require("vector")
local denver = require("denver")

local Door = {}
Door.tick = 0.05
Door.moveSound = denver.get({waveform='brownnoise', frequency=220, length=.03})

function Door:new(x, y, len, headingX, headingY)
    local inst = {
        x = x,
        y = y,
        maxLen = len,
        currentLen = len,
        headingX = headingX,
        headingY = headingY,
        close = true,
        timeSinceTick = 0
    }
    self.__index = self
    setmetatable(inst, self)
    
    return inst
end

function Door:update(dt)
    self.timeSinceTick = self.timeSinceTick + dt
    if self.timeSinceTick >= self.tick then
        self.timeSinceTick = self.timeSinceTick - self.tick
        if self.close and self.currentLen < self.maxLen then
            -- needs to close
            self.currentLen = self.currentLen + 1
            -- todo: check if snake gets cut
        elseif (not self.close) and self.currentLen > 1 then
            -- needs to open
            self.currentLen = self.currentLen - 1
        end
    end
end

function Door:draw()
    love.graphics.setColor(170, 170, 0, 255)
    local x,y = self.x, self.y
    for i=1, self.currentLen do
        love.graphics.rectangle("fill", x * cellWidth-1, y * cellHeight-1, 2-cellWidth, 2-cellHeight)
        x,y = vector.add(x,y, self.headingX,self.headingY)
    end
end

return Door
