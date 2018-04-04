input = require ("input")
cellWidth = 16
cellHeight = 16
local Game = require ("game")
local Menu = require ("menu")

local menu = nil
local game = nil

-- TODO: fix memory leeks and use weak tables where appropriate (input, and other event stuff)
-- https://www.lua.org/pil/17.html

local function startSinglePlayer()
    if menu then
        menu:unload()
        menu = nil
    end
    game = Game:new()
    game:loadSinglePlayer()
end

local function startTwoPlayer()
    if menu then
        menu:unload()
        menu = nil
    end
    game = Game:new()
    game:loadTwoPlayer()
end

local mainMenuItems = {"single player", "two players"}
local mainMenuFuncs = {startSinglePlayer, startTwoPlayer}

local function loadMainMenu()
    if game then
        if #game.snakes > 1 then --uff, this is a bit ugly..
            game:unloadTwoPlayer()
        else
            game:unloadSinglePlayer()
        end
        game = nil
    end

    -- collect garbage and show memory
    collectgarbage()
    print("memory:"..(collectgarbage("count")*1024))

    menu = Menu:new()
    menu:load(mainMenuItems, mainMenuFuncs)
end

local function newMenuGCtest()
    -- print("")
    -- print("newmenu")
    menu = Menu:new()
    menu:load(mainMenuItems, mainMenuFuncs)
    -- mem = collectgarbage("count")*1024
    -- print("memory:"..mem)
    -- print("menu = nil and collect garbage")
    menu:unload()
    menu = nil
    collectgarbage()
    print("memorya:"..(collectgarbage("count")*1024))
end

local function newgameGCtest()
    -- print("")
    -- print("newgame")
    game = Game:new()
    game:loadSinglePlayer();
    for i=1,10 do
        game:update(0.1)
        --game:draw()
    end
    

    -- mem = collectgarbage("count")*1024
    -- print("memory:"..mem)
    -- print("game = nil and collect garbage")
    game:unloadSinglePlayer()
    game=nil
    collectgarbage()
    print("memorya:"..(collectgarbage("count")*1024))
end

function love.load()
    collectgarbage("stop")

    -- game = Game:new()
    -- game:loadSinglePlayer()

    --loadMainMenu()

    for i=1,100 do
        --love.timer.sleep(.1)
        --collectgarbage()
        --mem = collectgarbage("count")*1024
        --print("memorya:"..mem)
        newgameGCtest()
    end

    -- newMenuGCtest()
    -- newMenuGCtest()
    -- newMenuGCtest()
    -- newMenuGCtest()
    -- newMenuGCtest()
    -- newMenuGCtest()

    collectgarbage("restart")
end

function love.update(dt)
    loadMainMenu()    
    startSinglePlayer()
end

-- function love.update(dt)
--     input.update(dt)
--     if game then
--         if game.over then
--             --loadMainMenu()
--             game:unloadSinglePlayer()
--             game = nil
--             collectgarbage()
--             mem = collectgarbage("count")*1024
--             print("memory:"..mem)
--             game = Game:new()
--             game:loadSinglePlayer()
--         else
--            game:update(dt)
--         end
--     end
-- end
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
        if game then
            game.pause = not game.pause
        end
    end

end

function love.quit()
    input.close()
end