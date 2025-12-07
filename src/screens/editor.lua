local editor = {}

function editor:init()
    self.currentProject = nil
    self.level = require("src.level"):new()
    self.camera = {
        x = 0,
        y = 0,
        zoom = 1
    }
    self.selectedTile = "floor"
    self.gridSize = 64
    self.showGrid = true
end

function editor:openProject(projectPath)
    self.currentProject = projectPath
    self:loadLevel(projectPath .. "/levels/level1.lvl")
end

function editor:loadLevel(levelPath)
    if love.filesystem.getInfo(levelPath) then
        local data = love.filesystem.read(levelPath)
        self.level:loadFromString(data)
    else
        self.level = require("src.level"):new()
    end
end

function editor:update(dt)
    local speed = 300
    if love.keyboard.isDown("w") then
        self.camera.y = self.camera.y - speed * dt
    end
    if love.keyboard.isDown("s") then
        self.camera.y = self.camera.y + speed * dt
    end
    if love.keyboard.isDown("a") then
        self.camera.x = self.camera.x - speed * dt
    end
    if love.keyboard.isDown("d") then
        self.camera.x = self.camera.x + speed * dt
    end
    
    if love.keyboard.isDown("up") then
        self.camera.zoom = math.min(self.camera.zoom + 1 * dt, 3)
    end
    if love.keyboard.isDown("down") then
        self.camera.zoom = math.max(self.camera.zoom - 1 * dt, 0.5)
    end
end

function editor:draw()
    love.graphics.clear(0.05, 0.05, 0.05)
    
    love.graphics.push()
    love.graphics.translate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
    love.graphics.scale(self.camera.zoom)
    love.graphics.translate(-self.camera.x, -self.camera.y)
    
    if self.showGrid then
        self:drawGrid()
    end
    
    self.level:draw(self.gridSize)
    
    love.graphics.pop()
    
    self:drawUI()
end

function editor:drawGrid()
    love.graphics.setColor(0.2, 0.2, 0.2)
    local startX = math.floor(self.camera.x / self.gridSize) * self.gridSize
    local startY = math.floor(self.camera.y / self.gridSize) * self.gridSize
    local width = love.graphics.getWidth() / self.camera.zoom
    local height = love.graphics.getHeight() / self.camera.zoom
    
    for x = startX, startX + width + self.gridSize, self.gridSize do
        love.graphics.line(x, startY - height, x, startY + height)
    end
    for y = startY, startY + height + self.gridSize, self.gridSize do
        love.graphics.line(startX - width, y, startX + width, y)
    end
end

function editor:drawUI()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(14))
    
    local infoText = "WASD: Move | UP/DOWN: Zoom | G: Toggle Grid | F1: Save | ESC: Menu"
    love.graphics.printf(infoText, 10, 10, love.graphics.getWidth() - 20, "left")
    
    love.graphics.printf("Selected: " .. self.selectedTile, 10, 40, "left")
    love.graphics.printf("F: Floor | W: Wall | E: Empty", 10, 60, "left")
end

function editor:mousepressed(x, y, button)
    local wx = (x - love.graphics.getWidth() / 2) / self.camera.zoom + self.camera.x
    local wy = (y - love.graphics.getHeight() / 2) / self.camera.zoom + self.camera.y
    
    local gridX = math.floor(wx / self.gridSize)
    local gridY = math.floor(wy / self.gridSize)
    
    if button == 1 then
        self.level:setTile(gridX, gridY, self.selectedTile)
    elseif button == 2 then
        self.level:setTile(gridX, gridY, "empty")
    end
end

function editor:keypressed(key)
    if key == "g" then
        self.showGrid = not self.showGrid
    elseif key == "f" then
        self.selectedTile = "floor"
    elseif key == "w" then
        self.selectedTile = "wall"
    elseif key == "e" then
        self.selectedTile = "empty"
    elseif key == "f1" then
        self:saveLevel()
    elseif key == "escape" then
        gameState:switchScreen("menu")
    end
end

function editor:saveLevel()
    if self.currentProject then
        local levelPath = self.currentProject .. "/levels/level1.lvl"
        local data = self.level:toString()
        love.filesystem.write(levelPath, data)
        print("Level saved!")
    end
end

return editor
