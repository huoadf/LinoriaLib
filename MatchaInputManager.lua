local RunService = game:GetService("RunService")

local MatchaInputManager = {
    Connections = {},
    HoveredObject = nil,
    MousePosition = Vector2.new(0, 0)
}

function MatchaInputManager.Start(proxyObjectsList)
    RunService.Heartbeat:Connect(function()
        local isMouseDown = ismouse1pressed()
        local mousePos = Vector2.new(0, 0) -- Need to get mouse position from absolute cursor... Assuming WorldToScreen hack or just skipping since Matcha doesn't provide getmouse location natively without UserInputService.
        -- Actually, wait. UserInputService CAN be used to get mouse location even if UI is external?
        -- Matcha says it has no direct access to internal Roblox API functions. Wait, if it can use game:GetService("Players"), it can use game:GetService("UserInputService") for inputs! 
        -- "Matcha is not an executor - it does not hook any functions... means it has no direct access to internal Roblox API functions."
        -- BUT it can access `RunService` and `Players`, can it access `UserInputService:GetMouseLocation()`? Yes, it's just a method!
        
        local UserInputService = game:GetService("UserInputService")
        local ok, loc = pcall(function() return UserInputService:GetMouseLocation() end)
        if ok then
            MatchaInputManager.MousePosition = loc
        end
        
        -- Find hovered object from proxyObjectsList (reverse order for ZIndex)
        local newHovered = nil
        for i = #proxyObjectsList, 1, -1 do
            local obj = proxyObjectsList[i]
            if obj.Visible and obj.AbsolutePosition and obj.AbsoluteSize then
                local pos = obj.AbsolutePosition
                local size = obj.AbsoluteSize
                if MatchaInputManager.MousePosition.X >= pos.X and MatchaInputManager.MousePosition.X <= pos.X + size.X and
                   MatchaInputManager.MousePosition.Y >= pos.Y and MatchaInputManager.MousePosition.Y <= pos.Y + size.Y then
                    newHovered = obj
                    break
                end
            end
        end
        
        if newHovered ~= MatchaInputManager.HoveredObject then
            if MatchaInputManager.HoveredObject and MatchaInputManager.HoveredObject.MouseLeave then
                MatchaInputManager.HoveredObject.MouseLeave:Fire()
            end
            if newHovered and newHovered.MouseEnter then
                newHovered.MouseEnter:Fire()
            end
            MatchaInputManager.HoveredObject = newHovered
        end
        
        -- Click detection (naive)
        if isMouseDown then
            if MatchaInputManager.HoveredObject and MatchaInputManager.HoveredObject.InputBegan then
                -- Fake input object
                MatchaInputManager.HoveredObject.InputBegan:Fire({UserInputType = Enum.UserInputType.MouseButton1})
            end
        end
    end)
end

return MatchaInputManager
