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
        timeSinceTick = 0,
        level = level
    }
    self.__index = self
    setmetatable(inst, self)
    
    return inst
end

function Door:setLevel(level)
    self.level = level
    local x,y = self.x, self.y
    for i=1, self.currentLen do
        local p = self.level:getP(x, y)
        p.go = self
        p.body:setActive(true)
        x,y = x+self.headingX, y+self.headingY
    end
end

function Door:update(dt)
    self.timeSinceTick = self.timeSinceTick + dt
    if self.timeSinceTick >= self.tick then
        self.timeSinceTick = self.timeSinceTick - self.tick
        if self.close and self.currentLen < self.maxLen then
            -- needs to close
            self.currentLen = self.currentLen + 1
            love.audio.play(self.moveSound)

            -- calculate the new coordinates that the door now occupies
            local cx,cy = self.x, self.y 
            cx,cy = cx+self.currentLen*self.headingX, cy+self.currentLen*self.headingY
            
            if self.level then
                p = self.level:getP(cx, cy)
                if p.go then
                    -- p.go
                    local cutIndex = p.go:checkCollision(cx, cy)
                    p.go:cutAtIndex(cutIndex)
                end
                p.go = self
                p.body:setActive(true)
            end
            return true
        elseif (not self.close) and self.currentLen > 1 then
            -- needs to open

            -- calculate the coordinates that the door no longer occupies
            local cx,cy = self.x, self.y 
            cx,cy = cx+self.currentLen*self.headingX, cy+self.currentLen*self.headingY
                        
            self.currentLen = self.currentLen - 1
            love.audio.play(self.moveSound)

            if self.level then
                p = self.level:getP(cx, cy)
                p.go = nil
                p.body:setActive(false)
            end
            return true
        end
    end
    return false
end

function Door:draw(cellWidth, cellHeight)
    love.graphics.setColor(170, 170, 0, 255)
    local x,y = self.x, self.y
    for i=1, self.currentLen do
        love.graphics.rectangle("fill", x * cellWidth-1, y * cellHeight-1, 2-cellWidth, 2-cellHeight)
        x,y = vector.add(x,y, self.headingX,self.headingY)
    end
end

return Door
