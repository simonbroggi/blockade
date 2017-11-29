local snakes = {}

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

    return s
end

return snakes