-- MATCH API LINORIALIB EXAMPLE
-- Do NOT use game:HttpGet to load the library from GitHub, because the GitHub version is not compatible with Matcha.
-- Instead, we load our local BundledLibrary.lua which contains the Drawing API proxy.

-- Load the bundled version from your workspace (you might need to copy paste the contents of BundledLibrary.lua into your executor if loadfile doesn't work)
local Library = loadfile("BundledLibrary.lua")()

-- Note: ThemeManager and SaveManager (addons) also use game:HttpGet to fetch from GitHub if you don't load them manually.
-- For this example, we skip them. If you need them, you must download them locally and load them similarly.

local Window = Library:CreateWindow({
    Title = 'Example menu',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Main = Window:AddTab('Main'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

local LeftGroupBox = Tabs.Main:AddLeftGroupbox('Groupbox')

LeftGroupBox:AddButton({
    Text = 'Button',
    Func = function()
        print('You clicked a button!')
    end,
    DoubleClick = false,
    Tooltip = 'This is the main button'
})

LeftGroupBox:AddToggle('MyToggle', {
    Text = 'This is a toggle',
    Default = true,
    Tooltip = 'This is a tooltip',
    Callback = function(Value)
        print('[cb] MyToggle changed to:', Value)
    end
})

Library:SetWatermarkVisibility(true)
Library:SetWatermark('Matcha API LinoriaLib Port')

print("Loaded successfully on Matcha!")
