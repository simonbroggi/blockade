local Input = {}

local function isModuleAvailable(name)
    if package.loaded[name] then
        return true
    else
        for _, searcher in ipairs(package.searchers or package.loaders) do
            local loader = searcher(name)
            if type(loader) == 'function' then
                package.preload[name] = loader
                return true
            end
        end
        return false
    end
end

local GPIO = false
if isModuleAvailable('periphery') then
    local periphery = require('periphery')
    GPIO = periphery.GPIO
end

Input.bindingsPerKey = {}
local function register(self, func, caller)
    if not self.funcs[func] then
        self.funcs[func] = {}
    end
    if caller then
        self.funcs[func][caller] = true
    else
        self.funcs[func][func] = true
    end

    --self.funcs[func] = caller or func
end
local function remove(self, func, caller)
    if caller then
        self.funcs[func][caller] = nil
    else
        self.funcs[func][func] = nil
    end

    local count = 0
    for _ in pairs(self.funcs[func]) do count = count + 1 end
    if count == 0 then
        self.funcs[func] = nil
    end
    --self.funcs[func] = nil
end
local function emit(self)
    for func, l in pairs(self.funcs) do
        for caller, b in pairs(l) do
            if b then
                if caller == func then
                    func()
                else
                    func(caller)
                end
            end
        end
        -- if caller == func then
        --     func()
        -- else
        --     func(caller)
        -- end
    end

    -- for func, caller in pairs(self.funcs) do
    --     if caller == func then
    --         func()
    --     else
    --         func(caller)
    --     end
    -- end
end
local function newBinding(key_str, gpio_pin)
    local b = {}
    b.key = key_str
    if GPIO then
        b.gpio = GPIO(gpio_pin, "in")
    end
    b.funcs = {}
    b.register = register
    b.remove = remove
    b.emit = emit

    b.pressed = false
    if Input.bindingsPerKey[key_str] then
        print("Warning: " .. key_str .. " already defined! overwriting!!")
    end
    Input.bindingsPerKey[key_str] = b
    return b
end

Input.p1_up         = newBinding("up", 3)
Input.p1_down       = newBinding("down", 4)
Input.p1_left       = newBinding("left", 15)
Input.p1_right      = newBinding("right", 14)
Input.p1_button1    = newBinding("space", 2)

Input.p2_up         = newBinding("w", 17)
Input.p2_down       = newBinding("s", 18)
Input.p2_left       = newBinding("a", 27)
Input.p2_right      = newBinding("d", 22)
Input.p2_button1    = newBinding("x", 23)

-- print("all bindings:")
-- for k, v in pairs(Input.bindingsPerKey) do
--     print(k)
-- end

-- called in love.update
function Input.update(dt)
    -- poll the GPIO edge events
    if GPIO then
        for _, binding in pairs(Input.bindingsPerKey) do
            if binding.gpio:poll(0) == false then
                binding.pressed = true
            end
        end
    end

    -- emit functions that were pressed in the last frame, and set pressed to false
    
    for _, binding in pairs(Input.bindingsPerKey) do
        if binding.pressed then
            binding:emit()
            binding.pressed = false
        end
    end
end

-- called in love.keypressed
function Input.keypressed(key)
    if Input.bindingsPerKey[key] then
        Input.bindingsPerKey[key].pressed = true
    end
end

-- test
--Input.p1_button1:register(function() print("button1 pressed") end)

return Input