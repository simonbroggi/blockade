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
    local sine = denver.get({waveform='square', frequency=240, length=.2})

    inst.snake = snakes.new(30, 24)

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
        

        if self.gameOver then
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
            self.level:update()
        end

        if love.keyboard.isDown("up") then
            love.audio.play(sine)
            self.snake.heading = {0, -1}
        elseif love.keyboard.isDown("down") then
            self.snake.heading = {0, 1}
        elseif love.keyboard.isDown("left") then
            self.snake.heading = {-1, 0}
        elseif love.keyboard.isDown("right") then
            self.snake.heading = {1, 0}
        end
        
        if self.tickCount <= 0 then
            self.tickCount = self.tickLength

            local nextPosX, nextPosY = self.snake:nextPos()
            local nextElement = self.level:getElement(nextPosX, nextPosY)
            if nextElement == "wall" or self.snake:checkNextPosSelfCollision() then
                self.gameOver = true
            else
                if nextElement == "fruit" then
                    self.level:setElement(nextPosX, nextPosY, nil)
                    self.level:openDoor()
                    self.snake:move(true)
                    inst.level:setElement(love.math.random(inst.level.roomX+1, inst.level.roomX+inst.level.roomWidth-1), love.math.random(inst.level.roomY+1, inst.level.roomY+inst.level.roomHeight-1), "fruit")
                else
                    self.snake:move()
                end

            end
        end
    end
    return inst
end

return game