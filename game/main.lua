-- to run on osx with love2d installed and when in the directory with the main.lua :
-- run in console:
-- /Applications/love.app/Contents/MacOS/love ~/Development/helloLove/

-- https://www.lua.org/pil/contents.html

game = require "game"
cellWidth = 16
cellHeight = 16

function love.load()
    --love.window.setFullscreen(true)
    currentGame = game.new()
end

function love.draw()
    currentGame:draw()
end

function love.update(dt)

    if love.keyboard.isDown("escape") then
        love.event.quit()
    end
    
    currentGame:update(dt)

    if currentGame.gameOver then
        if love.keyboard.isDown("space") then
            currentGame = game.new()
        end
    end
end

