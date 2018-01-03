local snakes = {}
local denver = require 'denver'
local cutSound = denver.get({waveform='pinknoise', frequency=1550, length=.2})
love.audio.play(cutSound)
function snakes.new(x, y)
    local s = {}
    table.insert(snakes, s)

    s[1] = {x, y}
    s[2] = {x-1, y}
    s[3] = {x-2, y}
    s[4] = {x-3, y}

    s.colors = {{255,255,255,255}, {200,200,200,255}, {255,0,0,255}}

    s.head = 1
    s.heading = {1, 0}

    function s:move(noGrow)
        local newHead = self.head
        if noGrow then
            table.insert(self, newHead, {self[newHead][1], self[newHead][2]})
        else
            newHead = self.head-1
            if newHead < 1 then
                newHead = #self
            end
        end
        self.lastHeading = {self.heading[1], self.heading[2]}
        self[newHead] = {s:nextPos()}
        self.head = newHead
    end

    function s:nextPos()
        return self[self.head][1]+self.heading[1], self[self.head][2]+self.heading[2]
    end

    function s:checkNextPosSelfCollision()
        local nextPos = {self:nextPos()}
        for i=1, #self do
            if nextPos[1] == self[i][1] and nextPos[2] == self[i][2] then
                return true
            end
        end
    end
    function s:cut(x, y)
        if self[self.head][1] == x and self[self.head][2] == y then
            self.dead = true
            return false --cut the head -> dead
        end
        local n = 1
        local startCutIndex = false
        local startCut = false
        local removeElements = {}
        local removeBeforeHead = 0
        for i=2, #self do
            local e = self:getElementIndex(i)
            if startCut or (self[e][1]== x and self[e][2]==y) then
                table.insert(removeElements, e)
                if e < self.head then
                    removeBeforeHead = removeBeforeHead+1
                end
                if startCut == false then
                    startCut = true
                    love.audio.play(cutSound)
                end
            end
        end
        if #removeElements > 0 then
            table.sort(removeElements)
            -- print("head: "..self.head .. "  snakeLength:"..#self)
            -- print("delete ", unpack(removeElements))
            -- print("removeBeforeHead: "..removeBeforeHead)
            self.head = self.head - removeBeforeHead
            
            for i=#removeElements, 1, -1 do
                table.remove(self, removeElements[i])
                --print("snake: "..unpack(self))
            end
            -- print("newHead: "..self.head .. " newSnakeLen:"..#self)
        end
        return true
    end
    function s:getElementIndex(n)
        if n > #self then print("error") return end
        local index = self.head + n -1
        --print(self.head.."  the "..n.."th element is at array index "..index)
        if index > #self then
            index = index - #self
        end
        --print("now the "..n.."th element is at array index "..index)
        return index
    end

    function s:draw(alpha)
        local alpha = alpha or 255
        local n = 0
        local function setcol()
            local col = self.colors[n % (#self.colors) +1]
            col[4] = alpha
            love.graphics.setColor(col)
        end
        for i=self.head, #self do
            setcol()
            love.graphics.rectangle("fill", self[i][1]*cellWidth-1, self[i][2]*cellHeight-1, 2-cellWidth, 2-cellHeight)
            n = n+1
        end
        if self.head > 1 then
            for i=1, self.head-1 do
                setcol()
                love.graphics.rectangle("fill", self[i][1]*cellWidth-1, self[i][2]*cellHeight-1, 2-cellWidth, 2-cellHeight)
                n = n+1
            end
        end
        -- for i=1, #s do
        --     love.graphics.rectangle("fill", s[i].x*cellWidth, s[i].y*cellHeight, -cellWidth, -cellHeight)
        -- end
    end

    function s:up()
        if not(self.lastHeading[1] == 0 and self.lastHeading[2] == 1) then
            self.heading = {0, -1}
        end
    end
    function s:down()
        if not(self.lastHeading[1] == 0 and self.lastHeading[2] == -1) then
            self.heading = {0, 1}
        end
    end
    function s:left()
        if not(self.lastHeading[1] == 1 and self.lastHeading[2] == 0) then
            self.heading = {-1, 0}
        end
    end
    function s:right()
        if not(self.lastHeading[1] == -1 and self.lastHeading[2] == 0) then
            self.heading = {1, 0}
        end
    end

    return s
end

return snakes