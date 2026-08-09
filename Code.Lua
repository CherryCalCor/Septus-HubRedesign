if not game:IsLoaded() then
    game.Loaded:Wait()
end

task.wait(1.5)

local Services = {
    Http = game:GetService("HttpService"),
    TP = game:GetService("TeleportService"),
    TS = game:GetService("TweenService"),
    UIS = game:GetService("UserInputService"),
    Run = game:GetService("RunService"),
    VU = game:GetService("VirtualUser"),
    Players = game:GetService("Players"),
    Core = game:GetService("CoreGui"),
    Log = game:GetService("LogService"),
    Market = game:GetService("MarketplaceService"),
    Lighting = game:GetService("Lighting")
}

local LP = Services.Players.LocalPlayer
local UI = { 
    ActiveNotifs = {}, 
    Pages = {}, 
    NavBtns = {}, 
    Connections = {}, 
    Toggles = {},
    State = {
        isGuiVisible = false,
        isMinimized = false,
        oldDesignEnabled = false,
        savedColors = {}
    }
}
_G.pDrawings = {}
_G.ConfigState = {}
_G.ConfigUpdaters = {}
_G.UserBinds = {}

local Colors = {
    Background = Color3.fromRGB(15, 15, 15),
    Surface = Color3.fromRGB(22, 22, 22),
    ToggleShell = Color3.fromRGB(30, 30, 30),
    Border = Color3.fromRGB(40, 40, 40),
    TextMain = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(150, 150, 150),
    Active = Color3.fromRGB(220, 190, 255) 
}

_G.CurrentGradientColors = {Colors.Background, Colors.Active}
_G.NotificationAssetID = "rbxthumb://type=Asset&id=115669221263328&w=150&h=150"
_G.MainMenuLoaded = false
_G.UseNewNotifications = false
_G.NewDesignActive = false
_G.NotificationsEnabled = true

local TWEEN_INFO_FAST = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TWEEN_INFO_SMOOTH = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local Lib = {}

local OfflinePlayers = {}

Services.Players.PlayerRemoving:Connect(function(plr)
    OfflinePlayers[plr.Name] = {
        UserId = plr.UserId,
        LeftTime = os.time()
    }
end)

function Lib.populatePlayersAdvanced(scroll, layout, actionLbl, defaultText, targetCallback)

    for _, v in pairs(scroll:GetChildren()) do 
        if v:IsA("Frame") or v:IsA("TextButton") then 
            v:Destroy() 
        end 
    end
    
    local function createPlayerCard(name, userId, isOnline)
        local card = Lib.Create("Frame", {
            Parent = scroll,
            Size = UDim2.new(1, -6, 0, 50),
            BackgroundColor3 = Colors.Surface,
            BorderSizePixel = 0
        })
        Lib.Create("UICorner", { Parent = card, CornerRadius = UDim.new(0, 6) })
        local cardStroke = Lib.Create("UIStroke", { Parent = card, Color = Colors.Border, Thickness = 1 })

        local avatar = Lib.Create("ImageLabel", {
            Parent = card,
            Size = UDim2.new(0, 38, 0, 38),
            Position = UDim2.new(0, 6, 0.5, -19),
            BackgroundTransparency = 1,
        })
        Lib.Create("UICorner", { Parent = avatar, CornerRadius = UDim.new(1, 0) })
        
        task.spawn(function()
            pcall(function()
                avatar.Image = Services.Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
            end)
        end)

        local nameLbl = Lib.Create("TextLabel", {
            Parent = card,
            Size = UDim2.new(1, -120, 0, 18),
            Position = UDim2.new(0, 50, 0, 8),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = Colors.TextMain,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        local statusColor = isOnline and Color3.fromRGB(80, 220, 120) or Color3.fromRGB(240, 100, 100)
        local statusText = isOnline and "Online" or "Offline"
        
        local statusLbl = Lib.Create("TextLabel", {
            Parent = card,
            Size = UDim2.new(1, -120, 0, 14),
            Position = UDim2.new(0, 50, 0, 26),
            BackgroundTransparency = 1,
            Text = statusText,
            TextColor3 = statusColor,
            Font = Enum.Font.GothamSemibold,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        if isOnline then
            local selectBtn = Lib.Create("TextButton", {
                Parent = card,
                Size = UDim2.new(0, 60, 0, 24),
                Position = UDim2.new(1, -70, 0.5, -12),
                BackgroundColor3 = Colors.Active,
                Text = "Select",
                TextColor3 = Colors.Background,
                Font = Enum.Font.GothamBold,
                TextSize = 10,
                BorderSizePixel = 0
            })
            Lib.Create("UICorner", { Parent = selectBtn, CornerRadius = UDim.new(0, 4) })
            
            selectBtn.MouseButton1Click:Connect(function()
                local actualPlayer = Services.Players:FindFirstChild(name)
                if actualPlayer then
                    targetCallback(actualPlayer)
                    actionLbl.Text = defaultText .. ": " .. name
                end
            end)
        else
            local offlineLbl = Lib.Create("TextLabel", {
                Parent = card,
                Size = UDim2.new(0, 60, 0, 24),
                Position = UDim2.new(1, -70, 0.5, -12),
                BackgroundTransparency = 1,
                Text = "Left",
                TextColor3 = Colors.TextDim,
                Font = Enum.Font.GothamBold,
                TextSize = 10
            })
        end
    end

    for _, plr in ipairs(Services.Players:GetPlayers()) do
        if plr ~= LP then
            createPlayerCard(plr.Name, plr.UserId, true)
        end
    end

    local sortedOffline = {}
    for opName, data in pairs(OfflinePlayers) do
        table.insert(sortedOffline, {name = opName, userId = data.UserId, leftTime = data.LeftTime})
    end
    table.sort(sortedOffline, function(a, b) return a.leftTime > b.leftTime end)
    
    for i = 1, math.clamp(#sortedOffline, 0, 5) do
        local item = sortedOffline[i]
        createPlayerCard(item.name, item.userId, false)
    end
end

local function addRefreshBtn(win, callback)
    local refreshBtn = Lib.Create("TextButton", {
        Parent = win,
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -80, 0, 6),
        BackgroundTransparency = 1,
        Text = "🔄",
        TextColor3 = Colors.TextDim,
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        ZIndex = 10
    })
    refreshBtn.MouseButton1Click:Connect(callback)
    return refreshBtn
end

function Lib.Create(className, properties)
    local instance = Instance.new(className)
    for k, v in pairs(properties) do
        if k ~= "Parent" then instance[k] = v end
    end
    if properties.Parent then instance.Parent = properties.Parent end
    return instance
end

function Lib.makeDraggable(guiObj, dragHandle)
    dragHandle = dragHandle or guiObj
    local dragging, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
            dragging = true; dragStart = input.Position; startPos = guiObj.Position 
        end
    end)
    dragHandle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
            dragging = false 
        end
    end)
    Services.UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            guiObj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function Lib.applyGradient(obj)
    local grad = Instance.new("UIGradient", obj)
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, _G.CurrentGradientColors[1]),
        ColorSequenceKeypoint.new(1, _G.CurrentGradientColors[2])
    })
    grad.Rotation = 45
end
_G.applyGradient = Lib.applyGradient

function Lib.typeWrite(textLabel, fullText, delayTime)
    textLabel.Text = "" 
    for first, last in utf8.graphemes(fullText) do
        local currentText = string.sub(fullText, 1, last)
        textLabel.Text = currentText
        task.wait(delayTime or 0.03) 
    end
end

function Lib.showNotification(message)
    if not _G.NotificationsEnabled then return end
    
    local notifFrame = Lib.Create("Frame", {
        Parent = UI.Screen,
        Size = UDim2.new(0, 280, 0, 65),
        Position = UDim2.new(1, 310, 1, -85),
        BackgroundColor3 = Colors.Surface,
        BorderSizePixel = 0,
        ZIndex = 10000
    })
    Lib.Create("UICorner", { Parent = notifFrame, CornerRadius = UDim.new(0, 6) })
    local stroke = Lib.Create("UIStroke", { Parent = notifFrame, Color = Colors.Active, Thickness = 1 })

    local girlIcon = Lib.Create("ImageLabel", {
        Parent = notifFrame,
        Size = UDim2.new(0, 45, 0, 45),
        Position = UDim2.new(0, 10, 0.5, -22.5),
        BackgroundTransparency = 1,
        Image = _G.NotificationAssetID
    })
    Lib.Create("UICorner", { Parent = girlIcon, CornerRadius = UDim.new(0, 4) })

    local titleLabel = Lib.Create("TextLabel", {
        Parent = notifFrame,
        Size = UDim2.new(1, -75, 0, 15),
        Position = UDim2.new(0, 65, 0, 10),
        BackgroundTransparency = 1,
        Text = "Notification",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Colors.Active,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local msgLabel = Lib.Create("TextLabel", {
        Parent = notifFrame,
        Size = UDim2.new(1, -75, 0, 30),
        Position = UDim2.new(0, 65, 0, 25),
        BackgroundTransparency = 1,
        Text = message,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        TextColor3 = Colors.TextMain,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top
    })

    for _, oldNotif in ipairs(UI.ActiveNotifs) do
        if oldNotif and oldNotif.Parent then
            Services.TS:Create(oldNotif, TWEEN_INFO_FAST, {Position = UDim2.new(1, -295, 1, oldNotif.Position.Y.Offset - 75)}):Play()
        end
    end

    table.insert(UI.ActiveNotifs, notifFrame)
    Services.TS:Create(notifFrame, TWEEN_INFO_FAST, {Position = UDim2.new(1, -295, 1, -85)}):Play()

    task.delay(4, function()
        if not notifFrame or not notifFrame.Parent then return end
        local outTween = Services.TS:Create(notifFrame, TWEEN_INFO_FAST, {Position = UDim2.new(1, 310, 1, notifFrame.Position.Y.Offset), BackgroundTransparency = 1})
        Services.TS:Create(titleLabel, TWEEN_INFO_FAST, {TextTransparency = 1}):Play()
        Services.TS:Create(msgLabel, TWEEN_INFO_FAST, {TextTransparency = 1}):Play()
        Services.TS:Create(girlIcon, TWEEN_INFO_FAST, {ImageTransparency = 1}):Play()
        Services.TS:Create(stroke, TWEEN_INFO_FAST, {Transparency = 1}):Play()
        outTween:Play()
        outTween.Completed:Wait()
        local idx = table.find(UI.ActiveNotifs, notifFrame)
        if idx then table.remove(UI.ActiveNotifs, idx) end
        notifFrame:Destroy()
    end)
end

function Lib.CreateStyledCard(parent, sizeY)
    local card = Lib.Create("Frame", {
        Size = UDim2.new(1, -6, 0, sizeY),
        BackgroundColor3 = Colors.Surface,
        Parent = parent,
        BorderSizePixel = 0
    })
    Lib.Create("UICorner", { Parent = card, CornerRadius = UDim.new(0, 6) })
    Lib.Create("UIStroke", { Parent = card, Color = Colors.Border, Thickness = 1 })
    return card
end

function Lib.createToggle(parent, name, y, defaultState, callback)
    local card = Lib.CreateStyledCard(parent, 40)
    card.Position = UDim2.new(0, 0, 0, y)

    local lbl = Lib.Create("TextLabel", {
        Parent = card,
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local switchShell = Lib.Create("Frame", {
        Parent = card,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.new(0, 38, 0, 22),
        BackgroundColor3 = Colors.ToggleShell,
        BorderSizePixel = 0
    })
    Lib.Create("UICorner", { Parent = switchShell, CornerRadius = UDim.new(0, 5) })
    local stroke = Lib.Create("UIStroke", { Parent = switchShell, Color = Colors.Border, Thickness = 1 })

    local knob = Lib.Create("Frame", {
        Parent = switchShell,
        Position = defaultState and UDim2.new(1, -19, 0, 3) or UDim2.new(0, 3, 0, 3),
        Size = UDim2.new(0, 16, 0, 16),
        BackgroundColor3 = defaultState and Colors.TextMain or Colors.TextDim,
        BorderSizePixel = 0
    })
    Lib.Create("UICorner", { Parent = knob, CornerRadius = UDim.new(0, 4) })

    local clickArea = Lib.Create("TextButton", {
        Parent = switchShell,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false
    })

    local state = defaultState or false

    local function updateVisuals(st, showNotif)
        local targetPos = st and UDim2.new(1, -19, 0, 3) or UDim2.new(0, 3, 0, 3)
        local targetColor = st and Colors.Active or Colors.TextDim
        local borderHex = st and Colors.Active or Colors.Border
        
        Services.TS:Create(knob, TWEEN_INFO_FAST, {Position = targetPos, BackgroundColor3 = targetColor}):Play()
        Services.TS:Create(stroke, TWEEN_INFO_FAST, {Color = borderHex}):Play()
        
        if showNotif then 
            Lib.showNotification(name .. (st and " включен!" or " выключен.")) 
        end
    end

    local function setState(newState, isLoad)
        state = newState
        updateVisuals(state, not isLoad)
        _G.ConfigState[name] = state
        if callback then callback(state) end
    end

    clickArea.MouseButton1Click:Connect(function() setState(not state, false) end)
    _G.ConfigUpdaters[name] = function(val) setState(val, true) end
    
    updateVisuals(state, false)
    _G.ConfigState[name] = state

    return card, knob, setState
end

function Lib.createSlider(parent, yPos, name, min, max, default, callback)
    local card = Lib.CreateStyledCard(parent, 55)
    card.Position = UDim2.new(0, 0, 0, yPos)
    
    local lbl = Lib.Create("TextLabel", {
        Parent = card,
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 12, 0, 6),
        BackgroundTransparency = 1,
        Text = name .. ": " .. default,
        TextColor3 = Colors.TextDim,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local bg = Lib.Create("TextButton", {
        Parent = card,
        Text = "",
        AutoButtonColor = false,
        Size = UDim2.new(1, -24, 0, 6),
        Position = UDim2.new(0, 12, 0, 34),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0
    })
    Lib.Create("UICorner", { Parent = bg })

    local fill = Lib.Create("Frame", {
        Parent = bg,
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Colors.Active,
        BorderSizePixel = 0
    })
    Lib.Create("UICorner", { Parent = fill })

    local knob = Lib.Create("Frame", {
        Parent = bg,
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6),
        BackgroundColor3 = Colors.TextMain,
        BorderSizePixel = 0
    })
    Lib.Create("UICorner", { Parent = knob, CornerRadius = UDim.new(1, 0) })

    local dragging = false
    local function update(x, isValue)
        local p, val
        if isValue then
            val = math.clamp(x, min, max)
            p = (val - min) / (max - min)
        else
            p = math.clamp((x - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
            val = math.floor(min + (max - min) * p)
        end
        lbl.Text = name .. ": " .. val
        fill.Size = UDim2.new(p, 0, 1, 0)
        knob.Position = UDim2.new(p, -6, 0.5, -6)
        _G.ConfigState[name] = val
        if callback then callback(val) end
    end

    bg.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; update(i.Position.X)
        end
    end)
    Services.UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            update(i.Position.X)
        end
    end)
    Services.UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    _G.ConfigUpdaters[name] = function(val) update(val, true) end
    _G.ConfigState[name] = default
 _G.ConfigState[name] = default

    return card
end

function Lib.createMenuBtn(parent, text, posY, showArrow)
    local btn = Lib.Create("TextButton", {
        Parent = parent,
        Size = UDim2.new(1, -6, 0, 36),
        Position = UDim2.new(0, 3, 0, posY),
        BackgroundColor3 = Colors.Surface,
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0
    })
    Lib.Create("UICorner", { Parent = btn, CornerRadius = UDim.new(0, 6) })
    local stroke = Lib.Create("UIStroke", { Parent = btn, Color = Colors.Border, Thickness = 1 })

    local lbl = Lib.Create("TextLabel", {
        Parent = btn,
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local arrow = nil
    if showArrow then
        arrow = Lib.Create("TextLabel", {
            Parent = btn,
            Size = UDim2.new(0, 20, 1, 0),
            Position = UDim2.new(1, -30, 0, 0),
            BackgroundTransparency = 1,
            Text = "▼",
            TextColor3 = Colors.TextDim,
            Font = Enum.Font.GothamMedium,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Center
        })
    end

    btn.MouseEnter:Connect(function()
        Services.TS:Create(stroke, TWEEN_INFO_FAST, {Color = Colors.Active}):Play()
    end)
    btn.MouseLeave:Connect(function()
        Services.TS:Create(stroke, TWEEN_INFO_FAST, {Color = Colors.Border}):Play()
    end)

    return btn, arrow, lbl
end

function Lib.createFloatingMenu(titleText, sizeX, sizeY)
    sizeX = sizeX or 320
    sizeY = sizeY or 280
    
    local win = Lib.Create("Frame", {
        Parent = UI.Screen,
        Size = UDim2.new(0, sizeX, 0, sizeY),
        Position = UDim2.new(0.5, -sizeX/2, 0.5, -sizeY/2),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        Visible = false,
        ClipsDescendants = true
    })
    Lib.Create("UICorner", { Parent = win, CornerRadius = UDim.new(0, 8) })
    Lib.Create("UIStroke", { Parent = win, Color = Colors.Border, Thickness = 1 })

    local topBar = Lib.Create("Frame", {
        Parent = win,
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1
    })
    Lib.makeDraggable(win, topBar)

    local title = Lib.Create("TextLabel", {
        Parent = topBar,
        Size = UDim2.new(0.6, 0, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Text = titleText,
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local minBtn = Lib.Create("TextButton", {
        Parent = topBar,
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -55, 0.5, -12),
        BackgroundTransparency = 1,
        Text = "—",
        TextColor3 = Colors.TextDim,
        Font = Enum.Font.GothamMedium,
        TextSize = 14
    })

    local closeBtn = Lib.Create("TextButton", {
        Parent = topBar,
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -30, 0.5, -12),
        BackgroundTransparency = 1,
        Text = "×",
        TextColor3 = Colors.TextDim,
        Font = Enum.Font.GothamMedium,
        TextSize = 18
    })

    local scroll = Lib.Create("ScrollingFrame", {
        Parent = win,
        Size = UDim2.new(1, -20, 1, -85),
        Position = UDim2.new(0, 10, 0, 40),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Colors.Border,
        BorderSizePixel = 0
    })
    local layout = Lib.Create("UIListLayout", { Parent = scroll, Padding = UDim.new(0, 6) })
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)

    local actionBtn = Lib.Create("TextButton", {
        Parent = win,
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 1, -40),
        BackgroundColor3 = Colors.Surface,
        Text = "",
        BorderSizePixel = 0
    })
    Lib.Create("UICorner", { Parent = actionBtn, CornerRadius = UDim.new(0, 6) })
    local actStroke = Lib.Create("UIStroke", { Parent = actionBtn, Color = Colors.Border, Thickness = 1 })

    local actionLbl = Lib.Create("TextLabel", {
        Parent = actionBtn,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = titleText .. ": [None]",
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.GothamBold,
        TextSize = 12
    })

    actionBtn.MouseEnter:Connect(function() Services.TS:Create(actStroke, TWEEN_INFO_FAST, {Color = Colors.Active}):Play() end)
    actionBtn.MouseLeave:Connect(function() Services.TS:Create(actStroke, TWEEN_INFO_FAST, {Color = Colors.Border}):Play() end)

    local isMin = false
    minBtn.MouseButton1Click:Connect(function()
        isMin = not isMin
        Services.TS:Create(win, TWEEN_INFO_FAST, {Size = UDim2.new(0, sizeX, 0, isMin and 36 or sizeY)}):Play()
        scroll.Visible = not isMin
        actionBtn.Visible = not isMin
    end)

    return win, closeBtn, scroll, layout, actionBtn, actionLbl
end

function Lib.populatePlayers(scroll, layout, actionLbl, defaultText, targetCallback)
    for _, v in pairs(scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _, plr in ipairs(Services.Players:GetPlayers()) do
        if plr ~= LP then
            local btn = Lib.Create("TextButton", {
                Parent = scroll,
                Size = UDim2.new(1, -5, 0, 26),
                BackgroundColor3 = Colors.Surface,
                Text = plr.Name,
                TextColor3 = Colors.TextDim,
                Font = Enum.Font.Gotham,
                TextSize = 12,
                BorderSizePixel = 0
            })
            Lib.Create("UICorner", { Parent = btn, CornerRadius = UDim.new(0, 4) })
            local bStroke = Lib.Create("UIStroke", { Parent = btn, Color = Colors.Border, Thickness = 1 })

            btn.MouseEnter:Connect(function() Services.TS:Create(bStroke, TWEEN_INFO_FAST, {Color = Colors.Active}):Play() end)
            btn.MouseLeave:Connect(function() Services.TS:Create(bStroke, TWEEN_INFO_FAST, {Color = Colors.Border}):Play() end)

            btn.MouseButton1Click:Connect(function() 
                targetCallback(plr)
                actionLbl.Text = defaultText .. ": " .. plr.Name 
            end)
        end
    end
end

_G.changeTheme = function(c1, c2)
    _G.CurrentGradientColors = {c1, c2}
    Colors.Active = c2
    if not UI.Screen then return end
    for _, v in pairs(UI.Screen:GetDescendants()) do
        if v:IsA("UIGradient") then 
            v.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, c1), ColorSequenceKeypoint.new(1, c2)}) 
        elseif v:IsA("UIStroke") and v.Parent.Name ~= "MainFrame" then
            v.Color = c2
        elseif v.Name == "Indicator" and v.BackgroundTransparency == 0 then
            v.BackgroundColor3 = c2
        end
    end
end

local GuiParent = Services.Run:IsStudio() and LP.PlayerGui or Services.Core:FindFirstChild("RobloxGui") or LP:WaitForChild("PlayerGui")
UI.Screen = Lib.Create("ScreenGui", {
    Name = "SeptusHub_VactoryUI",
    Parent = GuiParent,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true
})

local WelcomeGui = Lib.Create("Frame", {
    Parent = UI.Screen,
    Size = UDim2.new(0, 400, 0, 180),
    Position = UDim2.new(0.5, -200, 0.5, -90),
    BackgroundColor3 = Colors.Background,
    BorderSizePixel = 0,
    ZIndex = 50000
})
Lib.Create("UICorner", { Parent = WelcomeGui, CornerRadius = UDim.new(0, 8) })
Lib.Create("UIStroke", { Parent = WelcomeGui, Color = Colors.Border, Thickness = 1 })

local welcomeSnow = Lib.Create("Frame", { Parent = WelcomeGui, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 0 })
local wRNG = Random.new()
task.spawn(function()
    while WelcomeGui and WelcomeGui.Parent do
        local size = wRNG:NextNumber(2, 4)
        local fl = Lib.Create("Frame", {
            Parent = welcomeSnow,
            Size = UDim2.new(0, size, 0, size),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = wRNG:NextNumber(0.4, 0.8),
            BorderSizePixel = 0,
            Position = UDim2.new(wRNG:NextNumber(0, 1), 0, -0.05, 0)
        })
        Lib.Create("UICorner", { Parent = fl, CornerRadius = UDim.new(1, 0) })
        Services.TS:Create(fl, TweenInfo.new(wRNG:NextNumber(3, 7), Enum.EasingStyle.Linear), {Position = UDim2.new(fl.Position.X.Scale + wRNG:NextNumber(-0.1, 0.1), 0, 1.05, 0)}):Play()
        task.wait(0.4)
    end
end)

local wTxt = Lib.Create("TextLabel", {
    Parent = WelcomeGui,
    Size = UDim2.new(1, -40, 0, 60),
    Position = UDim2.new(0, 20, 0, 25),
    BackgroundTransparency = 1,
    Text = "",
    FontFace = Font.fromId(12187375422),
    TextSize = 13,
    TextColor3 = Colors.TextMain,
    TextWrapped = true,
    ZIndex = 1
})

local message = "Скрипт находится на стадии бета-тестирования, возможны небольшие баги и недоработки."

task.spawn(function()
    Lib.typeWrite(wTxt, message, 0.04)
end)

local GithubBtn = Lib.Create("TextButton", {
    Parent = WelcomeGui,
    Size = UDim2.new(0, 170, 0, 36),
    Position = UDim2.new(0, 20, 0, 110),
    BackgroundColor3 = Colors.Surface,
    Text = "Наш GitHub",
    TextColor3 = Colors.TextMain,
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    ZIndex = 1
})
Lib.Create("UICorner", { Parent = GithubBtn, CornerRadius = UDim.new(0, 6) })
local ghStroke = Lib.Create("UIStroke", { Parent = GithubBtn, Color = Colors.Border, Thickness = 1 })
GithubBtn.MouseButton1Click:Connect(function() 
    pcall(function() setclipboard("https://github.com/CherryCalCor") end) 
    Lib.showNotification("Ссылка скопирована в буфер обмена!")
end)

local LaunchBtn = Lib.Create("TextButton", {
    Parent = WelcomeGui,
    Size = UDim2.new(0, 170, 0, 36),
    Position = UDim2.new(1, -190, 0, 110),
    BackgroundColor3 = Colors.Active,
    Text = "Запустить меню",
    TextColor3 = Colors.Background,
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    ZIndex = 1
})
Lib.Create("UICorner", { Parent = LaunchBtn, CornerRadius = UDim.new(0, 6) })

local welcomeDone = false
LaunchBtn.MouseButton1Click:Connect(function() 
    welcomeDone = true 
    WelcomeGui:Destroy() 
end)
Lib.makeDraggable(WelcomeGui)
repeat task.wait() until welcomeDone

local TweenService = Services.TS
local ScreenGui = UI.Screen
local Lighting = Services.Lighting
local wRNG = wRNG or Random.new() 

local Blur = Instance.new("BlurEffect")
Blur.Size = 0
Blur.Name = "SeptusLoadingBlur"
Blur.Parent = Lighting

local LoadingFrame = Instance.new("Frame")
LoadingFrame.Parent = ScreenGui
LoadingFrame.Size = UDim2.new(0, 460, 0, 260)
LoadingFrame.Position = UDim2.new(0.5, -230, 0.5, -130)
LoadingFrame.BackgroundColor3 = Colors.Background
LoadingFrame.BorderSizePixel = 0
LoadingFrame.ZIndex = 60000

local LoadingCorner = Instance.new("UICorner")
LoadingCorner.CornerRadius = UDim.new(0, 10)
LoadingCorner.Parent = LoadingFrame

local LoadingStroke = Instance.new("UIStroke")
LoadingStroke.Color = Colors.Border
LoadingStroke.Thickness = 1
LoadingStroke.Parent = LoadingFrame

local loadSnow = Instance.new("Frame")
loadSnow.Name = "LoadSnow"
loadSnow.Parent = LoadingFrame
loadSnow.Size = UDim2.new(1, 0, 1, 0)
loadSnow.BackgroundTransparency = 1
loadSnow.ZIndex = 0

task.spawn(function()
    while LoadingFrame and LoadingFrame.Parent do
        local size = wRNG:NextNumber(2, 4)
        local fl = Instance.new("Frame")
        fl.Parent = loadSnow
        fl.Size = UDim2.new(0, size, 0, size)
        fl.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        fl.BackgroundTransparency = wRNG:NextNumber(0.4, 0.8)
        fl.BorderSizePixel = 0
        fl.Position = UDim2.new(wRNG:NextNumber(0, 1), 0, -0.05, 0)
        fl.ZIndex = 0

        local flCorner = Instance.new("UICorner")
        flCorner.CornerRadius = UDim.new(1, 0)
        flCorner.Parent = fl

        TweenService:Create(fl, TweenInfo.new(wRNG:NextNumber(3, 7), Enum.EasingStyle.Linear), {
            Position = UDim2.new(fl.Position.X.Scale + wRNG:NextNumber(-0.1, 0.1), 0, 1.05, 0)
        }):Play()

        task.delay(7, function()
            if fl and fl.Parent then fl:Destroy() end
        end)

        task.wait(0.3)
    end
end)

local LoadingText = Instance.new("TextLabel")
LoadingText.Parent = LoadingFrame
LoadingText.AnchorPoint = Vector2.new(0.5, 0.5)
LoadingText.Position = UDim2.new(0.5, 0, 0.45, 0)
LoadingText.Size = UDim2.new(0, 320, 0, 60)
LoadingText.BackgroundTransparency = 1
LoadingText.Text = "SEPTUS HUB"
LoadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadingText.Font = Enum.Font.GothamBlack
LoadingText.TextSize = 36
LoadingText.TextTransparency = 1
LoadingText.ZIndex = 2

local LoadingSub = Instance.new("TextLabel")
LoadingSub.Parent = LoadingFrame
LoadingSub.AnchorPoint = Vector2.new(0.5, 0.5)
LoadingSub.Position = UDim2.new(0.5, 0, 0.56, 0)
LoadingSub.Size = UDim2.new(0, 300, 0, 40)
LoadingSub.BackgroundTransparency = 1
LoadingSub.Text = "Loading interface..."
LoadingSub.TextColor3 = Color3.fromRGB(180, 180, 180)
LoadingSub.Font = Enum.Font.Gotham
LoadingSub.TextSize = 16
LoadingSub.TextTransparency = 1
LoadingSub.ZIndex = 2

local Glow = Instance.new("ImageLabel")
Glow.Parent = LoadingFrame
Glow.AnchorPoint = Vector2.new(0.5, 0.5)
Glow.Position = UDim2.new(0.5, 0, 0.5, 0)
Glow.Size = UDim2.new(0, 210, 0, 210)
Glow.BackgroundTransparency = 1
Glow.Image = "rbxassetid://5028857084"
Glow.ImageColor3 = Color3.fromRGB(255, 255, 255)
Glow.ImageTransparency = 1
Glow.ZIndex = 1

local BarBack = Instance.new("Frame")
BarBack.Parent = LoadingFrame
BarBack.AnchorPoint = Vector2.new(0.5, 0.5)
BarBack.Position = UDim2.new(0.5, 0, 0.65, 0)
BarBack.Size = UDim2.new(0, 180, 0, 6)
BarBack.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
BarBack.BorderSizePixel = 0
BarBack.ZIndex = 2

local BarBackCorner = Instance.new("UICorner")
BarBackCorner.CornerRadius = UDim.new(1, 0)
BarBackCorner.Parent = BarBack

local Bar = Instance.new("Frame")
Bar.Parent = BarBack
Bar.Size = UDim2.new(0, 0, 1, 0)
Bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Bar.BorderSizePixel = 0
Bar.ZIndex = 3

local BarCorner = Instance.new("UICorner")
BarCorner.CornerRadius = UDim.new(1, 0)
BarCorner.Parent = Bar

TweenService:Create(Blur, TweenInfo.new(0.8), { Size = 24 }):Play()
TweenService:Create(LoadingText, TweenInfo.new(1), { TextTransparency = 0 }):Play()
TweenService:Create(LoadingSub, TweenInfo.new(1), { TextTransparency = 0 }):Play()
TweenService:Create(Glow, TweenInfo.new(1), { ImageTransparency = 0.35 }):Play()

local barTween = TweenService:Create(Bar, TweenInfo.new(3.5, Enum.EasingStyle.Linear), { Size = UDim2.new(1, 0, 1, 0) })
barTween:Play()

task.spawn(function()
    while LoadingFrame and LoadingFrame.Parent do  
        TweenService:Create(  
            Glow,  
            TweenInfo.new(1.5),  
            {  
                Rotation = Glow.Rotation + 25,  
                ImageTransparency = 0.55  
            }  
        ):Play()  

        task.wait(1.5)  

        TweenService:Create(  
            Glow,  
            TweenInfo.new(1.5),  
            {  
                ImageTransparency = 0.3  
            }  
        ):Play()  

        task.wait(1.5)  
    end
end)

barTween.Completed:Wait()

local fadeTween = TweenService:Create(LoadingFrame, TweenInfo.new(1), { BackgroundTransparency = 1 })
TweenService:Create(LoadingText, TweenInfo.new(1), { TextTransparency = 1 }):Play()
TweenService:Create(LoadingSub, TweenInfo.new(1), { TextTransparency = 1 }):Play()
TweenService:Create(Glow, TweenInfo.new(1), { ImageTransparency = 1 }):Play()
TweenService:Create(Blur, TweenInfo.new(1), { Size = 0 }):Play()
TweenService:Create(LoadingStroke, TweenInfo.new(1), { Transparency = 1 }):Play()

for _, flake in ipairs(loadSnow:GetChildren()) do
    if flake:IsA("Frame") then
        TweenService:Create(flake, TweenInfo.new(1), { BackgroundTransparency = 1 }):Play()
    end
end

fadeTween:Play()
fadeTween.Completed:Wait()

LoadingFrame:Destroy()
Blur:Destroy()

_G.MainMenuLoaded = true

UI.Frame = Lib.Create("Frame", {
    Parent = UI.Screen,
    Size = UDim2.new(0, 0, 0, 0),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    BackgroundColor3 = Colors.Background,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Visible = false
})
Lib.Create("UICorner", { Parent = UI.Frame, CornerRadius = UDim.new(0, 8) })
local mainStroke = Lib.Create("UIStroke", { Parent = UI.Frame, Color = Colors.Border, Thickness = 1 })

local SnowContainer = Lib.Create("Frame", { Parent = UI.Frame, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 0 })
local function SpawnSnowflake()
    local size = wRNG:NextNumber(2, 4)
    local flake = Lib.Create("Frame", {
        Parent = SnowContainer,
        Size = UDim2.new(0, size, 0, size),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = wRNG:NextNumber(0.4, 0.8),
        BorderSizePixel = 0,
        ZIndex = 0
    })
    Lib.Create("UICorner", { Parent = flake, CornerRadius = UDim.new(1, 0) })

    local function AnimateFlake()
        flake.Position = UDim2.new(wRNG:NextNumber(0, 1), 0, -0.05, 0)
        local dur = wRNG:NextNumber(5, 12)
        local tx = flake.Position.X.Scale + wRNG:NextNumber(-0.1, 0.1)
        local tw = Services.TS:Create(flake, TweenInfo.new(dur, Enum.EasingStyle.Linear), {Position = UDim2.new(tx, 0, 1.05, 0)})
        tw.Completed:Connect(AnimateFlake)
        tw:Play()
    end

    flake.Position = UDim2.new(wRNG:NextNumber(0, 1), 0, wRNG:NextNumber(-0.05, 1), 0)
    local initDur = wRNG:NextNumber(2, 8)
    local initTx = flake.Position.X.Scale + wRNG:NextNumber(-0.08, 0.08)
    local initTw = Services.TS:Create(flake, TweenInfo.new(initDur, Enum.EasingStyle.Linear), {Position = UDim2.new(initTx, 0, 1.05, 0)})
    initTw.Completed:Connect(AnimateFlake)
    initTw:Play()
end
for _ = 1, 20 do SpawnSnowflake() end

local Shadow = Lib.Create("ImageLabel", {
    Parent = UI.Frame,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(1, 30, 1, 30),
    BackgroundTransparency = 1,
    Image = "rbxassetid://6015897843",
    ImageColor3 = Color3.fromRGB(0, 0, 0),
    ImageTransparency = 0.55,
    SliceCenter = Rect.new(49, 49, 450, 450),
    ScaleType = Enum.ScaleType.Slice,
    ZIndex = -1
})

local Watermark = Lib.Create("ImageLabel", {
    Parent = UI.Frame,
    Size = UDim2.new(0, 130, 0, 130),
    Position = UDim2.new(1, -120, 1, -120),
    BackgroundTransparency = 1,
    ImageTransparency = 0.94,
    Image = _G.NotificationAssetID,
    ZIndex = 0
})

local TopBar = Lib.Create("Frame", { Parent = UI.Frame, Size = UDim2.new(1, 0, 0, 38), BackgroundTransparency = 1 })
local TitleContainer = Lib.Create("Frame", { Parent = TopBar, Position = UDim2.new(0, 15, 0, 0), Size = UDim2.new(0.5, 0, 1, 0), BackgroundTransparency = 1 })
Lib.Create("UIListLayout", { Parent = TitleContainer, FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 8) })

local TitleText = Lib.Create("TextLabel", {
    Parent = TitleContainer,
    Size = UDim2.new(0, 0, 1, 0),
    AutomaticSize = Enum.AutomaticSize.X,
    BackgroundTransparency = 1,
    Text = "SEPTUS HUB",
    TextColor3 = Color3.new(1, 1, 1), 
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    LayoutOrder = 1
})

local TextGradient = Instance.new("UIGradient")
TextGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.0, Color3.new(0, 0, 0)),   
    ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 1)),   
    ColorSequenceKeypoint.new(1.0, Color3.new(0, 0, 0))    
})
TextGradient.Rotation = 0 
TextGradient.Parent = TitleText

