local menu = {}

function menu:init()
    self.projects = self:loadProjects()
    self.selectedProject = 1
    self.newProjectName = ""
    self.showNewProjectDialog = false
    self.inputActive = false
end

function menu:loadProjects()
    local projects = {}
    local projectDir = "projects"
    
    love.filesystem.createDirectory(projectDir)
    
    local files = love.filesystem.getDirectoryItems(projectDir)
    for _, file in ipairs(files) do
        table.insert(projects, {
            name = file,
            path = projectDir .. "/" .. file
        })
    end
    
    return projects
end

function menu:update(dt)
end

function menu:draw()
    love.graphics.clear(0.1, 0.1, 0.1)
    
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(40))
    love.graphics.printf("BALLER - Level Editor", 0, 50, width, "center")
    
    love.graphics.setFont(love.graphics.newFont(20))
    love.graphics.printf("Projects", 0, 150, width, "center")
    
    self:drawButton(width / 2 - 75, 200, 150, 40, "New Project", 
        self.showNewProjectDialog and {0.3, 0.6, 0.3} or {0.2, 0.5, 0.2})
    
    local yPos = 280
    if #self.projects == 0 then
        love.graphics.setColor(0.7, 0.7, 0.7)
        love.graphics.printf("No projects yet", 0, yPos, width, "center")
    else
        for i, project in ipairs(self.projects) do
            local bgColor = (i == self.selectedProject) and {0.3, 0.3, 0.5} or {0.2, 0.2, 0.3}
            self:drawButton(width / 2 - 150, yPos, 300, 40, project.name, bgColor)
            yPos = yPos + 50
        end
    end
    
    if self.showNewProjectDialog then
        self:drawNewProjectDialog()
    end
end

function menu:drawButton(x, y, w, h, text, color)
    love.graphics.setColor(color or {0.2, 0.2, 0.2})
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", x, y, w, h)
    
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(text)
    local textHeight = font:getHeight()
    love.graphics.printf(text, x, y + (h - textHeight) / 2, w, "center")
end

function menu:drawNewProjectDialog()
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, width, height)
    
    love.graphics.setColor(0.15, 0.15, 0.15)
    local dialogW, dialogH = 400, 250
    local dialogX, dialogY = (width - dialogW) / 2, (height - dialogH) / 2
    love.graphics.rectangle("fill", dialogX, dialogY, dialogW, dialogH)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", dialogX, dialogY, dialogW, dialogH)
    
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.printf("New Project", dialogX, dialogY + 20, dialogW, "center")
    
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.printf("Project Name:", dialogX + 20, dialogY + 80, dialogW - 40, "left")
    
    local inputX, inputY, inputW, inputH = dialogX + 20, dialogY + 110, 360, 30
    love.graphics.setColor(self.inputActive and {0.3, 0.3, 0.3} or {0.2, 0.2, 0.2})
    love.graphics.rectangle("fill", inputX, inputY, inputW, inputH)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", inputX, inputY, inputW, inputH)
    love.graphics.printf(self.newProjectName, inputX + 5, inputY + 5, inputW - 10, "left")
    
    self:drawButton(dialogX + 20, dialogY + 160, 160, 40, "Create", {0.2, 0.5, 0.2})
    self:drawButton(dialogX + 220, dialogY + 160, 160, 40, "Cancel", {0.5, 0.2, 0.2})
end

function menu:mousepressed(x, y, button)
    local width = love.graphics.getWidth()
    
    if self.showNewProjectDialog then
        local inputX, inputY, inputW, inputH = width / 2 - 180 + 20, 200 + 110, 360, 30
        if x >= inputX and x <= inputX + inputW and y >= inputY and y <= inputY + inputH then
            self.inputActive = true
        else
            self.inputActive = false
        end
        
        if self:isButtonPressed(x, y, width / 2 - 180 + 20, 200 + 160, 160, 40) then
            if #self.newProjectName > 0 then
                self:createNewProject(self.newProjectName)
            end
        end
        
        if self:isButtonPressed(x, y, width / 2 + 20, 200 + 160, 160, 40) then
            self.showNewProjectDialog = false
            self.newProjectName = ""
        end
    else
        if self:isButtonPressed(x, y, width / 2 - 75, 200, 150, 40) then
            self.showNewProjectDialog = true
            self.inputActive = true
        end
        
        local yPos = 280
        for i, project in ipairs(self.projects) do
            if self:isButtonPressed(x, y, width / 2 - 150, yPos, 300, 40) then
                gameState:switchScreen("editor")
                gameState.editor:openProject(project.path)
            end
            yPos = yPos + 50
        end
    end
end

function menu:isButtonPressed(x, y, bx, by, bw, bh)
    return x >= bx and x <= bx + bw and y >= by and y <= by + bh
end

function menu:createNewProject(name)
    local projectPath = "projects/" .. name
    love.filesystem.createDirectory(projectPath)
    love.filesystem.createDirectory(projectPath .. "/levels")
    
    local config = {
        name = name,
        created = os.time()
    }
    love.filesystem.write(projectPath .. "/project.json", self:tableToJson(config))
    
    self.projects = self:loadProjects()
    self.showNewProjectDialog = false
    self.newProjectName = ""
end

function menu:tableToJson(tbl)
    local json = "{"
    local first = true
    for k, v in pairs(tbl) do
        if not first then json = json .. "," end
        if type(v) == "string" then
            json = json .. '"' .. k .. '":"' .. v .. '"'
        else
            json = json .. '"' .. k .. '":' .. tostring(v)
        end
        first = false
    end
    json = json .. "}"
    return json
end

function menu:keypressed(key)
    if self.showNewProjectDialog and self.inputActive then
        if key == "backspace" then
            self.newProjectName = self.newProjectName:sub(1, -2)
        elseif key == "return" then
            if #self.newProjectName > 0 then
                self:createNewProject(self.newProjectName)
            end
        end
    end
end

return menu
