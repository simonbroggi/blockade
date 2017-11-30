-- to run on osx with love2d installed and when in the directory with the main.lua :
-- run in console:
-- /Applications/love.app/Contents/MacOS/love ~/Development/helloLove/

-- https://www.lua.org/pil/contents.html

game = require "game"
cellWidth = 16
cellHeight = 16

function love.load()
    love.window.setFullscreen(true, "exclusive")
    love.mouse.setVisible(false)
    currentGame = game.new()
end

function love.draw()

    currentGame:draw()
    if currentGame.gameOver then
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.print("Space to restart", love.graphics.getWidth()/3, love.graphics.getHeight()*3/4, 0, 2, 2)
        love.graphics.print("get the pink square!", love.graphics.getWidth()*2/3, love.graphics.getHeight()*1/6, 0, 2, 2)
    end
end

function love.update(dt)

    if love.keyboard.isDown("escape") then
        love.event.quit()
    end
    
    currentGame:update(dt)

    if currentGame.gameOver or currentGame.gameWon then

        if love.keyboard.isDown("space") then
            currentGame = game.new()
        end
    end
end