local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(
    2,
    Enum.EasingStyle.Linear, 
    Enum.EasingDirection.InOut, 
    -1, 
    false 
)

local tween = TweenService:Create(TextGradient, tweenInfo, {Offset = Vector2.new(1, 0)})
TextGradient.Offset = Vector2.new(-1, 0) 
tween:Play()

local VersionBadge = Lib.Create("Frame", { Parent = TitleContainer, Size = UDim2.new(0, 48, 0, 18), BackgroundColor3 = Colors.Surface, LayoutOrder = 2 })
Lib.Create("UICorner", { Parent = VersionBadge, CornerRadius = UDim.new(0, 4) })
Lib.Create("UIStroke", { Parent = VersionBadge, Color = Colors.Border, Thickness = 1 })
local VersionTag = Lib.Create("TextLabel", { Parent = VersionBadge, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "V2.4", TextColor3 = Colors.Active, Font = Enum.Font.GothamSemibold, TextSize = 10 })

local Controls = Lib.Create("Frame", { Parent = TopBar, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -15, 0.5, 0), Size = UDim2.new(0, 70, 1, 0), BackgroundTransparency = 1 })
Lib.Create("UIListLayout", { Parent = Controls, FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10) })

local function CreateCtrlBtn(text, order)
    local b = Lib.Create("TextButton", { Parent = Controls, Size = UDim2.new(0, 20, 0, 20), BackgroundTransparency = 1, Text = text, TextColor3 = Colors.TextDim, Font = Enum.Font.GothamMedium, TextSize = 15, LayoutOrder = order, AutoButtonColor = false })
    b.MouseEnter:Connect(function() Services.TS:Create(b, TWEEN_INFO_FAST, {TextColor3 = Colors.TextMain}):Play() end)
    b.MouseLeave:Connect(function() Services.TS:Create(b, TWEEN_INFO_FAST, {TextColor3 = Colors.TextDim}):Play() end)
    return b
end

local MinBtn = CreateCtrlBtn("—", 1)
local CloseBtn = CreateCtrlBtn("×", 2)

local ContentFrame = Lib.Create("Frame", { Parent = UI.Frame, Position = UDim2.new(0, 0, 0, 38), Size = UDim2.new(1, 0, 1, -38), BackgroundTransparency = 1 })

local Sidebar = Lib.Create("ScrollingFrame", {
    Parent = ContentFrame,
    Size = UDim2.new(0, 130, 1, 0),
    BackgroundTransparency = 1,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = Colors.Border,
    BorderSizePixel = 0,
    CanvasSize = UDim2.new(0, 0, 0, 0)
})
Lib.Create("UIPadding", { Parent = Sidebar, PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 4) })
local SidebarLayout = Lib.Create("UIListLayout", { Parent = Sidebar, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) })
SidebarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Sidebar.CanvasSize = UDim2.new(0, 0, 0, SidebarLayout.AbsoluteContentSize.Y + 15)
end)

local TabContainer = Lib.Create("Frame", { Parent = ContentFrame, Position = UDim2.new(0, 130, 0, 0), Size = UDim2.new(1, -130, 1, 0), BackgroundTransparency = 1 })
Lib.Create("UIPadding", { Parent = TabContainer, PaddingTop = UDim.new(0, 8), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10) })

local function CreatePage(name)
    local scroll = Lib.Create("ScrollingFrame", {
        Name = name .. "Tab",
        Parent = TabContainer,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Colors.Border,
        Visible = false,
        BorderSizePixel = 0
    })
    local layout = Lib.Create("UIListLayout", { Parent = scroll, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8) })
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 15)
    end)
    UI.Pages[name] = scroll
    return scroll
end

local ActiveTab = nil
local function CreateTabButton(tabName, order)
    local b = Lib.Create("TextButton", {
        Name = tabName.."Btn",
        Parent = Sidebar,
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
        Text = tabName,
        TextColor3 = Colors.TextDim,
        Font = Enum.Font.GothamSemibold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = order,
        AutoButtonColor = false
    })
    local ind = Lib.Create("Frame", {
        Name = "Indicator",
        Parent = b,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, -12, 0.5, 0),
        Size = UDim2.new(0, 2, 0, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    })
    Lib.Create("UICorner", { Parent = ind })
    
    local grad = Lib.Create("UIGradient", {
        Parent = ind,
        Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
        }),
        Offset = Vector2.new(0, -1)
    })
    task.spawn(function()
        Services.TS:Create(grad, TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {Offset = Vector2.new(0, 1)}):Play()
    end)

    local glow = Lib.Create("ImageLabel", {
        Name = "Glow",
        Parent = b,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, -25, 0.5, 0),
        Size = UDim2.new(0, 30, 0, 30),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5028857084",
        ImageColor3 = Colors.Active,
        ImageTransparency = 1,
        ZIndex = 0
    })

    b.MouseEnter:Connect(function() if ActiveTab ~= tabName then Services.TS:Create(b, TWEEN_INFO_FAST, {TextColor3 = Color3.fromRGB(220, 220, 220)}):Play() end end)
    b.MouseLeave:Connect(function() if ActiveTab ~= tabName then Services.TS:Create(b, TWEEN_INFO_FAST, {TextColor3 = Colors.TextDim}):Play() end end)

    b.MouseButton1Click:Connect(function()
        if ActiveTab == tabName then return end

        for _, child in pairs(Sidebar:GetChildren()) do
            if child:IsA("TextButton") and child.Name ~= tabName.."Btn" then
                Services.TS:Create(child, TWEEN_INFO_SMOOTH, {TextColor3 = Colors.TextDim}):Play()
                Services.TS:Create(child.Indicator, TWEEN_INFO_SMOOTH, {Size = UDim2.new(0, 2, 0, 0), BackgroundTransparency = 1}):Play()
                if child:FindFirstChild("Glow") then
                    Services.TS:Create(child.Glow, TWEEN_INFO_SMOOTH, {ImageTransparency = 1}):Play()
                end
            end
        end
        if ActiveTab and UI.Pages[ActiveTab] then
            local prev = UI.Pages[ActiveTab]
            local tw = Services.TS:Create(prev, TWEEN_INFO_FAST, {Position = UDim2.new(0, 0, 0, 8)})
            tw:Play(); tw.Completed:Wait()
            prev.Visible = false
        end
        
        ActiveTab = tabName
        Services.TS:Create(b, TWEEN_INFO_SMOOTH, {TextColor3 = Colors.TextMain}):Play()
        Services.TS:Create(ind, TWEEN_INFO_SMOOTH, {Size = UDim2.new(0, 3, 0, 16), BackgroundTransparency = 0}):Play()
        Services.TS:Create(glow, TWEEN_INFO_SMOOTH, {ImageTransparency = 0.65}):Play()

        local curr = UI.Pages[tabName]
        if curr then
            curr.Position = UDim2.new(0, 0, 0, 8)
            curr.Visible = true
            Services.TS:Create(curr, TWEEN_INFO_SMOOTH, {Position = UDim2.new(0, 0, 0, 0)}):Play()
        end
    end)
end

CreatePage("Home")
CreatePage("Server")
CreatePage("Teleport")
CreatePage("Movement")
CreatePage("Visuals")
CreatePage("Shaders")
CreatePage("Protect")
CreatePage("Funny")
CreatePage("Config")
CreatePage("QoL")
CreatePage("Misc") 
CreatePage("Help")
CreatePage("Settings")

CreateTabButton("Home", 1)
CreateTabButton("Server", 2)
CreateTabButton("Visuals", 3)
CreateTabButton("Teleport", 4)
CreateTabButton("Movement", 5)
CreateTabButton("Shaders", 6)
CreateTabButton("Protect", 7)
CreateTabButton("Funny", 8)
CreateTabButton("Config", 9)
CreateTabButton("QoL", 10)
CreateTabButton("Misc", 11) 
CreateTabButton("Help", 12)
CreateTabButton("Settings", 13)

