local RunService = game:GetService("RunService")

local MatchaUIProxy = {}
MatchaUIProxy.__index = MatchaUIProxy

local function updateAbsolutePositionAndSize(proxy)
    if not proxy.Visible then return end
    
    local parentPos = Vector2.new(0, 0)
    local parentSize = Vector2.new(workspace.CurrentCamera.ViewportSize.X, workspace.CurrentCamera.ViewportSize.Y)
    
    if proxy.Parent and type(proxy.Parent) == "table" and proxy.Parent.AbsolutePosition then
        parentPos = proxy.Parent.AbsolutePosition
        parentSize = proxy.Parent.AbsoluteSize
    end
    
    local pos = proxy.Position
    local size = proxy.Size
    
    if typeof(pos) == "UDim2" then
        proxy.AbsolutePosition = Vector2.new(
            parentPos.X + (pos.X.Scale * parentSize.X) + pos.X.Offset,
            parentPos.Y + (pos.Y.Scale * parentSize.Y) + pos.Y.Offset
        )
    else
        proxy.AbsolutePosition = parentPos
    end
    
    if typeof(size) == "UDim2" then
        proxy.AbsoluteSize = Vector2.new(
            (size.X.Scale * parentSize.X) + size.X.Offset,
            (size.Y.Scale * parentSize.Y) + size.Y.Offset
        )
    else
        proxy.AbsoluteSize = Vector2.new(0, 0)
    end
    
    if proxy.DrawingObject then
        if proxy.ClassName == "TextLabel" then
            proxy.DrawingObject.Position = proxy.AbsolutePosition
            -- Text has no size in Drawing API, but size sets bounds theoretically
        else
            proxy.DrawingObject.Position = proxy.AbsolutePosition
            proxy.DrawingObject.Size = proxy.AbsoluteSize
        end
    end
    
    for _, child in ipairs(proxy.Children) do
        updateAbsolutePositionAndSize(child)
    end
end

function MatchaUIProxy.new(className)
    local self = setmetatable({
        ClassName = className,
        Children = {},
        Parent = nil,
        AbsolutePosition = Vector2.new(0, 0),
        AbsoluteSize = Vector2.new(0, 0),
        
        -- Properties
        Visible = true,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0,
        BorderColor3 = Color3.new(0, 0, 0),
        BorderSizePixel = 0,
        ZIndex = 1,
        ClipsDescendants = false
    }, MatchaUIProxy)
    
    if className == "Frame" or className == "TextButton" or className == "ScrollingFrame" then
        self.DrawingObject = Drawing.new("Square")
        self.DrawingObject.Filled = true
    elseif className == "TextLabel" or className == "TextBox" then
        self.DrawingObject = Drawing.new("Text")
        self.Text = ""
        self.TextColor3 = Color3.new(0, 0, 0)
        self.TextSize = 14
        self.Font = Drawing.Fonts.UI
        self.TextXAlignment = Enum.TextXAlignment.Center
        self.TextYAlignment = Enum.TextYAlignment.Center
    elseif className == "ImageLabel" or className == "ImageButton" then
        self.DrawingObject = Drawing.new("Image")
        self.Image = ""
        self.ImageColor3 = Color3.new(1, 1, 1)
        self.ImageTransparency = 0
    elseif className == "UIStroke" then
        self.DrawingObject = Drawing.new("Square")
        self.DrawingObject.Filled = false
        self.Color = Color3.new(0, 0, 0)
        self.Thickness = 1
    elseif className == "ScreenGui" then
        -- Invisible container
        self.DrawingObject = nil
    else
        self.DrawingObject = Drawing.new("Square")
        self.DrawingObject.Filled = true
    end
    
    return self
end

function MatchaUIProxy:UpdateDrawing()
    if not self.DrawingObject then return end
    
    self.DrawingObject.Visible = self.Visible
    self.DrawingObject.ZIndex = self.ZIndex
    
    if self.ClassName == "Frame" or self.ClassName == "TextButton" or self.ClassName == "ScrollingFrame" then
        self.DrawingObject.Color = self.BackgroundColor3
        self.DrawingObject.Transparency = 1 - self.BackgroundTransparency
    elseif self.ClassName == "TextLabel" or self.ClassName == "TextBox" then
        self.DrawingObject.Text = self.Text or ""
        self.DrawingObject.Color = self.TextColor3 or Color3.new(0, 0, 0)
        self.DrawingObject.Size = self.TextSize or 14
        self.DrawingObject.Font = self.Font or Drawing.Fonts.UI
        if self.TextXAlignment == Enum.TextXAlignment.Center then
            self.DrawingObject.Center = true
        else
            self.DrawingObject.Center = false
        end
    elseif self.ClassName == "UIStroke" then
        self.DrawingObject.Color = self.Color or Color3.new(0, 0, 0)
        self.DrawingObject.Thickness = self.Thickness or 1
    end
end

function MatchaUIProxy:__newindex(index, value)
    if index == "Parent" then
        local oldParent = rawget(self, "Parent")
        if oldParent and type(oldParent) == "table" then
            for i, child in ipairs(oldParent.Children) do
                if child == self then
                    table.remove(oldParent.Children, i)
                    break
                end
            end
        end
        rawset(self, index, value)
        if value and type(value) == "table" then
            table.insert(value.Children, self)
        end
        updateAbsolutePositionAndSize(self)
    else
        rawset(self, index, value)
        if index == "Position" or index == "Size" or index == "Visible" then
            updateAbsolutePositionAndSize(self)
        end
        self:UpdateDrawing()
    end
end

function MatchaUIProxy:Destroy()
    if self.DrawingObject then
        self.DrawingObject:Remove()
    end
    for _, child in ipairs(self.Children) do
        child:Destroy()
    end
end

function MatchaUIProxy:FindFirstChild(name)
    for _, child in ipairs(self.Children) do
        if child.Name == name then return child end
    end
    return nil
end

function MatchaUIProxy:GetChildren()
    return self.Children
end

function MatchaUIProxy:ClearAllChildren()
    for _, child in ipairs(self.Children) do
        child:Destroy()
    end
    self.Children = {}
end

return MatchaUIProxy
