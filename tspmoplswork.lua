local UILibrary = {}

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local ViewportSize = workspace.CurrentCamera.ViewportSize
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Constants
local BACKGROUND_COLOR = Color3.fromRGB(15, 15, 15)
local SIDEBAR_COLOR = Color3.fromRGB(10, 10, 10)
local ACCENT_COLOR = Color3.fromRGB(255, 255, 255)
local TEXT_COLOR = Color3.fromRGB(255, 255, 255)
local SECONDARY_TEXT_COLOR = Color3.fromRGB(180, 180, 180)
local TOGGLE_COLOR = Color3.fromRGB(255, 255, 255)
local TOGGLE_OFF_COLOR = Color3.fromRGB(60, 60, 60)
local SLIDER_BACKGROUND = Color3.fromRGB(40, 40, 40)
local SLIDER_FILL = Color3.fromRGB(255, 255, 255)
local DROPDOWN_BACKGROUND = Color3.fromRGB(30, 30, 30)
local BUTTON_COLOR = Color3.fromRGB(40, 40, 40)
local BUTTON_HOVER_COLOR = Color3.fromRGB(50, 50, 50)
local INPUT_BACKGROUND = Color3.fromRGB(30, 30, 30)

-- Configuration
local ConfigSystem = {
    Folder = "UILibrary",
    Extension = ".config"
}

-- Utility Functions
local function createInstance(className, properties)
    local instance = Instance.new(className)
    for property, value in pairs(properties) do
        instance[property] = value
    end
    return instance
end

local function createTween(instance, properties, duration, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(
        duration or 0.2,
        easingStyle or Enum.EasingStyle.Quad,
        easingDirection or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(instance, tweenInfo, properties)
    return tween
end

local function createRoundedCorner(parent, radius)
    local corner = createInstance("UICorner", {
        CornerRadius = UDim.new(0, radius or 4),
        Parent = parent
    })
    return corner
end

local function createStroke(parent, color, thickness, transparency)
    local stroke = createInstance("UIStroke", {
        Color = color or Color3.fromRGB(50, 50, 50),
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        Parent = parent
    })
    return stroke
end

local function makeOnlyTopDraggable(frame, dragArea)
    local isDragging = false
    local dragInput
    local dragStart
    local startPos
    
    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isDragging = false
                end
            end)
        end
    end)
    
    dragArea.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and isDragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Color Picker Functions
