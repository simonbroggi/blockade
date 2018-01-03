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

    --local PlayerSnake = Snake(Vector2(10,30),Vector2(0,1), 7)

    inst.snake = snakes.new(30, 24)
    inst.snake.lastHeading = {}
    inst.snake.lastHeading[1] = inst.snake.heading[1]
    inst.snake.lastHeading[2] = inst.snake.heading[2]

    inst.snake2 = snakes.new(30, 33)
    inst.snake2.lastHeading = {}
    inst.snake2.lastHeading[1] = inst.snake2.heading[1]
    inst.snake2.lastHeading[2] = inst.snake2.heading[2]

    inst.level.snakes = {inst.snake, inst.snake2}

    Input.p1_up:register(inst.snake.up, inst.snake)
    Input.p1_down:register(inst.snake.down, inst.snake)
    Input.p1_left:register(inst.snake.left, inst.snake)
    Input.p1_right:register(inst.snake.right, inst.snake)
    Input.p2_up:register(inst.snake2.up, inst.snake2)
    Input.p2_down:register(inst.snake2.down, inst.snake2)
    Input.p2_left:register(inst.snake2.left, inst.snake2)
    Input.p2_right:register(inst.snake2.right, inst.snake2)

    print("registered p1_up funcs:")
    for k,v in pairs(Input.p1_up.funcs) do
        for kk, vv in pairs(v) do
            if vv then
                print(tostring(k) .. " (self= " .. tostring(kk) .. " )")
            end
        end
    end

    -- remove callback
    function inst:revoveCallbacks()
        Input.p1_up:remove(inst.snake.up, inst.snake)
        Input.p1_down:remove(inst.snake.down, inst.snake)
        Input.p1_left:remove(inst.snake.left, inst.snake)
        Input.p1_right:remove(inst.snake.right, inst.snake)
        Input.p2_up:remove(inst.snake2.up, inst.snake2)
        Input.p2_down:remove(inst.snake2.down, inst.snake2)
        Input.p2_left:remove(inst.snake2.left, inst.snake2)
        Input.p2_right:remove(inst.snake2.right, inst.snake2)
    end

    function inst:draw()
        self.level:draw()
        if self.snakeBlinkOn then
            self.snake:draw(255)
            self.snake2:draw(255)
        else
            self.snake:draw(100)
            self.snake2:draw(100)
        end
        --love.graphics.setColor(255, 255, 255, 255)
        --love.graphics.print("in: l" .. tostring(gpio_left01:read()) .. "  r" .. tostring(gpio_right01:read()) .. "  u" .. tostring(gpio_up01:read()) .. "  d" .. tostring(gpio_down01:read()), love.graphics.getWidth()/3, love.graphics.getHeight()/5, 0, 2, 2)
        --PlayerSnake:draw()
    end

    function inst:update(dt)
        self.tickCount = self.tickCount - dt
        --PlayerSnake:update(dt)
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
        
        if self.tickCount <= 0 then
            self.tickCount = self.tickLength

            --print(self.snake:getElementIndex(1).." "..self.snake:getElementIndex(2).." "..self.snake:getElementIndex(3).." "..self.snake:getElementIndex(4))
            if self.snake.dead or self.snake2.dead then
                self.gameOver = true
                love.audio.play(crashSound)
            else
                self.snake2:move()
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