-- to run on osx with love2d installed and when in the directory with the main.lua :
-- run in console:
-- /Applications/love.app/Contents/MacOS/love ~/Development/helloLove/

-- https://www.lua.org/pil/contents.html

game = require "game_mess"
Input = require "input"

cellWidth = 16
cellHeight = 16

function love.load()
    print(_VERSION)
    --love.window.setFullscreen(true, "exclusive")
    love.mouse.setVisible(false)
    currentGame = game.new()

    Input.p1_button1:register(
        function () 
            if currentGame.gameOver or currentGame.gameWon then
                currentGame:revoveCallbacks()
                currentGame = game.new()
            end
        end
    )

    print("hello ")
end

function love.draw()

    currentGame:draw()
    if currentGame.gameOver then
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.print("Space to restart", love.graphics.getWidth()/3, love.graphics.getHeight()*3/4, 0, 2, 2)
        love.graphics.print("get the pink square!", love.graphics.getWidth()*2/3, love.graphics.getHeight()*1/6, 0, 2, 2)
    end
    love.graphics.setColor(255,255,255,255)
end

function love.update(dt)
    Input.update(dt)

    if love.keyboard.isDown("escape") then
        love.event.quit()
    end
    
    currentGame:update(dt)

end

function love.keypressed(key, scancode, isrepeat)
    --print(key)
    Input.keypressed(key)
end

