local level = {}

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

    inst:addBox(1,1,width-1,height-1)
    inst.roomX = 24
    inst.roomY = 16
    inst.roomWidth = 16
    inst.roomHeight = 16
    inst:addBox(inst.roomX, inst.roomY, inst.roomWidth, inst.roomHeight)

    -- add some fruit
    for i=1, 5 do
        inst:setElement(love.math.random(inst.roomX+1, inst.roomX+inst.roomWidth-1), love.math.random(inst.roomY+1, inst.roomY+inst.roomHeight-1), "fruit")
    end

    function inst:openDoor()
        if self.openDoorStartT then return end

        print("open door!")
        self.openDoorStartT = love.timer.getTime()
    end


    function inst:draw()
        for y=1, self.height do
            for x=1, self.width do
                local element = self:getElement(x, y)
                if element == "wall" then
                    love.graphics.setColor(55,55,55,255)
                    love.graphics.rectangle("fill", x*cellWidth-1, y*cellHeight-1, 2-cellWidth, 2-cellHeight)
                elseif element == "fruit" then
                    love.graphics.setColor(55,255,55,255)
                    love.graphics.rectangle("fill", x*cellWidth-1, y*cellHeight-1, 2-cellWidth, 2-cellHeight)
                end
            end
        end
    end

    function inst:update()
        if self.openDoorStartT then
            local timeSinceDoorStartT = love.timer.getTime() - self.openDoorStartT
            --print("opening " .. timeSinceDoorStartT)
            for i=1, 10, 1 do
                if timeSinceDoorStartT > i*0.2 then
                    self:setElement(40, i+19, nil)
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