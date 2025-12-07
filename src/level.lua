local level = {}

function level:new()
    local obj = {
        tiles = {},
        width = 100,
        height = 100
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function level:getTile(x, y)
    if not self.tiles[x] then
        return "empty"
    end
    return self.tiles[x][y] or "empty"
end

function level:setTile(x, y, tileType)
    if not self.tiles[x] then
        self.tiles[x] = {}
    end
    self.tiles[x][y] = tileType
end

function level:draw(gridSize)
    for x, row in pairs(self.tiles) do
        for y, tileType in pairs(row) do
            local color = self:getTileColor(tileType)
            love.graphics.setColor(color)
            love.graphics.rectangle("fill", x * gridSize, y * gridSize, gridSize, gridSize)
            
            love.graphics.setColor(0.3, 0.3, 0.3)
            love.graphics.rectangle("line", x * gridSize, y * gridSize, gridSize, gridSize)
        end
    end
end

function level:getTileColor(tileType)
    if tileType == "floor" then
        return {0.3, 0.3, 0.3}
    elseif tileType == "wall" then
        return {0.6, 0.4, 0.2}
    else
        return {0.1, 0.1, 0.1}
    end
end

function level:toString()
    local data = "{" 
    local first = true
    for x, row in pairs(self.tiles) do
        if not first then data = data .. "," end
        data = data .. '"' .. x .. '":{' 
        local rowFirst = true
        for y, tile in pairs(row) do
            if not rowFirst then data = data .. "," end
            data = data .. '"' .. y .. '":"' .. tile .. '"'
            rowFirst = false
        end
        data = data .. "}"
        first = false
    end
    data = data .. "}"
    return data
end

function level:loadFromString(data)
    self.tiles = {}
end

return level
