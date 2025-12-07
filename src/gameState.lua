local gameState = {}

function gameState:init()
    self.currentScreen = "menu"
    self.menu = require("src.screens.menu")
    self.editor = require("src.screens.editor")
    self.menu:init()
end

function gameState:update(dt)
    if self.currentScreen == "menu" then
        self.menu:update(dt)
    elseif self.currentScreen == "editor" then
        self.editor:update(dt)
    end
end

function gameState:draw()
    love.graphics.setColor(1, 1, 1)
    if self.currentScreen == "menu" then
        self.menu:draw()
    elseif self.currentScreen == "editor" then
        self.editor:draw()
    end
end

function gameState:mousepressed(x, y, button)
    if self.currentScreen == "menu" then
        self.menu:mousepressed(x, y, button)
    elseif self.currentScreen == "editor" then
        self.editor:mousepressed(x, y, button)
    end
end

function gameState:mousemoved(x, y, dx, dy)
    if self.currentScreen == "editor" then
        self.editor:mousemoved(x, y, dx, dy)
    end
end

function gameState:keypressed(key)
    if self.currentScreen == "menu" then
        self.menu:keypressed(key)
    elseif self.currentScreen == "editor" then
        self.editor:keypressed(key)
    end
end

function gameState:keyreleased(key)
    if self.currentScreen == "editor" then
        self.editor:keyreleased(key)
    end
end

function gameState:switchScreen(screen)
    self.currentScreen = screen
    if screen == "menu" then
        self.menu:init()
    elseif screen == "editor" then
        self.editor:init()
    end
end

return gameState