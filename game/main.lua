input = require ("input")
cellWidth = 16
cellHeight = 16
local Game = require ("game")
local Menu = require ("menu")

local menu = nil
local game = nil

local loadMainMenu = function ()
    menu = Menu:new()
    menu:load({"single player", "two players"}, {function()
        menu:unload()
        menu = nil
        game = Game:new()
        game:loadSinglePlayer()
    end,
    function()
        menu:unload()
        menu = nil
        game = Game:new()
        game:loadTwoPlayer()
    end
    })
end

function love.load()
    loadMainMenu()
end

function love.update(dt)
    input.update(dt)
    if game then
        if game.over then
            if #game.snakes > 1 then --uff, this is a bit ugly..
                game:loadTwoPlayer()
            else
                game:unloadSinglePlayer()
            end
            game = nil
            loadMainMenu()
        else
           game:update(dt)
        end
    end
end
function love.draw()
    if game then
        game:draw()
    end
    if menu then
        menu:draw()
    end
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