local function createColorPicker(parent, defaultColor, callback)
    local ColorPickerGui = createInstance("Frame", {
        Name = "ColorPickerGui",
        Size = UDim2.new(0, 200, 0, 220),
        Position = UDim2.new(1, 10, 0, 0),
        BackgroundColor3 = BACKGROUND_COLOR,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 20,
        Parent = CoreGui
    })
    createRoundedCorner(ColorPickerGui, 6)
    createStroke(ColorPickerGui, Color3.fromRGB(50, 50, 50), 1, 0)
    
    local ColorPickerTitle = createInstance("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        Text = "Color Picker",
        TextColor3 = TEXT_COLOR,
        TextSize = 14,
        Font = Enum.Font.GothamSemibold,
        ZIndex = 20,
        Parent = ColorPickerGui
    })
    
    -- Create the hue slider
    local HueFrame = createInstance("Frame", {
        Name = "HueFrame",
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 0, 140),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 20,
        Parent = ColorPickerGui
    })
    createRoundedCorner(HueFrame, 4)
    
    -- Create the hue gradient
    local HueGradient = createInstance("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
        }),
        Parent = HueFrame
    })
    
    local HueSelector = createInstance("Frame", {
        Name = "HueSelector",
        Size = UDim2.new(0, 4, 1, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 21,
        Parent = HueFrame
    })
    createRoundedCorner(HueSelector, 2)
    
    -- Create the saturation/value picker
    local SVFrame = createInstance("Frame", {
        Name = "SVFrame",
        Size = UDim2.new(1, -20, 0, 100),
        Position = UDim2.new(0, 10, 0, 35),
        BackgroundColor3 = Color3.fromRGB(255, 0, 0),
        BorderSizePixel = 0,
        ZIndex = 20,
        Parent = ColorPickerGui
    })
    createRoundedCorner(SVFrame, 4)
    
    -- Create the saturation gradient (white to color)
    local SaturationGradient = createInstance("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 0)
        }),
        Rotation = 90,
        Parent = SVFrame
    })
    
    -- Create the value gradient (transparent to black)
    local ValueFrame = createInstance("Frame", {
        Name = "ValueFrame",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ZIndex = 21,
        Parent = SVFrame
    })
    createRoundedCorner(ValueFrame, 4)
    
    local ValueGradient = createInstance("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0)
        }),
        Rotation = 0,
        Parent = ValueFrame
    })
    
    local SVSelector = createInstance("Frame", {
        Name = "SVSelector",
        Size = UDim2.new(0, 10, 0, 10),
        Position = UDim2.new(1, -5, 0, -5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 22,
        Parent = SVFrame
    })
    createRoundedCorner(SVSelector, 10)
    createStroke(SVSelector, Color3.fromRGB(0, 0, 0), 1, 0)
    
    -- Create RGB input fields
    local RGBFrame = createInstance("Frame", {
        Name = "RGBFrame",
        Size = UDim2.new(1, -20, 0, 25),
        Position = UDim2.new(0, 10, 0, 170),
        BackgroundTransparency = 1,
        ZIndex = 20,
        Parent = ColorPickerGui
    })
    
    local RInput = createInstance("TextBox", {
        Name = "RInput",
        Size = UDim2.new(0, 40, 0, 25),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = INPUT_BACKGROUND,
        Text = "255",
        TextColor3 = TEXT_COLOR,
        PlaceholderText = "R",
        TextSize = 12,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false,
        ZIndex = 20,
        Parent = RGBFrame
    })
    createRoundedCorner(RInput, 4)
    
    local GInput = createInstance("TextBox", {
        Name = "GInput",
        Size = UDim2.new(0, 40, 0, 25),
        Position = UDim2.new(0, 45, 0, 0),
        BackgroundColor3 = INPUT_BACKGROUND,
        Text = "0",
        TextColor3 = TEXT_COLOR,
        PlaceholderText = "G",
        TextSize = 12,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false,
        ZIndex = 20,
        Parent = RGBFrame
    })
    createRoundedCorner(GInput, 4)
    
    local BInput = createInstance("TextBox", {
        Name = "BInput",
        Size = UDim2.new(0, 40, 0, 25),
        Position = UDim2.new(0, 90, 0, 0),
        BackgroundColor3 = INPUT_BACKGROUND,
        Text = "0",
        TextColor3 = TEXT_COLOR,
        PlaceholderText = "B",
        TextSize = 12,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false,
        ZIndex = 20,
        Parent = RGBFrame
    })
    createRoundedCorner(BInput, 4)
    
    local HexInput = createInstance("TextBox", {
        Name = "HexInput",
        Size = UDim2.new(0, 60, 0, 25),
        Position = UDim2.new(0, 135, 0, 0),
        BackgroundColor3 = INPUT_BACKGROUND,
        Text = "#FF0000",
        TextColor3 = TEXT_COLOR,
        PlaceholderText = "Hex",
        TextSize = 12,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false,
        ZIndex = 20,
        Parent = RGBFrame
    })
    createRoundedCorner(HexInput, 4)
    
    -- Variables for color picking
    local hue, sat, val = 0, 1, 1
    local selectedColor = defaultColor or Color3.fromRGB(255, 0, 0)
    
    -- Function to update the color display
    local function updateColor()
        -- Convert HSV to RGB
        local h, s, v = hue, sat, val
        local r, g, b
        
        local i = math.floor(h * 6)
        local f = h * 6 - i
        local p = v * (1 - s)
        local q = v * (1 - f * s)
        local t = v * (1 - (1 - f) * s)
        
        i = i % 6
        
        if i == 0 then r, g, b = v, t, p
        elseif i == 1 then r, g, b = q, v, p
        elseif i == 2 then r, g, b = p, v, t
        elseif i == 3 then r, g, b = p, q, v
        elseif i == 4 then r, g, b = t, p, v
        elseif i == 5 then r, g, b = v, p, q
        end
        
        selectedColor = Color3.fromRGB(r * 255, g * 255, b * 255)
        
        -- Update the SV frame color based on hue
        SVFrame.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
        
        -- Update RGB inputs
        RInput.Text = tostring(math.floor(selectedColor.R * 255))
        GInput.Text = tostring(math.floor(selectedColor.G * 255))
        BInput.Text = tostring(math.floor(selectedColor.B * 255))
        
        -- Update Hex input
        local hexR = string.format("%02X", math.floor(selectedColor.R * 255))
        local hexG = string.format("%02X", math.floor(selectedColor.G * 255))
        local hexB = string.format("%02X", math.floor(selectedColor.B * 255))
        HexInput.Text = "#" .. hexR .. hexG .. hexB
        
        -- Call the callback with the new color
        if callback then
            callback(selectedColor)
        end
    end
    
    -- Function to set the color from RGB values
    local function setColorFromRGB(r, g, b)
        r, g, b = r / 255, g / 255, b / 255
        
        local max = math.max(r, g, b)
        local min = math.min(r, g, b)
        local delta = max - min
        
        -- Calculate value
        val = max
        
        -- Calculate saturation
        if max == 0 then
            sat = 0
        else
            sat = delta / max
        end
        
        -- Calculate hue
        if delta == 0 then
            hue = 0
        elseif max == r then
            hue = ((g - b) / delta) % 6
        elseif max == g then
            hue = (b - r) / delta + 2
        else
            hue = (r - g) / delta + 4
        end
        
        hue = hue / 6
        
        -- Update selector positions
        HueSelector.Position = UDim2.new(hue, -2, 0, 0)
        SVSelector.Position = UDim2.new(sat, 0, 1 - val, 0)
        
        updateColor()
    end
    
    -- Function to set the color from hex value
    local function setColorFromHex(hex)
        hex = hex:gsub("#", "")
        
        if #hex == 3 then
            hex = hex:sub(1, 1) .. hex:sub(1, 1) .. hex:sub(2, 2) .. hex:sub(2, 2) .. hex:sub(3, 3) .. hex:sub(3, 3)
        end
        
        if #hex ~= 6 then
            return
        end
        
        local r = tonumber(hex:sub(1, 2), 16) or 0
        local g = tonumber(hex:sub(3, 4), 16) or 0
        local b = tonumber(hex:sub(5, 6), 16) or 0
        
        setColorFromRGB(r, g, b)
    end
    
    -- Set initial color
    setColorFromRGB(
        math.floor(defaultColor.R * 255),
        math.floor(defaultColor.G * 255),
        math.floor(defaultColor.B * 255)
    )
    
    -- Hue slider interaction
    local hueDragging = false
    
    HueFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            hueDragging = true
            
            local relativeX = math.clamp((input.Position.X - HueFrame.AbsolutePosition.X) / HueFrame.AbsoluteSize.X, 0, 1)
            hue = relativeX
            
            HueSelector.Position = UDim2.new(relativeX, -2, 0, 0)
            updateColor()
        end
    end)
    
    HueFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            hueDragging = false
        end
    end)
    
    HueFrame.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and hueDragging then
            local relativeX = math.clamp((input.Position.X - HueFrame.AbsolutePosition.X) / HueFrame.AbsoluteSize.X, 0, 1)
            hue = relativeX
            
            HueSelector.Position = UDim2.new(relativeX, -2, 0, 0)
            updateColor()
        end
    end)
    
    -- SV picker interaction
    local svDragging = false
    
    SVFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            svDragging = true
            
            local relativeX = math.clamp((input.Position.X - SVFrame.AbsolutePosition.X) / SVFrame.AbsoluteSize.X, 0, 1)
            local relativeY = math.clamp((input.Position.Y - SVFrame.AbsolutePosition.Y) / SVFrame.AbsoluteSize.Y, 0, 1)
            
            sat = relativeX
            val = 1 - relativeY
            
            SVSelector.Position = UDim2.new(relativeX, 0, relativeY, 0)
            updateColor()
        end
    end)
    
    SVFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            svDragging = false
        end
    end)
    
    SVFrame.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and svDragging then
            local relativeX = math.clamp((input.Position.X - SVFrame.AbsolutePosition.X) / SVFrame.AbsoluteSize.X, 0, 1)
            local relativeY = math.clamp((input.Position.Y - SVFrame.AbsolutePosition.Y) / SVFrame.AbsoluteSize.Y, 0, 1)
            
            sat = relativeX
            val = 1 - relativeY
            
            SVSelector.Position = UDim2.new(relativeX, 0, relativeY, 0)
            updateColor()
        end
    end)
    
    -- RGB input handling
    RInput.FocusLost:Connect(function()
        local r = tonumber(RInput.Text) or 0
        r = math.clamp(r, 0, 255)
        
        local g = tonumber(GInput.Text) or 0
        local b = tonumber(BInput.Text) or 0
        
        setColorFromRGB(r, g, b)
    end)
    
    GInput.FocusLost:Connect(function()
        local g = tonumber(GInput.Text) or 0
        g = math.clamp(g, 0, 255)
        
        local r = tonumber(RInput.Text) or 0
        local b = tonumber(BInput.Text) or 0
        
        setColorFromRGB(r, g, b)
    end)
    
    BInput.FocusLost:Connect(function()
        local b = tonumber(BInput.Text) or 0
        b = math.clamp(b, 0, 255)
        
        local r = tonumber(RInput.Text) or 0
        local g = tonumber(GInput.Text) or 0
        
        setColorFromRGB(r, g, b)
    end)
    
    -- Hex input handling
    HexInput.FocusLost:Connect(function()
        local hex = HexInput.Text
        setColorFromHex(hex)
    end)
    
    -- Close color picker when clicking outside
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local mousePos = UserInputService:GetMouseLocation()
            if ColorPickerGui.Visible and not (
                mousePos.X >= ColorPickerGui.AbsolutePosition.X and
                mousePos.X <= ColorPickerGui.AbsolutePosition.X + ColorPickerGui.AbsoluteSize.X and
                mousePos.Y >= ColorPickerGui.AbsolutePosition.Y and
                mousePos.Y <= ColorPickerGui.AbsolutePosition.Y + ColorPickerGui.AbsoluteSize.Y
            ) and not (
                mousePos.X >= parent.AbsolutePosition.X and
                mousePos.X <= parent.AbsolutePosition.X + parent.AbsoluteSize.X and
                mousePos.Y >= parent.AbsolutePosition.Y and
                mousePos.Y <= parent.AbsolutePosition.Y + parent.AbsoluteSize.Y
            ) then
                ColorPickerGui.Visible = false
            end
        end
    end)
    
    return {
        Gui = ColorPickerGui,
        SetColor = function(color)
            setColorFromRGB(
                math.floor(color.R * 255),
                math.floor(color.G * 255),
                math.floor(color.B * 255)
            )
        end,
        GetColor = function()
            return selectedColor
        end
    }
