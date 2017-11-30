local level = {}
local denver = require 'denver'
local doorSound=denver.get({waveform='brownnoise', frequency=220, length=.03})

function level.new(width, height)
    local inst = {}
    inst.width = width
    inst.height = height

    function inst:getElement(x, y)
        return self[(y-1)*self.width+x]
    end

    function inst:setElement(x, y, type)
        self[(y-1)*self.width +x] = type
    end

    function inst:addBox(x, y, width, height)
        for _y=y, y+height do
            for _x=x, x+width do
                if _x==x or _x==x+width or _y==y or _y==y+height then
                    self:setElement(_x, _y, "wall")
                end
            end
        end
    end
    function inst:addDoor(hingeX, hingeY, dirX, dirY, len)
        local door = {}
        local x=hingeX
        local y=hingeY
        
        for i=1, len do
            door[i] = {x=x, y=y}
            x=x+dirX
            y=y+dirY
        end

        -- initially close door
        for i=1, #door do
            inst:setElement(door[i].x, door[i].y, "door")
        end
        door.openElements = 0
        door.lastMovedT = love.timer.getTime()
        door.isOpen = false
        door.wantsToBeOpen = false
        -- it's closed

        function door:open()
            if self.wantsToBeOpen == false then
                self.wantsToBeOpen = true
                self.lastMovedT = love.timer.getTime()
            end
        end
        function door:close()
            if self.wantsToBeOpen then
                self.wantsToBeOpen = false
                self.lastMovedT = love.timer.getTime()
            end
        end
        door.switches={}
        function door:addSwitch(x,y)
            inst:setElement(x,y,"switch")
            table.insert(self.switches, {x=x,y=y})
        end

        function door:update(dt)
            local stepedOnAnySwitch = false
            if inst.snakes then
                for i=1, #self.switches do
                    local switch = self.switches[i]
                    for j=1, #inst.snakes do
                        local snake = inst.snakes[j]
                        for k=1, #snake do
                            if switch.x == snake[k][1] and switch.y == snake[k][2] then
                                stepedOnAnySwitch = true
                            end
                        end
                    end
                end
            end
            if stepedOnAnySwitch then
                self:open()
            else
                self:close()
            end

            if self.wantsToBeOpen ~= self.isOpen then
                --print("openingdoor")
                local timeSicneLastMove = love.timer.getTime() - self.lastMovedT
                if timeSicneLastMove >= .05 then
                    if self.wantsToBeOpen then
                        local doorEPos = self[#self-self.openElements]
                        inst:setElement(doorEPos.x, doorEPos.y, nil)
                        love.audio.play(doorSound)
                        self.isOpen = nil
                        self.openElements = self.openElements+1
                        if self.openElements >= #self then
                            self.isOpen = true
                        end
                    else
                        local doorEPos = self[#self-self.openElements+1]
                        inst:setElement(doorEPos.x, doorEPos.y, "door")
                        love.audio.play(doorSound)
                        --todo: cut snake
                        if inst.snakes then
                            for j=1, #inst.snakes do
                                local snake = inst.snakes[j]
                                local stilLiving = snake:cut(doorEPos.x, doorEPos.y)
                            end
                        end
                        self.isOpen = nil
                        self.openElements = self.openElements-1
                        if self.openElements <= 0 then
                            self.isOpen = false
                        end
                    end
                    self.lastMovedT = love.timer.getTime()
                end
            end
        end
        return door
    end

    inst:addBox(1,1,width-1,height-1)
    inst.roomX = 20
    inst.roomY = 16
    inst.roomWidth = 24
    inst.roomHeight = 16
    inst:addBox(inst.roomX, inst.roomY, inst.roomWidth, inst.roomHeight)
    inst.theDoor = inst:addDoor(inst.roomX, inst.roomY,0,1,6)
    inst.theDoor:addSwitch(inst.roomX+inst.roomWidth/4*3, inst.roomY+inst.roomHeight/2)
    inst.goal = {x=width/2, y=height/8}
    inst:setElement(inst.goal.x, inst.goal.y, "goal")

    --print(inst.theDoor.switches[0].x .. " / " .. inst.theDoor.switches[0].y)

    -- add some fruit
    for i=1, 5 do

        local x = love.math.random(inst.roomX+1, inst.roomX+inst.roomWidth-1)
        local y = love.math.random(inst.roomY+1, inst.roomY+inst.roomHeight-1)
        
        local function checkOverSwitch(x, y)
            for j=1, #inst.theDoor.switches do
                if x == inst.theDoor.switches[j].x and y == inst.theDoor.switches[j].y then
                    return true
                end
            end
            return false
        end
        while checkOverSwitch(x,y) do
            x = love.math.random(inst.roomX+1, inst.roomX+inst.roomWidth-1)
            y = love.math.random(inst.roomY+1, inst.roomY+inst.roomHeight-1)
        end

        inst:setElement(x, y, "fruit")
        --inst:setElement(love.math.random(inst.roomX+1, inst.roomX+inst.roomWidth-1), love.math.random(inst.roomY+1, inst.roomY+inst.roomHeight-1), "fruit")
    end

    function inst:openDoor()
        if self.theDoor.isOpen then
            self.theDoor:close()
        else
            self.theDoor:open()
        end
        if self.openDoorStartT then return end

        --print("open door!")
        self.openDoorStartT = love.timer.getTime()
    end


    function inst:draw()
        for y=1, self.height do
            for x=1, self.width do
                local element = self:getElement(x, y)
                if element == "wall" then
                    love.graphics.setColor(55,55,55,255)
                    love.graphics.rectangle("fill", x*cellWidth-1, y*cellHeight-1, 2-cellWidth, 2-cellHeight)
                elseif element == "door" then
                    love.graphics.setColor(170, 170, 0, 255)
                    love.graphics.rectangle("fill", x*cellWidth-1, y*cellHeight-1, 2-cellWidth, 2-cellHeight)
                elseif element == "switch" then
                    love.graphics.setColor(255, 255, 0, 255)
                    love.graphics.rectangle("fill", x*cellWidth-1, y*cellHeight-1, 2-cellWidth, 2-cellHeight)
                elseif element == "fruit" then
                    love.graphics.setColor(55,200,55,255)
                    love.graphics.rectangle("fill", x*cellWidth-1, y*cellHeight-1, 2-cellWidth, 2-cellHeight)
                elseif element == "goal" then
                    love.graphics.setColor(255,0,255,255)
                    love.graphics.rectangle("fill", x*cellWidth-1, y*cellHeight-1, 2-cellWidth, 2-cellHeight)
                end
            end
        end
    end

    function inst:update(dt)
        self.theDoor:update(dt)
        if self.openDoorStartT then
            local timeSinceDoorStartT = love.timer.getTime() - self.openDoorStartT
            --print("opening " .. timeSinceDoorStartT)
            for i=1, 7, 1 do
                if timeSinceDoorStartT > i*0.3 then
                    self:setElement(40, i+20, nil)
                    if i == 10 then
                        self.openDoorStartT = nil
                        break
                    end
                end
            end
        end
    end
    
    return inst
end

return level