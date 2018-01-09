local vector = require("vector")

local Laser = {}
Laser.tick = 0.05
Laser.maxDeflections = 6
local particleImageData = love.image.newImageData(1,1)
particleImageData:setPixel(0,0,200,0,0,255)
Laser.particleImage = love.graphics.newImage(particleImageData)

function Laser:new(x, y, dirX, dirY)
    local inst = {
        x = x,
        y = y,
        dirX = dirX,
        dirY = dirY,
        timeSinceTick = 0,
        segmentList = {},
        numDeflections = 0,
        hitN = 0
    }
    self.__index = self
    setmetatable(inst, self)
    inst:loadParticleSystems()
    return inst
end
function Laser:loadParticleSystems()
    self.particleSystems = {}
    for i=1, self.maxDeflections do
        local ps = love.graphics.newParticleSystem(self.particleImage, 128)
        ps:setParticleLifetime(0.05,0.3)
        ps:setEmissionRate(20)
        ps:setSpeed(60,170)
        ps:setSpread(math.pi*0.8)
        ps:setSizes(3,3,3,3)
        ps:setColors(255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 0) -- Fade to transparency.
        ps:stop()
        self.particleSystems[i] = ps
    end
end

function Laser:update(dt)
    for i,p in ipairs(self.particleSystems) do
        p:update(dt)
    end

    self.timeSinceTick = self.timeSinceTick + dt
    if self.timeSinceTick >= self.tick then
        self.timeSinceTick = self.timeSinceTick - self.tick

        local newNumDeflections = 0

        -- reset segmentList
        for i=1, #self.segmentList do
            self.segmentList[i] = nil
        end
        local startX,startY = self.x*game.cellWidth,self.y*game.cellHeight
        self.segmentList[1] = {
            startX=startX,
            startY=startY,
            dirX=love.mouse.getX()-startX,
            dirY=love.mouse.getY()-startY,
            fraction=1
        }
        
        -- repeat until hit stays false or max deflections reached
        local hit = false
        repeat
            hit = false
            local seg = self.segmentList[#self.segmentList]
            if vector.lenSquare(seg.dirX,seg.dirY) > 0 then
                local dirX,dirY = seg.dirX,seg.dirY
                local endX, endY = seg.startX+dirX, seg.startY+dirY
                self.level.world:rayCast(seg.startX,seg.startY, endX,endY,
                    function(fixture, x,y, xn,yn, fraction)
                        seg.dirX, seg.dirY = x-seg.startX, y-seg.startY
                        seg.fixture = fixture
                        seg.xn,seg.yn = xn,yn
                        seg.fraction = fraction
                        return fraction
                    end
                )
                if seg.fixture then
                    hit=true
                    newNumDeflections=newNumDeflections+1
                    -- there was a hit. it should be the closest. create new segment, update particles
                    local newDirX, newDirY = dirX*(1-seg.fraction), dirY*(1-seg.fraction)
                    newDirX,newDirY = vector.reflect(newDirX,newDirY,seg.xn,seg.yn)
                    local x,y = seg.startX+seg.dirX,seg.startY+seg.dirY
                    self.segmentList[#self.segmentList+1] = {
                        startX=x,
                        startY=y,
                        dirX=newDirX,
                        dirY=newDirY,
                        fraction=1
                    }
                    local ps = self.particleSystems[newNumDeflections]
                    if not ps:isActive() then
                        ps:start()
                    end
                    ps:setPosition(x,y)
                    ps:setDirection(math.atan2(seg.yn,seg.xn))
                end
            end
        until hit == false or newNumDeflections == self.maxDeflections
        if newNumDeflections < self.numDeflections then
            for i=newNumDeflections+1, self.numDeflections do
                self.particleSystems[i]:stop()
            end
        end 
        self.numDeflections = newNumDeflections
    end
end

function Laser:setLevel(level)
    self.level = level
end

function Laser:draw()
    -- draw it according to points found in update
    love.graphics.setBlendMode("add")
    love.graphics.setLineWidth(3)
    love.graphics.setColor(200,0,0,255)
    for i,p in ipairs(self.particleSystems) do
        love.graphics.draw(p)
    end
    for i,s in ipairs(self.segmentList) do
        love.graphics.line(s.startX,s.startY, s.startX+s.dirX,s.startY+s.dirY)
    end
end

return Laser