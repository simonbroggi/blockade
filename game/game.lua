local Snake = require ("snake")
local Level = require ("level")

local Game = {}

function Game:new()
    local inst = {
        snakes = {},
        pause = false,
        cellWidth = 16,
        cellHeight = 16
    }
    self.__index = self
    setmetatable(inst, self)
    return inst
end

function Game:loadSinglePlayer()
    local level = Level:new()
    level:load()
    self:setLevel(level)

    self.player1 = Snake:new(9,10,5)
    self.player1.colorR = 180
    self.player1.colorG = 255
    self.player1.colorB = 255
    self.player1:setLevel(level)
    table.insert(self.snakes, self.player1)

    input.p1_up:register(   self.player1.steerUp,    self.player1)
    input.p1_down:register( self.player1.steerDown,  self.player1)
    input.p1_left:register( self.player1.steerLeft,  self.player1)
    input.p1_right:register(self.player1.steerRight, self.player1)
end

function Game:unloadSinglePlayer()
    input.p1_up:remove(   self.player1.steerUp,    self.player1)
    input.p1_down:remove( self.player1.steerDown,  self.player1)
    input.p1_left:remove( self.player1.steerLeft,  self.player1)
    input.p1_right:remove(self.player1.steerRight, self.player1)

    -- todo: player1:unsetLevel ?
    -- todo: remove player1 from snakes
end

function Game:loadTwoPlayer()
    self:loadSinglePlayer()

    self.player2 = Snake:new(9,20,5)
    self.player2.colorR = 255
    self.player2.colorG = 180
    self.player2.colorB = 255
    self.player2:setLevel(self.level)
    table.insert(self.snakes, self.player2)

    input.p2_up:register(   self.player2.steerUp,    self.player2)
    input.p2_down:register( self.player2.steerDown,  self.player2)
    input.p2_left:register( self.player2.steerLeft,  self.player2)
    input.p2_right:register(self.player2.steerRight, self.player2)
end

function Game:unloadTwoPlayer()
    self:unloadSinglePlayer()
    input.p2_up:remove(   self.player2.steerUp,    self.player2)
    input.p2_down:remove( self.player2.steerDown,  self.player2)
    input.p2_left:remove( self.player2.steerLeft,  self.player2)
    input.p2_right:remove(self.player2.steerRight, self.player2)

    -- todo: player1:unsetLevel ?
    -- todo: remove player2 from snakes
end

function Game:update(dt)
    if self.pause then return end
    if self.level then
        self.level:update(dt)
    end
    for i, s in ipairs(self.snakes) do
        s:update(dt)
    end
end

function Game:draw()
    for i, s in ipairs(self.snakes) do
        s:draw(self.cellWidth, self.cellHeight)
    end
    if self.level then
        self.level:draw(self.cellWidth, self.cellHeight)
    end
end

function Game:setLevel(level)
    if self.level then
        -- unload
    end
    self.level = level
end

return Game