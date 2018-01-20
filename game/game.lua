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

    self.player1 = Snake:new(9,10,8)
    self.player1:setLevel(level)
    table.insert(self.snakes, self.player1)

    input.p1_up:register(self.player1.steerUp, self.player1)
    input.p1_down:register(self.player1.steerDown, self.player1)
    input.p1_left:register(self.player1.steerLeft, self.player1)
    input.p1_right:register(self.player1.steerRight, self.player1)
end

function Game:unloadSinglePlayer()
    input.p1_up:remove(self.player1.steerUp, self.player1)
    input.p1_down:remove(self.player1.steerDown, self.player1)
    input.p1_left:remove(self.player1.steerLeft, self.player1)
    input.p1_right:remove(self.player1.steerRight, self.player1)
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