input = require ("input")
Game = require ("game")

function love.load()
    game = Game:new()
    game:loadSinglePlayer()
    love.graphics.setFont(love.graphics.newFont(6))
end

function love.update(dt)
    input.update(dt)
    game:update(dt)
end
function love.draw(dt)
    game:draw()
end

function love.keypressed(key, scancode, isrepeat)
    --print(key)
    input.keypressed(key)

    if key == "escape" then
        love.event.quit()
    elseif key == "p" then
        game.pause = not game.pause
    end

end

function love.quit()
    input.close()
end