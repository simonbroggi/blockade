local game = {}
local level = require 'level'
local snakes = require 'snakes'
local denver = require 'denver'

function game.new()
    local inst = {}
    inst.tickLength = 0.1
    inst.tickCount = inst.tickLength
    inst.level = level.new(64, 48)
    inst.snakeBlinkOn = true
    local eatSound = denver.get({waveform='pinknoise', frequency=460, length=inst.tickLength*0.6})
    local crashSound = denver.get({waveform='pinknoise', frequency=300, length=inst.tickLength*3.3})

    inst.snake = snakes.new(30, 24)
    inst.level.snakes = {inst.snake}

    function inst:draw()
        self.level:draw()
        if self.snakeBlinkOn then
            self.snake:draw(255)
        else
            self.snake:draw(100)
        end
    end

    function inst:update(dt)
        self.tickCount = self.tickCount - dt
        
        if self.gameWon then
            if self.tickCount <= 0 then
                self.tickCount = self.tickLength*2
                local c = table.remove(self.snake.colors, #self.snake.colors)
                table.insert(self.snake.colors, 1, c)
            end
            return
        elseif self.gameOver then
            if self.tickCount <= 0 then
                if self.snakeBlinkOn then
                    self.tickCount = self.tickLength*2
                else
                    self.tickCount = self.tickLength*3
                end
                self.snakeBlinkOn = not self.snakeBlinkOn
            end
            return
        else
            self.level:update(dt)
        end

        if love.keyboard.isDown("up") then
            if not(self.snake.lastHeading[1] == 0 and self.snake.lastHeading[2] == 1) then
                self.snake.heading = {0, -1}
            end
        elseif love.keyboard.isDown("down") then
            if not(self.snake.lastHeading[1] == 0 and self.snake.lastHeading[2] == -1) then
                self.snake.heading = {0, 1}
            end
        elseif love.keyboard.isDown("left") then
            if not(self.snake.lastHeading[1] == 1 and self.snake.lastHeading[2] == 0) then
                self.snake.heading = {-1, 0}
            end
        elseif love.keyboard.isDown("right") then
            if not(self.snake.lastHeading[1] == -1 and self.snake.lastHeading[2] == 0) then
                self.snake.heading = {1, 0}
            end
        end
        
        if self.tickCount <= 0 then
            self.tickCount = self.tickLength

            --print(self.snake:getElementIndex(1).." "..self.snake:getElementIndex(2).." "..self.snake:getElementIndex(3).." "..self.snake:getElementIndex(4))
            if self.snake.dead then
                self.gameOver = true
                love.audio.play(crashSound)
            else
                local nextPosX, nextPosY = self.snake:nextPos()
                local nextElement = self.level:getElement(nextPosX, nextPosY)
                if nextElement == "wall" or nextElement == "door" or self.snake:checkNextPosSelfCollision() then
                    self.gameOver = true
                    love.audio.play(crashSound)
                elseif nextElement == "goal" then
                    self.gameWon = true
                    self.snake:move(true)
                    table.insert(self.snake.colors, 1, {255,0,255,255})
                else
                    if nextElement == "fruit" then
                        self.level:setElement(nextPosX, nextPosY, nil)
                        --self.level:openDoor()
                        self.snake:move(true)
                        love.audio.play(eatSound)
                        --wrong
                        local x = love.math.random(inst.level.roomX+1, inst.level.roomX+inst.level.roomWidth-1)
                        local y = love.math.random(inst.level.roomY+1, inst.level.roomY+inst.level.roomHeight-1)
                        local function checkOverSwitch(x, y)
                            for j=1, #inst.level.theDoor.switches do
                                if x == inst.level.theDoor.switches[j].x and y == inst.level.theDoor.switches[j].y then
                                    return true
                                end
                            end
                            return false
                        end
                        while checkOverSwitch(x,y) do
                            x = love.math.random(inst.level.roomX+1, inst.level.roomX+inst.level.roomWidth-1)
                            y = love.math.random(inst.level.roomY+1, inst.level.roomY+inst.level.roomHeight-1)
                        end
                        
                        inst.level:setElement(x, y, "fruit")
                        --inst.level:setElement(love.math.random(inst.level.roomX+1, inst.level.roomX+inst.level.roomWidth-1), love.math.random(inst.level.roomY+1, inst.level.roomY+inst.level.roomHeight-1), "fruit")
                    else
                        self.snake:move()
                    end

                end
            end
        end
    end
    return inst
end

return game