end

-- Configuration System Functions
local function saveConfig(name)
    if not isfolder(ConfigSystem.Folder) then
        makefolder(ConfigSystem.Folder)
    end
    
    local success, encodedData = pcall(function()
        return HttpService:JSONEncode(_G.UILibraryConfig)
    end)
    
    if success then
        writefile(ConfigSystem.Folder .. "/" .. name .. ConfigSystem.Extension, encodedData)
        return true
    else
        warn("Failed to save config: " .. tostring(encodedData))
        return false
    end
end

local function loadConfig(name)
    local path = ConfigSystem.Folder .. "/" .. name .. ConfigSystem.Extension
    
    if isfile(path) then
        local success, decodedData = pcall(function()
            return HttpService:JSONDecode(readfile(path))
        end)
        
        if success then
            return decodedData
        else
            warn("Failed to load config: " .. tostring(decodedData))
            return nil
        end
    else
        return nil
    end
end

local function getConfigList()
    if not isfolder(ConfigSystem.Folder) then
        makefolder(ConfigSystem.Folder)
        return {}
    end
    
    local files = listfiles(ConfigSystem.Folder)
    local configs = {}
    
    for _, file in ipairs(files) do
        local fileName = string.match(file, "[^/\\]+$")
        if string.sub(fileName, -#ConfigSystem.Extension) == ConfigSystem.Extension then
            table.insert(configs, string.sub(fileName, 1, -#ConfigSystem.Extension - 1))
        end
    end
    
    return configs
end

-- Key System Functions
local function fetchKey(url)
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    
    if success then
        return string.gsub(result, "%s+", "")
    else
        warn("Failed to fetch key: " .. tostring(result))
        return nil
    end
end

-- Main Library Functions
function UILibrary:CreateWindow(title, keySystemOptions)
    -- Initialize global config table
    if not _G.UILibraryConfig then
        _G.UILibraryConfig = {}
    end
    
    -- Key System Check
    if keySystemOptions and keySystemOptions.Enabled then
        -- Create key system UI
        local KeySystemGui = createInstance("ScreenGui", {
            Name = "KeySystem",
            Parent = CoreGui,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            ResetOnSpawn = false
        })
        
        local KeyFrame = createInstance("Frame", {
            Name = "KeyFrame",
            Size = UDim2.new(0, 300, 0, 200),
            Position = UDim2.new(0.5, -150, 0.5, -100),
            BackgroundColor3 = BACKGROUND_COLOR,
            BorderSizePixel = 0,
            Parent = KeySystemGui
        })
        createRoundedCorner(KeyFrame, 6)
        createStroke(KeyFrame, Color3.fromRGB(50, 50, 50), 1, 0)
        
        local KeyTitle = createInstance("TextLabel", {
            Name = "KeyTitle",
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundTransparency = 1,
            Text = "Key System",
            TextColor3 = TEXT_COLOR,
            TextSize = 18,
            Font = Enum.Font.GothamBold,
            Parent = KeyFrame
        })
        
        local KeyDescription = createInstance("TextLabel", {
            Name = "KeyDescription",
            Size = UDim2.new(1, -40, 0, 40),
            Position = UDim2.new(0, 20, 0, 40),
            BackgroundTransparency = 1,
            Text = keySystemOptions.Note or "Please enter the key to continue",
            TextColor3 = SECONDARY_TEXT_COLOR,
            TextSize = 14,
            TextWrapped = true,
            Font = Enum.Font.Gotham,
            Parent = KeyFrame
        })
        
        local KeyInput = createInstance("TextBox", {
            Name = "KeyInput",
            Size = UDim2.new(1, -40, 0, 40),
            Position = UDim2.new(0, 20, 0, 90),
            BackgroundColor3 = INPUT_BACKGROUND,
            Text = "",
            PlaceholderText = "Enter key here...",
            TextColor3 = TEXT_COLOR,
            PlaceholderColor3 = SECONDARY_TEXT_COLOR,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            ClearTextOnFocus = false,
            Parent = KeyFrame
        })
        createRoundedCorner(KeyInput, 4)
        
        local SubmitButton = createInstance("TextButton", {
            Name = "SubmitButton",
            Size = UDim2.new(1, -40, 0, 40),
            Position = UDim2.new(0, 20, 0, 140),
            BackgroundColor3 = ACCENT_COLOR,
            Text = "Submit",
            TextColor3 = BACKGROUND_COLOR,
            TextSize = 14,
            Font = Enum.Font.GothamSemibold,
            Parent = KeyFrame
        })
        createRoundedCorner(SubmitButton, 4)
        
        local StatusLabel = createInstance("TextLabel", {
            Name = "StatusLabel",
            Size = UDim2.new(1, 0, 0, 20),
            Position = UDim2.new(0, 0, 1, -20),
            BackgroundTransparency = 1,
            Text = "",
            TextColor3 = Color3.fromRGB(255, 100, 100),
            TextSize = 12,
            Font = Enum.Font.Gotham,
            Parent = KeyFrame
        })
        
        -- Make key frame draggable
        makeOnlyTopDraggable(KeyFrame, KeyTitle)
        
        -- Fetch the key from the URL
        local correctKey = nil
        
        if keySystemOptions.KeyURL then
            spawn(function()
                StatusLabel.Text = "Fetching key..."
                correctKey = fetchKey(keySystemOptions.KeyURL)
                if correctKey then
                    StatusLabel.Text = "Key fetched successfully"
                    StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                else
                    StatusLabel.Text = "Failed to fetch key"
                    StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                end
                wait(2)
                StatusLabel.Text = ""
            end)
        else
            correctKey = keySystemOptions.Key
        end
        
        -- Key validation
        local keyValidated = false
        
        local function validateKey()
            if not correctKey then
                StatusLabel.Text = "Key not available yet, try again"
                StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                wait(2)
                StatusLabel.Text = ""
                return
            end
            
            if KeyInput.Text == correctKey then
                keyValidated = true
                StatusLabel.Text = "Key validated successfully!"
                StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                wait(1)
                KeySystemGui:Destroy()
                return true
            else
                StatusLabel.Text = "Invalid key, please try again"
                StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                wait(2)
                StatusLabel.Text = ""
                return false
            end
        end
        
        SubmitButton.MouseButton1Click:Connect(function()
            validateKey()
        end)
        
        KeyInput.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                validateKey()
            end
        end)
        
        -- Wait for key validation
        repeat wait() until keyValidated
    end
    
    -- Check if a UI already exists and remove it
    if CoreGui:FindFirstChild("UILibrary") then
        CoreGui:FindFirstChild("UILibrary"):Destroy()
    end
    
    -- Create main GUI
    local UILibraryGui = createInstance("ScreenGui", {
        Name = "UILibrary",
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    
    -- Create main frame
    local MainFrame = createInstance("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 600, 0, 400),
        Position = UDim2.new(0.5, -300, 0.5, -200),
        BackgroundColor3 = BACKGROUND_COLOR,
        BorderSizePixel = 0,
        Parent = UILibraryGui,
        Visible = true
    })
    createRoundedCorner(MainFrame, 6)
    createStroke(MainFrame, Color3.fromRGB(50, 50, 50), 1, 0)
    
    -- Create shadow
    local Shadow = createInstance("ImageLabel", {
        Name = "Shadow",
        Size = UDim2.new(1, 30, 1, 30),
        Position = UDim2.new(0, -15, 0, -15),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        Parent = MainFrame,
        ZIndex = 0
    })
    
    -- Create sidebar
    local Sidebar = createInstance("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 120, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = SIDEBAR_COLOR,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    
    -- Create sidebar corner (only round the right side)
    local SidebarCorner = createInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = Sidebar
    })
    
    -- Create sidebar corner fix (to make only the right side rounded)
    local SidebarCornerFix = createInstance("Frame", {
        Name = "SidebarCornerFix",
        Size = UDim2.new(0, 6, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = SIDEBAR_COLOR,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = Sidebar
    })
    
    -- Create sidebar title
    local SidebarTitle = createInstance("TextLabel", {
        Name = "SidebarTitle",
        Size = UDim2.new(1, 0, 0, 50),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = title or "UI Library",
        TextColor3 = TEXT_COLOR,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        Parent = Sidebar
    })
    
    -- Create sidebar container for tabs
    local SidebarContainer = createInstance("ScrollingFrame", {
        Name = "SidebarContainer",
        Size = UDim2.new(1, 0, 1, -50),
        Position = UDim2.new(0, 0, 0, 50),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = Sidebar
    })
    
    local SidebarLayout = createInstance("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = SidebarContainer
    })
    
    local SidebarPadding = createInstance("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5),
        Parent = SidebarContainer
    })
    
    -- Create content area
    local ContentArea = createInstance("Frame", {
        Name = "ContentArea",
        Size = UDim2.new(1, -120, 1, 0),
        Position = UDim2.new(0, 120, 0, 0),
        BackgroundTransparency = 1,
        Parent = MainFrame
    })
    
    -- Create top bar
    local TopBar = createInstance("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Parent = ContentArea
    })
    
    -- Create tab title
    local TabTitle = createInstance("TextLabel", {
        Name = "TabTitle",
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 20, 0, 0),
        BackgroundTransparency = 1,
        Text = "Main",
        TextColor3 = TEXT_COLOR,
        TextSize = 16,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TopBar
    })
    
    -- Create search bar
    local SearchFrame = createInstance("Frame", {
        Name = "SearchFrame",
        Size = UDim2.new(0, 150, 0, 30),
        Position = UDim2.new(1, -170, 0.5, -15),
        BackgroundColor3 = SIDEBAR_COLOR,
        BorderSizePixel = 0,
        Parent = TopBar
    })
    createRoundedCorner(SearchFrame, 4)
    createStroke(SearchFrame, Color3.fromRGB(50, 50, 50), 1, 0)
    
    local SearchLabel = createInstance("TextLabel", {
        Name = "SearchLabel",
        Size = UDim2.new(0, 50, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = "Search",
        TextColor3 = SECONDARY_TEXT_COLOR,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = SearchFrame
    })
    
    local SearchIcon = createInstance("ImageLabel", {
        Name = "SearchIcon",
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -26, 0.5, -8),
        BackgroundTransparency = 1,
        Image = "rbxassetid://3926305904",
        ImageRectOffset = Vector2.new(964, 324),
        ImageRectSize = Vector2.new(36, 36),
        ImageColor3 = SECONDARY_TEXT_COLOR,
        Parent = SearchFrame
    })
    
    local SearchInput = createInstance("TextBox", {
        Name = "SearchInput",
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 60, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = "Search...",
        TextColor3 = TEXT_COLOR,
        PlaceholderColor3 = SECONDARY_TEXT_COLOR,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false,
        Parent = SearchFrame
    })
    
    -- Add search functionality
    SearchInput.Changed:Connect(function(prop)
        if prop == "Text" then
            local searchText = string.lower(SearchInput.Text)
            
            -- Search through all UI elements
            for _, tab in pairs(Tabs) do
                local tabContent = tab.Content
                
                for _, section in ipairs(tabContent:GetChildren()) do
                    if section:IsA("Frame") and section.Name:match("Section$") then
                        local sectionContent = section:FindFirstChild("Content")
                        
                        if sectionContent then
                            for _, element in ipairs(sectionContent:GetChildren()) do
                                if element:IsA("Frame") then
                                    local label = element:FindFirstChild("Label")
                                    
                                    if label and label:IsA("TextLabel") then
                                        if searchText == "" then
                                            element.Visible = true
                                        else
                                            element.Visible = string.find(string.lower(label.Text), searchText) ~= nil
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
    
    -- Create content container
    local ContentContainer = createInstance("Frame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, 0, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundTransparency = 1,
        Parent = ContentArea
    })
    
    -- Create bottom bar
    local BottomBar = createInstance("Frame", {
        Name = "BottomBar",
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 1, -30),
        BackgroundTransparency = 1,
        Parent = MainFrame
    })
    
    local BottomText = createInstance("TextLabel", {
        Name = "BottomText",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "UI Library v1.0",
        TextColor3 = SECONDARY_TEXT_COLOR,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        Parent = BottomBar
    })
    
    -- Create mobile toggle button
    local MobileToggle
    if IsMobile then
        MobileToggle = createInstance("ImageButton", {
            Name = "MobileToggle",
            Size = UDim2.new(0, 40, 0, 40),
            Position = UDim2.new(0, 10, 0, 10),
            BackgroundColor3 = BACKGROUND_COLOR,
            Image = "rbxassetid://6031094670",
            ImageColor3 = ACCENT_COLOR,
            Parent = UILibraryGui
        })
        createRoundedCorner(MobileToggle, 8)
        createStroke(MobileToggle, ACCENT_COLOR, 2, 0)
        
        -- Make mobile toggle draggable
        makeOnlyTopDraggable(MobileToggle, MobileToggle)
        
        MobileToggle.MouseButton1Click:Connect(function()
            MainFrame.Visible = not MainFrame.Visible
        end)
    end
    
    -- Make only the top part of the UI draggable
    makeOnlyTopDraggable(MainFrame, TopBar)
    makeOnlyTopDraggable(MainFrame, SidebarTitle)
    
    -- Tab system
    local Tabs = {}
    local SelectedTab = nil
    local UIElements = {}
    
    local Window = {}
    
    function Window:CreateTab(name, icon)
        -- Create tab button in sidebar
        local TabButton = createInstance("Frame", {
            Name = name .. "Tab",
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundTransparency = 1,
            Parent = SidebarContainer
        })
        
        local TabButtonBackground = createInstance("Frame", {
            Name = "Background",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = SIDEBAR_COLOR,
            BackgroundTransparency = 1,
            Parent = TabButton
        })
        createRoundedCorner(TabButtonBackground, 4)
        createStroke(TabButtonBackground, Color3.fromRGB(50, 50, 50), 1, 1)
        
        local TabButtonIcon
        if icon then
            TabButtonIcon = createInstance("ImageLabel", {
                Name = "Icon",
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(0, 5, 0.5, -10),
                BackgroundTransparency = 1,
                Image = icon,
                ImageColor3 = SECONDARY_TEXT_COLOR,
                Parent = TabButton
            })
        end
        
        local TabButtonText = createInstance("TextLabel", {
            Name = "Text",
            Size = UDim2.new(1, icon and -30 or -10, 1, 0),
            Position = UDim2.new(0, icon and 30 or 5, 0, 0),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = SECONDARY_TEXT_COLOR,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = TabButton
        })
        
        -- Create tab content
        local TabContent = createInstance("ScrollingFrame", {
            Name = name .. "Content",
            Size = UDim2.new(1, -40, 1, -20),
            Position = UDim2.new(0, 20, 0, 10),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = SECONDARY_TEXT_COLOR,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false,
            Parent = ContentContainer
        })
        
        local TabContentLayout = createInstance("UIListLayout", {
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = TabContent
        })
        
        -- Tab selection logic
        TabButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if SelectedTab then
                    -- Deselect current tab
                    createTween(Tabs[SelectedTab].ButtonBackground, {BackgroundTransparency = 1}):Play()
                    createTween(Tabs[SelectedTab].ButtonText, {TextColor3 = SECONDARY_TEXT_COLOR}):Play()
                    if Tabs[SelectedTab].ButtonIcon then
                        createTween(Tabs[SelectedTab].ButtonIcon, {ImageColor3 = SECONDARY_TEXT_COLOR}):Play()
                    end
                    Tabs[SelectedTab].Content.Visible = false
                end
                
                -- Select new tab
                createTween(TabButtonBackground, {BackgroundTransparency = 0.8}):Play()
                createTween(TabButtonText, {TextColor3 = TEXT_COLOR}):Play()
                if TabButtonIcon then
                    createTween(TabButtonIcon, {ImageColor3 = ACCENT_COLOR}):Play()
                end
                TabContent.Visible = true
                
                SelectedTab = name
                TabTitle.Text = name
            end
        end)
        
        -- Store tab data
        Tabs[name] = {
            Button = TabButton,
            ButtonBackground = TabButtonBackground,
            ButtonText = TabButtonText,
            ButtonIcon = TabButtonIcon,
            Content = TabContent
        }
        
        -- If this is the first tab, select it
        if not SelectedTab then
            createTween(TabButtonBackground, {BackgroundTransparency = 0.8}):Play()
            createTween(TabButtonText, {TextColor3 = TEXT_COLOR}):Play()
            if TabButtonIcon then
                createTween(TabButtonIcon, {ImageColor3 = ACCENT_COLOR}):Play()
            end
            TabContent.Visible = true
            
            SelectedTab = name
            TabTitle.Text = name
        end
        
        -- Tab content creation functions
        local Tab = {}
        
        function Tab:CreateSection(sectionName)
            local Section = createInstance("Frame", {
                Name = sectionName .. "Section",
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1,
                Parent = TabContent
            })
            
            local SectionTitle = createInstance("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1,
                Text = sectionName,
                TextColor3 = TEXT_COLOR,
                TextSize = 16,
                Font = Enum.Font.GothamSemibold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Section
            })
            
            local SectionContent = createInstance("Frame", {
                Name = "Content",
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 30),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = Section
            })
            
            local SectionContentLayout = createInstance("UIListLayout", {
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = SectionContent
            })
            
            -- Update section size based on content
            SectionContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Section.Size = UDim2.new(1, 0, 0, 30 + SectionContentLayout.AbsoluteContentSize.Y)
            end)
            
            local SectionObj = {}
            
            function SectionObj:CreateToggle(toggleName, defaultState, callback)
                local Toggle = createInstance("Frame", {
                    Name = toggleName .. "Toggle",
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    Parent = SectionContent
                })
                
                local ToggleLabel = createInstance("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, -60, 1, 0),
                    BackgroundTransparency = 1,
                    Text = toggleName,
                    TextColor3 = SECONDARY_TEXT_COLOR,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Toggle
                })
                
                local KeybindLabel = createInstance("TextLabel", {
                    Name = "KeybindLabel",
                    Size = UDim2.new(0, 30, 1, 0),
                    Position = UDim2.new(1, -60, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "[E]",
                    TextColor3 = SECONDARY_TEXT_COLOR,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = Toggle
                })
                
                local ToggleButton = createInstance("Frame", {
                    Name = "Button",
                    Size = UDim2.new(0, 40, 0, 20),
                    Position = UDim2.new(1, -45, 0.5, -10),
                    BackgroundColor3 = defaultState and TOGGLE_COLOR or TOGGLE_OFF_COLOR,
                    Parent = Toggle
                })
                createRoundedCorner(ToggleButton, 10)
                createStroke(ToggleButton, Color3.fromRGB(50, 50, 50), 1, 0)
                
                local ToggleCircle = createInstance("Frame", {
                    Name = "Circle",
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(defaultState and 1 or 0, defaultState and -18 or 2, 0.5, -8),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Parent = ToggleButton
                })
                createRoundedCorner(ToggleCircle, 8)
                
                local state = defaultState or false
                
                local function updateToggle()
                    state = not state
                    
                    local toggleTween = createTween(ToggleButton, {BackgroundColor3 = state and TOGGLE_COLOR or TOGGLE_OFF_COLOR})
                    local circleTween = createTween(ToggleCircle, {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
                    
                    toggleTween:Play()
                    circleTween:Play()
                    
                    if callback then
                        callback(state)
                    end
                    
                    -- Update config
                    _G.UILibraryConfig[toggleName] = state
                end
                
                ToggleButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        updateToggle()
                    end
                end)
                
                -- Register UI element for config saving
                local toggleElement = {
                    Type = "Toggle",
                    Name = toggleName,
                    Section = sectionName,
                    Tab = name,
                    Get = function()
                        return state
                    end,
                    Set = function(value)
                        if state ~= value then
                            state = not state -- We need to flip it because updateToggle will flip it again
                            updateToggle()
                        end
                    end
                }
                
                table.insert(UIElements, toggleElement)
                
                return toggleElement
            end
            
            function SectionObj:CreateSlider(sliderName, options, callback)
                options = options or {}
                local min = options.min or 0
                local max = options.max or 100
                local default = options.default or min
                local decimals = options.decimals or 0
                
                local Slider = createInstance("Frame", {
                    Name = sliderName .. "Slider",
                    Size = UDim2.new(1, 0, 0, 50),
                    BackgroundTransparency = 1,
                    Parent = SectionContent
                })
                
                local SliderLabel = createInstance("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, -70, 0, 20),
                    BackgroundTransparency = 1,
                    Text = sliderName,
                    TextColor3 = SECONDARY_TEXT_COLOR,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Slider
                })
                
                local SliderValue = createInstance("TextLabel", {
                    Name = "Value",
                    Size = UDim2.new(0, 40, 0, 20),
                    Position = UDim2.new(1, -40, 0, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(default),
                    TextColor3 = SECONDARY_TEXT_COLOR,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = Slider
                })
                
                local SliderBackground = createInstance("Frame", {
                    Name = "Background",
                    Size = UDim2.new(1, 0, 0, 8),
                    Position = UDim2.new(0, 0, 0, 30),
                    BackgroundColor3 = SLIDER_BACKGROUND,
                    Parent = Slider
                })
                createRoundedCorner(SliderBackground, 4)
                createStroke(SliderBackground, Color3.fromRGB(50, 50, 50), 1, 0)
                
                local SliderFill = createInstance("Frame", {
                    Name = "Fill",
                    Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                    BackgroundColor3 = SLIDER_FILL,
                    Parent = SliderBackground
                })
                createRoundedCorner(SliderFill, 4)
                
                local SliderKnob = createInstance("Frame", {
                    Name = "Knob",
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Parent = SliderBackground
                })
                createRoundedCorner(SliderKnob, 8)
                createStroke(SliderKnob, Color3.fromRGB(50, 50, 50), 1, 0)
                
                local value = default
                local isDragging = false
                
                local function updateSlider(newValue)
                    value = math.clamp(newValue, min, max)
                    
                    if decimals > 0 then
                        local mult = 10 ^ decimals
                        value = math.floor(value * mult + 0.5) / mult
                    else
                        value = math.floor(value)
                    end
                    
                    SliderValue.Text = tostring(value)
                    
                    local percent = (value - min) / (max - min)
                    SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                    SliderKnob.Position = UDim2.new(percent, -8, 0.5, -8)
                    
                    if callback then
                        callback(value)
                    end
                    
                    -- Update config
                    _G.UILibraryConfig[sliderName] = value
                end
                
                SliderBackground.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        isDragging = true
                        
                        local mousePos = input.Position.X
                        local sliderPos = SliderBackground.AbsolutePosition.X
                        local sliderSize = SliderBackground.AbsoluteSize.X
                        
                        local percent = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
                        local newValue = min + (max - min) * percent
                        
                        updateSlider(newValue)
                    end
                end)
                
                SliderBackground.InputEnded:Connect(function(input)
                    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                        isDragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local mousePos = input.Position.X
                        local sliderPos = SliderBackground.AbsolutePosition.X
                        local sliderSize = SliderBackground.AbsoluteSize.X
                        
                        local percent = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
                        local newValue = min + (max - min) * percent
                        
                        updateSlider(newValue)
                    end
                end)
                
                -- Register UI element for config saving
                local sliderElement = {
                    Type = "Slider",
                    Name = sliderName,
                    Section = sectionName,
                    Tab = name,
                    Min = min,
                    Max = max,
                    Get = function()
                        return value
                    end,
                    Set = function(newValue)
                        updateSlider(newValue)
                    end
                }
                
                table.insert(UIElements, sliderElement)
                
                return sliderElement
            end
            
            function SectionObj:CreateDropdown(dropdownName, options, callback)
                local items = options.items or {}
                local default = options.default or items[1] or ""
                
                local Dropdown = createInstance("Frame", {
                    Name = dropdownName .. "Dropdown",
                    Size = UDim2.new(1, 0, 0, 50),
                    BackgroundTransparency = 1,
                    Parent = SectionContent
                })
                
                local DropdownLabel = createInstance("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Text = dropdownName,
                    TextColor3 = SECONDARY_TEXT_COLOR,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Dropdown
                })
                
                local DropdownButton = createInstance("TextButton", {
                    Name = "Button",
                    Size = UDim2.new(1, 0, 0, 30),
                    Position = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = DROPDOWN_BACKGROUND,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = Dropdown
                })
                createRoundedCorner(DropdownButton, 4)
                createStroke(DropdownButton, Color3.fromRGB(50, 50, 50), 1, 0)
                
                local DropdownText = createInstance("TextLabel", {
                    Name = "Text",
                    Size = UDim2.new(1, -30, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = default,
                    TextColor3 = TEXT_COLOR,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = DropdownButton
                })
                
                local DropdownArrow = createInstance("ImageLabel", {
                    Name = "Arrow",
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(1, -26, 0.5, -8),
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://6031091004",
                    ImageColor3 = SECONDARY_TEXT_COLOR,
                    Parent = DropdownButton
                })
                
                local DropdownMenu = createInstance("Frame", {
                    Name = "Menu",
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 1, 0),
                    BackgroundColor3 = DROPDOWN_BACKGROUND,
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 10,
                    Parent = DropdownButton
                })
                createRoundedCorner(DropdownMenu, 4)
                createStroke(DropdownMenu, Color3.fromRGB(50, 50, 50), 1, 0)
                
                local DropdownList = createInstance("ScrollingFrame", {
                    Name = "List",
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = SECONDARY_TEXT_COLOR,
                    ZIndex = 10,
                    Parent = DropdownMenu
                })
                
                local DropdownListLayout = createInstance("UIListLayout", {
                    Padding = UDim.new(0, 5),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = DropdownList
                })
                
                local DropdownListPadding = createInstance("UIPadding", {
                    PaddingLeft = UDim.new(0, 5),
                    PaddingRight = UDim.new(0, 5),
                    PaddingTop = UDim.new(0, 5),
                    PaddingBottom = UDim.new(0, 5),
                    Parent = DropdownList
                })
                
                local isOpen = false
                local selectedItem = default
                
                local function updateDropdown()
                    isOpen = not isOpen
                    
                    if isOpen then
                        DropdownMenu.Visible = true
                        createTween(DropdownMenu, {Size = UDim2.new(1, 0, 0, math.min(#items * 30, 150))}):Play()
                        createTween(DropdownArrow, {Rotation = 180}):Play()
                    else
                        createTween(DropdownMenu, {Size = UDim2.new(1, 0, 0, 0)}):Play()
                        createTween(DropdownArrow, {Rotation = 0}):Play()
                        
                        delay(0.2, function()
                            if not isOpen then
                                DropdownMenu.Visible = false
                            end
                        end)
                    end
                end
                
                -- Populate dropdown items
                for i, item in ipairs(items) do
                    local ItemButton = createInstance("TextButton", {
                        Name = "Item_" .. i,
                        Size = UDim2.new(1, -10, 0, 25),
                        BackgroundTransparency = 1,
                        Text = item,
                        TextColor3 = item == selectedItem and ACCENT_COLOR or SECONDARY_TEXT_COLOR,
                        TextSize = 14,
                        Font = Enum.Font.Gotham,
                        ZIndex = 10,
                        Parent = DropdownList
                    })
                    
                    ItemButton.MouseEnter:Connect(function()
                        if item ~= selectedItem then
                            createTween(ItemButton, {TextColor3 = TEXT_COLOR}):Play()
                        end
                    end)
                    
                    ItemButton.MouseLeave:Connect(function()
                        if item ~= selectedItem then
                            createTween(ItemButton, {TextColor3 = SECONDARY_TEXT_COLOR}):Play()
                        end
                    end)
                    
                    ItemButton.MouseButton1Click:Connect(function()
                        if selectedItem ~= item then
                            -- Update selected item
                            for _, child in pairs(DropdownList:GetChildren()) do
                                if child:IsA("TextButton") then
                                    createTween(child, {TextColor3 = SECONDARY_TEXT_COLOR}):Play()
                                end
                            end
                            
                            selectedItem = item
                            DropdownText.Text = item
                            createTween(ItemButton, {TextColor3 = ACCENT_COLOR}):Play()
                            
                            if callback then
                                callback(item)
                            end
                            
                            -- Update config
                            _G.UILibraryConfig[dropdownName] = item
                        end
                        
                        updateDropdown()
                    end)
                end
                
                DropdownButton.MouseButton1Click:Connect(function()
                    updateDropdown()
                end)
                
                -- Close dropdown when clicking elsewhere
                UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        local mousePos = UserInputService:GetMouseLocation()
                        if isOpen and not (mousePos.X >= DropdownButton.AbsolutePosition.X and
                                mousePos.X <= DropdownButton.AbsolutePosition.X + DropdownButton.AbsoluteSize.X and
                                mousePos.Y >= DropdownButton.AbsolutePosition.Y and
                                mousePos.Y <= DropdownButton.AbsolutePosition.Y + DropdownButton.AbsoluteSize.Y + DropdownMenu.AbsoluteSize.Y) then
                            updateDropdown()
                        end
                    end
                end)
                
                -- Register UI element for config saving
                local dropdownElement = {
                    Type = "Dropdown",
                    Name = dropdownName,
                    Section = sectionName,
                    Tab = name,
                    Items = items,
                    Get = function()
                        return selectedItem
                    end,
                    Set = function(item)
                        if table.find(items, item) and selectedItem ~= item then
                            selectedItem = item
                            DropdownText.Text = item
                            
                            for _, child in pairs(DropdownList:GetChildren()) do
                                if child:IsA("TextButton") and child.Text == item then
                                    createTween(child, {TextColor3 = ACCENT_COLOR}):Play()
                                elseif child:IsA("TextButton") then
                                    createTween(child, {TextColor3 = SECONDARY_TEXT_COLOR}):Play()
                                end
                            end
                            
                            if callback then
                                callback(item)
                            end
                        end
                    end,
                    Refresh = function(newItems, keepSelected)
                        items = newItems
                        
                        -- Clear existing items
                        for _, child in pairs(DropdownList:GetChildren()) do
                            if child:IsA("TextButton") then
                                child:Destroy()
                            end
                        end
                        
                        -- Check if we should keep the selected item
                        if not keepSelected or not table.find(items, selectedItem) then
                            selectedItem = items[1] or ""
                            DropdownText.Text = selectedItem
                        end
                        
                        -- Repopulate dropdown items
                        for i, item in ipairs(items) do
                            local ItemButton = createInstance("TextButton", {
                                Name = "Item_" .. i,
                                Size = UDim2.new(1, -10, 0, 25),
                                BackgroundTransparency = 1,
                                Text = item,
                                TextColor3 = item == selectedItem and ACCENT_COLOR or SECONDARY_TEXT_COLOR,
                                TextSize = 14,
                                Font = Enum.Font.Gotham,
                                ZIndex = 10,
                                Parent = DropdownList
                            })
                            
                            ItemButton.MouseEnter:Connect(function()
                                if item ~= selectedItem then
                                    createTween(ItemButton, {TextColor3 = TEXT_COLOR}):Play()
                                end
                            end)
                            
                            ItemButton.MouseLeave:Connect(function()
                                if item ~= selectedItem then
                                    createTween(ItemButton, {TextColor3 = SECONDARY_TEXT_COLOR}):Play()
                                end
                            end)
                            
                            ItemButton.MouseButton1Click:Connect(function()
                                if selectedItem ~= item then
                                    -- Update selected item
                                    for _, child in pairs(DropdownList:GetChildren()) do
                                        if child:IsA("TextButton") then
                                            createTween(child, {TextColor3 = SECONDARY_TEXT_COLOR}):Play()
                                        end
                                    end
                                    
                                    selectedItem = item
                                    DropdownText.Text = item
                                    createTween(ItemButton, {TextColor3 = ACCENT_COLOR}):Play()
                                    
                                    if callback then
                                        callback(item)
                                    end
                                end
                                
                                updateDropdown()
                            end)
                        end
                    end
                }
                
                table.insert(UIElements, dropdownElement)
                
                return dropdownElement
            end
            
            function SectionObj:CreateTextBox(boxName, defaultText, placeholder, callback)
                local TextBox = createInstance("Frame", {
                    Name = boxName .. "TextBox",
                    Size = UDim2.new(1, 0, 0, 50),
                    BackgroundTransparency = 1,
                    Parent = SectionContent
                })
                
                local TextBoxLabel = createInstance("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Text = boxName,
                    TextColor3 = SECONDARY_TEXT_COLOR,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = TextBox
                })
                
                local TextBoxFrame = createInstance("Frame", {
                    Name = "Frame",
                    Size = UDim2.new(1, 0, 0, 30),
                    Position = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = DROPDOWN_BACKGROUND,
                    Parent = TextBox
                })
                createRoundedCorner(TextBoxFrame, 4)
                createStroke(TextBoxFrame, Color3.fromRGB(50, 50, 50), 1, 0)
                
                local EditIcon = createInstance("ImageLabel", {
                    Name = "EditIcon",
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(1, -26, 0.5, -8),
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://6764432408",
                    ImageColor3 = SECONDARY_TEXT_COLOR,
                    Parent = TextBoxFrame
                })
                
                local TextBoxInput = createInstance("TextBox", {
                    Name = "Input",
                    Size = UDim2.new(1, -40, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = defaultText or "",
                    PlaceholderText = placeholder or "Enter text...",
                    TextColor3 = TEXT_COLOR,
                    PlaceholderColor3 = Color3.fromRGB(120, 120, 120),
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false,
                    Parent = TextBoxFrame
                })
                
                TextBoxInput.FocusLost:Connect(function(enterPressed)
                    if callback then
                        callback(TextBoxInput.Text, enterPressed)
                    end
                    
                    -- Update config
                    _G.UILibraryConfig[boxName] = TextBoxInput.Text
                end)
                
                -- Register UI element for config saving
                local textboxElement = {
                    Type = "TextBox",
                    Name = boxName,
                    Section = sectionName,
                    Tab = name,
                    Get = function()
                        return TextBoxInput.Text
                    end,
                    Set = function(text)
                        TextBoxInput.Text = text
                    end
                }
                
                table.insert(UIElements, textboxElement)
                
                return textboxElement
            end
            
            function SectionObj:CreateColorPicker(pickerName, defaultColor, callback)
                local ColorPicker = createInstance("Frame", {
                    Name = pickerName .. "ColorPicker",
                    Size = UDim2.new(1, 0, 0, 50),
                    BackgroundTransparency = 1,
                    Parent = SectionContent
                })
                
                local ColorPickerLabel = createInstance("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, -60, 0, 20),
                    BackgroundTransparency = 1,
                    Text = pickerName,
                    TextColor3 = SECONDARY_TEXT_COLOR,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = ColorPicker
                })
                
                local ColorDisplay = createInstance("TextButton", {
                    Name = "Display",
                    Size = UDim2.new(0, 24, 0, 24),
                    Position = UDim2.new(1, -30, 0, 0),
                    BackgroundColor3 = defaultColor or Color3.fromRGB(255, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    Parent = ColorPicker
                })
                createRoundedCorner(ColorDisplay, 4)
                createStroke(ColorDisplay, Color3.fromRGB(50, 50, 50), 1, 0)
                
                -- Create the color picker
                local colorPickerInstance = createColorPicker(ColorDisplay, defaultColor or Color3.fromRGB(255, 0, 0), function(color)
                    ColorDisplay.BackgroundColor3 = color
                    if callback then
                        callback(color)
                    end
                    
                    -- Update config
                    _G.UILibraryConfig[pickerName] = {
                        R = color.R,
                        G = color.G,
                        B = color.B
                    }
                end)
                
                -- Show/hide color picker on click
                ColorDisplay.MouseButton1Click:Connect(function()
                    colorPickerInstance.Gui.Visible = not colorPickerInstance.Gui.Visible
                    
                    -- Position the color picker properly
                    if colorPickerInstance.Gui.Visible then
                        colorPickerInstance.Gui.Position = UDim2.new(0, ColorDisplay.AbsolutePosition.X + ColorDisplay.AbsoluteSize.X + 10, 0, ColorDisplay.AbsolutePosition.Y)
                    end
                end)
                
                -- Register UI element for config saving
                local colorPickerElement = {
                    Type = "ColorPicker",
                    Name = pickerName,
                    Section = sectionName,
                    Tab = name,
                    Get = function()
                        return ColorDisplay.BackgroundColor3
                    end,
                    Set = function(color)
                        ColorDisplay.BackgroundColor3 = color
                        colorPickerInstance.SetColor(color)
                        
                        if callback then
                            callback(color)
                        end
                    end
                }
                
                table.insert(UIElements, colorPickerElement)
                
                return colorPickerElement
            end
            
            function SectionObj:CreateButton(buttonName, callback)
                local Button = createInstance("Frame", {
                    Name = buttonName .. "Button",
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    Parent = SectionContent
                })
                
                local ButtonFrame = createInstance("TextButton", {
                    Name = "Frame",
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = BUTTON_COLOR,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = Button
                })
                createRoundedCorner(ButtonFrame, 4)
                createStroke(ButtonFrame, Color3.fromRGB(50, 50, 50), 1, 0)
                
                local ButtonLabel = createInstance("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = buttonName,
                    TextColor3 = TEXT_COLOR,
                    TextSize = 14,
                    Font = Enum.Font.GothamSemibold,
                    Parent = ButtonFrame
                })
                
                ButtonFrame.MouseButton1Click:Connect(function()
                    createTween(ButtonFrame, {BackgroundColor3 = BUTTON_HOVER_COLOR}):Play()
                    
                    if callback then
                        callback()
                    end
                    
                    delay(0.2, function()
                        createTween(ButtonFrame, {BackgroundColor3 = BUTTON_COLOR}):Play()
                    end)
                end)
                
                ButtonFrame.MouseEnter:Connect(function()
                    createTween(ButtonFrame, {BackgroundColor3 = BUTTON_HOVER_COLOR}):Play()
                end)
                
                ButtonFrame.MouseLeave:Connect(function()
                    createTween(ButtonFrame, {BackgroundColor3 = BUTTON_COLOR}):Play()
                end)
                
                return Button
            end
            
            return SectionObj
        end
        
        return Tab
    end
    
    -- Configuration functions
    function Window:SaveConfig(name)
        return saveConfig(name)
    end
    
    function Window:LoadConfig(name)
        local configData = loadConfig(name)
        if not configData then
            return false
        end
        
        _G.UILibraryConfig = configData
        
        for _, element in ipairs(UIElements) do
            local value = configData[element.Name]
            
            if value ~= nil then
                if element.Type == "ColorPicker" and type(value) == "table" then
                    -- Convert table back to Color3
                    element.Set(Color3.new(value.R, value.G, value.B))
                else
                    element.Set(value)
                end
            end
        end
        
        return true
    end
    
    function Window:GetConfigList()
        return getConfigList()
    end
    
    return Window
end

return UILibrary
