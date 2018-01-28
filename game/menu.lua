local Menu = {}

function Menu:new()
    local inst = {
        items = {},
        funcs = {},
        activ = 1
    }
    self.__index = self
    setmetatable(inst, self)
    return inst
end

function Menu:load(items, funcs)
    love.graphics.setFont(love.graphics.newFont(14))
    self.items = items
    self.funcs = funcs
    self.activ = 1

    input.p1_up:register(      self.up,    self)
    input.p1_down:register(    self.down,  self)
    input.p1_button1:register( self.select,self)

    input.p2_up:register(      self.up,    self)
    input.p2_down:register(    self.down,  self)
    input.p2_button1:register( self.select,self)
end

function Menu:unload()
    input.p1_up:remove(      self.up,    self)
    input.p1_down:remove(    self.down,  self)
    input.p1_button1:remove( self.select,self)

    input.p2_up:remove(      self.up,    self)
    input.p2_down:remove(    self.down,  self)
    input.p2_button1:remove( self.select,self)
    self.funcs = {}
end

function Menu:up()
    if self.activ > 1 then
        self.activ = self.activ-1
    end
end
function Menu:down()
    if self.activ < #self.items then
        self.activ = self.activ+1
    end
end
function Menu:select()
    if self.funcs[self.activ] then
        self.funcs[self.activ]()
    end
end

function Menu:draw()
    if #self.items <= 0 then return end

    local i = 1
    local x = 20
    local y = love.graphics.getHeight() / 4
    local yStep = love.graphics.getHeight() / 2 / #self.items
    for _, item in ipairs(self.items) do
        if i == self.activ then
            love.graphics.setColor(255, 255, 255, 255)
        else
            love.graphics.setColor(111, 111, 111, 255)
        end
        love.graphics.print(item, x, y);
        i = i+1
        y = y + yStep
    end
end

return Menu