function love.load()
    -- Инициализация окна
    love.window.setMode(1280, 800)
    love.window.setTitle("Baller - Level Editor")
    
    -- Загрузка состояния приложения
    gameState = require("src.gameState")
    gameState:init()
end

function love.update(dt)
    gameState:update(dt)
end

function love.draw()
    gameState:draw()
end

function love.mousepressed(x, y, button)
    gameState:mousepressed(x, y, button)
end

function love.mousemoved(x, y, dx, dy)
    gameState:mousemoved(x, y, dx, dy)
end

function love.keypressed(key)
    gameState:keypressed(key)
end

function love.keyreleased(key)
    gameState:keyreleased(key)
end