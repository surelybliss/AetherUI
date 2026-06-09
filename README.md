# AetherUI
Aether Ai Ui Lib


-- Load AetherUI (Assuming you hosted the module on GitHub, use the link below)
-- local AetherUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/surelybliss/AetherUi/main/AetherUI.lua"))()

-- For testing locally if you pasted the module into your workspace:
local AetherUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/surelybliss/AetherUi/main/AetherUI.lua"))() -- Replace with actual loadstring

-- 1. Create the Window
local Window = AetherUI:CreateWindow({
    Name = "Aether Hub",
    Subtitle = "Premium Experience",
    Size = UDim2.new(0, 750, 0, 480)
})

-- 2. Setup the UI Toggle Keybind
Window:SetToggleKey(Enum.KeyCode.RightControl)

-- 3. Create Tabs
local CombatTab = Window:CreateTab({ Name = "Combat" })
local PlayerTab = Window:CreateTab({ Name = "Local Player" })
local SettingsTab = Window:CreateTab({ Name = "Settings" })

-- 4. Populate Combat Tab
CombatTab:CreateSection("Assistance")

CombatTab:CreateToggle({
    Name = "Kill Aura",
    Default = false,
    Callback = function(Value)
        print("Kill Aura toggled:", Value)
    end
})

CombatTab:CreateToggle({
    Name = "Auto Farm",
    Default = false,
    Callback = function(Value)
        print("Auto Farm status:", Value)
    end
})

CombatTab:CreateButton({
    Name = "Wipe Entities",
    Description = "Instantly destroy all nearby targets",
    Callback = function()
        AetherUI:Notify({
            Title = "Success",
            Content = "All entities in radius wiped.",
            Duration = 3
        })
    end
})

-- 5. Populate Player Tab
PlayerTab:CreateSection("Movement Variables")

PlayerTab:CreateSlider({
    Name = "WalkSpeed Override",
    Min = 16,
    Max = 200,
    Default = 16,
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
    end
})

PlayerTab:CreateSlider({
    Name = "JumpPower",
    Min = 50,
    Max = 300,
    Default = 50,
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
    end
})

-- Send Welcome Notification
AetherUI:Notify({
    Title = "AetherUI Loaded",
    Content = "Welcome back to the Premium Experience. Press Right Control to toggle.",
    Duration = 5
})