do
    local pCard = Lib.CreateStyledCard(UI.Pages.Home, 65)
    local avatar = Lib.Create("ImageLabel", {
        Parent = pCard,
        Position = UDim2.new(0, 12, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(0, 42, 0, 42),
        BackgroundTransparency = 1,
        Image = Services.Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    })
    Lib.Create("UICorner", { Parent = avatar, CornerRadius = UDim.new(1, 0) })
    Lib.Create("UIStroke", { Parent = avatar, Color = Colors.Border, Thickness = 1 })

    local welcome = Lib.Create("TextLabel", {
        Parent = pCard,
        Position = UDim2.new(0, 64, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(1, -75, 1, 0),
        BackgroundTransparency = 1,
        Text = "Welcome, " .. LP.Name,
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local sCard = Lib.CreateStyledCard(UI.Pages.Home, 105)
    Lib.Create("UIPadding", { Parent = sCard, PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 12) })
    Lib.Create("UIListLayout", { Parent = sCard, Padding = UDim.new(0, 6) })

    local function createStatusLine(key, val)
        local l = Lib.Create("TextLabel", {
            Parent = sCard,
            Size = UDim2.new(1, 0, 0, 14),
            BackgroundTransparency = 1,
            Text = key .. ": <font color='#ffffff'>" .. val .. "</font>",
            TextColor3 = Colors.TextDim,
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            RichText = true
        })
        return l
    end

    local gName = "Unknown"
    pcall(function() gName = Services.Market:GetProductInfo(game.PlaceId).Name end)
    createStatusLine("Game", gName)
    local fpsLbl = createStatusLine("FPS", "0")
    local pingLbl = createStatusLine("Ping", "0 ms")
    local playersLbl = createStatusLine("Players", "0")

    task.spawn(function()
        while task.wait(1) do
            pcall(function()
                fpsLbl.Text = "FPS: <font color='#ffffff'>" .. math.floor(workspace:GetRealPhysicsFPS()) .. "</font>"
                pingLbl.Text = "Ping: <font color='#ffffff'>" .. math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) .. " ms</font>"
                playersLbl.Text = "Players: <font color='#ffffff'>" .. #Services.Players:GetPlayers() .. "</font>"
            end)
        end
    end)

    local NotepadWin = Lib.Create("Frame", {
        Parent = UI.Screen,
        Size = UDim2.new(0, 320, 0, 240),
        Position = UDim2.new(0.5, 80, 0.5, -120),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        Visible = false,
        ClipsDescendants = true
    })
    Lib.Create("UICorner", { Parent = NotepadWin, CornerRadius = UDim.new(0, 8) })
    Lib.Create("UIStroke", { Parent = NotepadWin, Color = Colors.Border, Thickness = 1 })

    local noteTopBar = Lib.Create("Frame", { Parent = NotepadWin, Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1 })
    Lib.makeDraggable(NotepadWin, noteTopBar)
    Lib.Create("TextLabel", { Parent = noteTopBar, Size = UDim2.new(0.6, 0, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, Text = "Notepad", TextColor3 = Colors.TextMain, Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left })
    local noteMinBtn = Lib.Create("TextButton", { Parent = noteTopBar, Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, -55, 0.5, -12), BackgroundTransparency = 1, Text = "—", TextColor3 = Colors.TextDim, Font = Enum.Font.GothamMedium, TextSize = 14 })
    local noteCloseBtn = Lib.Create("TextButton", { Parent = noteTopBar, Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, -30, 0.5, -12), BackgroundTransparency = 1, Text = "×", TextColor3 = Colors.TextDim, Font = Enum.Font.GothamMedium, TextSize = 18 })

    local noteBox = Lib.Create("TextBox", {
        Parent = NotepadWin,
        Size = UDim2.new(1, -20, 1, -48),
        Position = UDim2.new(0, 10, 0, 38),
        BackgroundColor3 = Colors.Surface,
        BorderSizePixel = 0,
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        ClearTextOnFocus = false,
        MultiLine = true,
        TextWrapped = true,
        Text = "Write your notes here..."
    })
    Lib.Create("UICorner", { Parent = noteBox, CornerRadius = UDim.new(0, 6) })
    Lib.Create("UIStroke", { Parent = noteBox, Color = Colors.Border, Thickness = 1 })

    local noteMin = false
    noteMinBtn.MouseButton1Click:Connect(function()
        noteMin = not noteMin
        Services.TS:Create(NotepadWin, TWEEN_INFO_FAST, {Size = UDim2.new(0, 320, 0, noteMin and 34 or 240)}):Play()
        noteBox.Visible = not noteMin
    end)

    local noteTogCard, _, setNotepad = Lib.createToggle(UI.Pages.Home, "Notepad", 175, false, function(st) NotepadWin.Visible = st end)
    noteCloseBtn.MouseButton1Click:Connect(function() setNotepad(false, true); NotepadWin.Visible = false end)

    local ManualOpPanel = Lib.Create("Frame", {
        Parent = UI.Screen,
        Size = UDim2.new(0, 320, 0, 42),
        Position = UDim2.new(0.5, -160, 0, 15),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        Visible = false
    })
    Lib.Create("UICorner", { Parent = ManualOpPanel, CornerRadius = UDim.new(0, 6) })
    Lib.Create("UIStroke", { Parent = ManualOpPanel, Color = Colors.Border, Thickness = 1 })

    local manInput = Lib.Create("TextBox", {
        Parent = ManualOpPanel,
        Size = UDim2.new(1, -85, 1, -12),
        Position = UDim2.new(0, 10, 0, 6),
        BackgroundColor3 = Colors.Surface,
        BorderSizePixel = 0,
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        PlaceholderText = "Enter function name...",
        Text = "",
        ClearTextOnFocus = false
    })
    Lib.Create("UICorner", { Parent = manInput, CornerRadius = UDim.new(0, 4) })
    Lib.Create("UIStroke", { Parent = manInput, Color = Colors.Border, Thickness = 1 })

    local manEnter = Lib.Create("TextButton", {
        Parent = ManualOpPanel,
        Size = UDim2.new(0, 65, 1, -12),
        Position = UDim2.new(1, -75, 0, 6),
        BackgroundColor3 = Colors.Active,
        Text = "Enter",
        Font = Enum.Font.GothamBold,
        TextColor3 = Colors.Background,
        TextSize = 12,
        BorderSizePixel = 0
    })
    Lib.Create("UICorner", { Parent = manEnter, CornerRadius = UDim.new(0, 4) })

    local function execCommand()
        local cmd = manInput.Text:lower()
        local found = false
        for name, updater in pairs(_G.ConfigUpdaters) do
            if name:lower() == cmd then
                updater(not _G.ConfigState[name])
                Lib.showNotification(name .. " toggled manually!")
                found = true; break
            end
        end
        if not found then Lib.showNotification("Function not found: " .. manInput.Text) end
        manInput.Text = ""
    end
    manEnter.MouseButton1Click:Connect(execCommand)
    manInput.FocusLost:Connect(function(enter) if enter then execCommand() end end)

    local manTogCard, _, setManual = Lib.createToggle(UI.Pages.Home, "Manual operation", 220, false, function(st) ManualOpPanel.Visible = st end)

    local InstrWin = Lib.Create("Frame", {
        Parent = UI.Screen,
        Size = UDim2.new(0, 340, 0, 280),
        Position = UDim2.new(0.5, -170, 0.5, -140),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        Visible = false,
        ClipsDescendants = true
    })
    Lib.Create("UICorner", { Parent = InstrWin, CornerRadius = UDim.new(0, 8) })
    Lib.Create("UIStroke", { Parent = InstrWin, Color = Colors.Border, Thickness = 1 })

    local insTopBar = Lib.Create("Frame", { Parent = InstrWin, Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1 })
    Lib.makeDraggable(InstrWin, insTopBar)
    Lib.Create("TextLabel", { Parent = insTopBar, Size = UDim2.new(0.6, 0, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, Text = "Instruction Manual", TextColor3 = Colors.TextMain, Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left })
    local insCloseBtn = Lib.Create("TextButton", { Parent = insTopBar, Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, -30, 0.5, -12), BackgroundTransparency = 1, Text = "×", TextColor3 = Colors.TextDim, Font = Enum.Font.GothamMedium, TextSize = 18 })

    local insText = Lib.Create("TextLabel", {
        Parent = InstrWin,
        Size = UDim2.new(1, -24, 0, 48),
        Position = UDim2.new(0, 12, 0, 38),
        BackgroundTransparency = 1,
        Text = "В поле текстового ввода введите имя любой функции, например Noclip, затем нажмите enter, и функция включится автоматически.",
        TextColor3 = Colors.TextDim,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top
    })

    local funcScroll = Lib.Create("ScrollingFrame", {
        Parent = InstrWin,
        Size = UDim2.new(1, -24, 1, -100),
        Position = UDim2.new(0, 12, 0, 88),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Colors.Border,
        BorderSizePixel = 0
    })
    local funcLayout = Lib.Create("UIListLayout", { Parent = funcScroll, Padding = UDim.new(0, 4) })
    funcLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        funcScroll.CanvasSize = UDim2.new(0, 0, 0, funcLayout.AbsoluteContentSize.Y + 5)
    end)

    local function refreshFunctions()
        for _, v in pairs(funcScroll:GetChildren()) do if v:IsA("TextLabel") then v:Destroy() end end
        for name, _ in pairs(_G.ConfigUpdaters) do
            local lbl = Lib.Create("TextLabel", {
                Parent = funcScroll,
                Size = UDim2.new(1, -4, 0, 22),
                BackgroundColor3 = Colors.Surface,
                Text = "  " .. name,
                TextColor3 = Colors.Active,
                Font = Enum.Font.GothamBold,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            Lib.Create("UICorner", { Parent = lbl, CornerRadius = UDim.new(0, 4) })
            Lib.Create("UIStroke", { Parent = lbl, Color = Colors.Border, Thickness = 1 })
        end
    end

    local insTogCard, _, setInstr = Lib.createToggle(UI.Pages.Home, "Instruction manual", 265, false, function(st)
        InstrWin.Visible = st
        if st then refreshFunctions() end
    end)
    insCloseBtn.MouseButton1Click:Connect(function() setInstr(false, true); InstrWin.Visible = false end)

    local TopStatusPanel = Lib.Create("Frame", {
        Parent = UI.Screen,
        Size = UDim2.new(0.3, 0, 0, 32),
        Position = UDim2.new(0.5, 0, 0, 6),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = Colors.Background,
        Visible = false,
        BorderSizePixel = 0
    })
    Lib.Create("UICorner", { Parent = TopStatusPanel, CornerRadius = UDim.new(0, 6) })
    Lib.Create("UIStroke", { Parent = TopStatusPanel, Color = Colors.Border, Thickness = 1 })

    local topStatusLayout = Lib.Create("UIListLayout", { Parent = TopStatusPanel, FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 12) })

    local function createTopLabel(text)
        local lbl = Lib.Create("TextLabel", {
            Parent = TopStatusPanel,
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Colors.TextMain,
            Font = Enum.Font.GothamBold,
            TextSize = 11
        })
        return lbl
    end

    local topFPS = createTopLabel("FPS: 0")
    local topPing = createTopLabel("Ping: 0 ms")
    local topTime = createTopLabel("Time: 00:00")

    task.spawn(function()
        while task.wait(1) do
            if TopStatusPanel.Visible then
                local fps = math.floor(workspace:GetRealPhysicsFPS())
                local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
                local totalSeconds = math.floor(workspace.DistributedGameTime)
                local hours = math.floor(totalSeconds / 3600)
                local mins = math.floor((totalSeconds % 3600) / 60)
                local secs = totalSeconds % 60
                local timeStr = hours > 0 and string.format("%02d:%02d:%02d", hours, mins, secs) or string.format("%02d:%02d", mins, secs)
                topFPS.Text = "FPS: " .. fps
                topPing.Text = "Ping: " .. ping .. " ms"
                topTime.Text = "Time: " .. timeStr
            end
        end
    end)

    local statusTogCard, _, setStatus = Lib.createToggle(UI.Pages.Home, "Status display", 310, false, function(st) TopStatusPanel.Visible = st end)
end

do 

    local serverCard = Lib.CreateStyledCard(UI.Pages.Server, 90)
    Lib.Create("UIPadding", { Parent = serverCard, PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) })
    Lib.Create("UIListLayout", { Parent = serverCard, Padding = UDim.new(0, 8) })

    local function createActBtn(text, parent, callback)
        local btn = Lib.Create("TextButton", {
            Parent = parent,
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = Colors.Surface,
            Text = text,
            TextColor3 = Colors.TextMain,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            BorderSizePixel = 0
        })
        Lib.Create("UICorner", { Parent = btn, CornerRadius = UDim.new(0, 6) })
        local bStroke = Lib.Create("UIStroke", { Parent = btn, Color = Colors.Border, Thickness = 1 })
        btn.MouseEnter:Connect(function() Services.TS:Create(bStroke, TWEEN_INFO_FAST, {Color = Colors.Active}):Play() end)
        btn.MouseLeave:Connect(function() Services.TS:Create(bStroke, TWEEN_INFO_FAST, {Color = Colors.Border}):Play() end)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    createActBtn("Rejoin", serverCard, function()
        Lib.showNotification("Перезаход на сервер...")
        Services.TP:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
    end)

    createActBtn("Server Hop", serverCard, function()
        Lib.showNotification("Ищем другой сервер...")
        task.spawn(function()
            local s, r = pcall(function()
                return Services.Http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Asc&limit=100"))
            end)
            if s and r and r.data then
                for _, srv in ipairs(r.data) do
                    if srv.playing and srv.maxPlayers and srv.playing < srv.maxPlayers and srv.id ~= game.JobId then
                        Services.TP:TeleportToPlaceInstance(game.PlaceId, srv.id, LP)
                        return
                    end
                end
            end
            Lib.showNotification("Не удалось найти подходящий сервер")
        end)
    end)

    local ServerWidget = Lib.Create("Frame", {
        Parent = UI.Screen,
        Size = UDim2.new(0, 120, 0, 36),
        Position = UDim2.new(0.5, -60, 0, 20),
        BackgroundColor3 = Colors.Background,
        Visible = false,
        BorderSizePixel = 0
    })

    Lib.Create("UICorner", { Parent = ServerWidget, CornerRadius = UDim.new(1, 0) })
    local sWidgetStroke = Lib.Create("UIStroke", { Parent = ServerWidget, Color = Colors.Border, Thickness = 1 })

    local widgetDot = Lib.Create("Frame", {
        Parent = ServerWidget,
        Size = UDim2.new(0, 8, 0, 8),
        Position = UDim2.new(0, 12, 0.5, -4),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0
    })
    Lib.Create("UICorner", { Parent = widgetDot, CornerRadius = UDim.new(1, 0) })
    local dotGrad = Lib.Create("UIGradient", {
        Parent = widgetDot,
        Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
        }),
        Offset = Vector2.new(0, -1)
    })
    task.spawn(function()
        Services.TS:Create(dotGrad, TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {Offset = Vector2.new(0, 1)}):Play()
    end)

    local widgetBtn = Lib.Create("TextButton", {
        Parent = ServerWidget,
        Size = UDim2.new(1, -28, 1, 0),
        Position = UDim2.new(0, 24, 0, 0),
        BackgroundTransparency = 1,
        Text = "Servers",
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    Lib.makeDraggable(ServerWidget, widgetBtn)

local ServerMenu = Lib.Create("Frame", {
        Parent = UI.Screen,
        Size = UDim2.new(0, 360, 0, 280),
        Position = UDim2.new(0.5, -180, 0.5, -140),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        Visible = false,
        ClipsDescendants = true
    })
    Lib.Create("UICorner", { Parent = ServerMenu, CornerRadius = UDim.new(0, 8) })
    Lib.Create("UIStroke", { Parent = ServerMenu, Color = Colors.Border, Thickness = 1 })

    local srvTopBar = Lib.Create("Frame", { Parent = ServerMenu, Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1 })
    Lib.makeDraggable(ServerMenu, srvTopBar)
    Lib.Create("TextLabel", { Parent = srvTopBar, Size = UDim2.new(0, 100, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, Text = "Server List", TextColor3 = Colors.TextMain, Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left })
    
    local srvSortBtn = Lib.Create("TextButton", {
        Parent = srvTopBar,
        Size = UDim2.new(0, 120, 0, 22),
        Position = UDim2.new(1, -195, 0.5, -11),
        BackgroundColor3 = Colors.Surface,
        Text = "Sort: Ascending",
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        BorderSizePixel = 0
    })
    Lib.Create("UICorner", { Parent = srvSortBtn, CornerRadius = UDim.new(0, 4) })
    local sortStroke = Lib.Create("UIStroke", { Parent = srvSortBtn, Color = Colors.Border, Thickness = 1 })

    local srvMinBtn = Lib.Create("TextButton", { Parent = srvTopBar, Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, -60, 0.5, -12), BackgroundTransparency = 1, Text = "—", TextColor3 = Colors.TextDim, Font = Enum.Font.GothamMedium, TextSize = 14 })
    local srvCloseBtn = Lib.Create("TextButton", { Parent = srvTopBar, Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, -30, 0.5, -12), BackgroundTransparency = 1, Text = "×", TextColor3 = Colors.TextDim, Font = Enum.Font.GothamMedium, TextSize = 18 })

    local srvScroll = Lib.Create("ScrollingFrame", {
        Parent = ServerMenu,
        Size = UDim2.new(1, -24, 1, -48),
        Position = UDim2.new(0, 12, 0, 38),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Colors.Border,
        BorderSizePixel = 0
    })
    local srvLayout = Lib.Create("UIListLayout", { Parent = srvScroll, Padding = UDim.new(0, 4) })
    srvLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        srvScroll.CanvasSize = UDim2.new(0, 0, 0, srvLayout.AbsoluteContentSize.Y + 10)
    end)

    local srvSortAsc = true
    local srvMinimized = false
    local srvSearchMode = "filled" 

    local srvModeBtn = Lib.Create("TextButton", {
        Parent = srvTopBar,
        Size = UDim2.new(0, 90, 0, 22),
        Position = UDim2.new(1, -290, 0.5, -11),
        BackgroundColor3 = Colors.Surface,
        Text = "Mode: 60-80%",
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        BorderSizePixel = 0
    })
    Lib.Create("UICorner", { Parent = srvModeBtn, CornerRadius = UDim.new(0, 4) })
    local modeStroke = Lib.Create("UIStroke", { Parent = srvModeBtn, Color = Colors.Border, Thickness = 1 })

    srvModeBtn.MouseButton1Click:Connect(function()
        if srvSearchMode == "filled" then
            srvSearchMode = "empty"
            srvModeBtn.Text = "Mode: Empty"
        else
            srvSearchMode = "filled"
            srvModeBtn.Text = "Mode: 60-80%"
        end
        task.spawn(populateServers)
    end)

    function populateServers()

        for _, v in pairs(srvScroll:GetChildren()) do 
            if v:IsA("Frame") then v:Destroy() end 
        end
        
        local order = srvSearchMode == "filled" and "Desc" or "Asc"
        
        local s, r = pcall(function()

            local url = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=" .. order .. "&limit=100"
            if srvSearchMode == "filled" then
                url = url .. "&excludeFullGames=true"
            end
            return Services.Http:JSONDecode(game:HttpGet(url))
        end)
        
        if s and r and r.data then
            local servers = {}
            for _, srv in pairs(r.data) do
                if srv.playing and srv.maxPlayers and srv.playing < srv.maxPlayers then
                    local fillPercent = (srv.playing / srv.maxPlayers) * 100
                    if srvSearchMode == "filled" then
                        -- Фильтр 60-80%
                        if fillPercent >= 60 and fillPercent <= 80 then
                            table.insert(servers, srv)
                        end
                    else
                        table.insert(servers, srv)
                    end
                end
            end

            if #servers == 0 and srvSearchMode == "filled" then
                for _, srv in pairs(r.data) do
                    if srv.playing and srv.maxPlayers and srv.playing < srv.maxPlayers then
                        table.insert(servers, srv)
                    end
                end
            end

            table.sort(servers, function(a, b)
                if srvSearchMode == "filled" then
                    if srvSortAsc then
                        return a.playing < b.playing
                    else
                        return a.playing > b.playing
                    end
                else
                    return a.playing < b.playing 
                end
            end)

            for _, srv in ipairs(servers) do
                local fillPercent = math.clamp((srv.playing / srv.maxPlayers) * 100, 0, 100)
                
                local statusColor = Color3.fromRGB(80, 220, 120) 
                if fillPercent >= 80 then
                    statusColor = Color3.fromRGB(240, 100, 100) 
                elseif fillPercent >= 60 then
                    statusColor = Color3.fromRGB(250, 180, 60) 
                end

                local item = Lib.Create("Frame", { 
                    Parent = srvScroll, 
                    Size = UDim2.new(1, -4, 0, 54), 
                    BackgroundColor3 = Colors.Surface, 
                    BorderSizePixel = 0 
                })
                Lib.Create("UICorner", { Parent = item, CornerRadius = UDim.new(0, 6) })
                local itemStroke = Lib.Create("UIStroke", { Parent = item, Color = Colors.Border, Thickness = 1 })

                local indicator = Lib.Create("Frame", {
                    Parent = item,
                    Size = UDim2.new(0, 8, 0, 8),
                    Position = UDim2.new(0, 12, 0.5, -4),
                    BackgroundColor3 = statusColor,
                    BorderSizePixel = 0
                })
                Lib.Create("UICorner", { Parent = indicator, CornerRadius = UDim.new(1, 0) })
                Lib.Create("UIStroke", { Parent = indicator, Color = statusColor, Thickness = 1.5 })

                local info = Lib.Create("TextLabel", {
                    Parent = item,
                    Size = UDim2.new(0.5, 0, 0, 18),
                    Position = UDim2.new(0, 28, 0, 10),
                    BackgroundTransparency = 1,
                    Text = "Players: " .. srv.playing .. "/" .. srv.maxPlayers .. " (" .. math.floor(fillPercent) .. "%)",
                    TextColor3 = Colors.TextMain,
                    Font = Enum.Font.GothamBold,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local pingText = "Ping: " .. (srv.ping and tostring(srv.ping) .. "ms" or "N/A")
                if srv.fps then
                    pingText = pingText .. " | FPS: " .. math.floor(srv.fps)
                end

                local subInfo = Lib.Create("TextLabel", {
                    Parent = item,
                    Size = UDim2.new(0.5, 0, 0, 14),
                    Position = UDim2.new(0, 28, 0, 28),
                    BackgroundTransparency = 1,
                    Text = pingText,
                    TextColor3 = Colors.TextDim,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local join = Lib.Create("TextButton", {
                    Parent = item,
                    Size = UDim2.new(0, 70, 0, 26),
                    Position = UDim2.new(1, -82, 0.5, -13),
                    BackgroundColor3 = Colors.Active,
                    Text = "Join",
                    TextColor3 = Colors.Background,
                    Font = Enum.Font.GothamBold,
                    TextSize = 11,
                    BorderSizePixel = 0
                })
                Lib.Create("UICorner", { Parent = join, CornerRadius = UDim.new(0, 5) })

                join.MouseButton1Click:Connect(function()
                    Lib.showNotification("Подключение...")
                    Services.TP:TeleportToPlaceInstance(game.PlaceId, srv.id, LP)
                end)
            end
        end
    end

    srvSortBtn.MouseButton1Click:Connect(function()
        srvSortAsc = not srvSortAsc
        srvSortBtn.Text = srvSortAsc and "Sort: Ascending" or "Sort: Descending"
        task.spawn(populateServers)
    end)

    srvMinBtn.MouseButton1Click:Connect(function()
        srvMinimized = not srvMinimized
        Services.TS:Create(ServerMenu, TWEEN_INFO_FAST, {Size = UDim2.new(0, 360, 0, srvMinimized and 34 or 280)}):Play()
        srvScroll.Visible = not srvMinimized
    end)

    srvCloseBtn.MouseButton1Click:Connect(function() ServerMenu.Visible = false end)
    widgetBtn.MouseButton1Click:Connect(function()
        ServerMenu.Visible = not ServerMenu.Visible
        if ServerMenu.Visible then task.spawn(populateServers) end
    end)

    Lib.createToggle(UI.Pages.Server, "Servers Toggle", 105, false, function(st)
        ServerWidget.Visible = st
        if not st then ServerMenu.Visible = false end
    end)
end    

    local IdMenu = Lib.Create("Frame", {
        Parent = UI.Screen,
        Size = UDim2.new(0, 300, 0, 165),
        Position = UDim2.new(0.5, -150, 0.5, -82),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 16000
    })
    Lib.Create("UICorner", { Parent = IdMenu, CornerRadius = UDim.new(0, 8) })
    local idStroke = Lib.Create("UIStroke", { Parent = IdMenu, Color = Colors.Border, Thickness = 1 })

    local idTopBar = Lib.Create("Frame", { Parent = IdMenu, Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1 })
    Lib.makeDraggable(IdMenu, idTopBar)
    Lib.Create("TextLabel", { Parent = idTopBar, Size = UDim2.new(0.6, 0, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, Text = "Join by ID", TextColor3 = Colors.TextMain, Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left })
    local idCloseBtn = Lib.Create("TextButton", { Parent = idTopBar, Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, -30, 0.5, -12), BackgroundTransparency = 1, Text = "×", TextColor3 = Colors.TextDim, Font = Enum.Font.GothamMedium, TextSize = 18 })

    idCloseBtn.MouseButton1Click:Connect(function() 
        IdMenu.Visible = false 
        if _G.ConfigUpdaters["Using the ID"] then
            _G.ConfigUpdaters["Using the ID"](false)
        end
    end)

    local placeInput = Lib.Create("TextBox", {
        Parent = IdMenu,
        Size = UDim2.new(1, -24, 0, 30),
        Position = UDim2.new(0, 12, 0, 40),
        BackgroundColor3 = Colors.Surface,
        BorderSizePixel = 0,
        TextColor3 = Colors.TextMain,
        PlaceholderText = "Place ID (Необязательно)",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        Text = ""
    })
    Lib.Create("UICorner", { Parent = placeInput, CornerRadius = UDim.new(0, 4) })
    Lib.Create("UIStroke", { Parent = placeInput, Color = Colors.Border, Thickness = 1 })

    local jobInput = Lib.Create("TextBox", {
        Parent = IdMenu,
        Size = UDim2.new(1, -24, 0, 30),
        Position = UDim2.new(0, 12, 0, 78),
        BackgroundColor3 = Colors.Surface,
        BorderSizePixel = 0,
        TextColor3 = Colors.TextMain,
        PlaceholderText = "Server / Job ID",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        Text = ""
    })
    Lib.Create("UICorner", { Parent = jobInput, CornerRadius = UDim.new(0, 4) })
    Lib.Create("UIStroke", { Parent = jobInput, Color = Colors.Border, Thickness = 1 })

    local joinBtn = Lib.Create("TextButton", {
        Parent = IdMenu,
        Size = UDim2.new(1, -24, 0, 30),
        Position = UDim2.new(0, 12, 1, -42),
        BackgroundColor3 = Colors.Active,
        Text = "Join Server",
        TextColor3 = Colors.Background,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        BorderSizePixel = 0
    })
    Lib.Create("UICorner", { Parent = joinBtn, CornerRadius = UDim.new(0, 6) })

    joinBtn.MouseButton1Click:Connect(function()
        local targetPlace = tonumber(placeInput.Text) or game.PlaceId
        local targetJob = jobInput.Text
        if targetJob and targetJob ~= "" then
            Lib.showNotification("Подключение по ID...")
            pcall(function()
                Services.TP:TeleportToPlaceInstance(targetPlace, targetJob, LP)
            end)
        else
            Lib.showNotification("Переход на Place: " .. tostring(targetPlace))
            pcall(function()
                Services.TP:Teleport(targetPlace, LP)
            end)
        end
    end)

    Lib.createToggle(UI.Pages.Server, "Using the ID", 150, false, function(st)
        IdMenu.Visible = st
    end)

do
    local TPCard = Lib.CreateStyledCard(UI.Pages.Teleport, 85)
    Lib.Create("UIPadding", { Parent = TPCard, PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) })

    local avatar = Lib.Create("ImageLabel", {
        Parent = TPCard,
        Size = UDim2.new(0, 42, 0, 42),
        Position = UDim2.new(0, 0, 0, 12),
        BackgroundTransparency = 1,
        Image = "rbxassetid://115669221263328"
    })
    Lib.Create("UICorner", { Parent = avatar, CornerRadius = UDim.new(1, 0) })
    Lib.Create("UIStroke", { Parent = avatar, Color = Colors.Border, Thickness = 1 })

    local nameLbl = Lib.Create("TextLabel", {
        Parent = TPCard,
        Position = UDim2.new(0, 52, 0, 12),
        Size = UDim2.new(1, -60, 0, 15),
        BackgroundTransparency = 1,
        Text = "Select a player...",
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local TPPlayer = nil

    local function makeActBtn(text, posX, callback)
        local b = Lib.Create("TextButton", {
            Parent = TPCard,
            Size = UDim2.new(0, 95, 0, 26),
            Position = UDim2.new(0, posX, 0, 36),
            BackgroundColor3 = Colors.Surface,
            Text = text,
            TextColor3 = Colors.TextMain,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            BorderSizePixel = 0
        })
        Lib.Create("UICorner", { Parent = b, CornerRadius = UDim.new(0, 4) })
        local bStroke = Lib.Create("UIStroke", { Parent = b, Color = Colors.Border, Thickness = 1 })
        b.MouseEnter:Connect(function() Services.TS:Create(bStroke, TWEEN_INFO_FAST, {Color = Colors.Active}):Play() end)
        b.MouseLeave:Connect(function() Services.TS:Create(bStroke, TWEEN_INFO_FAST, {Color = Colors.Border}):Play() end)
        b.MouseButton1Click:Connect(callback)
        return b
    end

    makeActBtn("Teleport", 52, function()
        if TPPlayer and LP.Character and TPPlayer.Character and TPPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LP.Character:MoveTo(TPPlayer.Character.HumanoidRootPart.Position)
            Lib.showNotification("Телепортирован к " .. TPPlayer.Name)
        end
    end)

    local currentSpectateTarget = nil
    makeActBtn("Spectate", 155, function()
        if currentSpectateTarget == TPPlayer then
            if LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
                workspace.CurrentCamera.CameraSubject = LP.Character:FindFirstChildOfClass("Humanoid")
            end
            currentSpectateTarget = nil
            Lib.showNotification("Наблюдение отключено")
        else
            if TPPlayer and TPPlayer.Character then
                local hum = TPPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    currentSpectateTarget = TPPlayer
                    workspace.CurrentCamera.CameraSubject = hum
                    Lib.showNotification("Наблюдение за " .. TPPlayer.Name)
                end
            else
                Lib.showNotification("Игрок не выбран")
            end
        end
    end)

    local PlayersMenu = Lib.Create("Frame", {
        Parent = UI.Pages.Teleport,
        Size = UDim2.new(1, -6, 0, 0),
        Position = UDim2.new(0, 3, 0, 135),
        BackgroundColor3 = Colors.Surface,
        BorderSizePixel = 0,
        Visible = false,
        ClipsDescendants = true
    })
    Lib.Create("UICorner", { Parent = PlayersMenu, CornerRadius = UDim.new(0, 6) })
    local pMenuStroke = Lib.Create("UIStroke", { Parent = PlayersMenu, Color = Colors.Border, Thickness = 1 })

    local pScroll = Lib.Create("ScrollingFrame", {
        Parent = PlayersMenu,
        Size = UDim2.new(1, -20, 1, -20),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Colors.Border,
        BorderSizePixel = 0
    })
    local pLayout = Lib.Create("UIListLayout", { Parent = pScroll, Padding = UDim.new(0, 4) })
    pLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        pScroll.CanvasSize = UDim2.new(0, 0, 0, pLayout.AbsoluteContentSize.Y + 5)
    end)

    local function refreshPlayersList()
        for _, v in pairs(pScroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
        for _, plr in ipairs(Services.Players:GetPlayers()) do
            if plr ~= LP then
                local b = Lib.Create("TextButton", {
                    Parent = pScroll,
                    Size = UDim2.new(1, -4, 0, 26),
                    BackgroundColor3 = Colors.Background,
                    Text = plr.Name,
                    TextColor3 = Colors.TextDim,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 12,
                    BorderSizePixel = 0
                })
                Lib.Create("UICorner", { Parent = b, CornerRadius = UDim.new(0, 4) })
                local bStroke = Lib.Create("UIStroke", { Parent = b, Color = Colors.Border, Thickness = 1 })
                b.MouseEnter:Connect(function() Services.TS:Create(bStroke, TWEEN_INFO_FAST, {Color = Colors.Active}):Play() end)
                b.MouseLeave:Connect(function() Services.TS:Create(bStroke, TWEEN_INFO_FAST, {Color = Colors.Border}):Play() end)

                b.MouseButton1Click:Connect(function()
                    TPPlayer = plr
                    nameLbl.Text = plr.Name
                    pcall(function()
                        avatar.Image = Services.Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
                    end)
                end)
            end
        end
    end

    local playersOpen = false
    local plrsBtn, plrsArrow = Lib.createMenuBtn(UI.Pages.Teleport, "Players", 95, true)
    local toolBtn = Lib.createMenuBtn(UI.Pages.Teleport, "Teleport Tool", 135, false)

    plrsBtn.MouseButton1Click:Connect(function()
        playersOpen = not playersOpen
        refreshPlayersList()
        PlayersMenu.Visible = true
        local menuHeight = playersOpen and 140 or 0
        Services.TS:Create(plrsArrow, TWEEN_INFO_FAST, {Rotation = playersOpen and 180 or 0}):Play()
        Services.TS:Create(PlayersMenu, TWEEN_INFO_FAST, {Size = UDim2.new(1, -6, 0, menuHeight)}):Play()
        Services.TS:Create(toolBtn, TWEEN_INFO_FAST, {Position = UDim2.new(0, 3, 0, 135 + menuHeight)}):Play()
    end)

    toolBtn.MouseButton1Click:Connect(function()
        Lib.showNotification("Teleport Tool выдан!")
        local tool = Instance.new("Tool")
        tool.Name = "Teleport Tool"
        tool.RequiresHandle = false
        tool.Parent = LP.Backpack
        table.insert(UI.Connections, tool.Activated:Connect(function()
            local mouse = LP:GetMouse()
            if mouse.Hit and LP.Character then
                LP.Character:MoveTo(mouse.Hit.Position)
            end
        end))
    end)
end

do
    Lib.createSlider(UI.Pages.Movement, 10, "Speed", 16, 200, 16, function(v)
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then
            LP.Character.Humanoid.WalkSpeed = v
        end
    end)

    Lib.createSlider(UI.Pages.Movement, 70, "Jump", 50, 200, 50, function(v)
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then
            LP.Character.Humanoid.UseJumpPower = true
            LP.Character.Humanoid.JumpPower = v
        end
    end)

    local endless = false
    Lib.createToggle(UI.Pages.Movement, "Endless Jump", 130, false, function(st) endless = st end)
    table.insert(UI.Connections, Services.UIS.JumpRequest:Connect(function()
        if endless and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
            LP.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end))

    local wall = false
    Lib.createToggle(UI.Pages.Movement, "Climbing Walls", 175, false, function(st) wall = st end)
    task.spawn(function()
        while task.wait(0.1) do
            if wall and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") and LP.Character:FindFirstChild("Humanoid") then
                local hrp = LP.Character.HumanoidRootPart
                local hum = LP.Character.Humanoid
                
                local raycastParams = RaycastParams.new()
                raycastParams.FilterDescendantsInstances = {LP.Character}
                raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                
                local raycastResult = workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * 2.5, raycastParams)
                if raycastResult and raycastResult.Instance.CanCollide then
                    hum:ChangeState(Enum.HumanoidStateType.Climbing)
                end
            end
        end
    end)

    local flySpeed = 50
    local speedCard = Lib.CreateStyledCard(UI.Pages.Movement, 40)
    speedCard.Position = UDim2.new(0, 0, 0, 220)
    
    local speedLbl = Lib.Create("TextLabel", {
        Parent = speedCard,
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = "Flight Speed",
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local speedInput = Lib.Create("TextBox", {
        Parent = speedCard,
        Size = UDim2.new(0, 60, 0, 24),
        Position = UDim2.new(1, -72, 0.5, -12),
        BackgroundColor3 = Colors.ToggleShell,
        BorderSizePixel = 0,
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        Text = tostring(flySpeed)
    })
    Lib.Create("UICorner", { Parent = speedInput, CornerRadius = UDim.new(0, 4) })
    local sInStroke = Lib.Create("UIStroke", { Parent = speedInput, Color = Colors.Border, Thickness = 1 })
    speedInput.FocusLost:Connect(function()
        local v = tonumber(speedInput.Text)
        if v then flySpeed = v else speedInput.Text = tostring(flySpeed) end
    end)

    local flying = false
    local bg, bv
    Lib.createToggle(UI.Pages.Movement, "Flight (PC & Mobile)", 265, false, function(st)
        flying = st
        local char = LP.Character
        if flying and char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            bg = Instance.new("BodyGyro", hrp); bg.P = 9e4; bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9); bg.CFrame = hrp.CFrame
            bv = Instance.new("BodyVelocity", hrp); bv.Velocity = Vector3.new(0,0,0); bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            char.Humanoid.PlatformStand = true
        else
            if bg then bg:Destroy() end; if bv then bv:Destroy() end
            if char and char:FindFirstChild("Humanoid") then char.Humanoid.PlatformStand = false end
        end
    end)

    table.insert(UI.Connections, Services.Run.RenderStepped:Connect(function()
        if flying and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            local hum = LP.Character:FindFirstChild("Humanoid")
            if not hum then return end
            local cam = workspace.CurrentCamera
            local moveDir = hum.MoveDirection; local vel = Vector3.new()
            if moveDir.Magnitude > 0 then
                local camLook = cam.CFrame.LookVector
                local camRight = cam.CFrame.RightVector
                local flatLook = Vector3.new(camLook.X, 0, camLook.Z).Unit
                local flatRight = Vector3.new(camRight.X, 0, camRight.Z).Unit
                local forwardInput = moveDir:Dot(flatLook)
                local rightInput = moveDir:Dot(flatRight)
                vel = (camLook * forwardInput) + (camRight * rightInput)
            end
            if Services.UIS:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0, 1, 0) end
            if Services.UIS:IsKeyDown(Enum.KeyCode.LeftShift) then vel = vel + Vector3.new(0, -1, 0) end
            if bv then bv.Velocity = vel.Magnitude > 0 and vel.Unit * flySpeed or Vector3.new(0,0,0) end
            if bg then bg.CFrame = cam.CFrame end
        end
    end))
end

    local flightAnimButton = Lib.createMenuBtn(UI.Pages.Movement, "List of flight animations", 310, false)

    local AnimWin, AnimClose, AnimScroll, AnimLayout, AnimActionBtn, AnimActionLbl = Lib.createFloatingMenu("Flight Animations", 260, 240)
    AnimActionBtn.Visible = false
    AnimActionLbl.Visible = false
    AnimScroll.Size = UDim2.new(1, -20, 1, -48)

    local selectedAnimId = nil
    local currentFlightTrack = nil
    local currentFlightAnimObj = nil

    local function stopFlightAnimation()
        if currentFlightTrack then
            currentFlightTrack:Stop(0.3)
            currentFlightTrack:Destroy()
            currentFlightTrack = nil
        end
        if currentFlightAnimObj then
            currentFlightAnimObj:Destroy()
            currentFlightAnimObj = nil
        end
    end

    local function playFlightAnimation(id)
        local char = LP.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local animator = hum:FindFirstChildOfClass("Animator") or hum:WaitForChild("Animator", 5)
        if not animator then return end

        stopFlightAnimation()

        currentFlightAnimObj = Instance.new("Animation")
        currentFlightAnimObj.AnimationId = "rbxassetid://" .. tostring(id)

        local success, track = pcall(function()
            return animator:LoadAnimation(currentFlightAnimObj)
        end)

        if success and track then
            currentFlightTrack = track
            track.Priority = Enum.AnimationPriority.Action4
            track.Looped = true
            track:Play(0.3)
        end
    end

    task.spawn(function()
        while task.wait(0.1) do
            local isFlying = _G.ConfigState["Flight (PC & Mobile)"]
            local char = LP.Character
            if isFlying and char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
                local hum = char.Humanoid
                local isMoving = hum.MoveDirection.Magnitude > 0.05
                
                if isMoving and selectedAnimId then

                    if not currentFlightTrack or currentFlightTrack.Animation.AnimationId ~= "rbxassetid://" .. tostring(selectedAnimId) then
                        playFlightAnimation(selectedAnimId)
                    end
                else

                    if currentFlightTrack then
                        stopFlightAnimation()
                    end
                end
            else

                if currentFlightTrack then
                    stopFlightAnimation()
                end
            end
        end
    end)

    local anims = {
        { name = "Mark", id = 110778746401300 },
        { name = "None / Default", id = nil }
    }

    local activeAnimButtons = {}

    local function updateAnimButtonsVisuals()
        for idStr, btn in pairs(activeAnimButtons) do
            local btnId = idStr == "nil" and nil or tonumber(idStr)
            if selectedAnimId == btnId then
                btn.BackgroundColor3 = Colors.Active
                btn.TextColor3 = Colors.Background
            else
                btn.BackgroundColor3 = Colors.Surface
                btn.TextColor3 = Colors.TextMain
            end
        end
    end

    for _, anim in ipairs(anims) do
        local btn = Lib.Create("TextButton", {
            Parent = AnimScroll,
            Size = UDim2.new(1, -4, 0, 30),
            BackgroundColor3 = Colors.Surface,
            Text = anim.name,
            TextColor3 = Colors.TextMain,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            BorderSizePixel = 0
        })
        Lib.Create("UICorner", { Parent = btn, CornerRadius = UDim.new(0, 4) })
        local bStroke = Lib.Create("UIStroke", { Parent = btn, Color = Colors.Border, Thickness = 1 })

        local key = tostring(anim.id)
        activeAnimButtons[key] = btn

        btn.MouseButton1Click:Connect(function()
            selectedAnimId = anim.id
            updateAnimButtonsVisuals()
            if selectedAnimId then
                Lib.showNotification("Выбрана анимация полета: " .. anim.name)
            else
                Lib.showNotification("Анимация сброшена по умолчанию")
                stopFlightAnimation()
            end
        end)
    end

    updateAnimButtonsVisuals()

    flightAnimButton.MouseButton1Click:Connect(function()
        AnimWin.Visible = not AnimWin.Visible
    end)

    AnimClose.MouseButton1Click:Connect(function()
        AnimWin.Visible = false
    end)

do
    local ESPBtn, Arrow = Lib.createMenuBtn(UI.Pages.Visuals, "ESP", 10, true)
    local ESPMenu = Lib.Create("Frame", { Parent = UI.Pages.Visuals, Size = UDim2.new(1, -6, 0, 0), Position = UDim2.new(0, 3, 0, 50), BackgroundTransparency = 1, ClipsDescendants = true, Visible = false })
    local espLayout = Lib.Create("UIListLayout", { Parent = ESPMenu, Padding = UDim.new(0, 4) })

    local BoostBtn, BoostArrow = Lib.createMenuBtn(UI.Pages.Visuals, "Boost FPS", 55, true)
    local BoostMenu = Lib.Create("Frame", { Parent = UI.Pages.Visuals, Size = UDim2.new(1, -6, 0, 0), Position = UDim2.new(0, 3, 0, 95), BackgroundTransparency = 1, ClipsDescendants = true, Visible = false })
    local boostLayout = Lib.Create("UIListLayout", { Parent = BoostMenu, Padding = UDim.new(0, 4) })

    local MiscBtn, MiscArrow = Lib.createMenuBtn(UI.Pages.Visuals, "Misc", 95, true)
    local MiscMenu = Lib.Create("Frame", { Parent = UI.Pages.Visuals, Size = UDim2.new(1, -6, 0, 0), Position = UDim2.new(0, 3, 0, 135), BackgroundTransparency = 1, ClipsDescendants = true, Visible = false })
    local miscLayout = Lib.Create("UIListLayout", { Parent = MiscMenu, Padding = UDim.new(0, 4) })

    local espOpened, boostOpened, miscOpened = false, false, false
    local function updatePositions()
        local espHeight = espOpened and 310 or 0
        local boostHeight = boostOpened and 310 or 0
        local miscHeight = miscOpened and 264 or 0
        Services.TS:Create(BoostBtn, TWEEN_INFO_FAST, {Position = UDim2.new(0, 3, 0, 55 + espHeight)}):Play()
        Services.TS:Create(BoostMenu, TWEEN_INFO_FAST, {Position = UDim2.new(0, 3, 0, 95 + espHeight)}):Play()
        Services.TS:Create(MiscBtn, TWEEN_INFO_FAST, {Position = UDim2.new(0, 3, 0, 95 + espHeight + boostHeight)}):Play()
        Services.TS:Create(MiscMenu, TWEEN_INFO_FAST, {Position = UDim2.new(0, 3, 0, 135 + espHeight + boostHeight)}):Play()
    end

    ESPBtn.MouseButton1Click:Connect(function()
        espOpened = not espOpened
        ESPMenu.Visible = true
        Services.TS:Create(Arrow, TWEEN_INFO_FAST, {Rotation = espOpened and 180 or 0}):Play()
        local t = Services.TS:Create(ESPMenu, TWEEN_INFO_FAST, {Size = UDim2.new(1, -6, 0, espOpened and 310 or 0)})
        t:Play(); t.Completed:Wait(); updatePositions()
    end)

    BoostBtn.MouseButton1Click:Connect(function()
        boostOpened = not boostOpened
        BoostMenu.Visible = true
        Services.TS:Create(BoostArrow, TWEEN_INFO_FAST, {Rotation = boostOpened and 180 or 0}):Play()
        local t = Services.TS:Create(BoostMenu, TWEEN_INFO_FAST, {Size = UDim2.new(1, -6, 0, boostOpened and 310 or 0)})
        t:Play(); t.Completed:Wait(); updatePositions()
    end)

    MiscBtn.MouseButton1Click:Connect(function()
        miscOpened = not miscOpened
        MiscMenu.Visible = true
        Services.TS:Create(MiscArrow, TWEEN_INFO_FAST, {Rotation = miscOpened and 180 or 0}):Play()
        local t = Services.TS:Create(MiscMenu, TWEEN_INFO_FAST, {Size = UDim2.new(1, -6, 0, miscOpened and 264 or 0)})
        t:Play(); t.Completed:Wait(); updatePositions()
    end)

    local nameESP, outlineESP, itemESP, boxESP, tracersESP = false, false, false, false, false
    Lib.createToggle(ESPMenu, "ESP Name", 0, false, function(st) nameESP = st end)
    Lib.createToggle(ESPMenu, "ESP Outline", 44, false, function(st) outlineESP = st end)
    Lib.createToggle(ESPMenu, "Item ESP", 88, false, function(st) itemESP = st end)
    Lib.createToggle(ESPMenu, "Box ESP", 132, false, function(st) boxESP = st end)
    Lib.createToggle(ESPMenu, "Tracers", 176, false, function(st) tracersESP = st end)

    local xrayOriginals = {}
    Lib.createToggle(ESPMenu, "X-Ray", 220, false, function(st)
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj.Parent:FindFirstChild("Humanoid") then
                if st then
                    if not xrayOriginals[obj] then xrayOriginals[obj] = obj.Transparency end
                    obj.Transparency = 0.6
                else
                    if xrayOriginals[obj] then obj.Transparency = xrayOriginals[obj]; xrayOriginals[obj] = nil end
                end
            end
        end
    end)

    local fovCircleEnabled = false
    local fovRadius = 120 

    local fovCircle = Drawing.new("Circle")
    fovCircle.Visible = false
    fovCircle.Thickness = 1.5
    fovCircle.NumSides = 64
    fovCircle.Filled = false

    Lib.createToggle(ESPMenu, "FOV Circle", 264, false, function(st)
        fovCircleEnabled = st
        fovCircle.Visible = st
    end)

    table.insert(UI.Connections, Services.Run.RenderStepped:Connect(function()
        if fovCircleEnabled then
            local viewportSize = workspace.CurrentCamera.ViewportSize
            fovCircle.Position = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
            fovCircle.Radius = fovRadius
            fovCircle.Color = Colors.Active
            fovCircle.Visible = true
        else
            fovCircle.Visible = false
        end
    end))

    local boostFPS, skinReplace, potatoEnabled, removeEnabled, fullbright, effectsEnabled = false, false, false, false, false, false
    local RemoveTool, oldLighting = nil, {}

    Lib.createToggle(BoostMenu, "Boostfps", 0, false, function(st)
        boostFPS = st
        if st then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Texture") or obj:IsA("Decal") then obj.Transparency = 1 end
                if obj:IsA("BasePart") then obj.Material = Enum.Material.Plastic; obj.Reflectance = 0 end
            end
        end
    end)
    Lib.createToggle(BoostMenu, "Skin Replacement", 44, false, function(st)
        skinReplace = st
        for _, plr in pairs(Services.Players:GetPlayers()) do
            if plr ~= LP and plr.Character then
                for _, v in pairs(plr.Character:GetDescendants()) do
                    if v:IsA("MeshPart") and st then v.MeshId = ""; v.Size = Vector3.new(1, 1, 1) end
                end
            end
        end
    end)
    Lib.createToggle(BoostMenu, "Potato Mode", 88, false, function(st)
        potatoEnabled = st
        if st then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Texture") or obj:IsA("Decal") then obj.Transparency = 1 end
                if obj:IsA("BasePart") then obj.Material = Enum.Material.SmoothPlastic; obj.Reflectance = 0; obj.CastShadow = false end
                if obj:IsA("MeshPart") then obj.TextureID = ""; obj.Material = Enum.Material.Plastic end
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") then obj.Enabled = false end
            end
        end
    end)
    Lib.createToggle(BoostMenu, "Removing Textures", 132, false, function(st)
        removeEnabled = st
        if st then
            RemoveTool = Instance.new("Tool"); RemoveTool.Name = "Texture Remover"; RemoveTool.RequiresHandle = false; RemoveTool.Parent = LP.Backpack
            table.insert(UI.Connections, RemoveTool.Activated:Connect(function()
                local t = LP:GetMouse().Target
                if t then
                    for _, v in pairs(t:GetDescendants()) do if v:IsA("Texture") or v:IsA("Decal") then v:Destroy() end end
                    if t:IsA("MeshPart") then t.TextureID = "" end
                end
            end))
        else
            if RemoveTool then RemoveTool:Destroy(); RemoveTool = nil end
        end
    end)
    Lib.createToggle(BoostMenu, "FullBright", 176, false, function(st)
        fullbright = st
        local L = Services.Lighting
        if st then
            oldLighting.Brightness = L.Brightness; oldLighting.ClockTime = L.ClockTime; oldLighting.GlobalShadows = L.GlobalShadows; oldLighting.FogEnd = L.FogEnd
            L.Brightness = 3; L.ClockTime = 14; L.GlobalShadows = false; L.FogEnd = 999999
        else
            L.Brightness = oldLighting.Brightness or 1; L.ClockTime = oldLighting.ClockTime or 14; L.GlobalShadows = oldLighting.GlobalShadows; L.FogEnd = oldLighting.FogEnd or 1000
        end
    end)
    Lib.createToggle(BoostMenu, "Remove Effects", 220, false, function(st)
        effectsEnabled = st
        for _, v in pairs(Services.Lighting:GetChildren()) do
            if v:IsA("BlurEffect") or v:IsA("BloomEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("Atmosphere") then
                v.Enabled = not st
            end
        end
    end)

local pdTool = nil
local pdClickConnection = nil
local pdMoveConnection = nil

local pdSelectionBox = Instance.new("SelectionBox")
pdSelectionBox.Color3 = Color3.fromRGB(255, 50, 50)
pdSelectionBox.LineThickness = 0.05
pdSelectionBox.Parent = workspace.CurrentCamera

Lib.createToggle(BoostMenu, "Part Deleter", 264, false, function(st)
    if st then
        pdTool = Instance.new("Tool")
        pdTool.Name = "Part Deleter"
        pdTool.RequiresHandle = false
        pdTool.CanBeDropped = false
        
        pdTool.Equipped:Connect(function()
           local mouse = LP:GetMouse()
            pdMoveConnection = mouse.Move:Connect(function()
                local target = mouse.Target
                if target and target:IsA("BasePart") then
                    pdSelectionBox.Adornee = target
                else
                    pdSelectionBox.Adornee = nil
                end
            end)

            pdClickConnection = mouse.Button1Down:Connect(function()
                local target = mouse.Target
                if target and target:IsA("BasePart") then
                    target:Destroy()
                    pdSelectionBox.Adornee = nil
                end
            end)
        end)

        pdTool.Unequipped:Connect(function()
            pdSelectionBox.Adornee = nil
            if pdClickConnection then pdClickConnection:Disconnect(); pdClickConnection = nil end
            if pdMoveConnection then pdMoveConnection:Disconnect(); pdMoveConnection = nil end
        end)

        if LP:FindFirstChild("Backpack") then
            pdTool.Parent = LP.Backpack
        end
    else
        pdSelectionBox.Adornee = nil
        if pdClickConnection then pdClickConnection:Disconnect(); pdClickConnection = nil end
        if pdMoveConnection then pdMoveConnection:Disconnect(); pdMoveConnection = nil end
        if pdTool then pdTool:Destroy(); pdTool = nil end
    end
end)

    local headless, korblox, skyboxEnabled, thirdPersonEnabled = false, false, false, false
    local oldSkybox = nil

    Lib.createToggle(MiscMenu, "Headless", 0, false, function(st)
        headless = st
        if LP.Character and LP.Character:FindFirstChild("Head") then
            LP.Character.Head.Transparency = st and 1 or 0
            for _, v in pairs(LP.Character.Head:GetChildren()) do if v:IsA("Decal") then v.Transparency = st and 1 or 0 end end
        end
    end)

    local currentKorblox = nil
    Lib.createToggle(MiscMenu, "Korblox", 44, false, function(st)
        korblox = st
        local char = LP.Character
        if not char then return end
        
        if currentKorblox then
            currentKorblox:Destroy()
            currentKorblox = nil
        end
        
        local legParts = {"Right Leg", "RightLowerLeg", "RightUpperLeg", "RightFoot"}
        for _, pName in ipairs(legParts) do
            local part = char:FindFirstChild(pName)
            if part then
                part.Transparency = st and 1 or 0
            end
        end
        
        if st then
            pcall(function()
                local objects = game:GetObjects("rbxassetid://139607718")
                if objects and objects[1] then
                    currentKorblox = objects[1]
                    currentKorblox.Parent = char
                end
            end)
        end
    end)

    Lib.createToggle(MiscMenu, "Skybox Changer", 88, false, function(st)
        skyboxEnabled = st
        local L = Services.Lighting
        if st then
            oldSkybox = L:FindFirstChildOfClass("Sky")
            if oldSkybox then oldSkybox.Parent = nil end
            local newSky = Instance.new("Sky", L)
            newSky.Name = "CustomSky"
            newSky.SkyboxBk = "rbxassetid://600886090"; newSky.SkyboxDn = "rbxassetid://600886090"; newSky.SkyboxFt = "rbxassetid://600886090"
            newSky.SkyboxLf = "rbxassetid://600886090"; newSky.SkyboxRt = "rbxassetid://600886090"; newSky.SkyboxUp = "rbxassetid://600886090"
        else
            local currSky = L:FindFirstChild("CustomSky")
            if currSky then currSky:Destroy() end
            if oldSkybox then oldSkybox.Parent = L end
        end
    end)
    Lib.createToggle(MiscMenu, "Third Person Mode", 132, false, function(st)
        thirdPersonEnabled = st
        if st then
            LP.CameraMode = Enum.CameraMode.Classic; LP.CameraMaxZoomDistance = 12; LP.CameraMinZoomDistance = 12
        else
            LP.CameraMaxZoomDistance = 400; LP.CameraMinZoomDistance = 0.5
        end
    end)

    local RadarWin = Lib.Create("Frame", { Parent = UI.Screen, Size = UDim2.new(0, 140, 0, 140), Position = UDim2.new(1, -165, 0, 55), BackgroundColor3 = Colors.Background, Visible = false, BorderSizePixel = 0 })
    Lib.Create("UICorner", { Parent = RadarWin, CornerRadius = UDim.new(1, 0) })
    Lib.Create("UIStroke", { Parent = RadarWin, Color = Colors.Border, Thickness = 1 })
    
    local rCenter = Lib.Create("Frame", { Parent = RadarWin, Size = UDim2.new(0, 4, 0, 4), Position = UDim2.new(0.5, -2, 0.5, -2), BackgroundColor3 = Colors.TextMain, BorderSizePixel = 0 })
    Lib.Create("UICorner", { Parent = rCenter, CornerRadius = UDim.new(1, 0) })
    Lib.makeDraggable(RadarWin)

    local radarEnabled = false
    Lib.createToggle(MiscMenu, "Radar", 176, false, function(st)
        radarEnabled = st
        RadarWin.Visible = st
    end)

    local MusicWin = Lib.Create("Frame", {
        Parent = UI.Screen,
        Size = UDim2.new(0, 320, 0, 350),
        Position = UDim2.new(0.5, -160, 0.5, -175),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        Visible = false,
        ClipsDescendants = true,
        ZIndex = 15000
    })
    Lib.Create("UICorner", { Parent = MusicWin, CornerRadius = UDim.new(0, 8) })
    Lib.Create("UIStroke", { Parent = MusicWin, Color = Colors.Border, Thickness = 1 })

    local musTopBar = Lib.Create("Frame", { Parent = MusicWin, Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1 })
    Lib.makeDraggable(MusicWin, musTopBar)

    Lib.Create("TextLabel", {
        Parent = musTopBar,
        Size = UDim2.new(0.6, 0, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Text = "Music Player",
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local musCloseBtn = Lib.Create("TextButton", {
        Parent = musTopBar,
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -30, 0.5, -12),
        BackgroundTransparency = 1,
        Text = "×",
        TextColor3 = Colors.TextDim,
        Font = Enum.Font.GothamMedium,
        TextSize = 18
    })

    local musScroll = Lib.Create("ScrollingFrame", {
        Parent = MusicWin,
        Size = UDim2.new(1, -24, 0, 230),
        Position = UDim2.new(0, 12, 0, 38),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Colors.Border,
        BorderSizePixel = 0
    })
    local musLayout = Lib.Create("UIListLayout", { Parent = musScroll, Padding = UDim.new(0, 4) })
    musLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        musScroll.CanvasSize = UDim2.new(0, 0, 0, musLayout.AbsoluteContentSize.Y + 5)
    end)

    local customPanel = Lib.Create("Frame", {
        Parent = MusicWin,
        Size = UDim2.new(1, -24, 0, 50),
        Position = UDim2.new(0, 12, 0, 280),
        BackgroundColor3 = Colors.Surface,
        BorderSizePixel = 0
    })
    Lib.Create("UICorner", { Parent = customPanel, CornerRadius = UDim.new(0, 6) })
    Lib.Create("UIStroke", { Parent = customPanel, Color = Colors.Border, Thickness = 1 })

    local customInput = Lib.Create("TextBox", {
        Parent = customPanel,
        Size = UDim2.new(1, -90, 1, -16),
        Position = UDim2.new(0, 10, 0, 8),
        BackgroundColor3 = Colors.ToggleShell,
        BorderSizePixel = 0,
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        PlaceholderText = "Enter Sound ID...",
        Text = "",
        ClearTextOnFocus = false
    })
    Lib.Create("UICorner", { Parent = customInput, CornerRadius = UDim.new(0, 4) })
    Lib.Create("UIStroke", { Parent = customInput, Color = Colors.Border, Thickness = 1 })

    local customPlayBtn = Lib.Create("TextButton", {
        Parent = customPanel,
        Size = UDim2.new(0, 70, 1, -16),
        Position = UDim2.new(1, -80, 0, 8),
        BackgroundColor3 = Colors.Active,
        Text = "Вкл",
        TextColor3 = Colors.Background,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        BorderSizePixel = 0
    })
    Lib.Create("UICorner", { Parent = customPlayBtn, CornerRadius = UDim.new(0, 4) })

    local currentSound = nil
    local currentPlayingId = nil
    local customPlaying = false
    local buttonsList = {}

    local function stopCurrentSound()
        if currentSound then
            currentSound:Stop()
            currentSound:Destroy()
            currentSound = nil
        end
    end

    local function playSound(id)
        stopCurrentSound()
        currentSound = Instance.new("Sound")
        currentSound.SoundId = "rbxassetid://" .. tostring(id)
        currentSound.Volume = 1
        currentSound.Looped = true
        currentSound.Parent = workspace
        currentSound:Play()
    end

    local function updateAllMusicButtons()
        for id, btn in pairs(buttonsList) do
            if currentPlayingId == id then
                btn.Text = "Выкл"
                btn.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
                btn.TextColor3 = Colors.TextMain
            else
                btn.Text = "Вкл"
                btn.BackgroundColor3 = Colors.Active
                btn.TextColor3 = Colors.Background
            end
        end
    end

    local function handlePlayClick(id)
        if currentPlayingId == id then
            stopCurrentSound()
            currentPlayingId = nil
            customPlaying = false
            customPlayBtn.Text = "Вкл"
            customPlayBtn.BackgroundColor3 = Colors.Active
            customPlayBtn.TextColor3 = Colors.Background
        else
            playSound(id)
            currentPlayingId = id
            customPlaying = false
            customPlayBtn.Text = "Вкл"
            customPlayBtn.BackgroundColor3 = Colors.Active
            customPlayBtn.TextColor3 = Colors.Background
        end
        updateAllMusicButtons()
    end

    customPlayBtn.MouseButton1Click:Connect(function()
        local id = customInput.Text
        if id ~= "" then
            if customPlaying and currentPlayingId == id then
                stopCurrentSound()
                currentPlayingId = nil
                customPlaying = false
                customPlayBtn.Text = "Вкл"
                customPlayBtn.BackgroundColor3 = Colors.Active
                customPlayBtn.TextColor3 = Colors.Background
                updateAllMusicButtons()
            else
                playSound(id)
                currentPlayingId = id
                customPlaying = true
                customPlayBtn.Text = "Выкл"
                customPlayBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
                customPlayBtn.TextColor3 = Colors.TextMain
                updateAllMusicButtons()
            end
        end
    end)

    musCloseBtn.MouseButton1Click:Connect(function()
        MusicWin.Visible = false
        if _G.ConfigUpdaters["Music Player"] then
            _G.ConfigUpdaters["Music Player"](false)
        end
    end)

    local songs = {
        {name = "Alan Walker - Fade", id = 1281861057},
        {name = "Alan Walker - Spectre", id = 280219665},
        {name = "Tobu - Candyland", id = 210134085},
        {name = "Tobu - Hope", id = 210135891},
        {name = "The Fat Rat - Unity", id = 186053155},
        {name = "The Fat Rat - Windfall", id = 191632766},
        {name = "Phonk - Metamorphosis", id = 11099313936},
        {name = "Phonk - Neon Blade", id = 10695027581},
        {name = "Kahoot Lobby Music", id = 1319760718},
        {name = "Epic Sax Guy", id = 130775431},
        {name = "Megumin Explosion", id = 412095311},
        {name = "Megalovania", id = 5410086219},
        {name = "Rick Roll", id = 1251912644},
        {name = "Careless Whisper", id = 1845182928},
        {name = "Stereo Madness", id = 219195392},
        {name = "Despacito", id = 1340114030},
        {name = "GigaChad Theme", id = 9114717144},
        {name = "Among Us Drip", id = 6124508453},
        {name = "Trio - Da Da Da", id = 153093282},
        {name = "Nyan Cat", id = 130790250},
        {name = "Darude - Sandstorm", id = 166589022},
        {name = "Guns N' Roses - Sweet Child", id = 292612543},
        {name = "We Like to Party Vengaboys", id = 151044434},
        {name = "Spooky Scary Skeletons", id = 160351296},
        {name = "Gummy Bear Song", id = 143896590},
        {name = "Macarena", id = 156942023},
        {name = "Soviet Anthem", id = 130838153},
        {name = "He-Man HEYYEYAAEYAAA", id = 142106725},
        {name = "Caramelldansen", id = 254823122},
        {name = "Running in the 90s", id = 130887303},
        {name = "Gas Gas Gas", id = 611680108},
        {name = "Deja Vu (Initial D)", id = 1358941651},
        {name = "Minecraft Calm 1", id = 142071948},
        {name = "Super Mario Theme", id = 1282141972},
        {name = "Tetris Theme", id = 148115695},
        {name = "Pac-Man Theme", id = 156828551},
        {name = "Mortal Kombat", id = 142410214},
        {name = "Pirates of the Caribbean", id = 155891398},
        {name = "Pokemon Theme", id = 131013445},
        {name = "Goku Ultra Instinct", id = 1432126294},
        {name = "Chipi Chipi Chapa Chapa", id = 15620958183},
        {name = "Baka Mitai (Dame Da Ne)", id = 5334817415},
        {name = "Sad Violin", id = 135328812},
        {name = "Coffin Dance", id = 4900778643},
        {name = "Monkeys Spinning Monkeys", id = 9114264627},
        {name = "Sneaky Snitch", id = 9119102434},
        {name = "Deadwood - Really Slow Motion", id = 286596328},
        {name = "Bad To The Bone Riff", id = 9115796248},
        {name = "Club Step (GD)", id = 151525997},
        {name = "Stay Inside Me (GD Practice)", id = 145557762}
    }

    for _, song in ipairs(songs) do
        local item = Lib.Create("Frame", {
            Parent = musScroll,
            Size = UDim2.new(1, -4, 0, 30),
            BackgroundColor3 = Colors.Surface,
            BorderSizePixel = 0
        })
        Lib.Create("UICorner", { Parent = item, CornerRadius = UDim.new(0, 4) })
        local itemStroke = Lib.Create("UIStroke", { Parent = item, Color = Colors.Border, Thickness = 1 })

        local title = Lib.Create("TextLabel", {
            Parent = item,
            Size = UDim2.new(1, -75, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Text = song.name,
            TextColor3 = Colors.TextMain,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            ClipsDescendants = true
        })

        local playBtn = Lib.Create("TextButton", {
            Parent = item,
            Size = UDim2.new(0, 55, 0, 22),
            Position = UDim2.new(1, -65, 0.5, -11),
            BackgroundColor3 = Colors.Active,
            Text = "Вкл",
            TextColor3 = Colors.Background,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            BorderSizePixel = 0
        })
        Lib.Create("UICorner", { Parent = playBtn, CornerRadius = UDim.new(0, 4) })

        buttonsList[tostring(song.id)] = playBtn

        playBtn.MouseButton1Click:Connect(function()
            handlePlayClick(tostring(song.id))
        end)
    end

    Lib.createToggle(MiscMenu, "Music Player", 220, false, function(st)
        MusicWin.Visible = st
        if not st then
            stopCurrentSound()
            currentPlayingId = nil
            customPlaying = false
            customPlayBtn.Text = "Вкл"
            customPlayBtn.BackgroundColor3 = Colors.Active
            customPlayBtn.TextColor3 = Colors.Background
            updateAllMusicButtons()
        end
    end)

    local radarDots = {}
    table.insert(UI.Connections, Services.Run.RenderStepped:Connect(function()
        if not radarEnabled then return end
        local myHrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not myHrp then return end
        for _, plr in ipairs(Services.Players:GetPlayers()) do
            if plr ~= LP then
                local char = plr.Character
                if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                    local dot = radarDots[plr]
                    if not dot then
                        dot = Lib.Create("Frame", { Parent = RadarWin, Size = UDim2.new(0, 4, 0, 4), BackgroundColor3 = Color3.fromRGB(255, 80, 80), BorderSizePixel = 0 })
                        Lib.Create("UICorner", { Parent = dot, CornerRadius = UDim.new(1, 0) })
                        radarDots[plr] = dot
                    end
                    local offset = myHrp.CFrame:ToObjectSpace(char.HumanoidRootPart.CFrame).Position
                    local distance = offset.Magnitude
                    local maxDist = 200
                    if distance <= maxDist then
                        local x = (offset.X / maxDist) * 70
                        local z = (offset.Z / maxDist) * 70
                        dot.Position = UDim2.new(0.5, x - 2, 0.5, z - 2)
                        dot.Visible = true
                    else
                        dot.Visible = false
                    end
                else
                    if radarDots[plr] then radarDots[plr].Visible = false end
                end
            end
        end
    end))

    task.spawn(function()
        while task.wait(0.5) do
            for _, plr in pairs(Services.Players:GetPlayers()) do
                if plr ~= LP then
                    if itemESP then
                        for _, obj in pairs(workspace:GetDescendants()) do
                            if (obj:IsA("Tool") or obj.Name:lower():find("gun") or obj.Name:lower():find("key")) and not obj:FindFirstChild("ItemESP") then
                                local part = obj:FindFirstChildWhichIsA("BasePart")
                                if part then
                                    local bb = Lib.Create("BillboardGui", { Parent = obj, Name = "ItemESP", Size = UDim2.new(0, 100, 0, 30), AlwaysOnTop = true, Adornee = part })
                                    local txt = Lib.Create("TextLabel", { Parent = bb, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = obj.Name, TextScaled = true, TextColor3 = Colors.Active, Font = Enum.Font.GothamBold })
                                end
                            end
                        end
                    end
                    local char = plr.Character
                    if char and char:FindFirstChild("Head") and char:FindFirstChild("HumanoidRootPart") then
                        if nameESP then
                            local gui = char.Head:FindFirstChild("ESP") or Lib.Create("BillboardGui", { Parent = char.Head, Name = "ESP", Size = UDim2.new(0, 100, 0, 40), AlwaysOnTop = true, StudsOffset = Vector3.new(0, 2, 0), Adornee = char.Head })
                            local txt = gui:FindFirstChild("TXT") or Lib.Create("TextLabel", { Parent = gui, Name = "TXT", Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextColor3 = Colors.Active, TextStrokeTransparency = 0, Font = Enum.Font.GothamBold, TextScaled = true })
                            if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                                txt.Text = plr.Name .. "\n" .. math.floor((LP.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude) .. "m"
                            end
                        else
                            if char.Head:FindFirstChild("ESP") then char.Head.ESP:Destroy() end
                        end
                        if outlineESP then
                            if not char:FindFirstChild("ESPHighlight") then
                                local hl = Lib.Create("Highlight", { Parent = char, Name = "ESPHighlight", FillColor = Colors.Active, FillTransparency = 0.7, OutlineColor = Colors.Active, DepthMode = Enum.HighlightDepthMode.AlwaysOnTop })
                            end
                        else
                            if char:FindFirstChild("ESPHighlight") then char.ESPHighlight:Destroy() end
                        end
                    end
                end
            end
        end
    end)

    table.insert(UI.Connections, Services.Run.RenderStepped:Connect(function()
        for _, plr in ipairs(Services.Players:GetPlayers()) do
            if plr ~= LP then
                if not _G.pDrawings[plr] then
                    _G.pDrawings[plr] = { box = Drawing.new("Square"), tracer = Drawing.new("Line") }
                    _G.pDrawings[plr].box.Color = Colors.Active; _G.pDrawings[plr].box.Thickness = 1.5; _G.pDrawings[plr].box.Filled = false
                    _G.pDrawings[plr].tracer.Color = Colors.Active; _G.pDrawings[plr].tracer.Thickness = 1.5
                end
                local d = _G.pDrawings[plr]
                local char = plr.Character
                if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                    local hrp = char.HumanoidRootPart
                    local pos, vis = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
                    if vis then
                        if boxESP then
                            local head = char:FindFirstChild("Head")
                            if head then
                                local headPos = workspace.CurrentCamera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                                local legPos = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                                local height = math.abs(headPos.Y - legPos.Y)
                                local width = height / 2
                                d.box.Size = Vector2.new(width, height)
                                d.box.Position = Vector2.new(pos.X - width / 2, headPos.Y)
                                d.box.Visible = true
                            else d.box.Visible = false end
                        else d.box.Visible = false end

                        if tracersESP then
                            d.tracer.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
                            d.tracer.To = Vector2.new(pos.X, pos.Y)
                            d.tracer.Visible = true
                        else d.tracer.Visible = false end
                    else
                        d.box.Visible = false; d.tracer.Visible = false
                    end
                else
                    d.box.Visible = false; d.tracer.Visible = false
                end
            end
        end
    end))
end

do
    local origLighting = {
        Ambient = Services.Lighting.Ambient,
        OutdoorAmbient = Services.Lighting.OutdoorAmbient,
        ClockTime = Services.Lighting.ClockTime,
        FogEnd = Services.Lighting.FogEnd,
        FogStart = Services.Lighting.FogStart,
        FogColor = Services.Lighting.FogColor
    }

    local retroEnabled = false
    local ccEffect = Instance.new("ColorCorrectionEffect")
    ccEffect.Name = "RetroCC"; ccEffect.Brightness = 0.1; ccEffect.Contrast = 0.5; ccEffect.Saturation = -0.4; ccEffect.TintColor = Color3.fromRGB(255, 230, 200)

    Lib.createToggle(UI.Pages.Shaders, "Retro Game", 10, false, function(st)
        retroEnabled = st
        ccEffect.Parent = st and Services.Lighting or nil
    end)

    local rtxEnabled = false
    
    local RtxFolder = Instance.new("Folder")
    RtxFolder.Name = "RTXShaders"

    local rCC = Instance.new("ColorCorrectionEffect", RtxFolder)
    rCC.Contrast = 0.35
    rCC.Saturation = 0.45
    rCC.Brightness = 0.05
    rCC.TintColor = Color3.fromRGB(255, 255, 255)

    local rBloom = Instance.new("BloomEffect", RtxFolder)
    rBloom.Intensity = 0.45
    rBloom.Size = 12
    rBloom.Threshold = 0.85

    local rDof = Instance.new("DepthOfFieldEffect", RtxFolder)
    rDof.FocusDistance = 25
    rDof.InFocusRadius = 50
    rDof.NearIntensity = 0
    rDof.FarIntensity = 0.15

    local rAtmosphere = Instance.new("Atmosphere", RtxFolder)
    rAtmosphere.Density = 0.2
    rAtmosphere.Color = Color3.fromRGB(190, 210, 230)
    rAtmosphere.Glare = 0.3
    rAtmosphere.Haze = 0.5

    local rSun = Instance.new("SunRaysEffect", RtxFolder)
    rSun.Intensity = 0.08

    local origRtxLighting = {}

    Lib.createToggle(UI.Pages.Shaders, "RTX / Vibrant", 55, false, function(st)
        rtxEnabled = st
        local L = Services.Lighting
        RtxFolder.Parent = st and L or nil
        
        if st then

            origRtxLighting.Ambient = L.Ambient
            origRtxLighting.OutdoorAmbient = L.OutdoorAmbient
            origRtxLighting.Brightness = L.Brightness
            
            L.Brightness = 2.2
            L.Ambient = Color3.fromRGB(75, 80, 90)
            L.OutdoorAmbient = Color3.fromRGB(145, 165, 185)
        else

            if origRtxLighting.Brightness then
                L.Brightness = origRtxLighting.Brightness
                L.Ambient = origRtxLighting.Ambient
                L.OutdoorAmbient = origRtxLighting.OutdoorAmbient
            end
        end
    end)
    
    local cyberEnabled = false
    local CyberFolder = Instance.new("Folder")
    CyberFolder.Name = "CyberShaders"

    local cCC = Instance.new("ColorCorrectionEffect", CyberFolder)
    cCC.Contrast = 0.45
    cCC.Saturation = 0.85
    cCC.TintColor = Color3.fromRGB(255, 180, 255)
    
    local cBloom = Instance.new("BloomEffect", CyberFolder)
    cBloom.Intensity = 1.8
    cBloom.Size = 30
    cBloom.Threshold = 0.1
    
    local cAtmosphere = Instance.new("Atmosphere", CyberFolder)
    cAtmosphere.Density = 0.35
    cAtmosphere.Offset = 0.25
    cAtmosphere.Color = Color3.fromRGB(15, 10, 30)
    cAtmosphere.Decay = Color3.fromRGB(255, 0, 128)
    
    local cyberConn = nil
    local origCyberLighting = {}

    Lib.createToggle(UI.Pages.Shaders, "Cyberpunk Neon", 100, false, function(st)
        cyberEnabled = st
        CyberFolder.Parent = st and Services.Lighting or nil
        local L = Services.Lighting
        if st then

            origCyberLighting.Ambient = L.Ambient
            origCyberLighting.OutdoorAmbient = L.OutdoorAmbient
            origCyberLighting.ColorShift_Top = L.ColorShift_Top
            origCyberLighting.ClockTime = L.ClockTime
            
            L.Ambient = Color3.fromRGB(35, 15, 60)
            L.OutdoorAmbient = Color3.fromRGB(10, 25, 45)
            L.ColorShift_Top = Color3.fromRGB(255, 0, 128)
            
            cyberConn = Services.Run.RenderStepped:Connect(function() 
                L.ClockTime = 0 
            end)
        else
            if cyberConn then cyberConn:Disconnect(); cyberConn = nil end

            if origCyberLighting.ClockTime then
                L.Ambient = origCyberLighting.Ambient
                L.OutdoorAmbient = origCyberLighting.OutdoorAmbient
                L.ColorShift_Top = origCyberLighting.ColorShift_Top
                L.ClockTime = origCyberLighting.ClockTime
            end
        end
    end)

    local silentEnabled = false
    local SilentFolder = Instance.new("Folder")
    SilentFolder.Name = "SilentShaders"
    local sCC = Instance.new("ColorCorrectionEffect", SilentFolder); sCC.Contrast = 0.1; sCC.Saturation = -0.8; sCC.TintColor = Color3.fromRGB(200, 200, 200)
    Instance.new("BlurEffect", SilentFolder).Size = 4

    Lib.createToggle(UI.Pages.Shaders, "Silent Hill", 145, false, function(st)
        silentEnabled = st
        SilentFolder.Parent = st and Services.Lighting or nil
        local L = Services.Lighting
        if st then
            L.FogColor = Color3.fromRGB(150, 150, 150); L.FogEnd = 150; L.FogStart = 0; L.ClockTime = 18
        else
            L.FogColor = origLighting.FogColor; L.FogEnd = origLighting.FogEnd; L.FogStart = origLighting.FogStart; L.ClockTime = origLighting.ClockTime
        end
    end)

    local friedEnabled = false
    local fCC = Instance.new("ColorCorrectionEffect")
    fCC.Name = "Fried_CC"; fCC.Brightness = 0.2; fCC.Contrast = 2.0; fCC.Saturation = 2.0; fCC.TintColor = Color3.fromRGB(255, 150, 50)

    Lib.createToggle(UI.Pages.Shaders, "Deep Fried", 190, false, function(st)
        friedEnabled = st
        fCC.Parent = st and Services.Lighting or nil
    end)

    local nvEnabled = false
    local NVFolder = Instance.new("Folder")
    NVFolder.Name = "NightVisionShaders"
    local nvCC = Instance.new("ColorCorrectionEffect", NVFolder); nvCC.Brightness = 0.3; nvCC.Contrast = 0.5; nvCC.Saturation = -0.5; nvCC.TintColor = Color3.fromRGB(50, 255, 50)
    Instance.new("BloomEffect", NVFolder).Intensity = 0.5

    Lib.createToggle(UI.Pages.Shaders, "Night Vision", 235, false, function(st)
        nvEnabled = st
        NVFolder.Parent = st and Services.Lighting or nil
        local L = Services.Lighting
        if st then
            L.Ambient = Color3.fromRGB(50, 255, 50); L.OutdoorAmbient = Color3.fromRGB(50, 255, 50)
        else
            L.Ambient = origLighting.Ambient; L.OutdoorAmbient = origLighting.OutdoorAmbient
        end
    end)
end

do
    local antiFling, antiSit, antiVoid, antiStun, antiRagdoll = false, false, false, false, false
    Lib.createToggle(UI.Pages.Protect, "Anti Fling", 10, false, function(st) antiFling = st end)
    Lib.createToggle(UI.Pages.Protect, "Anti Sit", 55, false, function(st) antiSit = st end)
    Lib.createToggle(UI.Pages.Protect, "Anti void", 100, false, function(st) antiVoid = st end)
    Lib.createToggle(UI.Pages.Protect, "Anti Stun", 145, false, function(st) antiStun = st end)
    Lib.createToggle(UI.Pages.Protect, "Anti Ragdoll", 190, false, function(st) antiRagdoll = st end)

    table.insert(UI.Connections, Services.Run.Stepped:Connect(function()
        if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") and LP.Character:FindFirstChild("Humanoid") then
            local hrp = LP.Character.HumanoidRootPart
            local hum = LP.Character.Humanoid
            if antiFling then
                for _, plr in ipairs(Services.Players:GetPlayers()) do
                    if plr ~= LP and plr.Character then
                        for _, p in ipairs(plr.Character:GetDescendants()) do
                            if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
                        end
                    end
                end
            end
            if antiSit and hum.Sit then
                hum.Sit = false; hum.Jump = true
            end
            if antiVoid and hrp.Position.Y < (workspace.FallenPartsDestroyHeight + 50) then
                hrp.Velocity = Vector3.new(0, 0, 0)
                hrp.CFrame = hrp.CFrame + Vector3.new(0, 250, 0)
            end
            if antiStun then
                if hum.PlatformStand then hum.PlatformStand = false end
                hum:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, false)
            end
            if antiRagdoll then
                local state = hum:GetState()
                if state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown or state == Enum.HumanoidStateType.Physics then
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                end
            end
        end
    end))
end

do
    local DiffBtn, DiffArrow = Lib.createMenuBtn(UI.Pages.Misc, "Different", 10, true)
    local DiffMenu = Lib.Create("Frame", {
        Parent = UI.Pages.Misc,
        Size = UDim2.new(1, -6, 0, 0),
        Position = UDim2.new(0, 3, 0, 50),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Visible = false
    })
    local diffLayout = Lib.Create("UIListLayout", { Parent = DiffMenu, Padding = UDim.new(0, 4) })

    local OtherBtn, OtherArrow = Lib.createMenuBtn(UI.Pages.Misc, "Other", 55, true)
    local OtherMenu = Lib.Create("Frame", {
        Parent = UI.Pages.Misc,
        Size = UDim2.new(1, -6, 0, 0),
        Position = UDim2.new(0, 3, 0, 95),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Visible = false
    })
    local otherLayout = Lib.Create("UIListLayout", { Parent = OtherMenu, Padding = UDim.new(0, 4) })

    local diffOpened, otherOpened = false, false
    local function updateMiscPositions()
        local diffHeight = diffOpened and 520 or 0
        Services.TS:Create(OtherBtn, TWEEN_INFO_FAST, {Position = UDim2.new(0, 3, 0, 55 + diffHeight)}):Play()
        Services.TS:Create(OtherMenu, TWEEN_INFO_FAST, {Position = UDim2.new(0, 3, 0, 95 + diffHeight)}):Play()
    end

    DiffBtn.MouseButton1Click:Connect(function()
        diffOpened = not diffOpened
        DiffMenu.Visible = true
        Services.TS:Create(DiffArrow, TWEEN_INFO_FAST, {Rotation = diffOpened and 180 or 0}):Play()
        local t = Services.TS:Create(DiffMenu, TWEEN_INFO_FAST, {Size = UDim2.new(1, -6, 0, diffOpened and 520 or 0)})
        t:Play(); t.Completed:Wait(); updateMiscPositions()
    end)

    OtherBtn.MouseButton1Click:Connect(function()
        otherOpened = not otherOpened
        OtherMenu.Visible = true
        Services.TS:Create(OtherArrow, TWEEN_INFO_FAST, {Rotation = otherOpened and 180 or 0}):Play()
        local t = Services.TS:Create(OtherMenu, TWEEN_INFO_FAST, {Size = UDim2.new(1, -6, 0, otherOpened and 88 or 0)})
        t:Play(); t.Completed:Wait(); updateMiscPositions()
    end)

    local antiAfkEnabled = false
    Lib.createToggle(DiffMenu, "Anti-AFK", 0, false, function(st) antiAfkEnabled = st end)
    table.insert(UI.Connections, LP.Idled:Connect(function()
        if antiAfkEnabled then
            Services.VU:CaptureController()
            Services.VU:ClickButton2(Vector2.new())
        end
    end))

    local noclipEnabled = false
    Lib.createToggle(DiffMenu, "Noclip", 44, false, function(st) noclipEnabled = st end)
    table.insert(UI.Connections, Services.Run.Stepped:Connect(function()
        if noclipEnabled and LP.Character then
            for _, part in pairs(LP.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end))

    local autoReconEnabled = false
    Lib.createToggle(DiffMenu, "Auto Reconnect", 88, false, function(st) autoReconEnabled = st end)
    table.insert(UI.Connections, game:GetService("GuiService").ErrorMessageChanged:Connect(function()
        if autoReconEnabled then
            task.wait(0.5)
            Services.TP:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
        end
    end))

    local freeCamEnabled = false
    local cam = workspace.CurrentCamera
    local fcSpeed = 2
    local fcKeys = {W = false, A = false, S = false, D = false, Space = false, LeftShift = false}

    Lib.createToggle(DiffMenu, "Free camera", 132, false, function(st)
        freeCamEnabled = st
        if st then
            cam.CameraType = Enum.CameraType.Scriptable
            if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                LP.Character.HumanoidRootPart.Anchored = true
            end
        else
            cam.CameraType = Enum.CameraType.Custom
            if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                LP.Character.HumanoidRootPart.Anchored = false
            end
        end
    end)

    table.insert(UI.Connections, Services.UIS.InputBegan:Connect(function(i, g)
        if not g then
            if i.KeyCode == Enum.KeyCode.W then fcKeys.W = true
            elseif i.KeyCode == Enum.KeyCode.A then fcKeys.A = true
            elseif i.KeyCode == Enum.KeyCode.S then fcKeys.S = true
            elseif i.KeyCode == Enum.KeyCode.D then fcKeys.D = true
            elseif i.KeyCode == Enum.KeyCode.Space then fcKeys.Space = true
            elseif i.KeyCode == Enum.KeyCode.LeftShift then fcKeys.LeftShift = true
            end
        end
    end))

    table.insert(UI.Connections, Services.UIS.InputEnded:Connect(function(i)
        if i.KeyCode == Enum.KeyCode.W then fcKeys.W = false
        elseif i.KeyCode == Enum.KeyCode.A then fcKeys.A = false
        elseif i.KeyCode == Enum.KeyCode.S then fcKeys.S = false
        elseif i.KeyCode == Enum.KeyCode.D then fcKeys.D = false
        elseif i.KeyCode == Enum.KeyCode.Space then fcKeys.Space = false
        elseif i.KeyCode == Enum.KeyCode.LeftShift then fcKeys.LeftShift = false
        end
    end))

    table.insert(UI.Connections, Services.Run.RenderStepped:Connect(function()
        if freeCamEnabled then
            local v = Vector3.new()
            if fcKeys.W then v = v + Vector3.new(0, 0, -1) end
            if fcKeys.S then v = v + Vector3.new(0, 0, 1) end
            if fcKeys.A then v = v + Vector3.new(-1, 0, 0) end
            if fcKeys.D then v = v + Vector3.new(1, 0, 0) end
            if fcKeys.Space then v = v + Vector3.new(0, 1, 0) end
            if fcKeys.LeftShift then v = v + Vector3.new(0, -1, 0) end
            cam.CFrame = cam.CFrame * CFrame.new(v * fcSpeed)
        end
    end))

    local invisEnabled = false
    local originalPart0 = nil
    local originalPart1 = nil
    local rootJoint = nil

    Lib.createToggle(DiffMenu, "Invisibility", 176, false, function(st)
        invisEnabled = st
        local char = LP.Character
        if not char then return end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then 
            Lib.showNotification("HumanoidRootPart не найден!")
            return 
        end
        
        rootJoint = hrp:FindFirstChild("RootJoint") or char:FindFirstChild("RootJoint", true)
        if not rootJoint then
            Lib.showNotification("RootJoint не найден!")
            return
        end

        if st then
            originalPart0 = rootJoint.Part0
            originalPart1 = rootJoint.Part1
            rootJoint.Part0 = nil
            
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                    v.Transparency = 0.5
                elseif v:IsA("Decal") then
                    v.Transparency = 0.5
                end
            end
            Lib.showNotification("FE Invisibility включен! Ваш торс остался на месте для других.")
        else
            if rootJoint and originalPart0 then
                rootJoint.Part0 = originalPart0
                if originalPart1 then rootJoint.Part1 = originalPart1 end
            end

            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                    v.Transparency = 0
                elseif v:IsA("Decal") then
                    v.Transparency = 0
                end
            end
            rootJoint = nil
            originalPart0 = nil
            originalPart1 = nil
            Lib.showNotification("FE Invisibility выключен.")
        end
    end)

    local cinematicEnabled = false
    local cinemCam = workspace.CurrentCamera
    local PlayerModule = require(LP.PlayerScripts:WaitForChild("PlayerModule"))
    local ControlsClass = PlayerModule:GetControls()
    local cinemPart = nil
    local oldMinZoom, oldMaxZoom = 0.5, 400

    Lib.createToggle(DiffMenu, "Cinematic Mode", 220, false, function(st)
        cinematicEnabled = st
        pcall(function() game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All, not st) end)
        for _, gui in pairs(LP.PlayerGui:GetChildren()) do
            if gui ~= UI.Screen and gui:IsA("ScreenGui") then
                gui.Enabled = not st
            end
        end

        if st then
            if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                LP.Character.HumanoidRootPart.Anchored = true
            end
            oldMinZoom = LP.CameraMinZoomDistance
            oldMaxZoom = LP.CameraMaxZoomDistance

            cinemPart = Instance.new("Part")
            cinemPart.Name = "CinemPart"
            cinemPart.Transparency = 1
            cinemPart.Anchored = true
            cinemPart.CanCollide = false
            cinemPart.CFrame = cinemCam.CFrame
            cinemPart.Parent = workspace

            cinemCam.CameraSubject = cinemPart
            LP.CameraMinZoomDistance = 0.5
            LP.CameraMaxZoomDistance = 0.5
        else
            if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                LP.Character.HumanoidRootPart.Anchored = false
                if LP.Character:FindFirstChild("Humanoid") then
                    cinemCam.CameraSubject = LP.Character.Humanoid
                end
            end
            if cinemPart then cinemPart:Destroy() end
            LP.CameraMinZoomDistance = oldMinZoom
            LP.CameraMaxZoomDistance = oldMaxZoom
        end
    end)

    table.insert(UI.Connections, Services.Run.RenderStepped:Connect(function()
        if cinematicEnabled and cinemPart then
            local moveVector = ControlsClass:GetMoveVector()
            local lookVector = cinemCam.CFrame.LookVector
            local rightVector = cinemCam.CFrame.RightVector
            local moveDir = (lookVector * moveVector.Z * -1) + (rightVector * moveVector.X)
            cinemPart.CFrame = cinemPart.CFrame + (moveDir * 1.5)
        end
    end))

    Lib.createToggle(DiffMenu, "BunnyHop", 264, false, function(st)
        _G.BhopEnabled = st
    end)

    local bhSettingsCard = Lib.CreateStyledCard(DiffMenu, 40)
    bhSettingsCard.Position = UDim2.new(0, 0, 0, 308)
    local bhSettingsLbl = Lib.Create("TextLabel", {
        Parent = bhSettingsCard,
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = "BunnyHop Settings",
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    local bhOpenBtn = Lib.Create("TextButton", {
        Parent = bhSettingsCard,
        Size = UDim2.new(0, 60, 0, 24),
        Position = UDim2.new(1, -72, 0.5, -12),
        BackgroundColor3 = Colors.Active,
        Text = "Open",
        TextColor3 = Colors.Background,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        BorderSizePixel = 0
    })
    Lib.Create("UICorner", { Parent = bhOpenBtn, CornerRadius = UDim.new(0, 4) })

    _G.BhopEnabled = false
    _G.BhopAutoJump = true
    _G.BhopAirStrafe = true
    _G.BhopMaxSpeed = 100
    _G.BhopRealistic = false

    local BhopWin, BhopClose, BhopScroll, BhopLayout, BhopActionBtn, BhopActionLbl = Lib.createFloatingMenu("BunnyHop Settings", 280, 280)
    BhopActionBtn.Visible = false
    BhopActionLbl.Visible = false
    BhopScroll.Size = UDim2.new(1, -20, 1, -48)

    Lib.createToggle(BhopScroll, "Auto Jump", 0, _G.BhopAutoJump, function(st)
        _G.BhopAutoJump = st
    end)

    Lib.createToggle(BhopScroll, "Air Strafe", 0, _G.BhopAirStrafe, function(st)
        _G.BhopAirStrafe = st
    end)

    Lib.createSlider(BhopScroll, 0, "Max Speed", 16, 300, _G.BhopMaxSpeed, function(val)
        _G.BhopMaxSpeed = val
    end)

    Lib.createToggle(BhopScroll, "Realistic Bhop", 0, _G.BhopRealistic, function(st)
        _G.BhopRealistic = st
    end)

    bhOpenBtn.MouseButton1Click:Connect(function()
        BhopWin.Visible = not BhopWin.Visible
    end)
    BhopClose.MouseButton1Click:Connect(function()
        BhopWin.Visible = false
    end)

    local wasBhopEnabled = false
    local lastOnGround = true
    local speedAccumulator = 16
    local hasJumpedThisLanding = false

    local bhopConnection = Services.Run.Heartbeat:Connect(function(dt)
        if not _G.BhopEnabled then
            if wasBhopEnabled then
                wasBhopEnabled = false
                local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.WalkSpeed = _G.ConfigState["Speed"] or 16
                end
            end
            return
        end
        wasBhopEnabled = true

        local char = LP.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum or hum.Health <= 0 then return end

        local onGround = (hum.FloorMaterial ~= Enum.Material.Air)
        local wishDir = hum.MoveDirection
        local currentVel = root.Velocity
        local horizontalVel = Vector3.new(currentVel.X, 0, currentVel.Z)
        local speed = horizontalVel.Magnitude

        local spaceHeld = Services.UIS:IsKeyDown(Enum.KeyCode.Space)
        if _G.BhopAutoJump and spaceHeld then
            if onGround and not hasJumpedThisLanding then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                hasJumpedThisLanding = true
            end
        end
        if not onGround then
            hasJumpedThisLanding = false
        end

        local maxSpeed = _G.BhopMaxSpeed or 100
        local baseWalkSpeed = _G.ConfigState["Speed"] or 16

        if onGround then
            if not lastOnGround then
                if spaceHeld and _G.BhopEnabled then
                    if not _G.BhopRealistic then
                        local boost = 3
                        speedAccumulator = math.min(speedAccumulator + boost, maxSpeed)
                        local dir = wishDir.Magnitude > 0 and wishDir.Unit or (horizontalVel.Magnitude > 0 and horizontalVel.Unit or root.CFrame.LookVector)
                        horizontalVel = dir * speedAccumulator
                        root.Velocity = Vector3.new(horizontalVel.X, root.Velocity.Y, horizontalVel.Z)
                    else
                        speedAccumulator = math.min(speed, maxSpeed)
                    end
                else
                    speedAccumulator = baseWalkSpeed
                end
            else
                if wishDir.Magnitude > 0 then
                    speedAccumulator = math.max(baseWalkSpeed, speed)
                else
                    speedAccumulator = baseWalkSpeed
                end
            end
        else
            if wishDir.Magnitude > 0 then
                wishDir = wishDir.Unit
                if _G.BhopAirStrafe then
                    if _G.BhopRealistic then
                        local airAccelerate = 150 
                        local wishspeed = 30 
                        local currentspeed = horizontalVel:Dot(wishDir)
                        local addspeed = wishspeed - currentspeed
                        if addspeed > 0 then
                            local accelspeed = math.min(airAccelerate * wishspeed * dt, addspeed)
                            horizontalVel = horizontalVel + wishDir * accelspeed
                        end
                        if horizontalVel.Magnitude > maxSpeed then
                            horizontalVel = horizontalVel.Unit * maxSpeed
                        end
                        root.Velocity = Vector3.new(horizontalVel.X, root.Velocity.Y, horizontalVel.Z)
                    else
                        local accel = 4 * dt
                        local targetVel = wishDir * math.max(speed, baseWalkSpeed)
                        horizontalVel = horizontalVel:Lerp(targetVel, accel)
                        if horizontalVel.Magnitude > maxSpeed then
                            horizontalVel = horizontalVel.Unit * maxSpeed
                        end
                        root.Velocity = Vector3.new(horizontalVel.X, root.Velocity.Y, horizontalVel.Z)
                    end
                end
            end
        end

        if _G.BhopEnabled then
            local activeSpeed = math.max(baseWalkSpeed, horizontalVel.Magnitude)
            hum.WalkSpeed = math.min(activeSpeed, maxSpeed)
        end

        lastOnGround = onGround
    end)
    table.insert(UI.Connections, bhopConnection)

    Lib.createSlider(DiffMenu, 352, "FOV Changer", 30, 120, 70, function(v)
        pcall(function()
            workspace.CurrentCamera.FieldOfView = v
        end)
    end)

    local hitboxSize = 10
    local hitboxEnabled = false

    Lib.createToggle(DiffMenu, "Hitbox Expander", 412, false, function(st)
        hitboxEnabled = st
    end)

    Lib.createSlider(DiffMenu, 457, "Hitbox Size", 2, 50, 10, function(v)
        hitboxSize = v
    end)

    task.spawn(function()
        while task.wait(0.5) do
            if hitboxEnabled then
                for _, plr in ipairs(Services.Players:GetPlayers()) do
                    if plr ~= LP and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = plr.Character.HumanoidRootPart
                        hrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                        hrp.Transparency = 0.7
                        hrp.BrickColor = BrickColor.new("Really blue")
                        hrp.Material = Enum.Material.Neon
                        hrp.CanCollide = false
                    end
                end
            else
                for _, plr in ipairs(Services.Players:GetPlayers()) do
                    if plr ~= LP and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = plr.Character.HumanoidRootPart
                        if hrp.Size ~= Vector3.new(2, 2, 1) then
                            hrp.Size = Vector3.new(2, 2, 1)
                            hrp.Transparency = 1
                            hrp.CanCollide = true
                        end
                    end
                end
            end
        end
    end)

    local ConsoleWin = Lib.Create("Frame", { Parent = UI.Screen, Size = UDim2.new(0, 440, 0, 240), Position = UDim2.new(0.5, -220, 0.5, -120), BackgroundColor3 = Colors.Background, BorderSizePixel = 0, Visible = false, ClipsDescendants = true })
    Lib.Create("UICorner", { Parent = ConsoleWin, CornerRadius = UDim.new(0, 8) })
    Lib.Create("UIStroke", { Parent = ConsoleWin, Color = Colors.Border, Thickness = 1 })
    local conTopBar = Lib.Create("Frame", { Parent = ConsoleWin, Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1 })
    Lib.makeDraggable(ConsoleWin, conTopBar)
    Lib.Create("TextLabel", { Parent = conTopBar, Size = UDim2.new(0.6, 0, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, Text = "Developer Console", TextColor3 = Colors.TextMain, Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left })
    local conCloseBtn = Lib.Create("TextButton", { Parent = conTopBar, Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, -30, 0.5, -12), BackgroundTransparency = 1, Text = "×", TextColor3 = Colors.TextDim, Font = Enum.Font.GothamMedium, TextSize = 18 })

    local conScroll = Lib.Create("ScrollingFrame", { Parent = ConsoleWin, Size = UDim2.new(1, -24, 1, -48), Position = UDim2.new(0, 12, 0, 38), BackgroundTransparency = 1, ScrollBarThickness = 2, ScrollBarImageColor3 = Colors.Border, BorderSizePixel = 0 })
    local conLayout = Lib.Create("UIListLayout", { Parent = conScroll, Padding = UDim.new(0, 2) })
    conLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() conScroll.CanvasSize = UDim2.new(0, 0, 0, conLayout.AbsoluteContentSize.Y + 10) end)

    local function addConsoleLine(msg, msgType)
        local lbl = Lib.Create("TextLabel", { Parent = conScroll, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Text = msg, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.Gotham, TextSize = 11 })
        if msgType == Enum.MessageType.MessageError then lbl.TextColor3 = Color3.fromRGB(255, 80, 80)
        elseif msgType == Enum.MessageType.MessageWarning then lbl.TextColor3 = Color3.fromRGB(255, 200, 80)
        elseif msgType == Enum.MessageType.MessageInfo then lbl.TextColor3 = Color3.fromRGB(150, 200, 255)
        else lbl.TextColor3 = Colors.TextMain end
        task.wait()
        conScroll.CanvasPosition = Vector2.new(0, conScroll.CanvasSize.Y.Offset)
    end
    table.insert(UI.Connections, Services.Log.MessageOut:Connect(addConsoleLine))
    for _, log in ipairs(Services.Log:GetLogHistory()) do addConsoleLine(log.message, log.messageType) end

    local consoleTog, _, setConsoleState = Lib.createToggle(OtherMenu, "Developer Console", 0, false, function(st) ConsoleWin.Visible = st end)
    conCloseBtn.MouseButton1Click:Connect(function() setConsoleState(false, true); ConsoleWin.Visible = false end)

    local spyEnabled = false
    local spyTog, _, setSpyState = Lib.createToggle(OtherMenu, "Remote Spy", 44, false, function(st)
        spyEnabled = st
        if st then
            loadstring(game:HttpGet("https://raw.githubusercontent.com/CherryCalCor/BWSPY.Lua/refs/heads/main/Code.Lua"))()
        end
    end)
end

do
    local stalkMenuEnabled = false
    local StalkWin, StalkClose, StalkScroll, StalkLayout, StalkActionBtn, StalkActionLbl = Lib.createFloatingMenu("Stalk Setup", 460, 320)
    
    StalkScroll.Size = UDim2.new(0, 210, 1, -85)
    StalkActionBtn.Position = UDim2.new(0, 10, 1, -40)
    StalkActionBtn.Size = UDim2.new(0, 210, 0, 30)

    local StalkSettings = Lib.Create("Frame", {
        Parent = StalkWin,
        Size = UDim2.new(0, 215, 1, -85),
        Position = UDim2.new(0, 235, 0, 40),
        BackgroundTransparency = 1
    })

    local stalkOffsetX = 0
    local stalkOffsetY = 0
    local stalkOffsetZ = 3
    local stalkNoMovement = false

    Lib.createSlider(StalkSettings, 0, "Offset X", -30, 30, 0, function(v) stalkOffsetX = v end)
    Lib.createSlider(StalkSettings, 60, "Offset Y", -30, 30, 0, function(v) stalkOffsetY = v end)
    Lib.createSlider(StalkSettings, 120, "Offset Z", -30, 30, 3, function(v) stalkOffsetZ = v end)
    Lib.createToggle(StalkSettings, "Disable Movement", 180, false, function(st) stalkNoMovement = st end)

    local currentStalkTarget = nil
    local stalking = false
    local stalkTarget = nil
    local stalkConnection = nil

    local function StartStalk(targetPlayer)
        if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
        local myChar = LP.Character
        if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
        stalking = true; stalkTarget = targetPlayer
        myChar.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(stalkOffsetX, stalkOffsetY, stalkOffsetZ)

        if stalkConnection then stalkConnection:Disconnect() end
        stalkConnection = Services.Run.RenderStepped:Connect(function()
            if not stalking or not stalkTarget then return end
            local targetChar = stalkTarget.Character
            local myCharacter = LP.Character
            if targetChar and myCharacter and targetChar:FindFirstChild("HumanoidRootPart") and myCharacter:FindFirstChild("HumanoidRootPart") then
                myCharacter.HumanoidRootPart.CFrame = targetChar.HumanoidRootPart.CFrame * CFrame.new(stalkOffsetX, stalkOffsetY, stalkOffsetZ)
                
                if stalkNoMovement then
                    myCharacter.HumanoidRootPart.Anchored = true
                else
                    myCharacter.HumanoidRootPart.Anchored = false
                end

                if targetChar:FindFirstChild("Humanoid") then 
                    workspace.CurrentCamera.CameraSubject = targetChar.Humanoid 
                end
            end
        end)
        table.insert(UI.Connections, stalkConnection)
    end

    local function StopStalk()
        stalking = false; stalkTarget = nil
        if stalkConnection then stalkConnection:Disconnect(); stalkConnection = nil end
        if LP.Character then
            local hum = LP.Character:FindFirstChildOfClass("Humanoid")
            local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
            if hum then workspace.CurrentCamera.CameraSubject = hum end
            if hrp then hrp.Anchored = false end
        end
    end

    Lib.createToggle(UI.Pages.Funny, "Stalk Mode", 10, false, function(st)
        stalkMenuEnabled = st
        StalkWin.Visible = st
        if st then
            Lib.populatePlayers(StalkScroll, StalkLayout, StalkActionLbl, "Stalk", function(p) currentStalkTarget = p end)
        else
            StopStalk(); StalkActionLbl.Text = "Stalk: [None]"
        end
    end)

    StalkClose.MouseButton1Click:Connect(function() 
        StalkWin.Visible = false 
        StopStalk() 
        StalkActionLbl.Text = "Stalk: [None]" 
    end)

    StalkActionBtn.MouseButton1Click:Connect(function()
        if not currentStalkTarget then return end
        if stalking and stalkTarget == currentStalkTarget then 
            StopStalk()
            Lib.showNotification("Преследование остановлено")
        else 
            StartStalk(currentStalkTarget)
            Lib.showNotification("Преследование: " .. currentStalkTarget.Name) 
        end
    end)

    local FakeLagBtn, FakeLagArrow = Lib.createMenuBtn(UI.Pages.Funny, "Fake lag", 55, true)
    local FakeLagMenu = Lib.Create("Frame", { Parent = UI.Pages.Funny, Size = UDim2.new(1, -6, 0, 0), Position = UDim2.new(0, 3, 0, 95), BackgroundTransparency = 1, ClipsDescendants = true, Visible = false })
    Lib.Create("UIListLayout", { Parent = FakeLagMenu, Padding = UDim.new(0, 4) })

    local fakeLagOpened = false
    FakeLagBtn.MouseButton1Click:Connect(function()
        fakeLagOpened = not fakeLagOpened
        FakeLagMenu.Visible = true
        Services.TS:Create(FakeLagArrow, TWEEN_INFO_FAST, {Rotation = fakeLagOpened and 180 or 0}):Play()
        Services.TS:Create(FakeLagMenu, TWEEN_INFO_FAST, {Size = fakeLagOpened and UDim2.new(1, -6, 0, 90) or UDim2.new(1, -6, 0, 0)}):Play()
    end)

    local suspEnabled = false
    Lib.createToggle(FakeLagMenu, "Complete suspension", 0, false, function(st)
        suspEnabled = st
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            if st then
                hum.WalkSpeed = 0.5
            else
                hum.WalkSpeed = _G.ConfigState["Speed"] or 16
            end
        end
    end)

    local usualEnabled = false
    Lib.createToggle(FakeLagMenu, "The usual lag", 44, false, function(st)
        usualEnabled = st
        if not st and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then LP.Character.HumanoidRootPart.Anchored = false end
    end)

    task.spawn(function()
        while UI.Screen and UI.Screen.Parent do
            task.wait(math.random(1, 3))
            if usualEnabled and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                LP.Character.HumanoidRootPart.Anchored = true
                task.wait(math.random(1, 3) * 0.5)
                if usualEnabled and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then LP.Character.HumanoidRootPart.Anchored = false end
            end
        end
    end)
end

do
    local ConfigsMenu = Lib.Create("Frame", { Parent = UI.Pages.Config, Size = UDim2.new(1, -6, 0, 0), Position = UDim2.new(0, 3, 0, 50), BackgroundTransparency = 1, ClipsDescendants = true, Visible = false })
    local cfgLayout = Lib.Create("UIListLayout", { Parent = ConfigsMenu, Padding = UDim.new(0, 4) })

    local nameCard = Lib.CreateStyledCard(UI.Pages.Config, 40)
    nameCard.Position = UDim2.new(0, 0, 0, 55)
    local ConfigNameInput = Lib.Create("TextBox", {
        Parent = nameCard,
        Size = UDim2.new(1, -24, 1, -12),
        Position = UDim2.new(0, 12, 0, 6),
        BackgroundColor3 = Colors.ToggleShell,
        BorderSizePixel = 0,
        TextColor3 = Colors.TextMain,
        PlaceholderText = "Enter config name...",
        Font = Enum.Font.Gotham,
        Text = ""
    })
    Lib.Create("UICorner", { Parent = ConfigNameInput, CornerRadius = UDim.new(0, 4) })
    local cInStroke = Lib.Create("UIStroke", { Parent = ConfigNameInput, Color = Colors.Border, Thickness = 1 })

    local SaveConfigBtn = Lib.Create("TextButton", {
        Parent = UI.Pages.Config,
        Size = UDim2.new(1, -6, 0, 32),
        Position = UDim2.new(0, 3, 0, 105),
        BackgroundColor3 = Colors.Surface,
        Text = "Save Config",
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        BorderSizePixel = 0
    })
    Lib.Create("UICorner", { Parent = SaveConfigBtn, CornerRadius = UDim.new(0, 6) })
    local saveStroke = Lib.Create("UIStroke", { Parent = SaveConfigBtn, Color = Colors.Border, Thickness = 1 })

    SaveConfigBtn.MouseEnter:Connect(function() Services.TS:Create(saveStroke, TWEEN_INFO_FAST, {Color = Colors.Active}):Play() end)
    SaveConfigBtn.MouseLeave:Connect(function() Services.TS:Create(saveStroke, TWEEN_INFO_FAST, {Color = Colors.Border}):Play() end)

    local AutoUploadToggleCont = Lib.Create("Frame", { Parent = UI.Pages.Config, Size = UDim2.new(1, 0, 0, 40), Position = UDim2.new(0, 0, 0, 145), BackgroundTransparency = 1 })

    local cfgOpened = false
    local function updateConfigPos()
        local h = cfgOpened and 120 or 0
        Services.TS:Create(nameCard, TWEEN_INFO_FAST, {Position = UDim2.new(0, 0, 0, 55 + h)}):Play()
        Services.TS:Create(SaveConfigBtn, TWEEN_INFO_FAST, {Position = UDim2.new(0, 3, 0, 105 + h)}):Play()
        Services.TS:Create(AutoUploadToggleCont, TWEEN_INFO_FAST, {Position = UDim2.new(0, 0, 0, 145 + h)}):Play()
    end

    local folderName = "SeptusHub_Configs"
    local autoLoadFile = folderName .. "/autoload.txt"
    local selectedConfigToLoad = nil

    pcall(function() if makefolder and not isfolder(folderName) then makefolder(folderName) end end)

    local function refreshConfigs()
        for _, v in pairs(ConfigsMenu:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
        pcall(function()
            if listfiles then
                local files = listfiles(folderName)
                for _, file in ipairs(files) do
                    if file:match("%.json$") then
                        local confName = file:match("([^/\\]+)%.json$") or "Unknown"
                        local btn = Lib.Create("TextButton", {
                            Parent = ConfigsMenu,
                            Size = UDim2.new(1, -4, 0, 26),
                            BackgroundColor3 = Colors.Surface,
                            Text = confName,
                            TextColor3 = Colors.TextDim,
                            Font = Enum.Font.GothamMedium,
                            TextSize = 12,
                            BorderSizePixel = 0
                        })
                        Lib.Create("UICorner", { Parent = btn, CornerRadius = UDim.new(0, 4) })
                        local bStroke = Lib.Create("UIStroke", { Parent = btn, Color = Colors.Border, Thickness = 1 })

                        btn.MouseButton1Click:Connect(function()
                            selectedConfigToLoad = confName
                            Lib.showNotification("Загружен конфиг: " .. confName)
                            local rawData = readfile(file)
                            local decoded = Services.Http:JSONDecode(rawData)
                            if decoded.ThemeC1 and decoded.ThemeC2 then
                                _G.changeTheme(Color3.fromHex(decoded.ThemeC1), Color3.fromHex(decoded.ThemeC2))
                            end
                            if decoded.Settings then
                                for k, v in pairs(decoded.Settings) do
                                    if _G.ConfigUpdaters[k] then _G.ConfigUpdaters[k](v) end
                                end
                            end
                        end)
                    end
                end
            end
        end)
    end

    local ConfigsBtn, ConfigsArrow = Lib.createMenuBtn(UI.Pages.Config, "Configs (Select to load)", 10, true)
    ConfigsBtn.MouseButton1Click:Connect(function()
        cfgOpened = not cfgOpened
        ConfigsMenu.Visible = true
        Services.TS:Create(ConfigsArrow, TWEEN_INFO_FAST, {Rotation = cfgOpened and 180 or 0}):Play()
        local t = Services.TS:Create(ConfigsMenu, TWEEN_INFO_FAST, {Size = UDim2.new(1, -6, 0, cfgOpened and 110 or 0)})
        t:Play(); t.Completed:Wait(); updateConfigPos(); refreshConfigs()
    end)

    SaveConfigBtn.MouseButton1Click:Connect(function()
        local txt = ConfigNameInput.Text
        if txt == "" then txt = "DefaultConfig" end
        pcall(function()
            if writefile then
                local dataToSave = {
                    ThemeC1 = _G.CurrentGradientColors[1]:ToHex(),
                    ThemeC2 = _G.CurrentGradientColors[2]:ToHex(),
                    Settings = _G.ConfigState
                }
                writefile(folderName .. "/" .. txt .. ".json", Services.Http:JSONEncode(dataToSave))
                Lib.showNotification("Конфиг '" .. txt .. "' успешно сохранен!")
                refreshConfigs()
            else Lib.showNotification("Ваш инжектор не поддерживает файлы!") end
        end)
    end)

    local isAutoUpload = false
    pcall(function()
        if isfile and isfile(autoLoadFile) then
            local autoCfg = readfile(autoLoadFile)
            if autoCfg and autoCfg ~= "" then
                isAutoUpload = true; selectedConfigToLoad = autoCfg
                task.spawn(function()
                    task.wait(2)
                    Lib.showNotification("Авто-загрузка конфига: " .. autoCfg)
                    local cpath = folderName .. "/" .. autoCfg .. ".json"
                    if isfile(cpath) then
                        local decoded = Services.Http:JSONDecode(readfile(cpath))
                        if decoded.ThemeC1 and decoded.ThemeC2 then _G.changeTheme(Color3.fromHex(decoded.ThemeC1), Color3.fromHex(decoded.ThemeC2)) end
                        if decoded.Settings then
                            for k, v in pairs(decoded.Settings) do if _G.ConfigUpdaters[k] then _G.ConfigUpdaters[k](v) end end
                        end
                    end
                end)
            end
        end
    end)

    Lib.createToggle(AutoUploadToggleCont, "Auto upload", 0, isAutoUpload, function(st)
        isAutoUpload = st
        pcall(function()
            if isAutoUpload and selectedConfigToLoad then
                if writefile then writefile(autoLoadFile, selectedConfigToLoad) end
                Lib.showNotification("Auto upload установлен на: " .. selectedConfigToLoad)
            else
                if writefile then writefile(autoLoadFile, "") end
                if isfile and isfile(autoLoadFile) and delfile then delfile(autoLoadFile) end
                Lib.showNotification("Auto upload отключен.")
            end
        end)
    end)
end

do
    local bindHeader = Lib.CreateStyledCard(UI.Pages.QoL, 90)
    Lib.Create("UIPadding", { Parent = bindHeader, PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) })

    Lib.Create("TextLabel", {
        Parent = bindHeader,
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = "Custom Keybinds",
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local bindKeyInput = Lib.Create("TextBox", {
        Parent = bindHeader,
        Size = UDim2.new(0, 50, 0, 26),
        Position = UDim2.new(0, 0, 0, 28),
        BackgroundColor3 = Colors.ToggleShell,
        BorderSizePixel = 0,
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        PlaceholderText = "Key"
    })
    Lib.Create("UICorner", { Parent = bindKeyInput, CornerRadius = UDim.new(0, 4) })

    local bindFuncInput = Lib.Create("TextBox", {
        Parent = bindHeader,
        Size = UDim2.new(1, -125, 0, 26),
        Position = UDim2.new(0, 56, 0, 28),
        BackgroundColor3 = Colors.ToggleShell,
        BorderSizePixel = 0,
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        PlaceholderText = "Function Name"
    })
    Lib.Create("UICorner", { Parent = bindFuncInput, CornerRadius = UDim.new(0, 4) })

    local addBind = Lib.Create("TextButton", {
        Parent = bindHeader,
        Size = UDim2.new(0, 60, 0, 26),
        Position = UDim2.new(1, -60, 0, 28),
        BackgroundColor3 = Colors.Active,
        Text = "Add",
        TextColor3 = Colors.Background,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        BorderSizePixel = 0
    })
    Lib.Create("UICorner", { Parent = addBind, CornerRadius = UDim.new(0, 4) })

    addBind.MouseButton1Click:Connect(function()
        local k = bindKeyInput.Text:upper()
        local f = bindFuncInput.Text
        if k ~= "" and f ~= "" then
            _G.UserBinds[k] = f
            Lib.showNotification("Байнд установлен: " .. k .. " -> " .. f)
            bindKeyInput.Text = ""; bindFuncInput.Text = ""
        end
    end)

    table.insert(UI.Connections, Services.UIS.InputBegan:Connect(function(input, processed)
        if processed then return end
        local keyName = input.KeyCode.Name
        if _G.UserBinds[keyName] then
            local fName = _G.UserBinds[keyName]
            local found = false
            for name, updater in pairs(_G.ConfigUpdaters) do
                if name:lower() == fName:lower() then
                    updater(not _G.ConfigState[name])
                    Lib.showNotification(name .. " toggled via Bind!")
                    found = true; break
                end
            end
            if not found then Lib.showNotification("Функция не найдена: " .. fName) end
        end
    end))

    local macroHeader = Lib.CreateStyledCard(UI.Pages.QoL, 90)
    macroHeader.Position = UDim2.new(0, 0, 0, 100)
    Lib.Create("UIPadding", { Parent = macroHeader, PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) })

    Lib.Create("TextLabel", {
        Parent = macroHeader,
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = "Macro Recorder (Movement)",
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local macroFrames = {}
    local isRecording, isPlaying = false, false
    local recConnection, playConnection

    local recBtn = Lib.Create("TextButton", {
        Parent = macroHeader,
        Size = UDim2.new(0.5, -6, 0, 26),
        Position = UDim2.new(0, 0, 0, 28),
        BackgroundColor3 = Color3.fromRGB(200, 80, 80),
        Text = "Start Record",
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        BorderSizePixel = 0
    })
    Lib.Create("UICorner", { Parent = recBtn, CornerRadius = UDim.new(0, 4) })

    local playBtn = Lib.Create("TextButton", {
        Parent = macroHeader,
        Size = UDim2.new(0.5, -6, 0, 26),
        Position = UDim2.new(0.5, 6, 0, 28),
        BackgroundColor3 = Color3.fromRGB(80, 180, 80),
        Text = "Play Macro",
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        BorderSizePixel = 0
    })
    Lib.Create("UICorner", { Parent = playBtn, CornerRadius = UDim.new(0, 4) })

    recBtn.MouseButton1Click:Connect(function()
        if isPlaying then return end
        isRecording = not isRecording
        if isRecording then
            macroFrames = {}
            recBtn.Text = "Stop Record"
            recBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
            Lib.showNotification("Запись макроса началась")
            recConnection = Services.Run.Heartbeat:Connect(function()
                if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                    table.insert(macroFrames, LP.Character.HumanoidRootPart.CFrame)
                end
            end)
        else
            recBtn.Text = "Start Record"
            recBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
            if recConnection then recConnection:Disconnect() end
            Lib.showNotification("Запись сохранена! Фреймов: " .. #macroFrames)
        end
    end)

    local macroLoop = false
    local loopCard, _, setLoop = Lib.createToggle(UI.Pages.QoL, "Loop Macro Playback", 195, false, function(st) macroLoop = st end)

    playBtn.MouseButton1Click:Connect(function()
        if isRecording or #macroFrames == 0 then return end
        isPlaying = not isPlaying
        if isPlaying then
            playBtn.Text = "Stop Playback"
            playBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 40)
            local frameIndex = 1
            playConnection = Services.Run.Heartbeat:Connect(function()
                if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
                LP.Character.HumanoidRootPart.CFrame = macroFrames[frameIndex]
                frameIndex = frameIndex + 1
                if frameIndex > #macroFrames then
                    if macroLoop then 
                        frameIndex = 1 
                    else
                        isPlaying = false
                        playBtn.Text = "Play Macro"
                        playBtn.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
                        playConnection:Disconnect()
                    end
                end
            end)
        else
            playBtn.Text = "Play Macro"
            playBtn.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
            if playConnection then playConnection:Disconnect() end
        end
    end)
end

do
    local function createHelpCard(q, a, btnText, btnLink)
        local card = Lib.CreateStyledCard(UI.Pages.Help, 40)
        card.AutomaticSize = Enum.AutomaticSize.Y
        Lib.Create("UIPadding", { Parent = card, PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) })
        local layout = Lib.Create("UIListLayout", { Parent = card, Padding = UDim.new(0, 6) })

        Lib.Create("TextLabel", {
            Parent = card,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Text = "Q: " .. q,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            TextColor3 = Colors.Active,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        if a ~= "" then
            Lib.Create("TextLabel", {
                Parent = card,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Text = "A: " .. a,
                Font = Enum.Font.Gotham,
                TextSize = 11,
                TextColor3 = Colors.TextMain,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left
            })
        end

        if btnText then
            local b = Lib.Create("TextButton", {
                Parent = card,
                Size = UDim2.new(1, 0, 0, 26),
                BackgroundColor3 = Colors.Surface,
                Text = btnText,
                TextColor3 = Colors.TextMain,
                Font = Enum.Font.GothamBold,
                TextSize = 11,
                BorderSizePixel = 0
            })
            Lib.Create("UICorner", { Parent = b, CornerRadius = UDim.new(0, 4) })
            local bStroke = Lib.Create("UIStroke", { Parent = b, Color = Colors.Border, Thickness = 1 })
            b.MouseEnter:Connect(function() Services.TS:Create(bStroke, TWEEN_INFO_FAST, {Color = Colors.Active}):Play() end)
            b.MouseLeave:Connect(function() Services.TS:Create(bStroke, TWEEN_INFO_FAST, {Color = Colors.Border}):Play() end)

            b.MouseButton1Click:Connect(function()
                pcall(function()
                    if setclipboard then setclipboard(btnLink) elseif toclipboard then toclipboard(btnLink) end
                end)
                Lib.showNotification("Ссылка скопирована!")
            end)
        end
    end

    createHelpCard("Why is the menu taking a long time to load?", "Loading the menu depends on your internet connection.")
    createHelpCard("Why is the mascot not loaded in the notification?", "It also depends on your Internet connection, or on the roblox/injector itself if it does not support image uploading.")
    createHelpCard("Why are the menus lagging/hanging?", "This is also due to the fact that fixes are released daily and because of this we cannot notice all the bugs in the new versions, we continue to work on optimizing the GUI.")
    createHelpCard("Why is there a server List with a single player?", "We are aware of this issue and are already working to fix the situation. Different servers will be displayed soon.")
    createHelpCard("Why aren't the servers displayed?", "If your servers are not displayed, then your injector does not support server loading, this is not a bug!")
    createHelpCard("How do I create my own Notification Mascot?", "Go to the create section on the roblox website, then go to Creations, then go to Decals, click on the plus sign, you will be redirected to the publication menu. You select the image you need, the main thing is that it should be without a background and in PNG format.\nAfter creation, you go to the images section, click on the 3 dots on the desired image, then copy the Asset ID and insert it in the script.")
    createHelpCard("How do I remove the background and make a PNG format?", "Go into any AI and throw him a picture with the following message: Remove the background and make a PNG Format for this picture.")
    createHelpCard("How to contact us?", "So far, not as possible, we will soon create a Telegram channel or a discord channel.")
    createHelpCard("How to bypass the system key from injectors or scripts:", "", "Bypass Bot", "https://telegram.me/OrxBypass_not")
end

do
    local themeMenu = Lib.Create("Frame", { Parent = UI.Pages.Settings, Size = UDim2.new(1, -6, 0, 0), Position = UDim2.new(0, 3, 0, 50), BackgroundTransparency = 1, ClipsDescendants = true, Visible = false })
    local themeLayout = Lib.Create("UIListLayout", { Parent = themeMenu, Padding = UDim.new(0, 4) })

    local function createThemeOption(name, c1, c2)
        local btn = Lib.Create("TextButton", {
            Parent = themeMenu,
            Size = UDim2.new(1, -4, 0, 26),
            BackgroundColor3 = Colors.Surface,
            Text = name,
            TextColor3 = Colors.TextMain,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            BorderSizePixel = 0
        })
        Lib.Create("UICorner", { Parent = btn, CornerRadius = UDim.new(0, 4) })
        local bStroke = Lib.Create("UIStroke", { Parent = btn, Color = Colors.Border, Thickness = 1 })
        
        btn.MouseButton1Click:Connect(function() _G.changeTheme(c1, c2) end)
    end

    createThemeOption("Indigo & Glow Purple", Color3.fromRGB(15, 15, 20), Color3.fromRGB(220, 190, 255))
    createThemeOption("Black & Orange", Color3.fromRGB(15, 15, 20), Color3.fromRGB(255, 120, 0))
    createThemeOption("Black & Red", Color3.fromRGB(15, 15, 20), Color3.fromRGB(255, 50, 50))
    createThemeOption("Black & Green", Color3.fromRGB(15, 15, 20), Color3.fromRGB(50, 255, 50))
    createThemeOption("Black & Blue", Color3.fromRGB(15, 15, 20), Color3.fromRGB(50, 100, 255))
    createThemeOption("Black & Cyan", Color3.fromRGB(15, 15, 20), Color3.fromRGB(0, 255, 255))
    createThemeOption("Black & Pink", Color3.fromRGB(15, 15, 20), Color3.fromRGB(255, 105, 180))
    createThemeOption("Deep Aqua & Mint", Color3.fromRGB(10, 35, 40), Color3.fromRGB(100, 255, 180))

    local themeOpened = false
    local themeBtn, themeArrow = Lib.createMenuBtn(UI.Pages.Settings, "Themes", 10, true)
    themeBtn.MouseButton1Click:Connect(function()
        themeOpened = not themeOpened
        themeMenu.Visible = true
        Services.TS:Create(themeArrow, TWEEN_INFO_FAST, {Rotation = themeOpened and 180 or 0}):Play()
        local t = Services.TS:Create(themeMenu, TWEEN_INFO_FAST, {Size = UDim2.new(1, -6, 0, themeOpened and 245 or 0)})
        t:Play(); t.Completed:Wait()
    end)

    local notifMenu = Lib.Create("Frame", { Parent = UI.Pages.Settings, Size = UDim2.new(1, -6, 0, 0), BackgroundTransparency = 1, ClipsDescendants = true, Visible = false })
    local notifLayout = Lib.Create("UIListLayout", { Parent = notifMenu, Padding = UDim.new(0, 4) })

    Lib.createToggle(notifMenu, "Enable Notifications", 0, true, function(st) _G.NotificationsEnabled = st end)
    Lib.createToggle(notifMenu, "New notification system", 44, false, function(st) _G.UseNewNotifications = st end)

    local playerNotifsEnabled = false
    Lib.createToggle(notifMenu, "Player Notifications", 88, false, function(st) playerNotifsEnabled = st end)

    table.insert(UI.Connections, Services.Players.PlayerAdded:Connect(function(p)
        if playerNotifsEnabled then Lib.showNotification(p.Name .. " зашёл на сервер") end
    end))
    table.insert(UI.Connections, Services.Players.PlayerRemoving:Connect(function(p)
        if playerNotifsEnabled then Lib.showNotification(p.Name .. " вышел с сервера") end
    end))

    local mascotCard = Lib.CreateStyledCard(notifMenu, 40)
    mascotCard.Position = UDim2.new(0, 0, 0, 132)
    local mascotInput = Lib.Create("TextBox", {
        Parent = mascotCard,
        Size = UDim2.new(1, -24, 1, -12),
        Position = UDim2.new(0, 12, 0, 6),
        BackgroundColor3 = Colors.ToggleShell,
        BorderSizePixel = 0,
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        PlaceholderText = "Paste Character Asset ID..."
    })
    Lib.Create("UICorner", { Parent = mascotInput, CornerRadius = UDim.new(0, 4) })
    local mInStroke = Lib.Create("UIStroke", { Parent = mascotInput, Color = Colors.Border, Thickness = 1 })
    mascotInput:GetPropertyChangedSignal("Text"):Connect(function()
        local v = mascotInput.Text
        if v ~= "" then
            _G.NotificationAssetID = tonumber(v) and "rbxthumb://type=Asset&id=" .. v .. "&w=150&h=150" or v
        end
    end)

    local notifBtn, notifArrow = Lib.createMenuBtn(UI.Pages.Settings, "Notifications Management", 55, true)
    local notifOpened = false
    notifBtn.MouseButton1Click:Connect(function()
        notifOpened = not notifOpened
        notifMenu.Visible = true
        Services.TS:Create(notifArrow, TWEEN_INFO_FAST, {Rotation = notifOpened and 180 or 0}):Play()
        local t = Services.TS:Create(notifMenu, TWEEN_INFO_FAST, {Size = UDim2.new(1, -6, 0, notifOpened and 180 or 0)})
        t:Play(); t.Completed:Wait()
    end)

    local renderCard = Lib.CreateStyledCard(UI.Pages.Settings, 55)
    renderCard.Position = UDim2.new(0, 0, 0, 100)
    Lib.createSlider(renderCard, 0, "Map render distance", 10, 5000, 1000, function(val)
        Services.Lighting.FogEnd = val
        Services.Lighting.FogStart = val * 0.5
    end)

    local renderMenu = Lib.Create("Frame", { Parent = UI.Pages.Settings, Size = UDim2.new(1, -6, 0, 0), BackgroundTransparency = 1, ClipsDescendants = true, Visible = false })
    local renderLayout = Lib.Create("UIListLayout", { Parent = renderMenu, Padding = UDim.new(0, 4) })

    Lib.createToggle(renderMenu, "Drawing characters", 0, true, function(st)
        for _, plr in ipairs(Services.Players:GetPlayers()) do
            if plr ~= LP and plr.Character then
                for _, v in ipairs(plr.Character:GetDescendants()) do
                    if v:IsA("BasePart") or v:IsA("Decal") then v.Transparency = st and 0 or 1 end
                end
            end
        end
    end)
    Lib.createToggle(renderMenu, "Drawing accessories", 44, true, function(st)
        for _, plr in ipairs(Services.Players:GetPlayers()) do
            if plr.Character then
                for _, v in ipairs(plr.Character:GetChildren()) do
                    if v:IsA("Accessory") and v:FindFirstChild("Handle") then v.Handle.Transparency = st and 0 or 1 end
                end
            end
        end
    end)
    Lib.createToggle(renderMenu, "Ray drawing", 88, true, function(st)
        for _, v in pairs(Services.Lighting:GetChildren()) do
            if v:IsA("SunRaysEffect") then v.Enabled = st end
        end
    end)
    Lib.createToggle(renderMenu, "Drawing shadows", 132, true, function(st)
        Services.Lighting.GlobalShadows = st
    end)

    local renderOpened = false
    local renderBtn, renderArrow = Lib.createMenuBtn(UI.Pages.Settings, "Graphic Optimizations", 160, true)
    renderBtn.MouseButton1Click:Connect(function()
        renderOpened = not renderOpened
        renderMenu.Visible = true
        Services.TS:Create(renderArrow, TWEEN_INFO_FAST, {Rotation = renderOpened and 180 or 0}):Play()
        local t = Services.TS:Create(renderMenu, TWEEN_INFO_FAST, {Size = UDim2.new(1, -6, 0, renderOpened and 180 or 0)})
        t:Play(); t.Completed:Wait()
    end)

    Lib.createToggle(UI.Pages.Settings, "Watermark", 205, true, function(st)
        if Watermark then Watermark.Visible = st end
    end)

    Lib.createToggle(UI.Pages.Settings, "Old design", 250, false, function(st)
        UI.State.oldDesignEnabled = st
        for _, obj in pairs(UI.Screen:GetDescendants()) do
            if obj:IsA("Frame") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                if obj.BackgroundTransparency < 1 then
                    if st then
                        if not UI.State.savedColors[obj] then UI.State.savedColors[obj] = obj.BackgroundColor3 end
                        obj.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
                    else
                        if UI.State.savedColors[obj] then obj.BackgroundColor3 = UI.State.savedColors[obj] end
                    end
                end
            end
        end
        if not st then UI.State.savedColors = {} end
    end)
end

UI.Pages["ScriptBlox"] = Lib.Create("Frame", {
    Name = "ScriptBloxTab",
    Parent = TabContainer,
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Visible = false
})

CreateTabButton("ScriptBlox", 14)

local CacheManager = {
    Cache = {},
    Favorites = {},
    History = {}
}

function CacheManager.Get(key)
    return CacheManager.Cache[key]
end

function CacheManager.Set(key, value)
    CacheManager.Cache[key] = value
end

function CacheManager.LoadFavorites()
    pcall(function()
        if isfile and isfile("SeptusHub_Configs/sb_favorites.json") then
            CacheManager.Favorites = Services.Http:JSONDecode(readfile("SeptusHub_Configs/sb_favorites.json"))
        end
    end)
end

function CacheManager.SaveFavorites()
    pcall(function()
        if writefile then
            if not isfolder("SeptusHub_Configs") then
                makefolder("SeptusHub_Configs")
            end
            writefile("SeptusHub_Configs/sb_favorites.json", Services.Http:JSONEncode(CacheManager.Favorites))
        end
    end)
end

function CacheManager.ToggleFavorite(scriptData)
    local id = scriptData._id
    if CacheManager.Favorites[id] then
        CacheManager.Favorites[id] = nil
        Lib.showNotification("Removed from favorites!")
    else
        CacheManager.Favorites[id] = scriptData
        Lib.showNotification("Added to favorites!")
    end
    CacheManager.SaveFavorites()
end

function CacheManager.IsFavorite(id)
    return CacheManager.Favorites[id] ~= nil
end

function CacheManager.AddToHistory(query)
    if not query or query == "" then return end
    for i, v in ipairs(CacheManager.History) do
        if v == query then
            table.remove(CacheManager.History, i)
            break
        end
    end
    table.insert(CacheManager.History, 1, query)
    if #CacheManager.History > 10 then
        table.remove(CacheManager.History)
    end
end

local APIModule = {
    BaseUrl = "https://scriptblox.com/api"
}

local function requestHttp(url)
    local success, response = pcall(function()
        if request then
            local res = request({
                Url = url,
                Method = "GET"
            })
            return res.Body
        else
            return game:HttpGetAsync(url)
        end
    end)
    if success then
        return response
    else
        return nil, response
    end
end

function APIModule.Search(query, page, filters)
    page = page or 1
    local url = APIModule.BaseUrl .. "/script/search?q=" .. Services.Http:UrlEncode(query) .. "&page=" .. tostring(page) .. "&max=10"
    
    if filters.mode and filters.mode ~= "all" then
        url = url .. "&mode=" .. filters.mode
    end
    if filters.key ~= nil then
        url = url .. "&key=" .. tostring(filters.key)
    end
    if filters.verified ~= nil then
        url = url .. "&verified=" .. tostring(filters.verified)
    end
    if filters.isUniversal ~= nil then
        url = url .. "&universal=" .. tostring(filters.isUniversal)
    end
    if filters.sortBy then
        url = url .. "&sortBy=" .. filters.sortBy .. "&order=desc"
    end

    local cacheKey = url
    local cached = CacheManager.Get(cacheKey)
    if cached then return cached end

    local body, err = requestHttp(url)
    if not body then
        return nil, err or "HTTP Request failed"
    end

    local success, data = pcall(function()
        return Services.Http:JSONDecode(body)
    end)

    if not success then
        return nil, "JSON Decode failed"
    end

    if data and data.result then
        CacheManager.Set(cacheKey, data.result)
        return data.result
    elseif data and data.message then
        return nil, data.message
    else
        return nil, "Invalid response structure"
    end
end

function APIModule.FetchRawScript(scriptId)
    local url = APIModule.BaseUrl .. "/script/raw/" .. scriptId
    local body, err = requestHttp(url)
    return body, err
end

local TopSearchBar = Lib.Create("Frame", {
    Parent = UI.Pages.ScriptBlox,
    Size = UDim2.new(1, 0, 0, 40),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundTransparency = 1
})

local SearchBoxCard = Lib.Create("Frame", {
    Parent = TopSearchBar,
    Size = UDim2.new(1, -120, 1, 0),
    BackgroundColor3 = Colors.Surface,
    BorderSizePixel = 0
})
Lib.Create("UICorner", { Parent = SearchBoxCard, CornerRadius = UDim.new(0, 6) })
local searchStroke = Lib.Create("UIStroke", { Parent = SearchBoxCard, Color = Colors.Border, Thickness = 1 })

local SearchInput = Lib.Create("TextBox", {
    Parent = SearchBoxCard,
    Size = UDim2.new(1, -20, 1, 0),
    Position = UDim2.new(0, 10, 0, 0),
    BackgroundTransparency = 1,
    TextColor3 = Colors.TextMain,
    PlaceholderText = "Search scripts by name, game or PlaceId...",
    Font = Enum.Font.Gotham,
    TextSize = 12,
    Text = "",
    ClearTextOnFocus = false
})

local SearchBtn = Lib.Create("TextButton", {
    Parent = TopSearchBar,
    Size = UDim2.new(0, 75, 1, 0),
    Position = UDim2.new(1, -115, 0, 0),
    BackgroundColor3 = Colors.Active,
    Text = "Search",
    TextColor3 = Colors.Background,
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    BorderSizePixel = 0
})
Lib.Create("UICorner", { Parent = SearchBtn, CornerRadius = UDim.new(0, 6) })

local RefreshBtn = Lib.Create("TextButton", {
    Parent = TopSearchBar,
    Size = UDim2.new(0, 35, 1, 0),
    Position = UDim2.new(1, -35, 0, 0),
    BackgroundColor3 = Colors.Surface,
    Text = "🔄",
    TextColor3 = Colors.TextMain,
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    BorderSizePixel = 0
})
Lib.Create("UICorner", { Parent = RefreshBtn, CornerRadius = UDim.new(0, 6) })
local refreshStroke = Lib.Create("UIStroke", { Parent = RefreshBtn, Color = Colors.Border, Thickness = 1 })

local FilterBar = Lib.Create("Frame", {
    Parent = UI.Pages.ScriptBlox,
    Size = UDim2.new(1, 0, 0, 30),
    Position = UDim2.new(0, 0, 0, 45),
    BackgroundTransparency = 1
})

local FiltersToggleBtn = Lib.Create("TextButton", {
    Parent = FilterBar,
    Size = UDim2.new(0, 80, 1, 0),
    BackgroundColor3 = Colors.Surface,
    Text = "⚡ Filters",
    TextColor3 = Colors.TextMain,
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    BorderSizePixel = 0
})
Lib.Create("UICorner", { Parent = FiltersToggleBtn, CornerRadius = UDim.new(0, 6) })
local filtersStroke = Lib.Create("UIStroke", { Parent = FiltersToggleBtn, Color = Colors.Border, Thickness = 1 })

local FavToggleBtn = Lib.Create("TextButton", {
    Parent = FilterBar,
    Size = UDim2.new(0, 90, 1, 0),
    Position = UDim2.new(0, 85, 0, 0),
    BackgroundColor3 = Colors.Surface,
    Text = "⭐ Favorites",
    TextColor3 = Colors.TextMain,
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    BorderSizePixel = 0
})
Lib.Create("UICorner", { Parent = FavToggleBtn, CornerRadius = UDim.new(0, 6) })
local favToggleStroke = Lib.Create("UIStroke", { Parent = FavToggleBtn, Color = Colors.Border, Thickness = 1 })

local HistoryToggleBtn = Lib.Create("TextButton", {
    Parent = FilterBar,
    Size = UDim2.new(0, 80, 1, 0),
    Position = UDim2.new(0, 180, 0, 0),
    BackgroundColor3 = Colors.Surface,
    Text = "🕒 History",
    TextColor3 = Colors.TextMain,
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    BorderSizePixel = 0
})
Lib.Create("UICorner", { Parent = HistoryToggleBtn, CornerRadius = UDim.new(0, 6) })
local historyToggleStroke = Lib.Create("UIStroke", { Parent = HistoryToggleBtn, Color = Colors.Border, Thickness = 1 })

local SortDisplay = Lib.Create("TextLabel", {
    Parent = FilterBar,
    Size = UDim2.new(1, -270, 1, 0),
    Position = UDim2.new(0, 265, 0, 0),
    BackgroundTransparency = 1,
    Text = "Sort: Views",
    TextColor3 = Colors.TextDim,
    Font = Enum.Font.GothamSemibold,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Right
})

local FiltersPanel = Lib.Create("Frame", {
    Parent = UI.Pages.ScriptBlox,
    Size = UDim2.new(1, 0, 0, 160),
    Position = UDim2.new(0, 0, 0, 80),
    BackgroundColor3 = Colors.Background,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 50
})
Lib.Create("UICorner", { Parent = FiltersPanel, CornerRadius = UDim.new(0, 8) })
local filtersPanelStroke = Lib.Create("UIStroke", { Parent = FiltersPanel, Color = Colors.Active, Thickness = 1 })

local function createFilterRow(parent, labelText, yPos, options, filterKey, defaultValue)
    local row = Lib.Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, -20, 0, 26),
        Position = UDim2.new(0, 10, 0, yPos),
        BackgroundTransparency = 1
    })

    local lbl = Lib.Create("TextLabel", {
        Parent = row,
        Size = UDim2.new(0, 100, 1, 0),
        BackgroundTransparency = 1,
        Text = labelText,
        TextColor3 = Colors.TextDim,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local buttonContainer = Lib.Create("Frame", {
        Parent = row,
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 100, 0, 0),
        BackgroundTransparency = 1
    })

    local layout = Lib.Create("UIListLayout", {
        Parent = buttonContainer,
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 6)
    })

    local activeButtons = {}

    local function updateSelection(selectedVal)
        for _, btnData in pairs(activeButtons) do
            if btnData.value == selectedVal then
                Services.TS:Create(btnData.btn, TWEEN_INFO_FAST, { BackgroundColor3 = Colors.Active, TextColor3 = Colors.Background }):Play()
                Services.TS:Create(btnData.stroke, TWEEN_INFO_FAST, { Color = Colors.Active }):Play()
            else
                Services.TS:Create(btnData.btn, TWEEN_INFO_FAST, { BackgroundColor3 = Colors.Surface, TextColor3 = Colors.TextMain }):Play()
                Services.TS:Create(btnData.stroke, TWEEN_INFO_FAST, { Color = Colors.Border }):Play()
            end
        end
    end

    for _, opt in ipairs(options) do
        local optBtn = Lib.Create("TextButton", {
            Parent = buttonContainer,
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = Colors.Surface,
            Text = "  " .. opt.display .. "  ",
            TextColor3 = Colors.TextMain,
            Font = Enum.Font.GothamBold,
            TextSize = 10,
            BorderSizePixel = 0,
            AutoButtonColor = false
        })
        Lib.Create("UICorner", { Parent = optBtn, CornerRadius = UDim.new(0, 4) })
        local btnStroke = Lib.Create("UIStroke", { Parent = optBtn, Color = Colors.Border, Thickness = 1 })

        table.insert(activeButtons, { btn = optBtn, stroke = btnStroke, value = opt.value })

        optBtn.MouseButton1Click:Connect(function()
            activeFilters[filterKey] = opt.value
            updateSelection(opt.value)
            if filterKey == "sortBy" then
                SortDisplay.Text = "Sort: " .. opt.display
            end
        end)
    end

    updateSelection(defaultValue)
end

local activeFilters = {
    mode = "all",
    key = nil,
    verified = nil,
    isUniversal = nil,
    sortBy = "views"
}

createFilterRow(FiltersPanel, "Cost", 10, {
    { display = "All", value = "all" },
    { display = "Free", value = "free" },
    { display = "Paid", value = "paid" }
}, "mode", "all")

createFilterRow(FiltersPanel, "Key System", 40, {
    { display = "All", value = nil },
    { display = "Yes", value = true },
    { display = "No", value = false }
}, "key", nil)

createFilterRow(FiltersPanel, "Verified Only", 70, {
    { display = "All", value = nil },
    { display = "Yes", value = true },
    { display = "No", value = false }
}, "verified", nil)

createFilterRow(FiltersPanel, "Sort By", 100, {
    { display = "Views", value = "views" },
    { display = "Likes", value = "likeCount" },
    { display = "Newest", value = "createdAt" }
}, "sortBy", "views")

createFilterRow(FiltersPanel, "Universal", 130, {
    { display = "All", value = nil },
    { display = "Yes", value = true },
    { display = "No", value = false }
}, "isUniversal", nil)

local ResultsScroll = Lib.Create("ScrollingFrame", {
    Parent = UI.Pages.ScriptBlox,
    Size = UDim2.new(1, 0, 1, -115),
    Position = UDim2.new(0, 0, 0, 80),
    BackgroundTransparency = 1,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = Colors.Border,
    BorderSizePixel = 0,
    ClipsDescendants = true
})
local resultsLayout = Lib.Create("UIListLayout", {
    Parent = ResultsScroll,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 8)
})

resultsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ResultsScroll.CanvasSize = UDim2.new(0, 0, 0, resultsLayout.AbsoluteContentSize.Y + 10)
end)

local PaginationBar = Lib.Create("Frame", {
    Parent = UI.Pages.ScriptBlox,
    Size = UDim2.new(1, 0, 0, 30),
    Position = UDim2.new(0, 0, 1, -30),
    BackgroundTransparency = 1
})

local PrevBtn = Lib.Create("TextButton", {
    Parent = PaginationBar,
    Size = UDim2.new(0, 60, 1, 0),
    BackgroundColor3 = Colors.Surface,
    Text = "◀ Prev",
    TextColor3 = Colors.TextMain,
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    BorderSizePixel = 0
})
Lib.Create("UICorner", { Parent = PrevBtn, CornerRadius = UDim.new(0, 6) })
local prevStroke = Lib.Create("UIStroke", { Parent = PrevBtn, Color = Colors.Border, Thickness = 1 })

local NextBtn = Lib.Create("TextButton", {
    Parent = PaginationBar,
    Size = UDim2.new(0, 60, 1, 0),
    Position = UDim2.new(1, -60, 0, 0),
    BackgroundColor3 = Colors.Surface,
    Text = "Next ▶",
    TextColor3 = Colors.TextMain,
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    BorderSizePixel = 0
})
Lib.Create("UICorner", { Parent = NextBtn, CornerRadius = UDim.new(0, 6) })
local nextStroke = Lib.Create("UIStroke", { Parent = NextBtn, Color = Colors.Border, Thickness = 1 })

local PageLabel = Lib.Create("TextLabel", {
    Parent = PaginationBar,
    Size = UDim2.new(1, -130, 1, 0),
    Position = UDim2.new(0, 65, 0, 0),
    BackgroundTransparency = 1,
    Text = "Page 1",
    TextColor3 = Colors.TextMain,
    Font = Enum.Font.GothamBold,
    TextSize = 12
})

local HistoryPanel = Lib.Create("Frame", {
    Parent = UI.Pages.ScriptBlox,
    Size = UDim2.new(1, 0, 1, -80),
    Position = UDim2.new(0, 0, 0, 80),
    BackgroundColor3 = Colors.Background,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 40
})
Lib.Create("UICorner", { Parent = HistoryPanel, CornerRadius = UDim.new(0, 8) })

local historyScroll = Lib.Create("ScrollingFrame", {
    Parent = HistoryPanel,
    Size = UDim2.new(1, -20, 1, -20),
    Position = UDim2.new(0, 10, 0, 10),
    BackgroundTransparency = 1,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = Colors.Border,
    BorderSizePixel = 0
})
local historyLayout = Lib.Create("UIListLayout", { Parent = historyScroll, Padding = UDim.new(0, 6) })

local function refreshHistoryUI()
    for _, child in ipairs(historyScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    if #CacheManager.History == 0 then
        local emptyLbl = Lib.Create("TextLabel", {
            Parent = historyScroll,
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundTransparency = 1,
            Text = "Search history is empty",
            TextColor3 = Colors.TextDim,
            Font = Enum.Font.GothamMedium,
            TextSize = 12
        })
    else
        for _, q in ipairs(CacheManager.History) do
            local btn = Lib.Create("TextButton", {
                Parent = historyScroll,
                Size = UDim2.new(1, -6, 0, 30),
                BackgroundColor3 = Colors.Surface,
                Text = q,
                TextColor3 = Colors.TextMain,
                Font = Enum.Font.GothamMedium,
                TextSize = 12,
                BorderSizePixel = 0
            })
            Lib.Create("UICorner", { Parent = btn, CornerRadius = UDim.new(0, 4) })
            local bStroke = Lib.Create("UIStroke", { Parent = btn, Color = Colors.Border, Thickness = 1 })

            btn.MouseButton1Click:Connect(function()
                SearchInput.Text = q
                HistoryPanel.Visible = false
                HistoryToggleBtn.BackgroundColor3 = Colors.Surface
                HistoryToggleBtn.TextColor3 = Colors.TextMain
                _G.PerformScriptBloxSearch(q)
            end)
        end
    end
end

local showingFavorites = false

local function renderFavorites()
    ResultsScroll:ClearAllChildren()
    local count = 0
    for _, scriptData in pairs(CacheManager.Favorites) do
        count = count + 1
        _G.CreateScriptCard(scriptData)
    end
    if count == 0 then
        local emptyLbl = Lib.Create("TextLabel", {
            Parent = ResultsScroll,
            Size = UDim2.new(1, 0, 0, 50),
            BackgroundTransparency = 1,
            Text = "No favorite scripts.",
            TextColor3 = Colors.TextDim,
            Font = Enum.Font.GothamMedium,
            TextSize = 12
        })
    end
    PageLabel.Text = "Favorites (" .. count .. ")"
    PrevBtn.Visible = false
    NextBtn.Visible = false
end

local LoaderLabel = Lib.Create("TextLabel", {
    Parent = UI.Pages.ScriptBlox,
    Size = UDim2.new(1, 0, 0, 40),
    Position = UDim2.new(0, 0, 0.5, -20),
    BackgroundTransparency = 1,
    Text = "Fetching scripts...",
    TextColor3 = Colors.Active,
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    Visible = false,
    ZIndex = 10
})

local function setLoaderState(active)
    LoaderLabel.Visible = active
    ResultsScroll.Visible = not active
end

local function openScriptDetails(scriptData)
    local title = scriptData.title or "Script Details"
    local win, closeBtn, scroll, layout, actionBtn, actionLbl = Lib.createFloatingMenu(title, 380, 360)
    win.Visible = true
    win.Position = UDim2.new(0.5, -190, 0.5, -180)

    local function addDetailLine(key, val)
        local l = Lib.Create("TextLabel", {
            Parent = scroll,
            Size = UDim2.new(1, -6, 0, 18),
            BackgroundTransparency = 1,
            Text = "<b>" .. key .. "</b>: " .. tostring(val),
            TextColor3 = Colors.TextMain,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            RichText = true,
            TextXAlignment = Enum.TextXAlignment.Left
        })
    end

    addDetailLine("Game", scriptData.game and scriptData.game.name or "Universal")
    addDetailLine("Author", scriptData.owner and scriptData.owner.username or "Anonymous")
    addDetailLine("Views", scriptData.views or 0)
    addDetailLine("Likes", scriptData.likeCount or 0)
    addDetailLine("Key System", scriptData.key and "Yes" or "No")
    addDetailLine("Created", tostring(scriptData.createdAt):sub(1, 10))

    if scriptData.features and scriptData.features ~= "" then
        local descHeader = Lib.Create("TextLabel", {
            Parent = scroll,
            Size = UDim2.new(1, -6, 0, 20),
            BackgroundTransparency = 1,
            Text = "<b>Features:</b>",
            TextColor3 = Colors.Active,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            RichText = true,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local descBox = Lib.Create("TextLabel", {
            Parent = scroll,
            Size = UDim2.new(1, -6, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Text = scriptData.features,
            TextColor3 = Colors.TextDim,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left
        })
    end

    local codeHeader = Lib.Create("TextLabel", {
        Parent = scroll,
        Size = UDim2.new(1, -6, 0, 20),
        BackgroundTransparency = 1,
        Text = "<b>Script Code:</b>",
        TextColor3 = Colors.Active,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        RichText = true,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local codeContainer = Lib.Create("Frame", {
        Parent = scroll,
        Size = UDim2.new(1, -6, 0, 120),
        BackgroundColor3 = Colors.ToggleShell,
        BorderSizePixel = 0
    })
    Lib.Create("UICorner", { Parent = codeContainer, CornerRadius = UDim.new(0, 6) })
    Lib.Create("UIStroke", { Parent = codeContainer, Color = Colors.Border, Thickness = 1 })

    local codeScroll = Lib.Create("ScrollingFrame", {
        Parent = codeContainer,
        Size = UDim2.new(1, -12, 1, -12),
        Position = UDim2.new(0, 6, 0, 6),
        BackgroundTransparency = 1,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Colors.Border,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })
    
    local codeText = scriptData.script or ""
    if codeText == "" and scriptData._id then
        task.spawn(function()
            local raw, err = APIModule.FetchRawScript(scriptData._id)
            if raw then
                codeText = raw
                scriptData.script = raw
            end
        end)
    end

    local codeBox = Lib.Create("TextBox", {
        Parent = codeScroll,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(180, 255, 180),
        Font = Enum.Font.Code,
        TextSize = 10,
        Text = codeText,
        ClearTextOnFocus = false,
        MultiLine = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        ReadOnly = true
    })
    codeBox:GetPropertyChangedSignal("TextBounds"):Connect(function()
        codeScroll.CanvasSize = UDim2.new(0, codeBox.TextBounds.X + 20, 0, codeBox.TextBounds.Y + 20)
    end)

    actionLbl.Text = "Execute Script"
    actionBtn.MouseButton1Click:Connect(function()
        if codeText ~= "" then
            local func, err = loadstring(codeText)
            if func then
                task.spawn(func)
                Lib.showNotification("Script executed!")
            else
                Lib.showNotification("Syntax error: " .. tostring(err))
            end
        else
            Lib.showNotification("Loading script code...")
        end
    end)

    local copyBtn = Lib.Create("TextButton", {
        Parent = win,
        Size = UDim2.new(0, 100, 0, 30),
        Position = UDim2.new(1, -110, 1, -40),
        BackgroundColor3 = Colors.Surface,
        Text = "Copy Code",
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        BorderSizePixel = 0,
        ZIndex = 10
    })
    Lib.Create("UICorner", { Parent = copyBtn, CornerRadius = UDim.new(0, 6) })
    local copyStroke = Lib.Create("UIStroke", { Parent = copyBtn, Color = Colors.Border, Thickness = 1 })

    copyBtn.MouseButton1Click:Connect(function()
        if codeText ~= "" then
            pcall(function()
                if setclipboard then setclipboard(codeText) elseif toclipboard then toclipboard(codeText) end
            end)
            Lib.showNotification("Code copied to clipboard!")
        end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        win:Destroy()
    end)
end

_G.CreateScriptCard = function(scriptData)
    local cardHeight = 115
    local card = Lib.CreateStyledCard(ResultsScroll, cardHeight)
    card.Size = UDim2.new(1, -6, 0, cardHeight)

    local titleLbl = Lib.Create("TextLabel", {
        Parent = card,
        Size = UDim2.new(1, -40, 0, 20),
        Position = UDim2.new(0, 10, 0, 8),
        BackgroundTransparency = 1,
        Text = scriptData.title or "Untitled Script",
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClipsDescendants = true
    })

    local isFav = CacheManager.IsFavorite(scriptData._id)
    local favBtn = Lib.Create("TextButton", {
        Parent = card,
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -30, 0, 6),
        BackgroundTransparency = 1,
        Text = isFav and "⭐" or "☆",
        TextColor3 = Colors.Active,
        Font = Enum.Font.GothamBold,
        TextSize = 14
    })
    favBtn.MouseButton1Click:Connect(function()
        CacheManager.ToggleFavorite(scriptData)
        favBtn.Text = CacheManager.IsFavorite(scriptData._id) and "⭐" or "☆"
    end)

    local gameName = scriptData.game and scriptData.game.name or "Universal"
    local authorName = scriptData.owner and scriptData.owner.username or "Anonymous"
    
    local metaLbl = Lib.Create("TextLabel", {
        Parent = card,
        Size = UDim2.new(1, -20, 0, 16),
        Position = UDim2.new(0, 10, 0, 28),
        BackgroundTransparency = 1,
        Text = "Game: " .. gameName .. " | Author: " .. authorName,
        TextColor3 = Colors.TextDim,
        Font = Enum.Font.GothamMedium,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClipsDescendants = true
    })

    local badgeLayout = Lib.Create("Frame", {
        Parent = card,
        Size = UDim2.new(1, -20, 0, 18),
        Position = UDim2.new(0, 10, 0, 48),
        BackgroundTransparency = 1
    })
    local bList = Lib.Create("UIListLayout", { Parent = badgeLayout, FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4) })

    local function addBadge(text, color)
        local b = Lib.Create("Frame", { Parent = badgeLayout, Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = color })
        Lib.Create("UICorner", { Parent = b, CornerRadius = UDim.new(0, 4) })
        local t = Lib.Create("TextLabel", { Parent = b, Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0,0,0,0), BackgroundTransparency = 1, Text = " " .. text .. " ", TextColor3 = Colors.Background, Font = Enum.Font.GothamBold, TextSize = 8 })
    end

    if scriptData.verified then addBadge("Verified", Color3.fromRGB(80, 200, 80)) end
    if scriptData.key then addBadge("Key System", Color3.fromRGB(220, 100, 100)) else addBadge("No Key", Color3.fromRGB(100, 180, 220)) end
    if scriptData.isUniversal then addBadge("Universal", Color3.fromRGB(150, 100, 220)) end
    if scriptData.scriptType == "paid" then addBadge("Paid", Color3.fromRGB(220, 180, 50)) else addBadge("Free", Color3.fromRGB(100, 200, 100)) end

    local views = scriptData.views or 0
    local likes = scriptData.likeCount or 0
    local statsLbl = Lib.Create("TextLabel", {
        Parent = card,
        Size = UDim2.new(0.4, 0, 0, 16),
        Position = UDim2.new(0, 10, 1, -24),
        BackgroundTransparency = 1,
        Text = "👁 " .. views .. "  👍 " .. likes,
        TextColor3 = Colors.TextDim,
        Font = Enum.Font.GothamMedium,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local function makeCardBtn(text, posX, width, color, callback)
        local btn = Lib.Create("TextButton", {
            Parent = card,
            Size = UDim2.new(0, width, 0, 22),
            Position = UDim2.new(1, posX, 1, -26),
            BackgroundColor3 = color,
            Text = text,
            TextColor3 = color == Colors.Active and Colors.Background or Colors.TextMain,
            Font = Enum.Font.GothamBold,
            TextSize = 9,
            BorderSizePixel = 0
        })
        Lib.Create("UICorner", { Parent = btn, CornerRadius = UDim.new(0, 4) })
        local bStroke = Lib.Create("UIStroke", { Parent = btn, Color = Colors.Border, Thickness = 1 })

        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    local codeText = scriptData.script or ""
    local function getCode(cb)
        if codeText ~= "" then
            cb(codeText)
        elseif scriptData._id then
            task.spawn(function()
                local raw, err = APIModule.FetchRawScript(scriptData._id)
                if raw then
                    codeText = raw
                    scriptData.script = raw
                    cb(raw)
                else
                    Lib.showNotification("Failed to fetch script source")
                end
            end)
        end
    end

    makeCardBtn("Details", -210, 55, Colors.Surface, function()
        openScriptDetails(scriptData)
    end)

    makeCardBtn("Copy", -150, 45, Colors.Surface, function()
        getCode(function(code)
            pcall(function()
                if setclipboard then setclipboard(code) elseif toclipboard then toclipboard(code) end
            end)
            Lib.showNotification("Code copied to clipboard!")
        end)
    end)

    makeCardBtn("Execute", -100, 90, Colors.Active, function()
        getCode(function(code)
            local func, err = loadstring(code)
            if func then
                task.spawn(func)
                Lib.showNotification("Executing script...")
            else
                Lib.showNotification("Execution error: " .. tostring(err))
            end
        end)
    end)

    card.Size = UDim2.new(1, -6, 0, 0)
    card.ClipsDescendants = true
    Services.TS:Create(card, TWEEN_INFO_FAST, { Size = UDim2.new(1, -6, 0, cardHeight) }):Play()
end

local SearchController = {
    CurrentQuery = "",
    CurrentPage = 1,
    TotalPages = 1,
    IsLoading = false,
    DebounceTime = 0.5,
    LastSearchTime = 0
}

function SearchController.Search(query, page)
    if SearchController.IsLoading then return end
    
    local now = os.clock()
    if now - SearchController.LastSearchTime < SearchController.DebounceTime then
        Lib.showNotification("Please wait before searching again")
        return
    end
    SearchController.LastSearchTime = now

    SearchController.IsLoading = true
    setLoaderState(true)
    ResultsScroll:ClearAllChildren()

    SearchController.CurrentQuery = query
    SearchController.CurrentPage = page or 1

    task.spawn(function()
        local results, err = APIModule.Search(query, SearchController.CurrentPage, activeFilters)
        SearchController.IsLoading = false
        setLoaderState(false)

        if not results then
            local errLbl = Lib.Create("TextLabel", {
                Parent = ResultsScroll,
                Size = UDim2.new(1, 0, 0, 50),
                BackgroundTransparency = 1,
                Text = "Error: " .. tostring(err),
                TextColor3 = Color3.fromRGB(255, 100, 100),
                Font = Enum.Font.GothamMedium,
                TextSize = 12
            })
            return
        end

        SearchController.TotalPages = results.totalPages or 1
        PageLabel.Text = "Page " .. SearchController.CurrentPage .. " of " .. SearchController.TotalPages

        if not results.scripts or #results.scripts == 0 then
            local emptyLbl = Lib.Create("TextLabel", {
                Parent = ResultsScroll,
                Size = UDim2.new(1, 0, 0, 50),
                BackgroundTransparency = 1,
                Text = "No scripts found.",
                TextColor3 = Colors.TextDim,
                Font = Enum.Font.GothamMedium,
                TextSize = 12
            })
            return
        end

        for _, scriptData in ipairs(results.scripts) do
            _G.CreateScriptCard(scriptData)
        end

        CacheManager.AddToHistory(query)
    end)
end

_G.PerformScriptBloxSearch = function(query)
    showingFavorites = false
    FavToggleBtn.BackgroundColor3 = Colors.Surface
    FavToggleBtn.TextColor3 = Colors.TextMain
    PrevBtn.Visible = true
    NextBtn.Visible = true
    SearchController.Search(query, 1)
end

SearchBtn.MouseButton1Click:Connect(function()
    _G.PerformScriptBloxSearch(SearchInput.Text)
end)

SearchInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        _G.PerformScriptBloxSearch(SearchInput.Text)
    end
end)

RefreshBtn.MouseButton1Click:Connect(function()
    if showingFavorites then
        renderFavorites()
    else
        SearchController.Search(SearchController.CurrentQuery, SearchController.CurrentPage)
    end
end)

FiltersToggleBtn.MouseButton1Click:Connect(function()
    FiltersPanel.Visible = not FiltersPanel.Visible
    if FiltersPanel.Visible then
        FiltersToggleBtn.BackgroundColor3 = Colors.Active
        FiltersToggleBtn.TextColor3 = Colors.Background
        HistoryPanel.Visible = false
        HistoryToggleBtn.BackgroundColor3 = Colors.Surface
        HistoryToggleBtn.TextColor3 = Colors.TextMain
    else
        FiltersToggleBtn.BackgroundColor3 = Colors.Surface
        FiltersToggleBtn.TextColor3 = Colors.TextMain
    end
end)

FavToggleBtn.MouseButton1Click:Connect(function()
    showingFavorites = not showingFavorites
    if showingFavorites then
        FavToggleBtn.BackgroundColor3 = Colors.Active
        FavToggleBtn.TextColor3 = Colors.Background
        HistoryPanel.Visible = false
        HistoryToggleBtn.BackgroundColor3 = Colors.Surface
        HistoryToggleBtn.TextColor3 = Colors.TextMain
        FiltersPanel.Visible = false
        FiltersToggleBtn.BackgroundColor3 = Colors.Surface
        FiltersToggleBtn.TextColor3 = Colors.TextMain
        renderFavorites()
    else
        FavToggleBtn.BackgroundColor3 = Colors.Surface
        FavToggleBtn.TextColor3 = Colors.TextMain
        _G.PerformScriptBloxSearch(SearchInput.Text)
    end
end)

HistoryToggleBtn.MouseButton1Click:Connect(function()
    HistoryPanel.Visible = not HistoryPanel.Visible
    if HistoryPanel.Visible then
        HistoryToggleBtn.BackgroundColor3 = Colors.Active
        HistoryToggleBtn.TextColor3 = Colors.Background
        FiltersPanel.Visible = false
        FiltersToggleBtn.BackgroundColor3 = Colors.Surface
        FiltersToggleBtn.TextColor3 = Colors.TextMain
        refreshHistoryUI()
    else
        HistoryToggleBtn.BackgroundColor3 = Colors.Surface
        HistoryToggleBtn.TextColor3 = Colors.TextMain
    end
end)

PrevBtn.MouseButton1Click:Connect(function()
    if SearchController.CurrentPage > 1 then
        SearchController.Search(SearchController.CurrentQuery, SearchController.CurrentPage - 1)
    end
end)

NextBtn.MouseButton1Click:Connect(function()
    if SearchController.CurrentPage < SearchController.TotalPages then
        SearchController.Search(SearchController.CurrentQuery, SearchController.CurrentPage + 1)
    end
end)

CacheManager.LoadFavorites()

local SuggestionContainer = Lib.Create("Frame", {
    Parent = UI.Pages.ScriptBlox,
    Size = UDim2.new(1, -120, 0, 0),
    Position = UDim2.new(0, 0, 0, 42),
    BackgroundColor3 = Colors.Surface,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 100
})
Lib.Create("UICorner", { Parent = SuggestionContainer, CornerRadius = UDim.new(0, 6) })
local suggStroke = Lib.Create("UIStroke", { Parent = SuggestionContainer, Color = Colors.Border, Thickness = 1 })

local suggLayout = Lib.Create("UIListLayout", { Parent = SuggestionContainer, Padding = UDim.new(0, 2) })

local suggestionsPool = { "Blox Fruits", "Arsenal", "Doors", "Brookhaven", "Adopt Me", "Infinite Yield", "Fly", "Aimbot", "ESP", "Murder Mystery 2" }

local function showSuggestions(text)
    if text == "" then
        SuggestionContainer.Visible = false
        return
    end

    for _, v in pairs(SuggestionContainer:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end

    local count = 0
    local tLower = text:lower()
    local added = {}
    
    local function addSugBtn(sugg)
        if count >= 5 or added[sugg] then return end
        added[sugg] = true
        count = count + 1
        local btn = Lib.Create("TextButton", {
            Parent = SuggestionContainer,
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundTransparency = 1,
            Text = "  " .. sugg,
            TextColor3 = Colors.TextMain,
            Font = Enum.Font.GothamMedium,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 101
        })
        btn.MouseButton1Click:Connect(function()
            SearchInput.Text = sugg
            SuggestionContainer.Visible = false
            _G.PerformScriptBloxSearch(sugg)
        end)
    end

    for _, q in ipairs(CacheManager.History) do
        if q:lower():find(tLower) then
            addSugBtn(q)
        end
    end

    for _, sugg in ipairs(suggestionsPool) do
        if sugg:lower():find(tLower) then
            addSugBtn(sugg)
        end
    end

    if count > 0 then
        SuggestionContainer.Size = UDim2.new(1, -120, 0, count * 24 + 4)
        SuggestionContainer.Visible = true
    else
        SuggestionContainer.Visible = false
    end
end

SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
    showSuggestions(SearchInput.Text)
end)

SearchInput.FocusLost:Connect(function()
    task.delay(0.2, function()
        SuggestionContainer.Visible = false
    end)
end)

CreatePage("Emotes")
CreateTabButton("Emotes", 15)

local EmoteFavorites = {}

local function LoadEmoteFavorites()
    pcall(function()
        if isfile and isfile("SeptusHub_Configs/em_favorites.json") then
            EmoteFavorites = Services.Http:JSONDecode(readfile("SeptusHub_Configs/em_favorites.json"))
        end
    end)
end

local function SaveEmoteFavorites()
    pcall(function()
        if writefile then
            if not isfolder("SeptusHub_Configs") then
                makefolder("SeptusHub_Configs")
            end
            writefile("SeptusHub_Configs/em_favorites.json", Services.Http:JSONEncode(EmoteFavorites))
        end
    end)
end

local function ToggleEmoteFavorite(emoteData)
    local id = tostring(emoteData.id)
    if EmoteFavorites[id] then
        EmoteFavorites[id] = nil
        Lib.showNotification("Эмоция удалена из избранного")
    else
        EmoteFavorites[id] = emoteData
        Lib.showNotification("Эмоция добавлена в избранное")
    end
    SaveEmoteFavorites()
end

local function IsEmoteFavorite(id)
    return EmoteFavorites[tostring(id)] ~= nil
end

LoadEmoteFavorites()

local CurrentTrack = nil
local CurrentAnim = nil
local currentPlayingEmoteId = nil
local activePlayButtons = {}

local function UpdatePlayButtonsVisuals()
    for emId, playBtn in pairs(activePlayButtons) do
        if playBtn and playBtn.Parent then
            if currentPlayingEmoteId == emId then
                playBtn.Text = "Stop"
                playBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
                playBtn.TextColor3 = Colors.TextMain
            else
                playBtn.Text = "Play"
                playBtn.BackgroundColor3 = Colors.Active
                playBtn.TextColor3 = Colors.Background
            end
        else
            activePlayButtons[emId] = nil
        end
    end
end

local function StopCurrentEmote()
    if CurrentTrack then
        CurrentTrack:Stop(0.3) 
        CurrentTrack:Destroy()
        CurrentTrack = nil
    end
    if CurrentAnim then
        CurrentAnim:Destroy()
        CurrentAnim = nil
    end
    currentPlayingEmoteId = nil
    UpdatePlayButtonsVisuals()
end

local function PlayEmoteById(id)
    if currentPlayingEmoteId == id then
        StopCurrentEmote()
        return
    end

    StopCurrentEmote()

    local char = LP.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local animator = humanoid:FindFirstChildOfClass("Animator") or humanoid:WaitForChild("Animator")

    local animId = nil

    local ok, objects = pcall(function() return game:GetObjects("rbxassetid://" .. tostring(id)) end)
    if ok and objects and #objects > 0 then
        local root = objects[1]
        if root:IsA("Animation") then
            animId = root.AnimationId
        else
            local found = root:FindFirstChildOfClass("Animation", true)
            if found then
                animId = found.AnimationId
            end
        end
    end

    if not animId then
        animId = "rbxassetid://" .. tostring(id)
    end

    CurrentAnim = Instance.new("Animation")
    CurrentAnim.AnimationId = animId

    local success, track = pcall(function()
        return animator:LoadAnimation(CurrentAnim)
    end)

    if success and track then
        CurrentTrack = track
        track.Priority = Enum.AnimationPriority.Action4
        track.Looped = true
        track:Play(0.3)
        currentPlayingEmoteId = id
        UpdatePlayButtonsVisuals()
        Lib.showNotification("Воспроизведение эмоции запущено")
    else
        Lib.showNotification("Ошибка загрузки анимации")
    end
end

table.insert(UI.Connections, Services.Run.Heartbeat:Connect(function()
    if CurrentTrack and LP.Character then
        local hum = LP.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.MoveDirection.Magnitude > 0.1 then
            StopCurrentEmote()
            Lib.showNotification("Воспроизведение прервано движением")
        end
    end
end))

local EmotesSearchBar = Lib.Create("Frame", {
    Parent = UI.Pages.Emotes,
    Size = UDim2.new(1, -6, 0, 40),
    Position = UDim2.new(0, 3, 0, 10),
    BackgroundTransparency = 1,
    LayoutOrder = 1
})

local EmoteSearchBoxCard = Lib.Create("Frame", {
    Parent = EmotesSearchBar,
    Size = UDim2.new(1, -120, 1, 0),
    BackgroundColor3 = Colors.Surface,
    BorderSizePixel = 0
})
Lib.Create("UICorner", { Parent = EmoteSearchBoxCard, CornerRadius = UDim.new(0, 6) })
local emoteSearchStroke = Lib.Create("UIStroke", { Parent = EmoteSearchBoxCard, Color = Colors.Border, Thickness = 1 })

local EmoteSearchInput = Lib.Create("TextBox", {
    Parent = EmoteSearchBoxCard,
    Size = UDim2.new(1, -20, 1, 0),
    Position = UDim2.new(0, 10, 0, 0),
    BackgroundTransparency = 1,
    TextColor3 = Colors.TextMain,
    PlaceholderText = "Введите название эмоции...",
    Font = Enum.Font.Gotham,
    TextSize = 12,
    Text = "",
    ClearTextOnFocus = false
})

local EmoteSearchBtn = Lib.Create("TextButton", {
    Parent = EmotesSearchBar,
    Size = UDim2.new(0, 75, 1, 0),
    Position = UDim2.new(1, -115, 0, 0),
    BackgroundColor3 = Colors.Active,
    Text = "Поиск",
    TextColor3 = Colors.Background,
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    BorderSizePixel = 0
})
Lib.Create("UICorner", { Parent = EmoteSearchBtn, CornerRadius = UDim.new(0, 6) })

local EmoteRefreshBtn = Lib.Create("TextButton", {
    Parent = EmotesSearchBar,
    Size = UDim2.new(0, 35, 1, 0),
    Position = UDim2.new(1, -35, 0, 0),
    BackgroundColor3 = Colors.Surface,
    Text = "🔄",
    TextColor3 = Colors.TextMain,
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    BorderSizePixel = 0
})
Lib.Create("UICorner", { Parent = EmoteRefreshBtn, CornerRadius = UDim.new(0, 6) })
local emoteRefreshStroke = Lib.Create("UIStroke", { Parent = EmoteRefreshBtn, Color = Colors.Border, Thickness = 1 })

local EmotesSortBar = Lib.Create("Frame", {
    Parent = UI.Pages.Emotes,
    Size = UDim2.new(1, -6, 0, 30),
    Position = UDim2.new(0, 3, 0, 55),
    BackgroundTransparency = 1,
    LayoutOrder = 2
})

local currentSortType = 2
local showingEmoteFavorites = false

local function createSortBtn(text, sortVal, posX, width)
    local btn = Lib.Create("TextButton", {
        Parent = EmotesSortBar,
        Size = UDim2.new(0, width, 1, 0),
        Position = UDim2.new(0, posX, 0, 0),
        BackgroundColor3 = Colors.Surface,
        Text = text,
        TextColor3 = Colors.TextDim,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        BorderSizePixel = 0
    })
    Lib.Create("UICorner", { Parent = btn, CornerRadius = UDim.new(0, 6) })
    local stroke = Lib.Create("UIStroke", { Parent = btn, Color = Colors.Border, Thickness = 1 })
    return btn, stroke
end

local sortButtons = {}
local function updateSortSelection(selectedBtn)
    for btn, data in pairs(sortButtons) do
        if btn == selectedBtn then
            btn.BackgroundColor3 = Colors.Active
            btn.TextColor3 = Colors.Background
            data.stroke.Color = Colors.Active
            currentSortType = data.sortType
        else
            btn.BackgroundColor3 = Colors.Surface
            btn.TextColor3 = Colors.TextDim
            data.stroke.Color = Colors.Border
        end
    end
end

local btnPopular, strokePopular = createSortBtn("Popular", 2, 0, 60)
sortButtons[btnPopular] = { stroke = strokePopular, sortType = 2 }

local btnViewed, strokeViewed = createSortBtn("Viewed", 0, 65, 60)
sortButtons[btnViewed] = { stroke = strokeViewed, sortType = 0 }

local btnLiked, strokeLiked = createSortBtn("Liked", 1, 130, 60)
sortButtons[btnLiked] = { stroke = strokeLiked, sortType = 1 }

local btnNewest, strokeNewest = createSortBtn("Newest", 3, 195, 60)
sortButtons[btnNewest] = { stroke = strokeNewest, sortType = 3 }

local FavEmotesToggleBtn, favEmotesStroke = createSortBtn("⭐ Favorites", -1, 260, 85)

updateSortSelection(btnPopular)

local EmotesScroll = Lib.Create("ScrollingFrame", {
    Parent = UI.Pages.Emotes,
    Size = UDim2.new(1, -6, 1, -100),
    Position = UDim2.new(0, 3, 0, 95),
    BackgroundTransparency = 1,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = Colors.Border,
    BorderSizePixel = 0,
    LayoutOrder = 3
})
local emotesLayout = Lib.Create("UIListLayout", {
    Parent = EmotesScroll,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 8)
})
emotesLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    EmotesScroll.CanvasSize = UDim2.new(0, 0, 0, emotesLayout.AbsoluteContentSize.Y + 10)
end)

_G.CreateEmoteCard = function(emoteData)
    local id = emoteData.id
    local cardHeight = 115
    local card = Lib.CreateStyledCard(EmotesScroll, cardHeight)
    card.Size = UDim2.new(1, -6, 0, cardHeight)

    local icon = Lib.Create("ImageLabel", {
        Parent = card,
        Size = UDim2.new(0, 95, 0, 95),
        Position = UDim2.new(0, 10, 0.5, -47.5),
        BackgroundTransparency = 1,
        Image = "rbxthumb://type=Asset&id=" .. tostring(id) .. "&w=150&h=150"
    })
    Lib.Create("UICorner", { Parent = icon, CornerRadius = UDim.new(0, 6) })
    local iconStroke = Lib.Create("UIStroke", { Parent = icon, Color = Colors.Border, Thickness = 1 })

    local titleLbl = Lib.Create("TextLabel", {
        Parent = card,
        Size = UDim2.new(1, -150, 0, 20),
        Position = UDim2.new(0, 115, 0, 8),
        BackgroundTransparency = 1,
        Text = emoteData.name or "Unknown Emote",
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClipsDescendants = true
    })

    local isFav = IsEmoteFavorite(id)
    local favBtn = Lib.Create("TextButton", {
        Parent = card,
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -30, 0, 6),
        BackgroundTransparency = 1,
        Text = isFav and "⭐" or "☆",
        TextColor3 = Colors.Active,
        Font = Enum.Font.GothamBold,
        TextSize = 14
    })
    favBtn.MouseButton1Click:Connect(function()
        ToggleEmoteFavorite(emoteData)
        favBtn.Text = IsEmoteFavorite(id) and "⭐" or "☆"
    end)

    local creatorName = emoteData.creatorName or "Roblox"
    local priceText = emoteData.price and (tostring(emoteData.price) .. " R$") or "Free / Offsale"
    
    local metaLbl = Lib.Create("TextLabel", {
        Parent = card,
        Size = UDim2.new(1, -150, 0, 16),
        Position = UDim2.new(0, 115, 0, 28),
        BackgroundTransparency = 1,
        Text = "By: " .. creatorName .. " | Price: " .. priceText,
        TextColor3 = Colors.TextDim,
        Font = Enum.Font.GothamMedium,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClipsDescendants = true
    })

    local views = emoteData.purchaseCount or math.random(1500, 8000)
    local likes = emoteData.favoriteCount or math.random(200, 1100)
    
    local statsLbl = Lib.Create("TextLabel", {
        Parent = card,
        Size = UDim2.new(0.4, 0, 0, 16),
        Position = UDim2.new(0, 115, 1, -24),
        BackgroundTransparency = 1,
        Text = "👁 " .. views .. "  👍 " .. likes,
        TextColor3 = Colors.TextDim,
        Font = Enum.Font.GothamMedium,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local playBtn = Lib.Create("TextButton", {
        Parent = card,
        Size = UDim2.new(0, 90, 0, 26),
        Position = UDim2.new(1, -100, 1, -30),
        BackgroundColor3 = Colors.Active,
        Text = "Play",
        TextColor3 = Colors.Background,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        BorderSizePixel = 0
    })
    Lib.Create("UICorner", { Parent = playBtn, CornerRadius = UDim.new(0, 4) })
    local playStroke = Lib.Create("UIStroke", { Parent = playBtn, Color = Colors.Border, Thickness = 1 })

    activePlayButtons[tostring(id)] = playBtn

    if currentPlayingEmoteId == id then
        playBtn.Text = "Stop"
        playBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
        playBtn.TextColor3 = Colors.TextMain
    end

    playBtn.MouseButton1Click:Connect(function()
        PlayEmoteById(id)
    end)

    card.Size = UDim2.new(1, -6, 0, 0)
    card.ClipsDescendants = true
    Services.TS:Create(card, TWEEN_INFO_FAST, { Size = UDim2.new(1, -6, 0, cardHeight) }):Play()
end

_G.RenderFavoriteEmotes = function()
    EmotesScroll:ClearAllChildren()
    local count = 0
    for _, emoteData in pairs(EmoteFavorites) do
        count = count + 1
        _G.CreateEmoteCard(emoteData)
    end
    if count == 0 then
        Lib.Create("TextLabel", {
            Parent = EmotesScroll,
            Size = UDim2.new(1, 0, 0, 50),
            BackgroundTransparency = 1,
            Text = "Список избранного пуст",
            TextColor3 = Colors.TextDim,
            Font = Enum.Font.GothamMedium,
            TextSize = 12
        })
    end
end

local EmoteSearchController = { IsLoading = false }

_G.SearchEmotes = function(query)
    if EmoteSearchController.IsLoading then return end
    EmoteSearchController.IsLoading = true

    EmotesScroll:ClearAllChildren()

    local loader = Lib.Create("TextLabel", {
        Parent = EmotesScroll,
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
        Text = "Загрузка эмоций...",
        TextColor3 = Colors.Active,
        Font = Enum.Font.GothamBold,
        TextSize = 12
    })

    task.spawn(function()
        local httpReq = request or http_request or (syn and syn.request)

        local domain = httpReq and "catalog.roblox.com" or "catalog.roproxy.com"
        local url = "https://" .. domain .. "/v1/search/items/details?Category=12&Subcategory=39&SortType=" .. tostring(currentSortType) .. "&Limit=30"
        
        if currentSortType == 1 or currentSortType == 2 then
            url = url .. "&SortAggregation=5"
        end

        if query and query ~= "" then
            url = url .. "&Keyword=" .. Services.Http:UrlEncode(query)
        end

        local success, response = pcall(function()
            if httpReq then
                local res = httpReq({ 
                    Url = url, 
                    Method = "GET",
                    Headers = {
                        ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
                    }
                })
                return res.Body
            else
                return game:HttpGet(url)
            end
        end)

        EmoteSearchController.IsLoading = false
        loader:Destroy()

        if not success or not response then
            Lib.Create("TextLabel", {
                Parent = EmotesScroll,
                Size = UDim2.new(1, 0, 0, 50),
                BackgroundTransparency = 1,
                Text = "Ошибка соединения. Прокси временно недоступен.",
                TextColor3 = Color3.fromRGB(255, 100, 100),
                Font = Enum.Font.GothamMedium,
                TextSize = 12
            })
            return
        end

        local decodeSuccess, decoded = pcall(function()
            return Services.Http:JSONDecode(response)
        end)

        if not decodeSuccess or not decoded or not decoded.data then
            local errMsg = "Ошибка обработки данных."
            if decoded and decoded.errors and decoded.errors[1] then
                errMsg = errMsg .. " (" .. tostring(decoded.errors[1].message) .. ")"
            end
            Lib.Create("TextLabel", {
                Parent = EmotesScroll,
                Size = UDim2.new(1, 0, 0, 50),
                BackgroundTransparency = 1,
                Text = errMsg,
                TextColor3 = Color3.fromRGB(255, 100, 100),
                Font = Enum.Font.GothamMedium,
                TextSize = 12
            })
            return
        end

        if #decoded.data == 0 then
            Lib.Create("TextLabel", {
                Parent = EmotesScroll,
                Size = UDim2.new(1, 0, 0, 50),
                BackgroundTransparency = 1,
                Text = "Эмоции не найдены.",
                TextColor3 = Colors.TextDim,
                Font = Enum.Font.GothamMedium,
                TextSize = 12
            })
            return
        end

        for _, itemData in ipairs(decoded.data) do
            _G.CreateEmoteCard(itemData)
        end
    end)
end

local function triggerSearch()
    showingEmoteFavorites = false
    FavEmotesToggleBtn.BackgroundColor3 = Colors.Surface
    FavEmotesToggleBtn.TextColor3 = Colors.TextDim
    favEmotesStroke.Color = Colors.Border
    _G.SearchEmotes(EmoteSearchInput.Text)
end

EmoteSearchBtn.MouseButton1Click:Connect(triggerSearch)
EmoteSearchInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then triggerSearch() end
end)

EmoteRefreshBtn.MouseButton1Click:Connect(function()
    if showingEmoteFavorites then
        _G.RenderFavoriteEmotes()
    else
        _G.SearchEmotes(EmoteSearchInput.Text)
    end
end)

btnPopular.MouseButton1Click:Connect(function() updateSortSelection(btnPopular) triggerSearch() end)
btnViewed.MouseButton1Click:Connect(function() updateSortSelection(btnViewed) triggerSearch() end)
btnLiked.MouseButton1Click:Connect(function() updateSortSelection(btnLiked) triggerSearch() end)
btnNewest.MouseButton1Click:Connect(function() updateSortSelection(btnNewest) triggerSearch() end)

FavEmotesToggleBtn.MouseButton1Click:Connect(function()
    showingEmoteFavorites = not showingEmoteFavorites
    if showingEmoteFavorites then
        FavEmotesToggleBtn.BackgroundColor3 = Colors.Active
        FavEmotesToggleBtn.TextColor3 = Colors.Background
        favEmotesStroke.Color = Colors.Active
        _G.RenderFavoriteEmotes()
    else
        FavEmotesToggleBtn.BackgroundColor3 = Colors.Surface
        FavEmotesToggleBtn.TextColor3 = Colors.TextDim
        favEmotesStroke.Color = Colors.Border
        _G.SearchEmotes(EmoteSearchInput.Text)
    end
end)

_G.SearchEmotes("")

local isFlinging = false
local currentFlingTarget = nil

local FlingWin, FlingClose, FlingScroll, FlingLayout, FlingActionBtn, FlingActionLbl = Lib.createFloatingMenu("Fling", 380, 380)

addRefreshBtn(FlingWin, function()
    Lib.populatePlayersAdvanced(FlingScroll, FlingLayout, FlingActionLbl, "Fling", function(p) currentFlingTarget = p end)
end)

Lib.createToggle(UI.Pages.Funny, "Fling Target", 145, false, function(st)
    FlingWin.Visible = st
    if st then 
        Lib.populatePlayersAdvanced(FlingScroll, FlingLayout, FlingActionLbl, "Fling", function(p) currentFlingTarget = p end) 
    end
end)

FlingClose.MouseButton1Click:Connect(function() FlingWin.Visible = false end)
FlingActionBtn.MouseButton1Click:Connect(function()
    if not currentFlingTarget or not currentFlingTarget.Character or isFlinging then return end
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    isFlinging = true; Lib.showNotification("Fling применяется к " .. currentFlingTarget.Name)
    local hrp = LP.Character.HumanoidRootPart; local oldPos = hrp.CFrame
    local bv = Instance.new("BodyAngularVelocity", hrp); bv.AngularVelocity = Vector3.new(0, 99999, 0); bv.MaxTorque = Vector3.new(math.huge, math.huge, math.huge); bv.P = math.huge
    local bt = Instance.new("BodyThrust", hrp); bt.Force = Vector3.new(9999, 9999, 9999); LP.Character.Humanoid.Sit = true
    local flingTime = 0; local flingCon
    flingCon = Services.Run.Stepped:Connect(function(_, dt)
        flingTime = flingTime + dt
        if flingTime > 2.5 or not currentFlingTarget.Character or not currentFlingTarget.Character:FindFirstChild("HumanoidRootPart") then
            if bv then bv:Destroy() end
            if bt then bt:Destroy() end; hrp.Velocity = Vector3.new(); hrp.RotVelocity = Vector3.new(); hrp.CFrame = oldPos; LP.Character.Humanoid.Sit = false
            isFlinging = false; flingCon:Disconnect(); return
        end
        hrp.CFrame = currentFlingTarget.Character.HumanoidRootPart.CFrame
    end)
    table.insert(UI.Connections, flingCon)
end)

local isBringing = false
local currentBringTarget = nil

local BringWin, BringClose, BringScroll, BringLayout, BringActionBtn, BringActionLbl = Lib.createFloatingMenu("Bring Parts", 380, 380)

addRefreshBtn(BringWin, function()
    Lib.populatePlayersAdvanced(BringScroll, BringLayout, BringActionLbl, "Bring", function(p) currentBringTarget = p end)
end)

Lib.createToggle(UI.Pages.Funny, "Bring Parts", 190, false, function(st)
    BringWin.Visible = st
    if st then 
        Lib.populatePlayersAdvanced(BringScroll, BringLayout, BringActionLbl, "Bring", function(p) currentBringTarget = p end) 
    end
end)
BringClose.MouseButton1Click:Connect(function() BringWin.Visible = false end)

local bringConnection = nil
local BringFolder = nil
local descConn = nil
BringActionBtn.MouseButton1Click:Connect(function()
    if not currentBringTarget or not currentBringTarget.Character then return end
    if isBringing then
        isBringing = false
        if bringConnection then bringConnection:Disconnect(); bringConnection = nil end
        if BringFolder then BringFolder:Destroy(); BringFolder = nil end
        if descConn then descConn:Disconnect(); descConn = nil end
        Lib.showNotification("Притяжение деталей остановлено")
        return
    end
    isBringing = true; Lib.showNotification("Сбор физических объектов к " .. currentBringTarget.Name)

    if not _G.SeptusNetwork then
        _G.SeptusNetwork = { BaseParts = {}, Velocity = Vector3.new(14.46262424, 14.46262424, 14.46262424) }
        _G.SeptusNetwork.RetainPart = function(Part)
            if Part:IsA("BasePart") and Part:IsDescendantOf(workspace) then
            table.insert(_G.SeptusNetwork.BaseParts, Part)
                Part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
                Part.CanCollide = false
            end
        end
        table.insert(UI.Connections, Services.Run.Heartbeat:Connect(function()
            pcall(function() sethiddenproperty(LP, "SimulationRadius", math.huge) end)
            for _, Part in pairs(_G.SeptusNetwork.BaseParts) do
                if Part:IsDescendantOf(workspace) then Part.Velocity = _G.SeptusNetwork.Velocity end
            end
        end))
    end

    BringFolder = Instance.new("Folder", workspace)
    local attPart = Instance.new("Part", BringFolder)
    attPart.Anchored = true; attPart.CanCollide = false; attPart.Transparency = 1
    local Attachment1 = Instance.new("Attachment", attPart)

    local function ForcePart(v)
        if v:IsA("BasePart") and not v.Anchored and not v.Parent:FindFirstChildOfClass("Humanoid") and not v.Parent:FindFirstChild("Head") and v.Name ~= "Handle" then
            for _, x in ipairs(v:GetChildren()) do
                if x:IsA("BodyMover") or x:IsA("RocketPropulsion") then x:Destroy() end
            end
            v.CanCollide = false
            _G.SeptusNetwork.RetainPart(v)
            local Torque = Instance.new("Torque", v)
            Torque.Torque = Vector3.new(100000, 100000, 100000)
            local AlignPosition = Instance.new("AlignPosition", v)
            local Attachment2 = Instance.new("Attachment", v)
            Torque.Attachment0 = Attachment2
            AlignPosition.MaxForce = math.huge
            AlignPosition.MaxVelocity = math.huge
            AlignPosition.Responsiveness = 200
            AlignPosition.Attachment0 = Attachment2
            AlignPosition.Attachment1 = Attachment1
        end
    end

    for _, v in ipairs(workspace:GetDescendants()) do ForcePart(v) end
    descConn = workspace.DescendantAdded:Connect(ForcePart)
    table.insert(UI.Connections, descConn)

    bringConnection = Services.Run.RenderStepped:Connect(function()
        if not isBringing or not currentBringTarget.Character then
            if descConn then descConn:Disconnect() end
            if BringFolder then BringFolder:Destroy(); BringFolder = nil end
            if bringConnection then bringConnection:Disconnect() end
            return
        end
        local hrp = currentBringTarget.Character:FindFirstChild("HumanoidRootPart")
        if hrp then Attachment1.WorldCFrame = hrp.CFrame end
    end)
    table.insert(UI.Connections, bringConnection)
end)

local ConfirmCloseWin = Lib.Create("Frame", { Parent = UI.Screen, Size = UDim2.new(0, 260, 0, 110), Position = UDim2.new(0.5, -130, 0.5, -55), BackgroundColor3 = Colors.Background, Visible = false, ZIndex = 99999 })
Lib.Create("UICorner", { Parent = ConfirmCloseWin, CornerRadius = UDim.new(0, 10) })
Lib.Create("UIStroke", { Parent = ConfirmCloseWin, Color = Colors.Border, Thickness = 1 })

local confLbl = Lib.Create("TextLabel", { Parent = ConfirmCloseWin, Size = UDim2.new(1, 0, 0, 40), Position = UDim2.new(0, 0, 0, 15), BackgroundTransparency = 1, Text = "Close the script?", TextColor3 = Colors.TextMain, Font = Enum.Font.GothamBold, TextSize = 14, ZIndex = 100000 })
local btnYes = Lib.Create("TextButton", { Parent = ConfirmCloseWin, Size = UDim2.new(0, 95, 0, 30), Position = UDim2.new(0, 25, 0, 60), BackgroundColor3 = Colors.Active, Text = "Yes", TextColor3 = Colors.Background, Font = Enum.Font.GothamBold, TextSize = 12, ZIndex = 100000 })
Lib.Create("UICorner", { Parent = btnYes, CornerRadius = UDim.new(0, 4) })
local btnNo = Lib.Create("TextButton", { Parent = ConfirmCloseWin, Size = UDim2.new(0, 95, 0, 30), Position = UDim2.new(1, -120, 0, 60), BackgroundColor3 = Colors.Surface, Text = "No", TextColor3 = Colors.TextMain, Font = Enum.Font.GothamBold, TextSize = 12, ZIndex = 100000 })
Lib.Create("UICorner", { Parent = btnNo, CornerRadius = UDim.new(0, 4) })
local noStroke = Lib.Create("UIStroke", { Parent = btnNo, Color = Colors.Border, Thickness = 1 })

btnNo.MouseButton1Click:Connect(function() ConfirmCloseWin.Visible = false end)
btnYes.MouseButton1Click:Connect(function()
    for name, updater in pairs(_G.ConfigUpdaters) do
        if name ~= "Drawing characters" and name ~= "Drawing accessories" and name ~= "Ray drawing" then
            if _G.ConfigState[name] then pcall(function() updater(false) end) end
        end
    end
    
    if _G.ConfigUpdaters["Drawing characters"] then pcall(function() _G.ConfigUpdaters["Drawing characters"](true) end) end
    if _G.ConfigUpdaters["Drawing accessories"] then pcall(function() _G.ConfigUpdaters["Drawing accessories"](true) end) end
    if _G.ConfigUpdaters["Ray drawing"] then pcall(function() _G.ConfigUpdaters["Ray drawing"](true) end) end
    
    for _, conn in pairs(UI.Connections) do if conn.Disconnect then conn:Disconnect() end end
    for _, draw in pairs(_G.pDrawings) do draw.box:Remove(); draw.tracer:Remove() end
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then LP.Character.HumanoidRootPart.Anchored = false end
    
    local L = Services.Lighting
    L.GlobalShadows = true
    for _, obj in pairs(L:GetChildren()) do
        if obj.Name == "RetroCC" or obj.Name == "CustomSky" or obj.Name == "RTXShaders" or obj.Name == "CyberShaders" or obj.Name == "SilentShaders" or obj.Name == "FriedShaders" or obj.Name == "NightVisionShaders" or obj.Name == "SeptusBlur" then
            obj:Destroy()
        end
    end
    UI.Screen:Destroy()
end)

CloseBtn.MouseButton1Click:Connect(function() ConfirmCloseWin.Visible = true end)

local ToggleBtn = Lib.Create("TextButton", {
    Parent = UI.Screen,
    Size = UDim2.new(0, 44, 0, 44),
    Position = UDim2.new(0, 20, 0.5, -22),
    BackgroundColor3 = Colors.Surface,
    Text = "",
    Visible = false,
    BorderSizePixel = 0
})
Lib.Create("UICorner", { Parent = ToggleBtn, CornerRadius = UDim.new(0, 10) })
local toggleStroke = Lib.Create("UIStroke", { Parent = ToggleBtn, Color = Colors.Active, Thickness = 1 })

local toggleIcon = Lib.Create("ImageLabel", {
    Parent = ToggleBtn,
    Size = UDim2.new(1, -12, 1, -12),
    Position = UDim2.new(0, 6, 0, 6),
    BackgroundTransparency = 1,
    Image = "rbxassetid://83309664199973"
})

_G.UpdateToggleIcon = function(id) if toggleIcon then toggleIcon.Image = id end end
Lib.makeDraggable(ToggleBtn)

local blurEffect = Instance.new("BlurEffect", Services.Lighting)
blurEffect.Size = 0
blurEffect.Name = "SeptusBlur"

ToggleBtn.MouseButton1Click:Connect(function()
    UI.State.isGuiVisible = not UI.State.isGuiVisible
    if UI.State.isGuiVisible then
        UI.Frame.Visible = true

        local targetSize = UI.State.isMinimized and UDim2.new(0, 520, 0, 38) or UDim2.new(0, 520, 0, 340)
        local targetBlur = UI.State.isMinimized and 0 or 15
        
        Services.TS:Create(UI.Frame, TWEEN_INFO_SMOOTH, { Size = targetSize, Position = UDim2.new(0.5, -260, 0.5, -170), BackgroundTransparency = 0 }):Play()
        Services.TS:Create(blurEffect, TWEEN_INFO_SMOOTH, { Size = targetBlur }):Play()
        ContentFrame.Visible = not UI.State.isMinimized
    else
        local shrink = Services.TS:Create(UI.Frame, TWEEN_INFO_SMOOTH, { Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0) })
        Services.TS:Create(blurEffect, TWEEN_INFO_SMOOTH, { Size = 0 }):Play()
        shrink:Play()
        shrink.Completed:Wait()
        if not UI.State.isGuiVisible then UI.Frame.Visible = false end
    end
end)

MinBtn.MouseButton1Click:Connect(function()
    UI.State.isMinimized = not UI.State.isMinimized
    if UI.State.isMinimized then
        Services.TS:Create(UI.Frame, TWEEN_INFO_SMOOTH, { Size = UDim2.new(0, 520, 0, 38) }):Play()
        Services.TS:Create(blurEffect, TWEEN_INFO_SMOOTH, { Size = 0 }):Play()
        ContentFrame.Visible = false
    else
        Services.TS:Create(UI.Frame, TWEEN_INFO_SMOOTH, { Size = UDim2.new(0, 520, 0, 340) }):Play()
        Services.TS:Create(blurEffect, TWEEN_INFO_SMOOTH, { Size = 15 }):Play()
        ContentFrame.Visible = true
    end
end)

task.spawn(function()
    repeat task.wait() until _G.MainMenuLoaded == true
    ToggleBtn.Visible = true
    Lib.showNotification("SEPTUS HUB успешно загружен!")
    
    local HomeBtn = Sidebar:FindFirstChild("HomeBtn")
    if HomeBtn then
        HomeBtn.Indicator.Size = UDim2.new(0, 3, 0, 16)
        HomeBtn.Indicator.BackgroundTransparency = 0
        HomeBtn.TextColor3 = Colors.TextMain
        ActiveTab = "Home"
        UI.Pages.Home.Visible = true
    end
end)

local executor = "Unknown"
pcall(function() if identifyexecutor then executor = identifyexecutor() elseif getexecutorname then executor = getexecutorname() end end)
local execLabel = Lib.Create("TextLabel", { Parent = UI.Frame, Size = UDim2.new(0, 100, 0, 20), Position = UDim2.new(1, -235, 0, 8), BackgroundTransparency = 1, Text = "Executor: " .. executor, TextColor3 = Colors.TextDim, Font = Enum.Font.GothamBold, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Right })
