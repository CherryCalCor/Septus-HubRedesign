local Services = {
	Players = game:GetService("Players"),
	Tween = game:GetService("TweenService"),
	Run = game:GetService("RunService"),
	Stats = game:GetService("Stats"),
	HttpService = game:GetService("HttpService"),
	InsertService = game:GetService("InsertService"),
	Lighting = game:GetService("Lighting"),
	Workspace = game:GetService("Workspace"),
	Teleport = game:GetService("TeleportService"),
	UserInputService = game:GetService("UserInputService"),
	GuiService = game:GetService("GuiService"),
	VirtualUser = game:GetService("VirtualUser"),
	SoundService = game:GetService("SoundService")
}

local App = {
	Player = Services.Players.LocalPlayer,
	Camera = Services.Workspace.CurrentCamera,

	UI = {
		Screen = nil,
		Main = nil,
		MainCorner = nil,
		HeaderLogo = nil,
		HeaderIcon = nil,
		ContentArea = nil,
		TopNavContainer = nil,
		WindowBtns = nil,
		PlaytimeTextLabel = nil,
		AchUpdateCallback = nil,
		NavElements = {},
		CurrentHoveredNav = nil,
		NotifContainer = nil,
		ActiveNotifs = {},
		BackgroundContainer = nil,
		CustomBgImage = nil,

		Graphs = { FPS = {}, Ping = {}, Players = {} }, Labels = {},
		ThemeElements = {},
		PanelElements = {},
		TextThemeElements = {},
		Switches = {}
	},

	State = {
		Minimized = false, Maximized = false,
		ActiveMain = "",
		CurrentTab = "", CurrentScriptsTab = "", CurrentEmotesTab = "", CurrentFeaturesTab = "", CurrentSettingsTab = "",
		OriginalSize = UDim2.fromOffset(800, 540),
		MenuAnim = "Standard",
		CornerRadius = 10,
		SelectedThemeIndex = 1,
		SelectedFontIndex = 1,
		ThemeColor = Color3.fromRGB(18, 18, 18),
		WindowTransparency = 0,
		PanelTransparency = 0,
		HideLogo = false,
		HideName = false,
		LightTheme = false,
		CustomTheme = nil,
		CustomThemes = {},
		CustomBackgroundId = "",
		BgOpacity = 85,
		AnimatedBgEnabled = false,
		BgZoom = 100,
		BgSaturation = 100,
		MusicVolume = 50,
		MusicFocus = false,
		MusicVisualizer = true,

		NotificationsEnabled = true,
		PlayerNotifsEnabled = true,

		ScriptsPage = 1, ScriptsTotalPages = 1, ScriptsLoading = false, ScriptsCache = {}, ScriptsGen = 0, ScriptsCount = 0, ScriptsBackoff = 0,
		ScriptsSources = { Rscripts = true }, ScriptsSort = "Relevance", ScriptsShow = "New", ScriptsOrder = "Descending", ScriptsGame = "", ScriptsQuery = "",

		EmotesPage = 1, EmotesTotalPages = 1, EmotesLoading = false,
		EmotesCache = {},
		AnimationPacksCache = {},
		AnimationIdCache = {},
		BundleAnimCache = {},
		EmotesCategory = "Emotes",
		EmotesSort = "Most Liked",
		EmotesQuery = "",
		EmotesGen = 0,

		CurrentEmoteTrack = nil,
		CurrentActiveBundle = nil,
		CurrentPlayingAssetId = nil,
		CurrentEmoteButton = nil,

		ESP_Name = false,
		ESP_Outline = false,
		ESP_Box = false,
		ESP_Tracers = false,
		BoostFPS = false,
		FullBright = false,
		Tool_RemoveTexture = false,
		Tool_PartDeleted = false,
		Tool_Teleport = false,

		WalkSpeed = 16,
		JumpPower = 50,
		Fly = false,
		FlySpeed = 50,
		FlyAntiSit = true,

		AntiFling = false,
		AntiSit = false,
		AntiVoid = false,
		AntiStun = false,
		AntiRagdoll = false,

		Shader_RTX = false,
		Shader_Cyberpunk = false,
		Shader_SilentHill = false,

		AntiAFK = false,
		Noclip = false,
		AutoReconnect = false,
		InvisFE = false,
		FOV = 70,
		BunnyHop = false,
		BunnyMaxSpeed = 80,
		BunnyNoLimit = false,
		BunnyAutoJump = true,

		StalkTarget = nil,
		StalkActive = false,
		StalkOffsetX = 0,
		StalkOffsetY = 0,
		StalkOffsetZ = 3,
		StalkDisableMovement = false,

		FakeLagSuspension = false,
		FakeLagUsual = false,

		FlingTarget = nil,
		IsFlinging = false,

		BringTarget = nil,
		IsBringing = false,

		ServerList = {
			IsOpen = false,
			Loading = false,
			Sort = "Most Players",
			FillState = "All",
			PercentRange = "All"
		},

		TeleportTarget = nil,
		IsSpectating = false,

		TotalPlaytimeSeconds = 0,
		LastActivityTick = os.clock(),
		IsDecorActive = false,
		Ach_10Hours_Claimed = false
	},

	Refs = {
		HoverBox = nil,
		FlyBV = nil,
		FlyBG = nil,
		InvisConn = nil,
		LastSafeCF = nil,
		ShaderFolder = nil,
		OrigLighting = {},
		OriginalAnims = nil,
		ESP = {},
		Tools = {},
		IntroBlur = nil,
		StalkConn = nil,
		BringFolder = nil,
		BringConn = nil,
		DescConn = nil
	},

	API = {},
	Lib = {},
	Handlers = {}
}

local Lib = App.Lib
local API = App.API
local State = App.State
local UI = App.UI
local Refs = App.Refs

Lib.Conns = {}
Refs.OrigFOV = App.Camera and App.Camera.FieldOfView or 70

function Lib.C(signal, callback)
	local connection = signal:Connect(callback)
	Lib.Conns[#Lib.Conns + 1] = connection
	return connection
end

local ClickSound = Instance.new("Sound")
ClickSound.SoundId = "rbxassetid://6895079853"
ClickSound.Volume = 0.5
ClickSound.Parent = Services.SoundService

function Lib.PlayClick()
	pcall(function()
		ClickSound:Play()
	end)
end

Lib.ToggleControls = {}
Lib.SliderControls = {}
Lib.ChoiceControls = {}
Lib.ConfigExtras = {}
Lib.FontSelectors = {}
Lib.BoundCorners = {}
Lib.ImageTheme = {}
Lib.ThemeHooks = {}

function Lib.BindCorner(parent, name)
	local corner = Instance.new("UICorner")
	corner.Name = name
	corner.CornerRadius = UDim.new(0, State.CornerRadius)
	corner.Parent = parent
	Lib.BoundCorners[corner] = true
	return corner
end

function Lib.SetCornerRadius(radius)
	State.CornerRadius = radius
	local value = UDim.new(0, radius)
	UI.MainCorner.CornerRadius = value
	for corner in pairs(Lib.BoundCorners) do
		if corner.Parent then
			corner.CornerRadius = value
		else
			Lib.BoundCorners[corner] = nil
		end
	end
end

function Lib.RegisterThemeImage(image)
	Lib.ImageTheme[image] = true
	image.ImageColor3 = Lib.Palette.Primary
end

function Lib.ResolveImage(value)
	local id = tonumber(value) and value or value:match("rbxassetid://(%d+)") or value:match("[?&]id=(%d+)") or value:match("/library/(%d+)") or value:match("/catalog/(%d+)")
	return id and ("rbxassetid://" .. id) or value, id
end

do
	local FontRoles = {}
	local BoldFonts = {
		[Enum.Font.GothamBold] = true,
		[Enum.Font.SourceSansBold] = true,
		[Enum.Font.RobotoCondensed] = true,
		[Enum.Font.FredokaOne] = true
	}

	Lib.TextClasses = { TextLabel = true, TextButton = true, TextBox = true }

	function Lib.StyleFont(inst)
		local role = FontRoles[inst]
		if not role then
			role = BoldFonts[inst.Font] and 2 or 1
			FontRoles[inst] = role
		end
		inst.Font = role == 2 and State.CurrentBoldFont or State.CurrentRegularFont
	end
end

function Lib.Create(className, props)
	local inst = Instance.new(className)
	if props then
		for k, v in pairs(props) do
			if type(k) == "number" then
				v.Parent = inst
			elseif k ~= "Parent" then
				inst[k] = v
			end
		end
	end
	if State.CurrentRegularFont and Lib.TextClasses[className] then Lib.StyleFont(inst) end
	if props and props.Parent then inst.Parent = props.Parent end
	return inst
end

function Lib.Tween(obj, time, style, dir, props)
	local tween = Services.Tween:Create(obj, TweenInfo.new(time, style, dir), props)
	tween:Play()
	return tween
end

Lib.SearchIcon = "rbxassetid://10734943674"

function Lib.MakeSearchBox(parent, placeholder, position, size, delay, onChange)
	local holder = Lib.Create("Frame", {
		Size = size, Position = position, BackgroundColor3 = Color3.fromRGB(22, 22, 22), Parent = parent,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 7) })
	})
	Lib.RegisterThemeElement(holder, "BackgroundColor3", 0.7, true)

	local box = Lib.Create("TextBox", {
		Size = UDim2.new(1, -42, 1, 0), Position = UDim2.fromOffset(12, 0), BackgroundTransparency = 1, Text = "",
		PlaceholderText = placeholder, PlaceholderColor3 = Color3.fromRGB(110, 110, 110), TextColor3 = Color3.fromRGB(240, 240, 240),
		TextSize = 12, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Parent = holder
	})
	Lib.RegisterThemeText(box, "Primary")

	local icon = Lib.Create("ImageLabel", {
		Size = UDim2.fromOffset(14, 14), Position = UDim2.new(1, -26, 0.5, -7), BackgroundTransparency = 1,
		Image = Lib.SearchIcon, ImageTransparency = 0.3, ScaleType = Enum.ScaleType.Fit, Parent = holder
	})
	Lib.RegisterThemeImage(icon)

	local ticket = 0
	box:GetPropertyChangedSignal("Text"):Connect(function()
		local text = box.Text:match("^%s*(.-)%s*$")
		if delay <= 0 then return onChange(text) end
		ticket += 1
		local mine = ticket
		task.delay(delay, function()
			if mine == ticket then onChange(text) end
		end)
	end)
	return box, holder
end

Lib.ThemeCount = 0
Lib.Theme = {
	Base = Color3.fromRGB(18, 18, 18),
	Main = Color3.fromRGB(0, 0, 0),
	Card = Color3.fromRGB(15, 15, 15),
	Item = Color3.fromRGB(22, 22, 22)
}

Lib.Palette = {
	Primary = Color3.fromRGB(245, 245, 245),
	Secondary = Color3.fromRGB(145, 145, 145),
	SwitchOn = Color3.fromRGB(46, 213, 115),
	SwitchOff = Color3.fromRGB(38, 38, 38)
}

Lib.ThemePresets = {
	Color3.fromRGB(18, 18, 18), Color3.fromRGB(225, 29, 52), Color3.fromRGB(45, 125, 245),
	Color3.fromRGB(155, 100, 245), Color3.fromRGB(255, 75, 75), Color3.fromRGB(46, 213, 115),
	Color3.fromRGB(255, 205, 50), Color3.fromRGB(0, 225, 225), Color3.fromRGB(255, 130, 200),
	Color3.fromRGB(60, 75, 105), Color3.fromRGB(75, 45, 75), Color3.fromRGB(255, 255, 255)
}

Lib.HalloweenTheme = {
	Name = "Halloween",
	Halloween = true,
	Background = Color3.fromRGB(14, 9, 18),
	Surface = Color3.fromRGB(26, 16, 30),
	Item = Color3.fromRGB(40, 24, 42),
	Text = Color3.fromRGB(255, 238, 220),
	Muted = Color3.fromRGB(178, 142, 122),
	Accent = Color3.fromRGB(255, 122, 24),
	SwitchOff = Color3.fromRGB(60, 40, 54)
}

Lib.HalloweenAssets = { Pumpkin = "", Web = "", Bat = "", Ghost = "" }
Lib.HalloweenEmoji = { Pumpkin = "🎃", Web = "🕸️", Bat = "🦇", Ghost = "👻" }

function Lib.ThemeColor(factor)
	if factor == 0.5 then return Lib.Theme.Card end
	if factor == 0.7 then return Lib.Theme.Item end
	return Lib.Theme.Base
end

function Lib.Lighten(color, amount)
	return color:Lerp(Color3.new(1, 1, 1), amount)
end

function Lib.Luma(color)
	return color.R * 0.299 + color.G * 0.587 + color.B * 0.114
end

function Lib.ResolveTheme(index)
	if index == 0 then return Lib.HalloweenTheme end
	local presets = Lib.ThemePresets
	if index <= #presets then return presets[index] end
	return State.CustomThemes[index - #presets]
end

function Lib.RegisterThemeElement(element, propType, darkMultiplier, panel)
	local prop, factor = propType or "BackgroundColor3", darkMultiplier or 1
	element[prop] = Lib.ThemeColor(factor)
	UI.ThemeElements[element] = { prop, factor }
	Lib.ThemeCount = Lib.ThemeCount + 1
	if (factor == 0.5 or panel) and prop == "BackgroundColor3" and element.BackgroundTransparency == 0 then
		element.BackgroundTransparency = State.PanelTransparency / 100
		UI.PanelElements[element] = true
	end
	element.Destroying:Connect(function()
		UI.ThemeElements[element] = nil
		UI.PanelElements[element] = nil
		Lib.ThemeCount = Lib.ThemeCount - 1
	end)
end

function Lib.RegisterThemeText(element, role)
	UI.TextThemeElements[element] = role or "Primary"
	element.Destroying:Connect(function()
		UI.TextThemeElements[element] = nil
	end)
end

function Lib.RegisterSwitch(switchBg, getStateFunc, updateKnobFunc)
	table.insert(UI.Switches, { Bg = switchBg, GetState = getStateFunc, UpdateKnob = updateKnobFunc })
	switchBg.Destroying:Connect(function()
		for i, sw in ipairs(UI.Switches) do
			if sw.Bg == switchBg then
				table.remove(UI.Switches, i)
				break
			end
		end
	end)
end

function Lib.GetActiveSwitchColor()
	return Lib.Palette.SwitchOn
end

function Lib.ApplyPanelTransparency()
	local value = State.PanelTransparency / 100
	for element in pairs(UI.PanelElements) do
		element.BackgroundTransparency = value
	end
end

function Lib.ApplyHeader()
	UI.HeaderIcon.Visible = not State.HideLogo
	UI.HeaderLogo.Visible = not State.HideName
	UI.HeaderLogo.Position = UDim2.fromOffset(State.HideLogo and 14 or 66, 10)
end

function Lib.ApplyTheme(spec, instant)
	local theme, palette = Lib.Theme, Lib.Palette
	local light

	if typeof(spec) == "Color3" then
		local r, g, b = spec.R, spec.G, spec.B
		light = r > 0.9 and g > 0.9 and b > 0.9
		local isDefaultBlack = math.floor(r * 255) == 18 and math.floor(g * 255) == 18 and math.floor(b * 255) == 18

		State.ThemeColor = spec
		State.CustomTheme = nil
		theme.Base = spec

		if isDefaultBlack then
			theme.Main, theme.Card, theme.Item = Color3.fromRGB(0, 0, 0), Color3.fromRGB(15, 15, 15), Color3.fromRGB(22, 22, 22)
		elseif light then
			theme.Main, theme.Card, theme.Item = Color3.fromRGB(242, 242, 244), Color3.fromRGB(255, 255, 255), Color3.fromRGB(232, 234, 238)
		else
			local function Scale(k)
				return Color3.new(math.clamp(r * k, 0, 1), math.clamp(g * k, 0, 1), math.clamp(b * k, 0, 1))
			end
			if Lib.Luma(spec) > 0.65 then
				theme.Main, theme.Card, theme.Item = Scale(0.92), Scale(0.98), Scale(0.85)
			else
				theme.Main, theme.Card, theme.Item = Scale(0.45), Scale(0.65), Scale(0.85)
			end
		end

		palette.Primary = light and Color3.fromRGB(15, 15, 15) or Color3.fromRGB(245, 245, 245)
		palette.Secondary = light and Color3.fromRGB(85, 85, 85) or Color3.fromRGB(145, 145, 145)
		palette.SwitchOff = light and Color3.fromRGB(205, 205, 210) or Color3.fromRGB(38, 38, 38)
		palette.SwitchOn = light and Color3.fromRGB(20, 20, 20) or (isDefaultBlack and Color3.fromRGB(46, 213, 115) or spec)
	else
		light = Lib.Luma(spec.Background) > 0.6

		State.ThemeColor = spec.Accent
		State.CustomTheme = spec
		theme.Base, theme.Main, theme.Card, theme.Item = spec.Background, spec.Background, spec.Surface, spec.Item

		palette.Primary = spec.Text
		palette.Secondary = spec.Muted
		palette.SwitchOn = spec.Accent
		palette.SwitchOff = spec.SwitchOff
	end

	State.LightTheme = light

	if Lib.SetHalloweenDecor then
		Lib.SetHalloweenDecor(typeof(spec) == "table" and spec.Halloween == true)
	end

	if UI.Main then
		if instant then
			UI.Main.BackgroundColor3 = theme.Main
		else
			Lib.Tween(UI.Main, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = theme.Main })
		end
	end

	if UI.HeaderLogo then
		UI.HeaderLogo.Image = light and "rbxassetid://105446913647633" or "rbxassetid://97808676894113"
	end

	local animate = not instant and Lib.ThemeCount <= 150

	for element, data in pairs(UI.ThemeElements) do
		local color = Lib.ThemeColor(data[2])
		if animate then
			Lib.Tween(element, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { [data[1]] = color })
		else
			element[data[1]] = color
		end
	end

	for element, role in pairs(UI.TextThemeElements) do
		local color = role == "Primary" and palette.Primary or palette.Secondary
		if animate then
			Lib.Tween(element, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { TextColor3 = color })
		else
			element.TextColor3 = color
		end
	end

	for _, bars in pairs(UI.Graphs) do
		for _, bar in ipairs(bars) do
			bar.BackgroundColor3 = palette.Primary
		end
	end

	for image in pairs(Lib.ImageTheme) do
		image.ImageColor3 = palette.Primary
	end

	for _, hook in ipairs(Lib.ThemeHooks) do
		pcall(hook)
	end

	for _, sw in ipairs(UI.Switches) do
		local color = sw.GetState() and palette.SwitchOn or palette.SwitchOff
		if instant then
			sw.Bg.BackgroundColor3 = color
		else
			Lib.Tween(sw.Bg, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = color })
		end
	end

	if Lib.RecalculateNavPositions then
		Lib.RecalculateNavPositions()
	end
end

do
	local users = 0

	local function Prepare(backdrop)
		if backdrop:FindFirstChild("GlassCorner") then return end
		Lib.BindCorner(backdrop, "GlassCorner")
		Lib.Create("UIGradient", {
			Name = "GlassSheen",
			Rotation = 90,
			Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(200, 200, 200)),
			Parent = backdrop
		})
	end

	function Lib.GlassOpen(backdrop)
		users = users + 1
		Prepare(backdrop)
		local light = State.LightTheme
		backdrop.BackgroundColor3 = light and Color3.new(1, 1, 1) or Lib.Theme.Main:Lerp(Color3.new(1, 1, 1), 0.2)
		backdrop.BackgroundTransparency = 1
		backdrop.Visible = true
		Lib.Tween(backdrop, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundTransparency = light and 0.3 or 0.4 })
	end

	function Lib.GlassClose(backdrop, onDone)
		users = math.max(users - 1, 0)
		Lib.Tween(backdrop, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In, { BackgroundTransparency = 1 }).Completed:Connect(onDone)
	end
end

function Lib.ApplyGlobalFont(regularFont, boldFont)
	State.CurrentRegularFont = regularFont
	State.CurrentBoldFont = boldFont or regularFont
	if not UI.Screen then return end
	for _, inst in ipairs(UI.Screen:GetDescendants()) do
		if Lib.TextClasses[inst.ClassName] then Lib.StyleFont(inst) end
	end
end

function Lib.Notify(options)
	if not State.NotificationsEnabled then return end
	if not UI.NotifContainer then return end

	local isWhite = State.LightTheme
	local bgColor = isWhite and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(14, 14, 14)
	local textColor = isWhite and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(250, 250, 250)
	local subTextColor = isWhite and Color3.fromRGB(100, 100, 100) or Color3.fromRGB(140, 140, 140)

	local title = options.Title or "Notification"
	local text = options.Text or ""
	local duration = options.Duration or 3.5
	local userId = options.UserId

	local notifFrame = Lib.Create("Frame", {
		Size = UDim2.fromOffset(260, 60),
		Position = UDim2.new(1, 280, 1, 0),
		BackgroundColor3 = bgColor,
		BorderSizePixel = 0,
		Parent = UI.NotifContainer,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) })
	})

	local contentX = 12
	if userId then
		contentX = 52
		local avatar = Lib.Create("ImageLabel", {
			Size = UDim2.fromOffset(36, 36),
			Position = UDim2.new(0, 8, 0.5, -18),
			BackgroundTransparency = 1,
			Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(userId) .. "&w=100&h=100",
			Parent = notifFrame,
			Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) })
		})
	end

	local tLbl = Lib.Create("TextLabel", {
		Size = UDim2.new(1, -(contentX + 10), 0, 18),
		Position = UDim2.new(0, contentX, 0, 10),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = textColor,
		TextSize = 12,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = notifFrame
	})

	local mText = Lib.Create("TextLabel", {
		Size = UDim2.new(1, -(contentX + 10), 0, 16),
		Position = UDim2.new(0, contentX, 0, 28),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = subTextColor,
		TextSize = 11,
		Font = Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = notifFrame
	})

	table.insert(UI.ActiveNotifs, notifFrame)

	local function RepositionNotifs()
		for i, n in ipairs(UI.ActiveNotifs) do
			local targetY = -(i * 68)
			Lib.Tween(n, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Position = UDim2.new(1, -270, 1, targetY) })
		end
	end

	RepositionNotifs()

	task.delay(duration, function()
		if notifFrame and notifFrame.Parent then
			local out = Lib.Tween(notifFrame, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In, { Position = UDim2.new(1, 280, notifFrame.Position.Y.Scale, notifFrame.Position.Y.Offset) })
			out.Completed:Connect(function()
				local idx = table.find(UI.ActiveNotifs, notifFrame)
				if idx then table.remove(UI.ActiveNotifs, idx) end
				notifFrame:Destroy()
				RepositionNotifs()
			end)
		end
	end)
end

function Lib.CreateTabSystem(section, sideBar, stateKey, onSwitch)
	local views, btns, icons = {}, {}, {}

	local function Tint(name, color, time)
		local icon = icons[name]
		if icon then Lib.Tween(icon, time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { ImageColor3 = color }) end
	end

	local function Switch(tabName)
		if State[stateKey] == tabName then return end
		State[stateKey] = tabName

		local isWhite = State.LightTheme

		for name, view in pairs(views) do
			local isSel = (name == tabName)
			local selColor = isWhite and Color3.fromRGB(15, 15, 15) or Color3.fromRGB(255, 255, 255)
			local unselColor = isWhite and Color3.fromRGB(110, 110, 110) or Color3.fromRGB(150, 150, 150)

			Lib.Tween(btns[name], 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
				TextColor3 = isSel and selColor or unselColor,
				BackgroundTransparency = isSel and (isWhite and 0.88 or 0.92) or 1
			})

			Tint(name, isSel and selColor or unselColor, 0.2)

			if isSel then
				view.Visible = true
				view.Position = UDim2.new(0, 195, 0, 10)
				view.GroupTransparency = 1
				Lib.Tween(view, 0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, { Position = UDim2.new(0, 180, 0, 10), GroupTransparency = 0 })
			elseif view.Visible then
				Lib.Tween(view, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Position = UDim2.new(0, 170, 0, 10), GroupTransparency = 1 }).Completed:Connect(function()
					if State[stateKey] ~= name then view.Visible = false end
				end)
			end
		end

		if onSwitch then onSwitch(tabName) end
	end

	local function Make(name, posY, iconId)
		local isWhite = State.LightTheme
		local btn = Lib.Create("TextButton", {
			Size = UDim2.new(1, -30, 0, 34),
			Position = UDim2.new(0, 15, 0, posY),
			BackgroundColor3 = isWhite and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			Text = name,
			TextColor3 = isWhite and Color3.fromRGB(110, 110, 110) or Color3.fromRGB(150, 150, 150),
			TextSize = 14,
			Font = Enum.Font.GothamMedium,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = sideBar,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 7) }),
			Lib.Create("UIPadding", { PaddingLeft = UDim.new(0, 12) })
		})

		local view = Lib.Create("CanvasGroup", {
			Name = name,
			Size = UDim2.new(1, -190, 1, -20),
			Position = UDim2.new(0, 180, 0, 10),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Visible = false,
			GroupTransparency = 1,
			Parent = section
		})

		views[name], btns[name] = view, btn

		if iconId then
			local icon = Lib.Create("ImageLabel", {
				Size = UDim2.fromOffset(16, 16), Position = UDim2.new(0, 0, 0.5, -8), BackgroundTransparency = 1,
				Image = "rbxassetid://" .. iconId, ImageColor3 = btn.TextColor3, ScaleType = Enum.ScaleType.Fit, Parent = btn
			})
			icons[name] = icon
			local function Place() icon.Position = UDim2.new(0, btn.TextBounds.X + 8, 0.5, -8) end
			btn:GetPropertyChangedSignal("TextBounds"):Connect(Place)
			Place()
		end

		btn.MouseEnter:Connect(function()
			local currentWhite = State.LightTheme
			if State[stateKey] ~= name then
				Tint(name, currentWhite and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(210, 210, 210), 0.15)
				Lib.Tween(btn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
					TextColor3 = currentWhite and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(210, 210, 210),
					BackgroundTransparency = currentWhite and 0.92 or 0.96
				})
			end
		end)
		btn.MouseLeave:Connect(function()
			local currentWhite = State.LightTheme
			Lib.Tween(btn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Size = UDim2.new(1, -30, 0, 34) })
			if State[stateKey] ~= name then
				Tint(name, currentWhite and Color3.fromRGB(110, 110, 110) or Color3.fromRGB(150, 150, 150), 0.15)
				Lib.Tween(btn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
					TextColor3 = currentWhite and Color3.fromRGB(110, 110, 110) or Color3.fromRGB(150, 150, 150),
					BackgroundTransparency = 1
				})
			end
		end)
		btn.MouseButton1Down:Connect(function()
			Lib.PlayClick()
			Lib.Tween(btn, 0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Size = UDim2.new(1, -36, 0, 31) })
		end)
		btn.MouseButton1Up:Connect(function()
			Lib.Tween(btn, 0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Size = UDim2.new(1, -30, 0, 34) })
		end)
		btn.MouseButton1Click:Connect(function() Switch(name) end)

		return view
	end

	return Switch, Make
end

function Lib.Timed(fn, limit)
	local done, ok, result = false, false, nil
	task.spawn(function()
		ok, result = pcall(fn)
		done = true
	end)
	local started = os.clock()
	while not done and os.clock() - started < limit do task.wait(0.05) end
	if not done then return false, "timed out" end
	return ok, result
end

function API.HTTPRequest(url)
	local agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
	local headerSets = {
		{ ["User-Agent"] = agent },
		{ ["User-Agent"] = agent, ["Roblox-Place-Id"] = "", ["Roblox-Game-Id"] = "", ["Roblox-Universe-Id"] = "" }
	}
	local req = (syn and syn.request) or http_request or request or (fluxus and fluxus.request) or (http and http.request)
	local hasGet, httpGet = pcall(function() return game.HttpGet end)
	hasGet = hasGet and type(httpGet) == "function"
	local reasons = {}

	local function Note(host, text)
		reasons[#reasons + 1] = host .. ": " .. tostring(text):sub(1, 140)
	end

	local function Accept(host, body)
		if type(body) ~= "string" or body == "" then
			Note(host, "empty body")
			return nil
		end
		if body:find("In experience search is denied", 1, true) then
			Note(host, "in-experience search denied")
			return nil
		end
		local head = body:sub(1, 120):lower()
		if head:find("<!doctype", 1, true) or head:find("<html", 1, true) then
			Note(host, "HTML response (blocked or rate limited)")
			return nil
		end
		return body
	end

	local function Attempt(target)
		local host = target:match("//([^/]+)") or target
		if type(req) == "function" then
			for _, headers in ipairs(headerSets) do
				local ok, res = Lib.Timed(function()
					return req({ Url = target, Method = "GET", Headers = headers })
				end, 8)
				if not ok then
					Note(host, "request error " .. tostring(res))
				elseif type(res) ~= "table" then
					Note(host, "empty response")
				elseif res.StatusCode and (res.StatusCode < 200 or res.StatusCode >= 300) then
					local body = Accept(host, res.Body)
					if body then Note(host, "HTTP " .. res.StatusCode) end
				else
					local body = Accept(host, res.Body)
					if body then return body end
				end
			end
		end
		if hasGet then
			local ok, body = Lib.Timed(function() return game:HttpGet(target) end, 8)
			if ok then
				local accepted = Accept(host, body)
				if accepted then return accepted end
			else
				Note(host, "HttpGet error " .. tostring(body))
			end
		end
		if type(req) ~= "function" and not hasGet then
			Note(host, "executor has no HTTP function")
		end
	end

	local body = Attempt(url)
	if body then return true, body end

	if url:find("roblox%.com") then
		body = Attempt((url:gsub("roblox%.com", "roproxy.com")))
		if body then return true, body end
	end

	return false, nil, table.concat(reasons, "; ")
end

do
	local PLAYTIME_FILE = "SeptusHub_Playtime.txt"
	local ACH_FILE = "SeptusHub_Achievements.json"
	local FIRST_FILE = "SeptusHub_FirstLaunch.txt"

	local SECRET_SALT = 8492019

	local function HashIntegrity(val)
		local num = tonumber(val) or 0
		local h = (num * 31 + SECRET_SALT + App.Player.UserId) % 999999937
		return string.format("%08x", math.floor(h))
	end

	function Lib.GetFirstLaunch()
		local date = ""
		if isfile and readfile and isfile(FIRST_FILE) then
			pcall(function()
				local raw = readfile(FIRST_FILE)
				local parts = string.split(raw, "||")
				if #parts == 2 and parts[2] == HashIntegrity(#parts[1]) then
					date = parts[1]
				end
			end)
		end
		if date == "" or not date then
			date = os.date("%d.%m.%Y %H:%M")
			if writefile then
				local content = date .. "||" .. HashIntegrity(#date)
				pcall(writefile, FIRST_FILE, content)
			end
		end
		return date
	end

	function Lib.LoadPlaytimeData()
		if isfile and readfile and isfile(PLAYTIME_FILE) then
			pcall(function()
				local raw = readfile(PLAYTIME_FILE)
				local parts = string.split(raw, "||")
				if #parts == 2 then
					local sec = tonumber(parts[1]) or 0
					if parts[2] == HashIntegrity(sec) then
						State.TotalPlaytimeSeconds = sec
					end
				end
			end)
		end
		if isfile and readfile and isfile(ACH_FILE) then
			pcall(function()
				local raw = readfile(ACH_FILE)
				local parts = string.split(raw, "||")
				if #parts == 2 then
					local data = Services.HttpService:JSONDecode(parts[1])
					if parts[2] == HashIntegrity(#parts[1]) then
						State.Ach_10Hours_Claimed = data.Ach_10Hours_Claimed or false
						State.IsDecorActive = data.IsDecorActive or false
					end
				end
			end)
		end

		if App.Player.Name:lower() == "cherrycalcor" then
			State.Ach_10Hours_Claimed = true
			State.IsDecorActive = true
			if State.TotalPlaytimeSeconds < 36000 then
				State.TotalPlaytimeSeconds = 36000
			end
		end
	end

	function Lib.SavePlaytimeData()
		if writefile then
			local sec = math.floor(State.TotalPlaytimeSeconds)
			local playContent = tostring(sec) .. "||" .. HashIntegrity(sec)
			pcall(writefile, PLAYTIME_FILE, playContent)

			local achData = {
				Ach_10Hours_Claimed = State.Ach_10Hours_Claimed,
				IsDecorActive = State.IsDecorActive
			}
			local json = Services.HttpService:JSONEncode(achData)
			local achContent = json .. "||" .. HashIntegrity(#json)
			pcall(writefile, ACH_FILE, achContent)
		end
	end

	Lib.LoadPlaytimeData()

	local function RegisterUserActivity()
		State.LastActivityTick = os.clock()
	end

	Lib.C(Services.UserInputService.InputBegan, RegisterUserActivity)
	Lib.C(Services.UserInputService.InputChanged, function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			RegisterUserActivity()
		end
	end)

	task.spawn(function()
		local saveTimer = 0
		while not State.Unloaded do
			task.wait(1)
			if (os.clock() - State.LastActivityTick) <= 1800 then
				State.TotalPlaytimeSeconds = State.TotalPlaytimeSeconds + 1
			end

			saveTimer = saveTimer + 1
			if saveTimer >= 15 then
				saveTimer = 0
				Lib.SavePlaytimeData()
			end

			if UI.PlaytimeTextLabel then
				local hours = math.floor(State.TotalPlaytimeSeconds / 3600)
				local mins = math.floor((State.TotalPlaytimeSeconds % 3600) / 60)
				UI.PlaytimeTextLabel.Text = string.format("%dh %dm", hours, mins)
			end

			if UI.AchUpdateCallback then
				UI.AchUpdateCallback()
			end
		end
	end)
end

function Lib.RejoinCurrentServer()
	pcall(function()
		if #Services.Players:GetPlayers() <= 1 then
			App.Player:Kick("\n[Septus Hub] Rejoining server...")
			task.wait()
			Services.Teleport:Teleport(game.PlaceId, App.Player)
		else
			Services.Teleport:TeleportToPlaceInstance(game.PlaceId, game.JobId, App.Player)
		end
	end)
end

function Lib.ServerHop()
	task.spawn(function()
		local placeId = game.PlaceId
		local currentJob = game.JobId
		local url = "https://games.roproxy.com/v1/games/" .. tostring(placeId) .. "/servers/Public?sortOrder=Asc&limit=100"
		local success, body = API.HTTPRequest(url)

		if success and body then
			local decSuccess, data = pcall(function() return Services.HttpService:JSONDecode(body) end)
			if decSuccess and data and data.data then
				local candidates = {}
				for _, s in ipairs(data.data) do
					if s.id ~= currentJob and s.playing and s.maxPlayers and (s.playing < s.maxPlayers) then
						table.insert(candidates, s.id)
					end
				end

				if #candidates > 0 then
					local targetServerId = candidates[math.random(1, #candidates)]
					Services.Teleport:TeleportToPlaceInstance(placeId, targetServerId, App.Player)
					return
				end
			end
		end

		Services.Teleport:Teleport(placeId, App.Player)
	end)
end

function API.ResolveAnimationId(assetId, itemType, strict)
	if not assetId then return nil end
	assetId = tonumber(assetId) or assetId

	local cached = State.AnimationIdCache[assetId]
	if cached then return cached end

	local function Decode(body)
		local ok, data = pcall(Services.HttpService.JSONDecode, Services.HttpService, body)
		return ok and data or nil
	end

	local resolved

	if itemType == "Bundle" then
		local items
		for _, base in ipairs({ "https://catalog.roproxy.com", "https://catalog.roblox.com" }) do
			local ok, body = API.HTTPRequest(base .. "/v1/bundles/" .. tostring(assetId) .. "/details")
			local data = ok and body and Decode(body)
			if data and data.items then
				items = data.items
				break
			end
		end

		if items then
			local function Rank(item)
				return tostring(item.name):lower():find("idle") and 0 or 1
			end
			table.sort(items, function(a, b)
				local ra, rb = Rank(a), Rank(b)
				if ra ~= rb then return ra < rb end
				return (a.id or 0) < (b.id or 0)
			end)
			for _, item in ipairs(items) do
				if item.type == "Asset" and item.id then
					resolved = API.ResolveAnimationId(item.id, "Asset", true)
					if resolved then break end
				end
			end
		end

		if resolved then State.AnimationIdCache[assetId] = resolved end
		return resolved
	end

	pcall(function()
		local objects = game:GetObjects("rbxassetid://" .. tostring(assetId))
		local root = objects and objects[1]
		if root then
			local anim = root:IsA("Animation") and root or root:FindFirstChildWhichIsA("Animation", true)
			local matchId = anim and anim.AnimationId:match("%d+")
			if matchId then resolved = tonumber(matchId) end
		end
	end)

	if not resolved then
		for _, url in ipairs({
			"https://assetdelivery.roproxy.com/v1/asset/?id=" .. tostring(assetId),
			"https://assetdelivery.roblox.com/v1/asset/?id=" .. tostring(assetId)
		}) do
			local ok, body = API.HTTPRequest(url)
			if ok and type(body) == "string" then
				local animId = body:match("<url>.-id=(%d+).-</url>")
					or body:match("rbxassetid://(%d+)")
					or body:match('"assetId":(%d+)')
					or body:match("id=(%d+)")
				if animId and tonumber(animId) and tonumber(animId) ~= assetId then
					resolved = tonumber(animId)
					break
				end
			end
		end
	end

	if resolved then
		State.AnimationIdCache[assetId] = resolved
		return resolved
	end

	if strict then return nil end

	State.AnimationIdCache[assetId] = assetId
	return assetId
end

function API.FetchBundleAnimationPack(bundleId)
	bundleId = tonumber(bundleId) or bundleId
	if State.BundleAnimCache[bundleId] then return State.BundleAnimCache[bundleId] end

	local items
	for _, base in ipairs({ "https://catalog.roproxy.com", "https://catalog.roblox.com" }) do
		local ok, body = API.HTTPRequest(base .. "/v1/bundles/" .. tostring(bundleId) .. "/details")
		local data = ok and body and (pcall(Services.HttpService.JSONDecode, Services.HttpService, body) and Services.HttpService:JSONDecode(body))
		if data and data.items then
			items = data.items
			break
		end
	end

	if not items then return nil end

	local animMap = {}
	for _, item in ipairs(items) do
		if item.type == "Asset" and item.id then
			local resolvedId = API.ResolveAnimationId(item.id, "Asset", true)
			if resolvedId then
				local n = tostring(item.name):lower()
				if n:find("idle") then animMap.idle = resolvedId
				elseif n:find("walk") then animMap.walk = resolvedId
				elseif n:find("run") then animMap.run = resolvedId
				elseif n:find("jump") then animMap.jump = resolvedId
				elseif n:find("fall") then animMap.fall = resolvedId
				elseif n:find("climb") then animMap.climb = resolvedId
				elseif n:find("swim") then animMap.swim = resolvedId
				end
			end
		end
	end

	if next(animMap) then
		State.BundleAnimCache[bundleId] = animMap
		return animMap
	end
	return nil
end

do
	local SortQueries = {
		["Most Viewed"] = "sortType=2&sortAggregation=5",
		["Least Viewed"] = "sortType=2&sortAggregation=1",
		["Most Liked"] = "sortType=1&sortAggregation=5",
		["Least Liked"] = "sortType=1&sortAggregation=1",
		["Newest"] = "sortType=3",
		["Oldest"] = "sortType=0"
	}

	local Kinds = {
		Emote = { subName = "EmoteAnimations", subId = 39, cache = "EmotesCache", prefix = "Emotes_", itemType = "Asset", fallback = "Unknown Emote" },
		Pack = { subName = "Bundles", subId = 38, cache = "AnimationPacksCache", prefix = "Packs_", itemType = "Bundle", fallback = "Animation Pack" }
	}

	local function Fetch(kind, page, sortType)
		local k = Kinds[kind]
		local result = { success = false, data = {}, totalPages = 1 }
		local sortQuery = (SortQueries[sortType] or SortQueries["Most Liked"]) .. (State.EmotesQuery ~= "" and ("&keyword=" .. Services.HttpService:UrlEncode(State.EmotesQuery)) or "")
		local cache = State[k.cache]
		local cursorKey = k.prefix .. tostring(sortType) .. "_cursor_"
		local cursor = cache[cursorKey .. page] or ""

		local urls = {
			"https://catalog.roproxy.com/v1/search/items/details?category=AvatarAnimations&subcategory=" .. k.subName .. "&limit=30&" .. sortQuery,
			"https://catalog.roproxy.com/v1/search/items/details?category=12&subcategory=" .. k.subId .. "&limit=30&" .. sortQuery,
			"https://catalog.roblox.com/v1/search/items/details?category=12&subcategory=" .. k.subId .. "&limit=30&" .. sortQuery
		}

		local failures = {}
		for index, baseUrl in ipairs(urls) do
			local tag = "[" .. index .. "] "
			local ok, body, reason = API.HTTPRequest(cursor ~= "" and (baseUrl .. "&cursor=" .. cursor) or baseUrl)
			if not ok then
				failures[#failures + 1] = tag .. (reason or "request failed")
			else
				local decOk, decoded = pcall(Services.HttpService.JSONDecode, Services.HttpService, body)
				if not decOk or type(decoded) ~= "table" then
					failures[#failures + 1] = tag .. "response is not valid JSON"
				elseif decoded.errors and decoded.errors[1] then
					failures[#failures + 1] = tag .. "API error: " .. tostring(decoded.errors[1].message or decoded.errors[1].code)
				elseif not decoded.data or #decoded.data == 0 then
					failures[#failures + 1] = tag .. "API returned no items"
					if State.EmotesQuery ~= "" then
						result.empty = true
						break
					end
				else
					result.success = true
					if decoded.nextPageCursor then
						cache[cursorKey .. (page + 1)] = decoded.nextPageCursor
						result.totalPages = page + 1
					else
						result.totalPages = page
					end

					for _, item in ipairs(decoded.data) do
						local price = "Off Sale"
						if item.priceStatus == "Free" or item.price == 0 then
							price = "Free"
						elseif item.price then
							price = tostring(item.price) .. " Robux"
						end
						result.data[#result.data + 1] = {
							id = item.id,
							itemType = item.itemType or k.itemType,
							name = item.name or k.fallback,
							price = price,
							thumbnailId = item.id
						}
					end
					break
				end
			end
		end

		if not result.success then result.error = table.concat(failures, "\n") end
		return result
	end

	function API.FetchEmotes(page, sortType) return Fetch("Emote", page, sortType) end
	function API.FetchAnimationPacks(page, sortType) return Fetch("Pack", page, sortType) end
end

local function BackupCharacterAnimations(character)
	if Refs.OriginalAnims then return end
	local animate = character:FindFirstChild("Animate")
	if not animate then return end
	local backup = {}
	for _, child in ipairs(animate:GetChildren()) do
		if child:IsA("StringValue") or child:IsA("NumberValue") or child:IsA("Folder") then
			for _, anim in ipairs(child:GetChildren()) do
				if anim:IsA("Animation") then
					backup[anim] = anim.AnimationId
				end
			end
		end
	end
	Refs.OriginalAnims = backup
end

local function RestoreCharacterAnimations(character)
	if not Refs.OriginalAnims then return end
	for anim, origId in pairs(Refs.OriginalAnims) do
		pcall(function() anim.AnimationId = origId end)
	end
	Refs.OriginalAnims = nil

	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	if animator then
		for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
			pcall(function() track:Stop(0.1) end)
		end
	end
end

local function ApplyPackToCharacter(character, animMap)
	local animate = character:FindFirstChild("Animate")
	if not animate then return false end
	BackupCharacterAnimations(character)

	local map = {
		idle = { animate:FindFirstChild("idle") },
		walk = { animate:FindFirstChild("walk") },
		run = { animate:FindFirstChild("run") },
		jump = { animate:FindFirstChild("jump") },
		fall = { animate:FindFirstChild("fall") },
		climb = { animate:FindFirstChild("climb") },
		swim = { animate:FindFirstChild("swim") }
	}

	for animKey, animId in pairs(animMap) do
		local containers = map[animKey]
		if containers then
			for _, container in ipairs(containers) do
				for _, anim in ipairs(container:GetChildren()) do
					if anim:IsA("Animation") then
						anim.AnimationId = "rbxassetid://" .. tostring(animId)
					end
				end
			end
		end
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	if animator then
		for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
			pcall(function() track:Stop(0.1) end)
		end
	end
	return true
end

function Lib.StopCurrentEmote()
	if State.CurrentActiveBundle then
		RestoreCharacterAnimations(App.Player.Character)
		State.CurrentActiveBundle = nil
	end

	if State.CurrentEmoteTrack then
		pcall(function()
			State.CurrentEmoteTrack:Stop()
			State.CurrentEmoteTrack:Destroy()
		end)
		State.CurrentEmoteTrack = nil
	end

	if State.CurrentEmoteButton and State.CurrentEmoteButton.Parent then
		State.CurrentEmoteButton.Text = "Play"
		State.CurrentEmoteButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		State.CurrentEmoteButton.TextColor3 = Color3.fromRGB(0, 0, 0)
	end

	State.CurrentPlayingAssetId = nil
	State.CurrentEmoteButton = nil
end

function Lib.PlayEmote(assetId, itemType, triggerBtn)
	if State.CurrentPlayingAssetId == assetId then
		Lib.StopCurrentEmote()
		return
	end

	Lib.StopCurrentEmote()

	local character = App.Player.Character
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	local animator = humanoid:FindFirstChildOfClass("Animator") or Lib.Create("Animator", { Parent = humanoid })

	triggerBtn.Text = "Resolving..."

	task.spawn(function()
		if itemType == "Bundle" then
			local packData = API.FetchBundleAnimationPack(assetId)
			if not packData then
				local singleId = API.ResolveAnimationId(assetId, "Bundle")
				if singleId then packData = { idle = singleId, walk = singleId, run = singleId, jump = singleId } end
			end

			if not packData or not next(packData) then
				triggerBtn.Text = "Failed"
				task.delay(1.5, function()
					if triggerBtn.Parent then triggerBtn.Text = "Play" end
				end)
				return
			end

			if not App.Player.Character or App.Player.Character ~= character then
				if triggerBtn.Parent then triggerBtn.Text = "Play" end
				return
			end

			local success = ApplyPackToCharacter(character, packData)
			if success then
				State.CurrentActiveBundle = assetId
				State.CurrentPlayingAssetId = assetId
				State.CurrentEmoteButton = triggerBtn

				triggerBtn.Text = "Stop"
				triggerBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
				triggerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			else
				triggerBtn.Text = "Failed"
				task.delay(1.5, function()
					if triggerBtn.Parent then triggerBtn.Text = "Play" end
				end)
			end
			return
		end

		local animationId = API.ResolveAnimationId(assetId, itemType)

		if not animationId or animationId == "" then
			triggerBtn.Text = "Failed"
			task.delay(1.5, function()
				if triggerBtn.Parent then triggerBtn.Text = "Play" end
			end)
			return
		end

		if not App.Player.Character or App.Player.Character:FindFirstChildOfClass("Humanoid") ~= humanoid then
			if triggerBtn.Parent then triggerBtn.Text = "Play" end
			return
		end

		local animObject = Lib.Create("Animation", {
			AnimationId = "rbxassetid://" .. tostring(animationId)
		})

		local loadSuccess, track = pcall(function()
			return animator:LoadAnimation(animObject)
		end)

		if loadSuccess and track then
			State.CurrentEmoteTrack = track
			State.CurrentPlayingAssetId = assetId
			State.CurrentEmoteButton = triggerBtn

			track.Priority = Enum.AnimationPriority.Action
			track:Play()

			triggerBtn.Text = "Stop"
			triggerBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
			triggerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

			track.Stopped:Connect(function()
				if State.CurrentPlayingAssetId == assetId then
					Lib.StopCurrentEmote()
				end
			end)
		else
			triggerBtn.Text = "Failed"
			task.delay(1.5, function()
				if triggerBtn.Parent then triggerBtn.Text = "Play" end
			end)
		end
	end)
end

Lib.C(App.Player.CharacterAdded, function(newChar)
	Refs.OriginalAnims = nil
	Lib.StopCurrentEmote()
end)

UI.Screen = Lib.Create("ScreenGui", {
	Name = "SeptusHub",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 2147483647,
	Parent = App.Player:WaitForChild("PlayerGui")
})

UI.NotifContainer = Lib.Create("Frame", {
	Name = "NotifContainer",
	Size = UDim2.new(0, 280, 1, 0),
	Position = UDim2.new(1, -290, 0, 0),
	BackgroundTransparency = 1,
	ClipsDescendants = false,
	ZIndex = 150,
	Parent = UI.Screen
})

Lib.C(Services.Players.PlayerAdded, function(p)
	if State.PlayerNotifsEnabled and State.NotificationsEnabled then
		Lib.Notify({ Title = "Player Joined", Text = p.DisplayName .. " (@" .. p.Name .. ")", UserId = p.UserId })
	end
end)

Lib.C(Services.Players.PlayerRemoving, function(p)
	if State.PlayerNotifsEnabled and State.NotificationsEnabled then
		Lib.Notify({ Title = "Player Left", Text = p.DisplayName .. " (@" .. p.Name .. ")", UserId = p.UserId })
	end
end)

UI.MainCorner = Lib.Create("UICorner", { CornerRadius = UDim.new(0, State.CornerRadius) })

UI.HeaderIcon = Lib.Create("ImageLabel", {
	Size = UDim2.fromOffset(45, 45),
	Position = UDim2.fromOffset(14, 7),
	BackgroundTransparency = 1,
	Image = "rbxassetid://74736110237331",
	ScaleType = Enum.ScaleType.Fit
})

UI.HeaderLogo = Lib.Create("ImageLabel", {
	Size = UDim2.fromOffset(174, 39),
	Position = UDim2.fromOffset(66, 10),
	BackgroundTransparency = 1,
	Image = "rbxassetid://97808676894113",
	ScaleType = Enum.ScaleType.Fit
})

UI.BackgroundContainer = Lib.Create("CanvasGroup", {
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	ZIndex = 0
})
Lib.BindCorner(UI.BackgroundContainer, "BgCorner")

function Lib.BgSize(factor)
	local zoom = State.BgZoom / 100 * factor
	return UDim2.fromScale(zoom, zoom)
end

UI.CustomBgImage = Lib.Create("ImageLabel", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = Lib.BgSize(1),
	BackgroundTransparency = 1,
	ImageTransparency = (100 - State.BgOpacity) / 100,
	ScaleType = Enum.ScaleType.Crop,
	Visible = false,
	ZIndex = 0,
	Parent = UI.BackgroundContainer
})
Lib.BindCorner(UI.CustomBgImage, "ImageCorner")

UI.Main = Lib.Create("Frame", {
	Name = "Main",
	Size = State.OriginalSize,
	ZIndex = 5,
	Position = UDim2.new(0.5, 0, 0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	ClipsDescendants = true,
	Visible = false,
	Parent = UI.Screen,
	UI.MainCorner,
	UI.BackgroundContainer,
	UI.HeaderIcon,
	UI.HeaderLogo
})

do
	local Tween = Services.Tween
	local container, motion, active = nil, {}, false

	local function Piece(kind, size, alpha, props)
		local id = Lib.HalloweenAssets[kind]
		props.BackgroundTransparency = 1
		props.Size = UDim2.fromOffset(size, size)
		props.Parent = container
		if id ~= "" then
			props.Image = (Lib.ResolveImage(id))
			props.ImageTransparency = alpha
			props.ScaleType = Enum.ScaleType.Fit
			return Lib.Create("ImageLabel", props)
		end
		props.Text = Lib.HalloweenEmoji[kind]
		props.TextSize = math.floor(size * 0.78)
		props.TextTransparency = alpha
		return Lib.Create("TextLabel", props)
	end

	local function Loop(piece, goal, duration)
		motion[#motion + 1] = Tween:Create(piece, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), goal)
	end

	local function Build()
		container = Lib.Create("CanvasGroup", {
			Name = "HalloweenDecor",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			GroupTransparency = 1,
			ZIndex = 4,
			Visible = false,
			Parent = UI.Main
		})

		Piece("Web", 96, 0.3, { Position = UDim2.fromOffset(0, 0) })
		Piece("Web", 72, 0.4, { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Rotation = 90 })

		local pumpkin = Piece("Pumpkin", 58, 0.1, { AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 8, 1, -4) })
		Loop(pumpkin, { Position = UDim2.new(0, 8, 1, -9) }, 2.4)

		local small = Piece("Pumpkin", 44, 0.1, { AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -10, 1, -4) })
		Loop(small, { Position = UDim2.new(1, -10, 1, -8) }, 2.9)

		local ghost = Piece("Ghost", 40, 0.2, { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.84, 0, 1, -6) })
		Loop(ghost, { Position = UDim2.new(0.84, 0, 1, -16) }, 3.4)

		local bat = Piece("Bat", 24, 0.15, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(-0.06, 0.07) })
		Loop(bat, { Position = UDim2.fromScale(1.06, 0.07) }, 18)

		local second = Piece("Bat", 20, 0.25, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(1.06, 0.16) })
		Loop(second, { Position = UDim2.fromScale(-0.06, 0.16) }, 26)
	end

	function Lib.SetHalloweenDecor(on)
		if on == active then return end
		active = on
		if on then
			if not container then Build() end
			container.Visible = true
			for _, tween in ipairs(motion) do tween:Play() end
			Lib.Tween(container, 0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { GroupTransparency = 0 })
		elseif container then
			Lib.Tween(container, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { GroupTransparency = 1 }).Completed:Connect(function()
				if active then return end
				container.Visible = false
				for _, tween in ipairs(motion) do tween:Pause() end
			end)
		end
	end
end

UI.ContentArea = Lib.Create("Frame", { Size = UDim2.new(1, 0, 1, -58), Position = UDim2.new(0, 0, 0, 58), BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 2, Parent = UI.Main })

UI.TopNavContainer = Lib.Create("Frame", {
	Name = "TopNavContainer",
	Size = UDim2.new(0, 460, 0, 36),
	Position = UDim2.new(0.5, 0, 0, 11),
	AnchorPoint = Vector2.new(0.5, 0),
	BackgroundTransparency = 1,
	ClipsDescendants = false,
	ZIndex = 3,
	Parent = UI.Main
})

UI.WindowBtns = Lib.Create("Frame", { Size = UDim2.fromOffset(120, 36), Position = UDim2.new(1, -125, 0, 11), BackgroundTransparency = 1, ZIndex = 3, Parent = UI.Main })

do
	local function MakeWinBtn(name, text, pos, callback)
		local btnContainer = Lib.Create("Frame", {
			Size = UDim2.fromOffset(34, 34),
			Position = pos,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			Parent = UI.WindowBtns,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
		})

		local btn = Lib.Create("TextButton", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = text,
			TextColor3 = Color3.fromRGB(125, 125, 125),
			TextSize = 16,
			Font = Enum.Font.GothamMedium,
			Parent = btnContainer
		})
		Lib.RegisterThemeText(btn, "Secondary")

		btn.MouseEnter:Connect(function()
			local isWhite = State.LightTheme
			Lib.Tween(btnContainer, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
				BackgroundColor3 = isWhite and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = isWhite and 0.92 or 0.88
			})
			Lib.Tween(btn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { TextColor3 = isWhite and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255) })
		end)

		btn.MouseLeave:Connect(function()
			local isWhite = State.LightTheme
			Lib.Tween(btnContainer, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundTransparency = 1 })
			Lib.Tween(btn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { TextColor3 = isWhite and Color3.fromRGB(85, 85, 85) or Color3.fromRGB(125, 125, 125) })
		end)

		btn.MouseButton1Click:Connect(function()
			Lib.PlayClick()
			callback()
		end)
	end

	local function ApplyWindowState()
		Lib.ApplyWindowState()
	end

	MakeWinBtn("Minimize", "—", UDim2.fromOffset(0, 0), function()
		State.Minimized = not State.Minimized
		ApplyWindowState()
	end)

	MakeWinBtn("Maximize", "□", UDim2.fromOffset(40, 0), function()
		State.Minimized = false
		State.Maximized = not State.Maximized
		ApplyWindowState()
	end)

	MakeWinBtn("Close", "×", UDim2.fromOffset(80, 0), function()
		Lib.Unload()
		Lib.StopCurrentEmote()
		Lib.SavePlaytimeData()
		if Refs.IntroBlur then Refs.IntroBlur:Destroy() end
		if Refs.GlassBlur then Refs.GlassBlur:Destroy() end
		UI.Screen:Destroy()
	end)
end

Lib.DragOffset = Vector2.zero

function Lib.MainLayout()
	local original = State.OriginalSize
	local offset = State.Maximized and Vector2.zero or Lib.DragOffset
	if State.Minimized then
		local size = UDim2.new(State.Maximized and 1 or original.X.Scale, State.Maximized and -30 or original.X.Offset, 0, 58)
		local position = State.Maximized and UDim2.new(0.5, 0, 0, 44) or UDim2.new(0.5, offset.X, 0.5, 29 - original.Y.Offset / 2 + offset.Y)
		return size, position
	end
	if State.Maximized then
		return UDim2.new(1, -30, 1, -30), UDim2.new(0.5, 0, 0.5, 0)
	end
	return original, UDim2.new(0.5, offset.X, 0.5, offset.Y)
end

function Lib.WindowBusy()
	return State.MenuHiding or (Lib.WindowTween ~= nil and Lib.WindowTween.PlaybackState == Enum.PlaybackState.Playing)
end

function Lib.ApplyWindowState()
	local minimized = State.Minimized
	State.WindowAnimId = (State.WindowAnimId or 0) + 1
	local id = State.WindowAnimId
	local size, position = Lib.MainLayout()
	if not minimized then
		UI.TopNavContainer.Visible = true
		UI.ContentArea.Visible = true
	end
	local tween = Lib.Tween(UI.Main, 0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut, { Size = size, Position = position })
	Lib.WindowTween = tween
	Lib.Tween(UI.TopNavContainer, 0.38, Enum.EasingStyle.Quint, minimized and Enum.EasingDirection.In or Enum.EasingDirection.Out, {
		Position = UDim2.new(0.5, 0, 0, minimized and -44 or 11)
	})
	if minimized then
		tween.Completed:Connect(function()
			if State.WindowAnimId == id and State.Minimized then
				UI.TopNavContainer.Visible = false
				UI.ContentArea.Visible = false
			end
		end)
	end
end

function Lib.ToggleMenu(force)
	local show = force
	if show == nil then show = (not UI.Main.Visible) or State.MenuHiding end
	State.MenuToken = (State.MenuToken or 0) + 1
	local token = State.MenuToken
	local scale, button, main = UI.MainScale, UI.SHToggleButton, UI.Main
	if not scale or not button then
		main.Visible = show
		return
	end
	local base = Lib.MenuBaseScale or 1
	local size, target = Lib.MainLayout()
	local mode = State.MenuAnim
	local center = button.AbsolutePosition + button.AbsoluteSize / 2
	local origin = UDim2.fromOffset(center.X, center.Y)
	local below = UDim2.new(target.X.Scale, target.X.Offset, target.Y.Scale, target.Y.Offset + UI.Screen.AbsoluteSize.Y)
	local line = UDim2.new(size.X.Scale, size.X.Offset, 0, 4)
	local quint = Enum.EasingStyle.Quint

	local function Finish()
		if State.MenuToken ~= token then return end
		main.Visible = false
		State.MenuHiding = false
		scale.Scale = base
		main.Size, main.Position = Lib.MainLayout()
	end

	local function Chain(first, nextStage)
		Lib.WindowTween = first
		first.Completed:Connect(function()
			if State.MenuToken == token then nextStage() end
		end)
	end

	if show then
		State.MenuHiding = false
		if mode == "Slide Up" then
			scale.Scale = base * 0.9
			main.Size, main.Position = size, below
			main.Visible = true
			Lib.WindowTween = Lib.Tween(main, 0.6, quint, Enum.EasingDirection.Out, { Position = target })
			Lib.Tween(scale, 0.6, quint, Enum.EasingDirection.Out, { Scale = base })
		elseif mode == "Unfold" then
			scale.Scale = base
			main.Size, main.Position = UDim2.fromOffset(0, 4), target
			main.Visible = true
			Chain(Lib.Tween(main, 0.3, quint, Enum.EasingDirection.Out, { Size = line }), function()
				Lib.WindowTween = Lib.Tween(main, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Size = size })
			end)
		else
			scale.Scale = base * 0.05
			main.Size, main.Position = size, origin
			main.Visible = true
			Lib.WindowTween = Lib.Tween(main, 0.5, quint, Enum.EasingDirection.Out, { Position = target })
			Lib.Tween(scale, 0.5, quint, Enum.EasingDirection.Out, { Scale = base })
		end
		return
	end

	State.MenuHiding = true
	if mode == "Slide Up" then
		Lib.WindowTween = Lib.Tween(main, 0.45, quint, Enum.EasingDirection.In, { Position = below })
		Lib.Tween(scale, 0.45, quint, Enum.EasingDirection.In, { Scale = base * 0.9 }).Completed:Connect(Finish)
	elseif mode == "Unfold" then
		Chain(Lib.Tween(main, 0.3, quint, Enum.EasingDirection.In, { Size = line }), function()
			local last = Lib.Tween(main, 0.22, quint, Enum.EasingDirection.In, { Size = UDim2.fromOffset(0, 4) })
			Lib.WindowTween = last
			last.Completed:Connect(Finish)
		end)
	else
		Lib.WindowTween = Lib.Tween(main, 0.34, quint, Enum.EasingDirection.In, { Position = origin })
		Lib.Tween(scale, 0.34, quint, Enum.EasingDirection.In, { Scale = base * 0.05 }).Completed:Connect(Finish)
	end
end

do
	local UIS = Services.UserInputService
	local handle = Lib.Create("Frame", { Name = "DragHandle", Size = UDim2.new(1, 0, 0, 58), BackgroundTransparency = 1, Active = true, ZIndex = 1, Parent = UI.Main })
	local dragging, origin, startOffset, goal, loop = false, nil, nil, Lib.DragOffset, nil

	local function Clamp(v)
		local view = UI.Screen.AbsoluteSize
		local s = Lib.MenuBaseScale or 1
		local w, h = State.OriginalSize.X.Offset * s, State.OriginalSize.Y.Offset * s
		return Vector2.new(
			math.clamp(v.X, -view.X / 2 - w / 2 + 140, view.X / 2 + w / 2 - 140),
			math.clamp(v.Y, h / 2 - view.Y / 2, view.Y / 2 + h / 2 - 58 * s)
		)
	end

	local function Step(dt)
		Lib.DragOffset = Lib.DragOffset:Lerp(goal, 1 - math.exp(-dt * 22))
		if not dragging and (Lib.DragOffset - goal).Magnitude < 0.4 then
			Lib.DragOffset = goal
			loop:Disconnect()
			loop = nil
		end
		UI.Main.Position = select(2, Lib.MainLayout())
	end

	handle.InputBegan:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not State.Maximized and not Lib.WindowBusy() then
			dragging = true
			origin = input.Position
			startOffset = Lib.DragOffset
			goal = Lib.DragOffset
			if not loop then loop = Services.Run.RenderStepped:Connect(Step) end
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)

	Lib.C(UIS.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - origin
			goal = Clamp(startOffset + Vector2.new(delta.X, delta.Y))
		end
	end)
end

do
	local UIS = Services.UserInputService
	local MIN_W, MIN_H, MAX_W, MAX_H = 560, 380, 1500, 950
	local EDGE, CORNER = 6, 14
	local active, origin, startW, startH, startOffset

	local handles = {
		{ -1, 0, UDim2.new(0, EDGE, 1, -CORNER * 2), UDim2.fromOffset(0, CORNER) },
		{ 1, 0, UDim2.new(0, EDGE, 1, -CORNER * 2), UDim2.new(1, -EDGE, 0, CORNER) },
		{ 0, -1, UDim2.new(1, -CORNER * 2, 0, EDGE), UDim2.fromOffset(CORNER, 0) },
		{ 0, 1, UDim2.new(1, -CORNER * 2, 0, EDGE), UDim2.new(0, CORNER, 1, -EDGE) },
		{ -1, -1, UDim2.fromOffset(CORNER, CORNER), UDim2.fromOffset(0, 0) },
		{ 1, -1, UDim2.fromOffset(CORNER, CORNER), UDim2.new(1, -CORNER, 0, 0) },
		{ -1, 1, UDim2.fromOffset(CORNER, CORNER), UDim2.new(0, 0, 1, -CORNER) },
		{ 1, 1, UDim2.fromOffset(CORNER, CORNER), UDim2.new(1, -CORNER, 1, -CORNER) }
	}

	local function Blocked()
		return State.Maximized or State.Minimized or Lib.WindowBusy()
	end

	for _, data in ipairs(handles) do
		local handle = Lib.Create("Frame", {
			Name = "ResizeHandle", Size = data[3], Position = data[4], BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 1, BorderSizePixel = 0, Active = true, ZIndex = 60, Parent = UI.Main
		})
		local function Glow(transparency)
			handle.BackgroundColor3 = State.LightTheme and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
			Lib.Tween(handle, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundTransparency = transparency })
		end
		handle.MouseEnter:Connect(function()
			if not active and not Blocked() then Glow(0.82) end
		end)
		handle.MouseLeave:Connect(function()
			if active ~= data then Glow(1) end
		end)
		handle.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
			if Blocked() then return end
			active, origin = data, input.Position
			startW, startH, startOffset = State.OriginalSize.X.Offset, State.OriginalSize.Y.Offset, Lib.DragOffset
			Glow(0.6)
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					active = nil
					Glow(1)
				end
			end)
		end)
	end

	Lib.C(UIS.InputChanged, function(input)
		if not active or (input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch) then return end
		if Blocked() then
			active = nil
			return
		end
		local s = Lib.MenuBaseScale or 1
		local view = UI.Screen.AbsoluteSize
		local dx, dy = active[1], active[2]
		local delta = input.Position - origin
		local w = math.clamp(startW + dx * delta.X / s, MIN_W, math.max(MIN_W, math.min(MAX_W, view.X / s - 20)))
		local h = math.clamp(startH + dy * delta.Y / s, MIN_H, math.max(MIN_H, math.min(MAX_H, view.Y / s - 20)))
		State.OriginalSize = UDim2.fromOffset(w, h)
		Lib.DragOffset = startOffset + Vector2.new(dx * (w - startW) * s / 2, dy * (h - startH) * s / 2)
		UI.Main.Size, UI.Main.Position = Lib.MainLayout()
	end)
end

do
	local NavTabsData = {
		{ id = "Home", title = "Home", icon = "rbxassetid://128407802503574", expWidth = 76 },
		{ id = "Features", title = "Features", icon = "rbxassetid://74917927400316", expWidth = 94 },
		{ id = "Scripts", title = "Scripts", icon = "rbxassetid://99356660335373", expWidth = 84 },
		{ id = "Emotes", title = "Emotes", icon = "rbxassetid://132655372254315", expWidth = 84 },
		{ id = "Settings", title = "Settings", icon = "rbxassetid://112763474266331", expWidth = 94 }
	}
	local BASE_TAB_WIDTH, TAB_GAP = 34, 8

	function Lib.RecalculateNavPositions()
		local widths, totalWidth = {}, 0
		local isWhite = State.LightTheme

		for i, tab in ipairs(NavTabsData) do
			local isHover = (UI.CurrentHoveredNav == i)
			local w = isHover and tab.expWidth or BASE_TAB_WIDTH
			widths[i] = w
			totalWidth = totalWidth + w
		end
		totalWidth = totalWidth + (#NavTabsData - 1) * TAB_GAP

		local currentX = -totalWidth / 2
		for i, tab in ipairs(NavTabsData) do
			local elem = UI.NavElements[i]
			local w = widths[i]
			local isHover = (UI.CurrentHoveredNav == i)
			local isActive = (State.ActiveMain == tab.id)

			local activeColor = isWhite and Color3.fromRGB(15, 15, 15) or Color3.fromRGB(255, 255, 255)
			local inactiveColor = isWhite and Color3.fromRGB(130, 130, 130) or Color3.fromRGB(150, 150, 150)

			Lib.Tween(elem.Container, 0.22, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, {
				Position = UDim2.new(0.5, currentX, 0, 0),
				Size = UDim2.fromOffset(w, 36)
			})

			Lib.Tween(elem.Icon, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
				Position = isHover and UDim2.new(0, 7, 0.5, -9) or UDim2.new(0.5, -9, 0.5, -9),
				ImageColor3 = (isActive or isHover) and activeColor or inactiveColor
			})

			Lib.Tween(elem.Text, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
				TextTransparency = isHover and 0 or 1,
				TextColor3 = (isActive or isHover) and activeColor or inactiveColor
			})

			local lineTargetWidth = isActive and (isHover and (w - 14) or 18) or 0
			local lineTargetX = isHover and 7 or (w / 2 - lineTargetWidth / 2)
			elem.Line.BackgroundColor3 = activeColor
			Lib.Tween(elem.Line, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
				Position = UDim2.new(0, lineTargetX, 1, -2),
				Size = UDim2.fromOffset(lineTargetWidth, 2)
			})

			currentX = currentX + w + TAB_GAP
		end
	end

	for i, tab in ipairs(NavTabsData) do
		local TabFrame = Lib.Create("TextButton", {
			Name = "NavTab_" .. tab.id,
			Size = UDim2.fromOffset(BASE_TAB_WIDTH, 36),
			Position = UDim2.new(0.5, 0, 0, 0),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			ClipsDescendants = true,
			Parent = UI.TopNavContainer
		})

		local TabIcon = Lib.Create("ImageLabel", {
			Size = UDim2.fromOffset(18, 18),
			Position = UDim2.new(0.5, -9, 0.5, -9),
			BackgroundTransparency = 1,
			Image = tab.icon,
			ImageColor3 = Color3.fromRGB(150, 150, 150),
			ScaleType = Enum.ScaleType.Fit,
			Parent = TabFrame
		})

		local TabText = Lib.Create("TextLabel", {
			Size = UDim2.new(1, -30, 1, 0),
			Position = UDim2.new(0, 30, 0, 0),
			BackgroundTransparency = 1,
			Text = tab.title,
			TextColor3 = Color3.fromRGB(150, 150, 150),
			TextSize = 13,
			Font = Enum.Font.GothamMedium,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTransparency = 1,
			Parent = TabFrame
		})

		local TabLine = Lib.Create("Frame", {
			Size = UDim2.fromOffset(0, 2),
			Position = UDim2.new(0.5, -9, 1, -2),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
			Parent = TabFrame
		})

		UI.NavElements[i] = {
			Container = TabFrame,
			Icon = TabIcon,
			Text = TabText,
			Line = TabLine,
			Data = tab
		}

		TabFrame.MouseEnter:Connect(function()
			UI.CurrentHoveredNav = i
			Lib.RecalculateNavPositions()
		end)

		TabFrame.MouseLeave:Connect(function()
			if UI.CurrentHoveredNav == i then
				UI.CurrentHoveredNav = nil
				Lib.RecalculateNavPositions()
			end
		end)

		TabFrame.MouseButton1Click:Connect(function()
			Lib.PlayClick()
			Lib.SwitchMainTab(tab.id)
		end)
	end
end

function Lib.BuildUpdateLog(view)
	local releases = {
		{
			version = "V3.4", date = "Oct 10", latest = true,
			notes = {
				"Visual change to certain objects.",
				"Changing the settings icons and the Features icon.",
				"Added two types of animations for the menu.",
				"Adding two subsections to Scripts and Emotes: Saved and Recent.",
				"Reworked Settings for the Scripts and Emotes sections [Now called Filters]",
				"Adding icons to some subsection buttons.",
				"Added the ability to resize the main menu.",
				"Addition of the new script search service HaxHell.",
				"Fixed the copying of loadstring references for scripts.",
				"Adding a Combat subsection to Features."
			}
		},
		{
			version = "V3.3", title = "Halloween", date = "Oct 9",
			notes = {
				"Adding search bars to the Features, Emotes, and Scripts sections.",
				"Visual update of certain objects.",
				"Adding an \"Update Log\" subsection to Home.",
				"New Halloween menu theme.",
				"Fixed menu-related bugs.",
				"An option to select the sound played when pressing various switches and buttons has been added to the \"Appearance\" section.",
				"Fixed an issue where some objects did not change their transparency.",
				"Added Anti-AFK to the Misc subsection"
			}
		},
		{
			version = "V3.2", date = "Oct 6",
			notes = {
				"Fixing Corner Radius bugs for Custom Background.",
				"Adding auto-loading for the selected config.",
				"Fixing bugs and sliders/switches not changing their position when loading the config.",
				"Added functionality to disable features when the menu is fully closed.",
				"Adding Music to Appearance.",
				"Increased the z-index for all menus and script objects so they are not overlapped by the game interface."
			}
		}
	}

	local scroll = Lib.Create("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2,
		ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100), AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(),
		Parent = view,
		Lib.Create("UIListLayout", { Padding = UDim.new(0, 24), SortOrder = Enum.SortOrder.LayoutOrder }),
		Lib.Create("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 12), PaddingBottom = UDim.new(0, 14) })
	})

	for index, release in ipairs(releases) do
		local block = Lib.Create("Frame", {
			Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = index, Parent = scroll,
			Lib.Create("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder })
		})

		local header = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, LayoutOrder = 0, Parent = block })
		local left = Lib.Create("Frame", {
			Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Parent = header,
			Lib.Create("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder
			})
		})

		local title = Lib.Create("TextLabel", {
			Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, LayoutOrder = 1,
			Text = release.title and (release.version .. " " .. release.title) or release.version,
			TextColor3 = Color3.fromRGB(245, 245, 245), TextSize = 17, Font = Enum.Font.GothamBold, Parent = left
		})
		Lib.RegisterThemeText(title, "Primary")

		if release.latest then
			local badge = Lib.Create("TextLabel", {
				Size = UDim2.fromOffset(0, 18), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = Color3.fromRGB(128, 128, 128),
				BackgroundTransparency = 0.8, LayoutOrder = 2, Text = "LATEST", TextColor3 = Color3.fromRGB(245, 245, 245),
				TextSize = 10, Font = Enum.Font.GothamBold, Parent = left,
				Lib.Create("UICorner", { CornerRadius = UDim.new(0, 5) }),
				Lib.Create("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) })
			})
			Lib.RegisterThemeText(badge, "Primary")
		end

		local date = Lib.Create("TextLabel", {
			Size = UDim2.fromOffset(100, 24), Position = UDim2.new(1, -100, 0, 0), BackgroundTransparency = 1, Text = release.date,
			TextColor3 = Color3.fromRGB(145, 145, 145), TextSize = 12, Font = Enum.Font.GothamMedium,
			TextXAlignment = Enum.TextXAlignment.Right, Parent = header
		})
		Lib.RegisterThemeText(date, "Secondary")

		local notes = Lib.Create("Frame", {
			Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = 1, Parent = block,
			Lib.Create("UIListLayout", { Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder }),
			Lib.Create("UIPadding", { PaddingLeft = UDim.new(0, 2) })
		})

		for noteIndex, note in ipairs(release.notes) do
			local label = Lib.Create("TextLabel", {
				Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = noteIndex,
				Text = "\u{2022}  " .. note, TextColor3 = Color3.fromRGB(145, 145, 145), TextSize = 13, Font = Enum.Font.GothamMedium,
				TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true, Parent = notes
			})
			Lib.RegisterThemeText(label, "Secondary")
		end
	end
end

do
	local HomeSection = Lib.Create("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, Parent = UI.ContentArea })
	UI.HomeSection = HomeSection

	local HomeTitle = Lib.Create("TextLabel", { Size = UDim2.new(1, -30, 0, 30), Position = UDim2.new(0, 20, 0, 10), BackgroundTransparency = 1, Text = "Home", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 20, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left })
	Lib.RegisterThemeText(HomeTitle, "Primary")

	local SideBar = Lib.Create("Frame", { Size = UDim2.new(0, 180, 1, 0), BackgroundTransparency = 1, Parent = HomeSection, HomeTitle })

	local MakeTab
	Lib.SwitchTab, MakeTab = Lib.CreateTabSystem(HomeSection, SideBar, "CurrentTab")

	local View_Overview = MakeTab("Overview", 50)
	local View_Account = MakeTab("Account", 90)
	local View_Achievements = MakeTab("Achievements", 130)
	local View_Developers = MakeTab("Developers", 170)
	Lib.BuildUpdateLog(MakeTab("Update Log", 210))

	Lib.Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 15), Parent = View_Overview })

	local StatsArea = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 170), BackgroundTransparency = 1, LayoutOrder = 1, Parent = View_Overview, Lib.Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 12) }) })

	local function MakeGraphCard(title, layout, typeKey)
		local titleLbl = Lib.Create("TextLabel", { Size = UDim2.new(1, -20, 0, 25), Position = UDim2.new(0, 10, 0, 10), BackgroundTransparency = 1, Text = title, TextColor3 = Color3.fromRGB(150, 150, 150), TextSize = 13, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left })
		Lib.RegisterThemeText(titleLbl, "Secondary")

		local card = Lib.Create("Frame", { Size = UDim2.new(0.32, -5, 1, 0), BackgroundColor3 = Color3.fromRGB(15, 15, 15), LayoutOrder = layout, Parent = StatsArea,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
			titleLbl
		})
		Lib.RegisterThemeElement(card, "BackgroundColor3", 0.5)

		local valLbl = Lib.Create("TextLabel", { Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 10, 0, 35), BackgroundTransparency = 1, Text = "0", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 20, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, Parent = card })
		Lib.RegisterThemeText(valLbl, "Primary")
		UI.Labels[typeKey] = valLbl

		local graph = Lib.Create("Frame", { Size = UDim2.new(1, -20, 0, 75), Position = UDim2.new(0, 10, 0, 75), BackgroundTransparency = 1, Parent = card, Lib.Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0, 3) }) })

		for i = 1, 15 do
			local bar = Lib.Create("Frame", { Size = UDim2.new(1/15, -3, 0.1, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.3, BorderSizePixel = 0, Parent = graph, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 2) }) })
			UI.Graphs[typeKey][i] = bar
		end
	end
	MakeGraphCard("FPS", 1, "FPS")
	MakeGraphCard("Ping", 2, "Ping")
	MakeGraphCard("Players", 3, "Players")

	local InfoArea = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 160), BackgroundTransparency = 1, LayoutOrder = 2, Parent = View_Overview, Lib.Create("UIListLayout", { Padding = UDim.new(0, 12) }) })
	local function MakeCopyCard(title, val, layout)
		local tLbl = Lib.Create("TextLabel", { Size = UDim2.new(0, 150, 0, 12), Position = UDim2.new(0, 15, 0, 12), BackgroundTransparency = 1, Text = title, TextColor3 = Color3.fromRGB(150, 150, 150), TextSize = 13, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left })
		Lib.RegisterThemeText(tLbl, "Secondary")

		local vLbl = Lib.Create("TextLabel", { Size = UDim2.new(1, -120, 0, 25), Position = UDim2.new(0, 15, 0, 34), BackgroundTransparency = 1, Text = val, TextColor3 = Color3.fromRGB(220, 220, 220), TextSize = 13, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd })
		Lib.RegisterThemeText(vLbl, "Primary")

		local card = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 70), BackgroundColor3 = Color3.fromRGB(15, 15, 15), LayoutOrder = layout, Parent = InfoArea, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
			tLbl, vLbl
		})
		Lib.RegisterThemeElement(card, "BackgroundColor3", 0.5)

		local btn = Lib.Create("TextButton", { Size = UDim2.fromOffset(80, 34), Position = UDim2.new(1, -95, 0.5, -17), BackgroundColor3 = Color3.fromRGB(255, 255, 255), Text = "Copy", TextColor3 = Color3.fromRGB(0, 0, 0), TextSize = 13, Font = Enum.Font.GothamBold, Parent = card, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }) })
		btn.MouseButton1Click:Connect(function()
			Lib.PlayClick()
			;(setclipboard or toclipboard)(tostring(val))
			btn.Text = "Copied!"
			task.delay(1.5, function() btn.Text = "Copy" end)
		end)
	end
	MakeCopyCard("Server ID", game.JobId ~= "" and game.JobId or "Singleplayer / Studio", 1)
	MakeCopyCard("Place ID", tostring(game.PlaceId), 2)

	local AccountScroll = Lib.Create("ScrollingFrame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ScrollBarThickness = 2, ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100), BorderSizePixel = 0, Parent = View_Account })
	local AccountLayout = Lib.Create("UIListLayout", { Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder, Parent = AccountScroll })
	AccountLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		AccountScroll.CanvasSize = UDim2.new(0, 0, 0, AccountLayout.AbsoluteContentSize.Y + 20)
	end)

	local AccountCard = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 310), BackgroundColor3 = Color3.fromRGB(15, 15, 15), LayoutOrder = 1, Parent = AccountScroll, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) }) })
	Lib.RegisterThemeElement(AccountCard, "BackgroundColor3", 0.5)

	local AvatarContainer = Lib.Create("Frame", { Size = UDim2.fromOffset(64, 64), Position = UDim2.fromOffset(20, 20), BackgroundTransparency = 1, Parent = AccountCard })
	local AvatarGlowRing = Lib.Create("Frame", { Size = UDim2.new(1, 8, 1, 8), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1, Visible = State.IsDecorActive, Parent = AvatarContainer, Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
	Lib.Create("ImageLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(25, 25, 25), Image = "rbxthumb://type=AvatarHeadShot&id=" .. App.Player.UserId .. "&w=150&h=150", ZIndex = 2, Parent = AvatarContainer, Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })

	local GlowTween = Services.Tween:Create(AvatarGlowRing, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { BackgroundTransparency = 0.2, Size = UDim2.new(1, 10, 1, 10) })
	AvatarGlowRing.BackgroundTransparency = 0.85
	AvatarGlowRing.Size = UDim2.new(1, 4, 1, 4)

	local AccDName = Lib.Create("TextLabel", { Size = UDim2.new(1, -120, 0, 25), Position = UDim2.fromOffset(96, 26), BackgroundTransparency = 1, Text = App.Player.DisplayName, TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 18, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, Parent = AccountCard })
	Lib.RegisterThemeText(AccDName, "Primary")

	local AccUName = Lib.Create("TextLabel", { Size = UDim2.new(1, -120, 0, 20), Position = UDim2.fromOffset(96, 50), BackgroundTransparency = 1, Text = "@" .. App.Player.Name, TextColor3 = Color3.fromRGB(150, 150, 150), TextSize = 13, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, Parent = AccountCard })
	Lib.RegisterThemeText(AccUName, "Secondary")

	Lib.Create("Frame", { Size = UDim2.new(1, -40, 0, 1), Position = UDim2.fromOffset(20, 100), BackgroundColor3 = Color3.fromRGB(30, 30, 30), BorderSizePixel = 0, Parent = AccountCard })

	local RDateT = Lib.Create("TextLabel", { Size = UDim2.new(1, -40, 0, 18), Position = UDim2.fromOffset(20, 115), BackgroundTransparency = 1, Text = "Registration date", TextColor3 = Color3.fromRGB(130, 130, 130), TextSize = 13, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, Parent = AccountCard })
	Lib.RegisterThemeText(RDateT, "Secondary")

	local RDateV = Lib.Create("TextLabel", { Size = UDim2.new(1, -40, 0, 22), Position = UDim2.fromOffset(20, 135), BackgroundTransparency = 1, Text = os.date("%d.%m.%Y", os.time() - (App.Player.AccountAge * 86400)), TextColor3 = Color3.fromRGB(220, 220, 220), TextSize = 14, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, Parent = AccountCard })
	Lib.RegisterThemeText(RDateV, "Primary")

	local FLaunchT = Lib.Create("TextLabel", { Size = UDim2.new(1, -40, 0, 18), Position = UDim2.fromOffset(20, 170), BackgroundTransparency = 1, Text = "The first script launch", TextColor3 = Color3.fromRGB(130, 130, 130), TextSize = 13, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, Parent = AccountCard })
	Lib.RegisterThemeText(FLaunchT, "Secondary")

	local FLaunchV = Lib.Create("TextLabel", { Size = UDim2.new(1, -40, 0, 22), Position = UDim2.fromOffset(20, 190), BackgroundTransparency = 1, Text = Lib.GetFirstLaunch(), TextColor3 = Color3.fromRGB(220, 220, 220), TextSize = 14, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, Parent = AccountCard })
	Lib.RegisterThemeText(FLaunchV, "Primary")

	local PTimeT = Lib.Create("TextLabel", { Size = UDim2.new(1, -40, 0, 18), Position = UDim2.fromOffset(20, 225), BackgroundTransparency = 1, Text = "Total playtime", TextColor3 = Color3.fromRGB(130, 130, 130), TextSize = 13, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, Parent = AccountCard })
	Lib.RegisterThemeText(PTimeT, "Secondary")

	UI.PlaytimeTextLabel = Lib.Create("TextLabel", { Size = UDim2.new(1, -40, 0, 22), Position = UDim2.fromOffset(20, 245), BackgroundTransparency = 1, Text = string.format("%dh %dm", math.floor(State.TotalPlaytimeSeconds / 3600), math.floor((State.TotalPlaytimeSeconds % 3600) / 60)), TextColor3 = Color3.fromRGB(220, 220, 220), TextSize = 14, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, Parent = AccountCard })
	Lib.RegisterThemeText(UI.PlaytimeTextLabel, "Primary")

	local DecorDropdownCard = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = Color3.fromRGB(15, 15, 15), LayoutOrder = 2, ClipsDescendants = true, Parent = AccountScroll, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) }) })
	Lib.RegisterThemeElement(DecorDropdownCard, "BackgroundColor3", 0.5)

	local DecorHeaderBtn = Lib.Create("TextButton", { Size = UDim2.new(1, 0, 0, 50), BackgroundTransparency = 1, Text = "", Parent = DecorDropdownCard })
	local DecorHeadTitle = Lib.Create("TextLabel", { Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, Text = "Profile Decorations", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 14, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, Parent = DecorHeaderBtn })
	Lib.RegisterThemeText(DecorHeadTitle, "Primary")

	local DropdownArrow = Lib.Create("TextLabel", { Size = UDim2.fromOffset(30, 30), Position = UDim2.new(1, -40, 0.5, -15), BackgroundTransparency = 1, Text = "▼", TextColor3 = Color3.fromRGB(150, 150, 150), TextSize = 12, Font = Enum.Font.GothamMedium, Parent = DecorHeaderBtn })
	Lib.RegisterThemeText(DropdownArrow, "Secondary")

	local DecorItemsContainer = Lib.Create("Frame", { Size = UDim2.new(1, -30, 0, 80), Position = UDim2.new(0, 15, 0, 50), BackgroundTransparency = 1, Parent = DecorDropdownCard })
	local PulseDecorItem = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 60), BackgroundColor3 = Color3.fromRGB(22, 22, 22), Parent = DecorItemsContainer, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }) })
	Lib.RegisterThemeElement(PulseDecorItem, "BackgroundColor3", 0.7)

	local PulseTitle = Lib.Create("TextLabel", { Size = UDim2.new(1, -120, 0, 20), Position = UDim2.new(0, 12, 0, 10), BackgroundTransparency = 1, Text = "White Pulse Glow", TextColor3 = Color3.fromRGB(240, 240, 240), TextSize = 13, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, Parent = PulseDecorItem })
	Lib.RegisterThemeText(PulseTitle, "Primary")

	local PulseDescLabel = Lib.Create("TextLabel", { Size = UDim2.new(1, -120, 0, 18), Position = UDim2.new(0, 12, 0, 30), BackgroundTransparency = 1, Text = State.Ach_10Hours_Claimed and "Unlocked from 10 Hours Played" or "Locked (Reach 10h achievement)", TextColor3 = State.Ach_10Hours_Claimed and Color3.fromRGB(140, 140, 140) or Color3.fromRGB(220, 80, 80), TextSize = 11, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, Parent = PulseDecorItem })
	local ToggleDecorBtn = Lib.Create("TextButton", { Size = UDim2.fromOffset(80, 30), Position = UDim2.new(1, -90, 0.5, -15), BackgroundColor3 = State.IsDecorActive and Color3.fromRGB(46, 213, 115) or Color3.fromRGB(40, 40, 40), Text = State.IsDecorActive and "Equipped" or (State.Ach_10Hours_Claimed and "Equip" or "Locked"), TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 12, Font = Enum.Font.GothamBold, Parent = PulseDecorItem, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }) })

	local function UpdateDecorButtonState()
		if not State.Ach_10Hours_Claimed then
			ToggleDecorBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
			ToggleDecorBtn.TextColor3 = Color3.fromRGB(120, 120, 120)
			ToggleDecorBtn.Text = "Locked"
			PulseDescLabel.Text = "Locked (Reach 10h achievement)"
			PulseDescLabel.TextColor3 = Color3.fromRGB(220, 80, 80)
		else
			PulseDescLabel.Text = "Unlocked from 10 Hours Played"
			PulseDescLabel.TextColor3 = Color3.fromRGB(140, 140, 140)
			if State.IsDecorActive then
				ToggleDecorBtn.BackgroundColor3 = Lib.GetActiveSwitchColor()
				ToggleDecorBtn.TextColor3 = State.LightTheme and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 255, 255)
				ToggleDecorBtn.Text = "Equipped"
			else
				ToggleDecorBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				ToggleDecorBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
				ToggleDecorBtn.Text = "Equip"
			end
		end
		AvatarGlowRing.Visible = State.IsDecorActive
		if State.IsDecorActive then GlowTween:Play() else GlowTween:Pause() end
	end

	ToggleDecorBtn.MouseButton1Click:Connect(function()
		Lib.PlayClick()
		if not State.Ach_10Hours_Claimed then return end
		State.IsDecorActive = not State.IsDecorActive
		UpdateDecorButtonState()
		Lib.SavePlaytimeData()
	end)

	local isDropdownOpen = false
	DecorHeaderBtn.MouseButton1Click:Connect(function()
		Lib.PlayClick()
		isDropdownOpen = not isDropdownOpen
		Lib.Tween(DropdownArrow, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Rotation = isDropdownOpen and 180 or 0 })
		Lib.Tween(DecorDropdownCard, 0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, { Size = isDropdownOpen and UDim2.new(1, 0, 0, 140) or UDim2.new(1, 0, 0, 50) })
	end)

	local AchievementsScroll = Lib.Create("ScrollingFrame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ScrollBarThickness = 2, ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100), BorderSizePixel = 0, Parent = View_Achievements })
	local AchievementsLayout = Lib.Create("UIListLayout", { Padding = UDim.new(0, 14), SortOrder = Enum.SortOrder.LayoutOrder, Parent = AchievementsScroll })
	Lib.Create("UIPadding", { PaddingTop = UDim.new(0, 5), PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 15), Parent = AchievementsScroll })

	AchievementsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		AchievementsScroll.CanvasSize = UDim2.new(0, 0, 0, AchievementsLayout.AbsoluteContentSize.Y + 20)
	end)

	local AchCard = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 90), BackgroundColor3 = Color3.fromRGB(12, 12, 12), Parent = AchievementsScroll, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) }), Lib.Create("UIStroke", { Color = Color3.fromRGB(35, 35, 35), Thickness = 1, Transparency = 0.4 }) })
	Lib.RegisterThemeElement(AchCard, "BackgroundColor3", 0.5)

	local AchIconSection = Lib.Create("Frame", { Size = UDim2.new(0, 80, 1, 0), BackgroundTransparency = 1, Parent = AchCard })
	Lib.Create("ImageLabel", { Size = UDim2.fromOffset(58, 58), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Image = "rbxassetid://9241155124241", ScaleType = Enum.ScaleType.Fit, Parent = AchIconSection })
	Lib.Create("Frame", { Size = UDim2.new(0, 1, 1, -20), Position = UDim2.new(0, 80, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.fromRGB(30, 30, 30), BorderSizePixel = 0, Parent = AchCard })

	local AchInfoSection = Lib.Create("Frame", { Size = UDim2.new(1, -210, 1, 0), Position = UDim2.new(0, 92, 0, 0), BackgroundTransparency = 1, Parent = AchCard })
	local AchTitle = Lib.Create("TextLabel", { Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0, 12), BackgroundTransparency = 1, Text = "10 HOURS PLAYED", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 15, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, Parent = AchInfoSection })
	Lib.RegisterThemeText(AchTitle, "Primary")

	local AchDesc = Lib.Create("TextLabel", { Size = UDim2.new(1, 0, 0, 16), Position = UDim2.new(0, 0, 0, 34), BackgroundTransparency = 1, Text = "Thanks for spending 10 hours with us!", TextColor3 = Color3.fromRGB(140, 140, 140), TextSize = 11, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, Parent = AchInfoSection })
	Lib.RegisterThemeText(AchDesc, "Secondary")

	local RewardRow = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 18), Position = UDim2.new(0, 0, 0, 56), BackgroundTransparency = 1, Parent = AchInfoSection })
	Lib.Create("ImageLabel", { Size = UDim2.fromOffset(13, 13), Position = UDim2.new(0, 0, 0.5, -7), BackgroundTransparency = 1, Image = "rbxassetid://10734944449", ImageColor3 = Color3.fromRGB(255, 255, 255), ScaleType = Enum.ScaleType.Fit, Parent = RewardRow })
	local RewL = Lib.Create("TextLabel", { Size = UDim2.new(0, 50, 1, 0), Position = UDim2.new(0, 17, 0, 0), BackgroundTransparency = 1, Text = "REWARD:", TextColor3 = Color3.fromRGB(220, 220, 220), TextSize = 10, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, Parent = RewardRow })
	Lib.RegisterThemeText(RewL, "Primary")

	local RewV = Lib.Create("TextLabel", { Size = UDim2.new(1, -70, 1, 0), Position = UDim2.new(0, 72, 0, 0), BackgroundTransparency = 1, Text = "Profile Decoration", TextColor3 = Color3.fromRGB(150, 150, 150), TextSize = 11, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, Parent = RewardRow })
	Lib.RegisterThemeText(RewV, "Secondary")

	local ClaimAchBtn = Lib.Create("TextButton", { Size = UDim2.fromOffset(105, 30), Position = UDim2.new(1, -115, 0.5, -15), BackgroundColor3 = Color3.fromRGB(255, 255, 255), Text = "Claim", TextColor3 = Color3.fromRGB(0, 0, 0), TextSize = 12, Font = Enum.Font.GothamBold, Parent = AchCard, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }) })

	local function RefreshAchievementUI()
		local hours = State.TotalPlaytimeSeconds / 3600
		if State.Ach_10Hours_Claimed then
			ClaimAchBtn.Text = "Claimed ✓"
			ClaimAchBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
			ClaimAchBtn.TextColor3 = Color3.fromRGB(120, 120, 120)
			ClaimAchBtn.AutoButtonColor = false
		elseif hours >= 10 then
			ClaimAchBtn.Text = "Claim Reward"
			ClaimAchBtn.BackgroundColor3 = Lib.GetActiveSwitchColor()
			ClaimAchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			ClaimAchBtn.AutoButtonColor = true
		else
			ClaimAchBtn.Text = string.format("%.1f / 10h", math.min(hours, 10))
			ClaimAchBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
			ClaimAchBtn.TextColor3 = Color3.fromRGB(130, 130, 130)
			ClaimAchBtn.AutoButtonColor = false
		end
	end

	ClaimAchBtn.MouseButton1Click:Connect(function()
		Lib.PlayClick()
		local hours = State.TotalPlaytimeSeconds / 3600
		if (hours >= 10 or App.Player.Name:lower() == "cherrycalcor") and not State.Ach_10Hours_Claimed then
			State.Ach_10Hours_Claimed = true
			State.IsDecorActive = true
			Lib.SavePlaytimeData()
			RefreshAchievementUI()
			UpdateDecorButtonState()
			Lib.Notify({ Title = "Achievement Unlocked", Text = "You unlocked Profile Decoration!" })
		end
	end)

	UI.AchUpdateCallback = RefreshAchievementUI
	RefreshAchievementUI()
	UpdateDecorButtonState()

	Lib.Create("UIListLayout", { Padding = UDim.new(0, 10), Parent = View_Developers })
	local Devs = {
		{"CherryCalcor", "Main Developer | UI Designer | The ideologist"},
		{"HiveMango", "Deputy Chief Developer | UI Designer | Functions Developer"},
		{"Adevihia", "Junior Developer | Functions Developer"},
		{"GrenkiWaves", "Tester"}
	}
	for i, v in ipairs(Devs) do
		local devName = Lib.Create("TextLabel", { Size = UDim2.new(1, -30, 0, 22), Position = UDim2.fromOffset(15, 12), BackgroundTransparency = 1, Text = v[1], TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 15, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left })
		Lib.RegisterThemeText(devName, "Primary")

		local devRole = Lib.Create("TextLabel", { Size = UDim2.new(1, -30, 0, 18), Position = UDim2.fromOffset(15, 34), BackgroundTransparency = 1, Text = v[2], TextColor3 = Color3.fromRGB(150, 150, 150), TextSize = 12, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left })
		Lib.RegisterThemeText(devRole, "Secondary")

		local devCard = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 65), BackgroundColor3 = Color3.fromRGB(15, 15, 15), LayoutOrder = i, Parent = View_Developers, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
			devName, devRole
		})
		Lib.RegisterThemeElement(devCard, "BackgroundColor3", 0.5)
	end
end

do
	Lib.SearchItems, Lib.SearchGroups, Lib.SearchScrolls = {}, {}, {}

	function Lib.SearchAdd(card, item, title)
		if not Lib.SearchGroups[card] then return end
		local list = Lib.SearchItems
		local index = #list + 1
		list[index] = { Item = item, Parent = card, Title = title:lower() }
		item.LayoutOrder = index
	end

	function Lib.CreateFeatureGroup(parentScroll, title, layoutOrder)
		local GroupContainer = Lib.Create("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = layoutOrder,
			Parent = parentScroll
		})

		local grpTitle = Lib.Create("TextLabel", {
			Size = UDim2.new(1, 0, 0, 20),
			Position = UDim2.new(0, 4, 0, 0),
			BackgroundTransparency = 1,
			Text = title,
			TextColor3 = Color3.fromRGB(220, 220, 220),
			TextSize = 14,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = GroupContainer
		})
		Lib.RegisterThemeText(grpTitle, "Primary")

		local grp = Lib.Create("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Position = UDim2.new(0, 0, 0, 26),
			BackgroundColor3 = Color3.fromRGB(15, 15, 15),
			Parent = GroupContainer,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
			Lib.Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder })
		})
		Lib.RegisterThemeElement(grp, "BackgroundColor3", 0.5)
		if Lib.SearchScrolls[parentScroll] then Lib.SearchGroups[grp] = true end
		return grp
	end

	function Lib.CreateSettingToggleItem(parentCard, title, desc, defaultState, onToggle, isLast)
		local Item = Lib.Create("Frame", {
			Size = UDim2.new(1, 0, 0, 50),
			BackgroundTransparency = 1,
			Parent = parentCard
		})

		local titleLabel = Lib.Create("TextLabel", {
			Size = UDim2.new(1, -70, 0, 20),
			Position = UDim2.new(0, 14, 0, 7),
			BackgroundTransparency = 1,
			Text = title,
			TextColor3 = Color3.fromRGB(240, 240, 240),
			TextSize = 13,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = Item
		})
		Lib.RegisterThemeText(titleLabel, "Primary")

		local descLabel = Lib.Create("TextLabel", {
			Size = UDim2.new(1, -70, 0, 16),
			Position = UDim2.new(0, 14, 0, 26),
			BackgroundTransparency = 1,
			Text = desc,
			TextColor3 = Color3.fromRGB(130, 130, 130),
			TextSize = 11,
			Font = Enum.Font.GothamMedium,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = Item
		})
		Lib.RegisterThemeText(descLabel, "Secondary")

		local inactiveBg = Lib.Palette.SwitchOff
		local activeBg = Lib.GetActiveSwitchColor()

		local SwitchBg = Lib.Create("TextButton", {
			Size = UDim2.fromOffset(40, 22),
			Position = UDim2.new(1, -54, 0.5, -11),
			BackgroundColor3 = defaultState and activeBg or inactiveBg,
			Text = "",
			AutoButtonColor = false,
			Parent = Item,
			Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) })
		})

		local SwitchKnob = Lib.Create("Frame", {
			Size = UDim2.fromOffset(16, 16),
			Position = defaultState and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Parent = SwitchBg,
			Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) })
		})

		if not isLast then
			Lib.Create("Frame", {
				Size = UDim2.new(1, -28, 0, 1),
				Position = UDim2.new(0, 14, 1, -1),
				BackgroundColor3 = Color3.fromRGB(25, 25, 25),
				BorderSizePixel = 0,
				Parent = Item
			})
		end

		local state = defaultState
		local function UpdateSwitchVisual()
			local currentActive = Lib.GetActiveSwitchColor()
			local currentInactive = Lib.Palette.SwitchOff

			Lib.Tween(SwitchBg, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
				BackgroundColor3 = state and currentActive or currentInactive
			})
			Lib.Tween(SwitchKnob, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
				Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
			})
		end

		Lib.RegisterSwitch(SwitchBg, function() return state end, UpdateSwitchVisual)

		Lib.ToggleControls[title] = {
			Get = function() return state end,
			Set = function(value)
				if state == value then return end
				state = value
				UpdateSwitchVisual()
				onToggle(state)
			end
		}

		SwitchBg.MouseButton1Click:Connect(function()
			Lib.PlayClick()
			state = not state
			UpdateSwitchVisual()
			onToggle(state)
			Lib.Notify({ Title = title, Text = state and "Enabled" or "Disabled" })
		end)

		Lib.SearchAdd(parentCard, Item, title)
		return Item
	end

	function Lib.CreateSettingSliderItem(parentCard, title, desc, minVal, maxVal, defaultVal, onChange, isLast, suffix, step)
		local digits = step and #(tostring(step):match("%.(%d+)") or "") or 0
		local function Fmt(value)
			if not step then return tostring(math.floor(value)) end
			return string.format("%." .. digits .. "f", value)
		end

		local Item = Lib.Create("Frame", {
			Size = UDim2.new(1, 0, 0, 50),
			BackgroundTransparency = 1,
			Parent = parentCard
		})

		local titleLabel = Lib.Create("TextLabel", {
			Size = UDim2.new(1, -190, 0, 20),
			Position = UDim2.new(0, 14, 0, 7),
			BackgroundTransparency = 1,
			Text = title,
			TextColor3 = Color3.fromRGB(240, 240, 240),
			TextSize = 13,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = Item
		})
		Lib.RegisterThemeText(titleLabel, "Primary")

		local DescLabel = Lib.Create("TextLabel", {
			Size = UDim2.new(1, -190, 0, 16),
			Position = UDim2.new(0, 14, 0, 26),
			BackgroundTransparency = 1,
			Text = desc .. " (" .. Fmt(defaultVal) .. (suffix or "") .. ")",
			TextColor3 = Color3.fromRGB(130, 130, 130),
			TextSize = 11,
			Font = Enum.Font.GothamMedium,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = Item
		})
		Lib.RegisterThemeText(DescLabel, "Secondary")

		local SliderContainer = Lib.Create("Frame", {
			Size = UDim2.fromOffset(130, 24),
			Position = UDim2.new(1, -144, 0.5, -12),
			BackgroundTransparency = 1,
			Parent = Item
		})

		local SliderTrack = Lib.Create("Frame", {
			Size = UDim2.new(1, 0, 0, 4),
			Position = UDim2.new(0, 0, 0.5, -2),
			BackgroundColor3 = Color3.fromRGB(35, 35, 35),
			BorderSizePixel = 0,
			Parent = SliderContainer,
			Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) })
		})

		local SliderFill = Lib.Create("Frame", {
			Size = UDim2.new(0, 0, 1, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
			Parent = SliderTrack,
			Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) })
		})

		local SliderKnob = Lib.Create("Frame", {
			Size = UDim2.fromOffset(20, 12),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
			Parent = SliderTrack,
			Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) })
		})

		if not isLast then
			Lib.Create("Frame", {
				Size = UDim2.new(1, -28, 0, 1),
				Position = UDim2.new(0, 14, 1, -1),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 0.9,
				BorderSizePixel = 0,
				Parent = Item
			})
		end

		local dragging = false

		local function UpdateSlider(inputPos)
			local trackAbsPos = SliderTrack.AbsolutePosition.X
			local trackAbsSize = SliderTrack.AbsoluteSize.X
			local relX = math.clamp((inputPos.X - trackAbsPos) / trackAbsSize, 0, 1)
			local currentVal = math.floor(minVal + (maxVal - minVal) * relX)
			local shown = relX
			if step then
				currentVal = tonumber(Fmt(math.clamp(minVal + math.floor((maxVal - minVal) * relX / step + 0.5) * step, minVal, maxVal)))
				shown = math.clamp((currentVal - minVal) / (maxVal - minVal), 0, 1)
			end

			SliderKnob.Position = UDim2.new(shown, 0, 0.5, 0)
			SliderFill.Size = UDim2.new(shown, 0, 1, 0)
			DescLabel.Text = desc .. " (" .. Fmt(currentVal) .. (suffix or "") .. ")"
			onChange(currentVal)
		end

		local function Display(value)
			local percent = math.clamp((value - minVal) / (maxVal - minVal), 0, 1)
			SliderKnob.Position = UDim2.new(percent, 0, 0.5, 0)
			SliderFill.Size = UDim2.new(percent, 0, 1, 0)
			DescLabel.Text = desc .. " (" .. Fmt(value) .. (suffix or "") .. ")"
		end

		Display(defaultVal)
		Lib.SliderControls[title] = function(value)
			Display(value)
			onChange(value)
		end

		local TriggerBtn = Lib.Create("TextButton", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = "",
			Parent = SliderContainer
		})

		TriggerBtn.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				UpdateSlider(input.Position)
			end
		end)

		Lib.C(Services.UserInputService.InputChanged, function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				UpdateSlider(input.Position)
			end
		end)

		Lib.C(Services.UserInputService.InputEnded, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)

		Lib.SearchAdd(parentCard, Item, title)
		return Item
	end

	function Lib.CreateSettingChoiceItem(parentCard, title, options, default, onChange, isLast, multi)
		local entries = {}
		for i, option in ipairs(options) do
			entries[i] = type(option) == "table" and option or { option, option }
		end
		local cycle = not multi and #entries > 4
		local selected, current = {}, entries[1][2]
		if multi then
			for _, value in ipairs(default or {}) do selected[value] = true end
		elseif default ~= nil then
			current = default
		end

		local Item = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 46), BackgroundTransparency = 1, Parent = parentCard })

		local titleLabel = Lib.Create("TextLabel", {
			Size = UDim2.new(1, -28, 1, 0),
			Position = UDim2.fromOffset(14, 0),
			BackgroundTransparency = 1,
			Text = title,
			TextColor3 = Color3.fromRGB(240, 240, 240),
			TextSize = 13,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = Item
		})
		Lib.RegisterThemeText(titleLabel, "Primary")

		local holder = Lib.Create("Frame", {
			Size = UDim2.fromOffset(0, 24),
			AutomaticSize = Enum.AutomaticSize.X,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -14, 0.5, 0),
			BackgroundTransparency = 1,
			Parent = Item,
			Lib.Create("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 4),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center
			})
		})

		local pills = {}

		local function Active(value)
			if multi then return selected[value] == true end
			return current == value
		end

		local function Label(value)
			for _, entry in ipairs(entries) do
				if entry[2] == value then return entry[1] end
			end
			return tostring(value)
		end

		local function Snapshot()
			local copy = {}
			for key in pairs(selected) do copy[key] = true end
			return copy
		end

		local function Paint()
			if cycle then
				pills[1].Text = Label(current)
				return
			end
			local on, off = Lib.Palette.SwitchOn, Lib.Palette.SwitchOff
			for i, pill in ipairs(pills) do
				local active = Active(entries[i][2])
				Lib.Tween(pill, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
					BackgroundColor3 = active and on or off,
					TextColor3 = active and Color3.new(1, 1, 1) or Color3.fromRGB(170, 170, 170)
				})
			end
		end

		for i = 1, cycle and 1 or #entries do
			local pill = Lib.Create("TextButton", {
				Size = UDim2.fromOffset(0, 24),
				AutomaticSize = Enum.AutomaticSize.X,
				LayoutOrder = i,
				AutoButtonColor = false,
				BackgroundColor3 = Lib.Palette.SwitchOff,
				TextColor3 = cycle and Color3.new(1, 1, 1) or Color3.fromRGB(170, 170, 170),
				Text = cycle and Label(current) or entries[i][1],
				TextSize = 11,
				Font = Enum.Font.GothamMedium,
				Parent = holder,
				Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
				Lib.Create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) })
			})
			pills[i] = pill
			if not cycle then
				Lib.RegisterSwitch(pill, function() return Active(entries[i][2]) end, Paint)
			end
			pill.MouseButton1Click:Connect(function()
				Lib.PlayClick()
				if cycle then
					local index = 1
					for j, entry in ipairs(entries) do
						if entry[2] == current then
							index = j
							break
						end
					end
					current = entries[index % #entries + 1][2]
					Paint()
					onChange(current)
				elseif multi then
					local value = entries[i][2]
					selected[value] = not selected[value] or nil
					Paint()
					onChange(Snapshot())
				else
					current = entries[i][2]
					Paint()
					onChange(current)
				end
			end)
		end
		Paint()

		Lib.ChoiceControls[title] = {
			Get = function()
				if not multi then return current end
				local list = {}
				for _, entry in ipairs(entries) do
					if selected[entry[2]] then list[#list + 1] = entry[2] end
				end
				return list
			end,
			Set = function(value)
				if multi then
					table.clear(selected)
					for _, item in ipairs(type(value) == "table" and value or { value }) do selected[item] = true end
					Paint()
					onChange(Snapshot())
					return
				end
				for _, entry in ipairs(entries) do
					if entry[2] == value then
						current = value
						Paint()
						onChange(value)
						return
					end
				end
			end
		}

		if not isLast then
			Lib.Create("Frame", {
				Size = UDim2.new(1, -28, 0, 1),
				Position = UDim2.new(0, 14, 1, -1),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 0.9,
				BorderSizePixel = 0,
				Parent = Item
			})
		end

		Lib.SearchAdd(parentCard, Item, title)
		return Item
	end

	function Lib.CreateSettingButtonItem(parentCard, title, desc, onClick, isLast)
		local Item = Lib.Create("TextButton", {
			Size = UDim2.new(1, 0, 0, 52),
			BackgroundColor3 = Color3.fromRGB(15, 15, 15),
			BackgroundTransparency = 0,
			Text = "",
			AutoButtonColor = false,
			Parent = parentCard,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) })
		})
		Lib.RegisterThemeElement(Item, "BackgroundColor3", 0.5)

		local TitleLabel = Lib.Create("TextLabel", {
			Size = UDim2.new(1, -30, 0, 20),
			Position = UDim2.new(0, 14, 0, 8),
			BackgroundTransparency = 1,
			Text = title,
			TextColor3 = Color3.fromRGB(240, 240, 240),
			TextSize = 13,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = Item
		})
		Lib.RegisterThemeText(TitleLabel, "Primary")

		local DescLabel = Lib.Create("TextLabel", {
			Size = UDim2.new(1, -30, 0, 16),
			Position = UDim2.new(0, 14, 0, 28),
			BackgroundTransparency = 1,
			Text = desc,
			TextColor3 = Color3.fromRGB(130, 130, 130),
			TextSize = 11,
			Font = Enum.Font.GothamMedium,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = Item
		})
		Lib.RegisterThemeText(DescLabel, "Secondary")

		if not isLast then
			Lib.Create("Frame", {
				Size = UDim2.new(1, -28, 0, 1),
				Position = UDim2.new(0, 14, 1, -1),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 0.9,
				BorderSizePixel = 0,
				Parent = Item
			})
		end

		Item.MouseEnter:Connect(function() Lib.Tween(Item, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Lib.Lighten(Lib.Theme.Card, 0.055) }) end)
		Item.MouseLeave:Connect(function() Lib.Tween(Item, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Lib.Theme.Card }) end)
		Item.MouseButton1Down:Connect(function()
			Lib.PlayClick()
			Lib.Tween(Item, 0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Lib.Lighten(Lib.Theme.Card, 0.105) })
		end)
		Item.MouseButton1Up:Connect(function() Lib.Tween(Item, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Lib.Lighten(Lib.Theme.Card, 0.055) }) end)
		Item.MouseButton1Click:Connect(function() onClick(TitleLabel) end)

		Lib.SearchAdd(parentCard, Item, title)
		return Item
	end
end

function Lib.BuildFeatureSearch(section, sideBar, tabs)
	local list = Lib.SearchItems
	local shown = {}
	local active = false

	local results = Lib.Create("ScrollingFrame", {
		Size = UDim2.new(1, -190, 1, -20), Position = UDim2.new(0, 180, 0, 10), BackgroundTransparency = 1, BorderSizePixel = 0,
		ScrollBarThickness = 2, ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100), CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false, Parent = section,
		Lib.Create("UIPadding", { PaddingTop = UDim.new(0, 5), PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 15) })
	})
	local card = Lib.Create("Frame", {
		Size = UDim2.fromScale(1, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Color3.fromRGB(15, 15, 15), Parent = results,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
		Lib.Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder })
	})
	Lib.RegisterThemeElement(card, "BackgroundColor3", 0.5)
	local empty = Lib.Create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Text = "No features found", TextColor3 = Color3.fromRGB(130, 130, 130),
		TextSize = 13, Font = Enum.Font.GothamMedium, Visible = false, Parent = results
	})
	Lib.RegisterThemeText(empty, "Secondary")

	local function SetViews(current)
		for _, view in ipairs(section:GetChildren()) do
			if view:IsA("CanvasGroup") then view.Visible = view.Name == current end
		end
	end

	local function Apply(text)
		local query = text:lower()
		for i = #shown, 1, -1 do
			local entry = shown[i]
			entry.Item.Parent = entry.Parent
			shown[i] = nil
		end
		if query == "" then
			if active then
				active = false
				results.Visible = false
				SetViews(State.CurrentFeaturesTab)
			end
			return
		end
		if not active then
			active = true
			SetViews(nil)
			results.Visible = true
		end
		local length = #query
		for i = 1, #list do
			local entry = list[i]
			local title = entry.Title
			if title:sub(1, length) == query or title:find(" " .. query, 1, true) then
				entry.Item.Parent = card
				shown[#shown + 1] = entry
			end
		end
		card.Visible = #shown > 0
		empty.Visible = #shown == 0
		results.CanvasPosition = Vector2.zero
	end

	local box = Lib.MakeSearchBox(sideBar, "Search features", UDim2.fromOffset(15, 46), UDim2.new(1, -30, 0, 28), 0, Apply)
	for _, button in ipairs(tabs:GetChildren()) do
		if button:IsA("TextButton") then
			button.MouseButton1Click:Connect(function()
				task.defer(function() box.Text = "" end)
			end)
		end
	end
end

function Lib.BuildBrowseSearch(view, scroll, bottom, placeholder, onQuery)
	local api = {}

	local strip = Lib.Create("ScrollingFrame", {
		Size = UDim2.new(1, 0, 0, 56), Position = UDim2.fromOffset(0, 38), BackgroundTransparency = 1, BorderSizePixel = 0,
		ScrollBarThickness = 2, ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100), ScrollingDirection = Enum.ScrollingDirection.X,
		CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.X, Visible = false, Parent = view,
		Lib.Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
		Lib.Create("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 4) })
	})

	local function Layout(hasStrip)
		local top = hasStrip and 102 or 38
		scroll.Position = UDim2.fromOffset(0, top)
		scroll.Size = UDim2.new(1, 0, 1, -(top + bottom))
		strip.Visible = hasStrip
	end

	api.Box = Lib.MakeSearchBox(view, placeholder, UDim2.fromOffset(8, 0), UDim2.new(1, -16, 0, 30), 0.4, onQuery)

	function api.SetSuggestions(list)
		for _, child in ipairs(strip:GetChildren()) do
			if child:IsA("GuiButton") then child:Destroy() end
		end
		local count = list and #list or 0
		for i = 1, count do
			local data = list[i]
			local card = Lib.Create("TextButton", {
				Size = UDim2.fromOffset(190, 50), BackgroundColor3 = Color3.fromRGB(15, 15, 15), Text = "", AutoButtonColor = false,
				LayoutOrder = i, Parent = strip,
				Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) })
			})
			Lib.RegisterThemeElement(card, "BackgroundColor3", 0.5)

			local thumb = Lib.Create("ImageLabel", {
				Size = UDim2.fromOffset(36, 36), Position = UDim2.fromOffset(7, 7), BackgroundColor3 = Color3.fromRGB(22, 22, 22),
				Image = data.Image or "rbxassetid://113533839488998", ScaleType = Enum.ScaleType.Crop, Parent = card,
				Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
			})
			Lib.RegisterThemeElement(thumb, "BackgroundColor3", 0.7)

			local name = Lib.Create("TextLabel", {
				Size = UDim2.new(1, -56, 0, 16), Position = UDim2.fromOffset(50, 7), BackgroundTransparency = 1, Text = data.Name,
				TextColor3 = Color3.fromRGB(240, 240, 240), TextSize = 12, Font = Enum.Font.GothamBold,
				TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = card
			})
			Lib.RegisterThemeText(name, "Primary")

			local sub = Lib.Create("TextLabel", {
				Size = UDim2.new(1, -56, 0, 20), Position = UDim2.fromOffset(50, 24), BackgroundTransparency = 1, Text = data.Sub or "",
				TextColor3 = Color3.fromRGB(130, 130, 130), TextSize = 10, Font = Enum.Font.Gotham, TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextTruncate = Enum.TextTruncate.AtEnd, Parent = card
			})
			Lib.RegisterThemeText(sub, "Secondary")

			card.MouseEnter:Connect(function()
				Lib.Tween(card, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Lib.Lighten(Lib.Theme.Card, 0.04) })
			end)
			card.MouseLeave:Connect(function()
				Lib.Tween(card, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Lib.Theme.Card })
			end)
			card.MouseButton1Click:Connect(function()
				Lib.PlayClick()
				api.Box.Text = data.Name
			end)
		end
		Layout(count > 0)
	end

	Layout(false)
	return api
end


function Lib.MakeStore(file, limit)
	local Http = Services.HttpService
	local list, store = {}, {}
	if isfile and readfile then
		pcall(function()
			if isfile(file) then
				local data = Http:JSONDecode(readfile(file))
				if type(data) == "table" then list = data end
			end
		end)
	end
	local function Commit()
		if not writefile then return end
		pcall(function() writefile(file, Http:JSONEncode(list)) end)
	end
	function store.List() return list end
	function store.Find(key)
		for index, entry in ipairs(list) do
			if entry.key == key then return index end
		end
	end
	function store.Has(key) return store.Find(key) ~= nil end
	function store.Add(key, data)
		local index = store.Find(key)
		if index then table.remove(list, index) end
		table.insert(list, 1, { key = key, data = data })
		if limit and #list > limit then table.remove(list) end
		Commit()
	end
	function store.Remove(key)
		local index = store.Find(key)
		if index then
			table.remove(list, index)
			Commit()
		end
	end
	function store.Toggle(key, data)
		if store.Has(key) then
			store.Remove(key)
			return false
		end
		store.Add(key, data)
		return true
	end
	return store
end

function Lib.MakeStar(parent, position, saved, onToggle)
	local gold, white = Color3.fromRGB(255, 200, 40), Color3.new(1, 1, 1)
	local star = Lib.Create("TextButton", {
		Size = UDim2.fromOffset(24, 24), Position = position, BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.5,
		AutoButtonColor = false, Text = "\u{2605}", TextSize = 15, Font = Enum.Font.GothamBold, TextColor3 = saved and gold or white,
		ZIndex = 9, Parent = parent,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
	})
	star.MouseButton1Click:Connect(function()
		Lib.PlayClick()
		Lib.Tween(star, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { TextColor3 = onToggle() and gold or white })
	end)
	return star
end

function Lib.MakeCardList(view, emptyText, cell, gap, padX)
	local scroll = Lib.Create("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ScrollBarThickness = 2, ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100),
		BorderSizePixel = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = view,
		Lib.Create("UIGridLayout", { CellSize = cell, CellPadding = gap, SortOrder = Enum.SortOrder.LayoutOrder }),
		Lib.Create("UIPadding", { PaddingTop = UDim.new(0, 5), PaddingLeft = UDim.new(0, padX), PaddingRight = UDim.new(0, padX), PaddingBottom = UDim.new(0, 15) })
	})
	local empty = Lib.Create("TextLabel", {
		Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = emptyText, TextColor3 = Color3.fromRGB(150, 150, 150),
		TextSize = 14, Font = Enum.Font.GothamMedium, Visible = false, Parent = view
	})
	Lib.RegisterThemeText(empty, "Secondary")
	return scroll, empty
end

function Lib.MakeFilterButton(sideBar, onClick)
	local api, hover = {}, false
	local function Idle() return State.LightTheme and Color3.fromRGB(100, 100, 100) or Color3.fromRGB(150, 150, 150) end
	local button = Lib.Create("TextButton", {
		Size = UDim2.new(1, -30, 0, 34), Position = UDim2.new(0, 15, 1, -74), BackgroundColor3 = Lib.Palette.Primary, BackgroundTransparency = 1,
		Text = "", AutoButtonColor = false, Parent = sideBar,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 7) })
	})
	local label = Lib.Create("TextLabel", {
		Size = UDim2.new(1, -72, 1, 0), Position = UDim2.fromOffset(38, 0), BackgroundTransparency = 1, Text = "Filters", TextSize = 14,
		Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Idle(), Parent = button
	})
	local pieces = {}
	local function Piece(size, position, round)
		local piece = Lib.Create("Frame", { Size = size, Position = position, BackgroundColor3 = Idle(), BorderSizePixel = 0, Parent = button })
		if round then Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = piece }) end
		pieces[#pieces + 1] = piece
	end
	Piece(UDim2.fromOffset(14, 2), UDim2.fromOffset(12, 11))
	Piece(UDim2.fromOffset(14, 2), UDim2.fromOffset(12, 21))
	Piece(UDim2.fromOffset(6, 6), UDim2.fromOffset(21, 9), true)
	Piece(UDim2.fromOffset(6, 6), UDim2.fromOffset(13, 19), true)

	local badge = Lib.Create("TextLabel", {
		Size = UDim2.fromOffset(20, 18), Position = UDim2.new(1, -28, 0.5, -9), BackgroundColor3 = Lib.Palette.Primary, Text = "0",
		TextColor3 = Color3.new(0, 0, 0), TextSize = 11, Font = Enum.Font.GothamBold, Visible = false, Parent = button,
		Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) })
	})

	local function Paint()
		local color = hover and Lib.Palette.Primary or Idle()
		local info = { Enum.EasingStyle.Quad, Enum.EasingDirection.Out }
		Lib.Tween(label, 0.15, info[1], info[2], { TextColor3 = color })
		for _, piece in ipairs(pieces) do Lib.Tween(piece, 0.15, info[1], info[2], { BackgroundColor3 = color }) end
		Lib.Tween(button, 0.15, info[1], info[2], { BackgroundColor3 = Lib.Palette.Primary, BackgroundTransparency = hover and 0.92 or 1 })
		badge.BackgroundColor3 = Lib.Palette.Primary
		badge.TextColor3 = State.LightTheme and Color3.new(1, 1, 1) or Color3.new(0, 0, 0)
	end

	button.MouseEnter:Connect(function() hover = true Paint() end)
	button.MouseLeave:Connect(function() hover = false Paint() end)
	button.MouseButton1Click:Connect(function()
		Lib.PlayClick()
		onClick()
	end)
	table.insert(Lib.ThemeHooks, Paint)
	Paint()

	function api.SetCount(count)
		badge.Text = tostring(count)
		badge.Visible = count > 0
	end
	return api
end

function Lib.MakeFilterChips(parent, title, options, isOn, onPick, order, cellWidth, disabled)
	local section = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = order, Parent = parent })
	local heading = Lib.Create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Text = title, TextColor3 = Color3.fromRGB(200, 200, 200), TextSize = 12,
		Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, Parent = section
	})
	Lib.RegisterThemeText(heading, "Primary")
	local grid = Lib.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Position = UDim2.fromOffset(0, 22), BackgroundColor3 = Color3.fromRGB(22, 22, 22), Parent = section,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 9) }),
		Lib.Create("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6) }),
		Lib.Create("UIGridLayout", { CellSize = UDim2.fromOffset(cellWidth, 28), CellPadding = UDim2.fromOffset(6, 6), SortOrder = Enum.SortOrder.LayoutOrder })
	})
	Lib.RegisterThemeElement(grid, "BackgroundColor3", 0.7)

	local buttons = {}
	local function Refresh()
		local light = State.LightTheme
		for option, button in pairs(buttons) do
			local on = isOn(option)
			local off = disabled and disabled[option]
			Lib.Tween(button, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
				BackgroundColor3 = Lib.Palette.Primary,
				BackgroundTransparency = on and 0 or 1,
				TextColor3 = on and (light and Color3.new(1, 1, 1) or Color3.new(0, 0, 0)) or (off and Color3.fromRGB(85, 85, 85) or Color3.fromRGB(150, 150, 150))
			})
		end
	end
	for index, option in ipairs(options) do
		local button = Lib.Create("TextButton", {
			BackgroundColor3 = Lib.Palette.Primary, BackgroundTransparency = 1, Text = option, TextSize = 12, Font = Enum.Font.GothamMedium,
			TextColor3 = Color3.fromRGB(150, 150, 150), AutoButtonColor = false, LayoutOrder = index, Parent = grid,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 7) })
		})
		buttons[option] = button
		button.MouseButton1Click:Connect(function()
			Lib.PlayClick()
			onPick(option)
			Refresh()
		end)
	end
	Refresh()
	table.insert(Lib.ThemeHooks, Refresh)
	return Refresh
end

function Lib.BuildFilterModal(title, subtitle)
	local api, busy = {}, false
	local backdrop = Lib.Create("TextButton", {
		Name = "FilterBackdrop", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1,
		Text = "", AutoButtonColor = false, Visible = false, ZIndex = 30, Parent = UI.Main
	})
	local window = Lib.Create("Frame", {
		Size = UDim2.fromOffset(400, 470), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(16, 16, 16), ClipsDescendants = true, Active = true, ZIndex = 31, Parent = backdrop,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 12) }),
		Lib.Create("UIStroke", { Color = Color3.fromRGB(60, 60, 60), Thickness = 1, Transparency = 0.5 })
	})
	Lib.RegisterThemeElement(window, "BackgroundColor3", 0.7)

	local heading = Lib.Create("TextLabel", {
		Size = UDim2.new(1, -70, 0, 22), Position = UDim2.fromOffset(18, 14), BackgroundTransparency = 1, Text = title, TextSize = 17,
		Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 32, Parent = window
	})
	Lib.RegisterThemeText(heading, "Primary")
	local sub = Lib.Create("TextLabel", {
		Size = UDim2.new(1, -70, 0, 16), Position = UDim2.fromOffset(18, 37), BackgroundTransparency = 1, Text = subtitle, TextSize = 12,
		Font = Enum.Font.GothamMedium, TextColor3 = Color3.fromRGB(130, 130, 130), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 32, Parent = window
	})
	Lib.RegisterThemeText(sub, "Secondary")
	local close = Lib.Create("TextButton", {
		Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, -42, 0, 14), BackgroundTransparency = 1, Text = "\u{00D7}", TextSize = 20,
		Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(150, 150, 150), AutoButtonColor = false, ZIndex = 32, Parent = window
	})
	Lib.RegisterThemeText(close, "Secondary")

	api.Content = Lib.Create("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, -70), Position = UDim2.fromOffset(0, 70), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2,
		ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 32, Parent = window,
		Lib.Create("UIListLayout", { Padding = UDim.new(0, 14), SortOrder = Enum.SortOrder.LayoutOrder }),
		Lib.Create("UIPadding", { PaddingLeft = UDim.new(0, 18), PaddingRight = UDim.new(0, 18), PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 18) })
	})

	function api.Open()
		if backdrop.Visible then return end
		Lib.GlassOpen(backdrop)
		window.Size = UDim2.fromOffset(380, 450)
		Lib.Tween(window, 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, { Size = UDim2.fromOffset(400, 470) })
	end
	function api.Close()
		if not backdrop.Visible or busy then return end
		busy = true
		Lib.GlassClose(backdrop, function()
			backdrop.Visible = false
			busy = false
		end)
	end
	close.MouseButton1Click:Connect(function()
		Lib.PlayClick()
		api.Close()
	end)
	backdrop.MouseButton1Click:Connect(api.Close)
	return api
end

function Lib.CollectPlaces(data, query)
	local order, map = {}, {}
	for _, script in ipairs(data) do
		local name = script.game
		if name and name ~= "" and name ~= "Universal" then
			local lower = name:lower()
			if lower:sub(1, #query) == query or lower:find(" " .. query, 1, true) then
				local entry = map[lower]
				if not entry and #order < 10 then
					entry = { Name = name, Image = script.imageUrl, Titles = {} }
					map[lower] = entry
					order[#order + 1] = entry
				end
				if entry and script.title and #entry.Titles < 2 then
					entry.Titles[#entry.Titles + 1] = script.title
				end
			end
		end
	end
	for _, entry in ipairs(order) do
		entry.Sub = table.concat(entry.Titles, " \u{2022} ")
	end
	return order
end


do
	local function ClearPlayerESP(plr)
		if Refs.ESP[plr] then
			if Refs.ESP[plr].Highlight then pcall(function() Refs.ESP[plr].Highlight:Destroy() end) end
			if Refs.ESP[plr].Billboard then pcall(function() Refs.ESP[plr].Billboard:Destroy() end) end
			if Refs.ESP[plr].BoxLines then
				for _, line in pairs(Refs.ESP[plr].BoxLines) do pcall(function() line:Remove() end) end
			end
			if Refs.ESP[plr].TracerLine then pcall(function() Refs.ESP[plr].TracerLine:Remove() end) end
			Refs.ESP[plr] = nil
		end
	end

	function Lib.ClearAllESP()
		for plr in pairs(Refs.ESP) do ClearPlayerESP(plr) end
	end

	local function InitPlayerESP(plr)
		if plr == App.Player then return end
		ClearPlayerESP(plr)

		local data = { Highlight = nil, Billboard = nil, BoxLines = nil, TracerLine = nil }

		if Drawing and Drawing.new then
			pcall(function()
				local line = Drawing.new("Line")
				line.Thickness = 1.5
				line.Color = Color3.fromRGB(255, 255, 255)
				line.Transparency = 0.85
				line.Visible = false
				data.TracerLine = line

				local box = {
					Top = Drawing.new("Line"),
					Bottom = Drawing.new("Line"),
					Left = Drawing.new("Line"),
					Right = Drawing.new("Line")
				}
				for _, l in pairs(box) do
					l.Thickness = 1.5
					l.Color = Color3.fromRGB(255, 255, 255)
					l.Transparency = 0.85
					l.Visible = false
				end
				data.BoxLines = box
			end)
		end

		Refs.ESP[plr] = data
	end

	for _, p in ipairs(Services.Players:GetPlayers()) do
		if p ~= App.Player then InitPlayerESP(p) end
	end
	Lib.C(Services.Players.PlayerAdded, InitPlayerESP)
	Lib.C(Services.Players.PlayerRemoving, ClearPlayerESP)

	Lib.C(Services.Run.RenderStepped, function()
		if not (State.ESP_Name or State.ESP_Outline or State.ESP_Box or State.ESP_Tracers) then
			if Refs.ESPActive then
				Refs.ESPActive = false
				for _, esp in pairs(Refs.ESP) do
					if esp.Billboard then esp.Billboard.Enabled = false end
					if esp.Highlight then esp.Highlight.Enabled = false end
					if esp.BoxLines then for _, l in pairs(esp.BoxLines) do l.Visible = false end end
					if esp.TracerLine then esp.TracerLine.Visible = false end
				end
			end
			return
		end
		Refs.ESPActive = true

		for plr, esp in pairs(Refs.ESP) do
			local char = plr.Character
			local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"))
			local hum = char and char:FindFirstChildOfClass("Humanoid")

			if char and root and hum and hum.Health > 0 then
				local distance = math.floor((root.Position - App.Camera.CFrame.Position).Magnitude)
				local screenPos, onScreen = App.Camera:WorldToViewportPoint(root.Position)

				if State.ESP_Name then
					if not esp.Billboard or esp.Billboard.Parent ~= char then
						if esp.Billboard then esp.Billboard:Destroy() end
						local head = char:FindFirstChild("Head") or root
						local bb = Lib.Create("BillboardGui", {
							Name = "Septus_NameESP",
							Adornee = head,
							Size = UDim2.fromOffset(180, 30),
							StudsOffset = Vector3.new(0, 2.3, 0),
							AlwaysOnTop = true,
							Parent = char,
							Lib.Create("TextLabel", {
								Name = "ESPLabel",
								Size = UDim2.new(1, 0, 1, 0),
								BackgroundTransparency = 1,
								TextColor3 = Color3.fromRGB(255, 255, 255),
								TextStrokeTransparency = 0.2,
								TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
								Font = Enum.Font.GothamBold,
								TextSize = 13
							})
						})
						esp.Billboard = bb
					end
					local lbl = esp.Billboard:FindFirstChild("ESPLabel")
					if lbl then
						lbl.Text = plr.DisplayName .. " [" .. tostring(distance) .. " studs]"
					end
					esp.Billboard.Enabled = true
				else
					if esp.Billboard then esp.Billboard.Enabled = false end
				end

				if State.ESP_Outline then
					if not esp.Highlight or esp.Highlight.Parent ~= char then
						if esp.Highlight then esp.Highlight:Destroy() end
						esp.Highlight = Lib.Create("Highlight", {
							Name = "Septus_OutlineESP",
							FillColor = Color3.fromRGB(255, 255, 255),
							FillTransparency = 0.6,
							OutlineColor = Color3.fromRGB(255, 255, 255),
							OutlineTransparency = 0,
							DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
							Adornee = char,
							Parent = char
						})
					end
					esp.Highlight.Enabled = true
				else
					if esp.Highlight then esp.Highlight.Enabled = false end
				end

				if onScreen then
					local head = char:FindFirstChild("Head")
					local headPos = head and App.Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0)) or App.Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 2.5, 0))
					local legPos = App.Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))

					local height = math.abs(headPos.Y - legPos.Y)
					local width = height * 0.65
					local topLeft = Vector2.new(screenPos.X - width / 2, screenPos.Y - height / 2)

					if State.ESP_Box and esp.BoxLines then
						esp.BoxLines.Top.From = topLeft
						esp.BoxLines.Top.To = Vector2.new(topLeft.X + width, topLeft.Y)
						esp.BoxLines.Top.Visible = true

						esp.BoxLines.Bottom.From = Vector2.new(topLeft.X, topLeft.Y + height)
						esp.BoxLines.Bottom.To = Vector2.new(topLeft.X + width, topLeft.Y + height)
						esp.BoxLines.Bottom.Visible = true

						esp.BoxLines.Left.From = topLeft
						esp.BoxLines.Left.To = Vector2.new(topLeft.X, topLeft.Y + height)
						esp.BoxLines.Left.Visible = true

						esp.BoxLines.Right.From = Vector2.new(topLeft.X + width, topLeft.Y)
						esp.BoxLines.Right.To = Vector2.new(topLeft.X + width, topLeft.Y + height)
						esp.BoxLines.Right.Visible = true
					elseif esp.BoxLines then
						for _, l in pairs(esp.BoxLines) do l.Visible = false end
					end

					if State.ESP_Tracers and esp.TracerLine then
						esp.TracerLine.From = Vector2.new(App.Camera.ViewportSize.X / 2, App.Camera.ViewportSize.Y)
						esp.TracerLine.To = Vector2.new(screenPos.X, screenPos.Y)
						esp.TracerLine.Visible = true
					elseif esp.TracerLine then
						esp.TracerLine.Visible = false
					end
				else
					if esp.BoxLines then for _, l in pairs(esp.BoxLines) do l.Visible = false end end
					if esp.TracerLine then esp.TracerLine.Visible = false end
				end
			else
				if esp.Billboard then esp.Billboard.Enabled = false end
				if esp.Highlight then esp.Highlight.Enabled = false end
				if esp.BoxLines then for _, l in pairs(esp.BoxLines) do l.Visible = false end end
				if esp.TracerLine then esp.TracerLine.Visible = false end
			end
		end
	end)

	Refs.OrigLighting = {
		Brightness = Services.Lighting.Brightness,
		ClockTime = Services.Lighting.ClockTime,
		FogStart = Services.Lighting.FogStart,
		FogEnd = Services.Lighting.FogEnd,
		FogColor = Services.Lighting.FogColor,
		GlobalShadows = Services.Lighting.GlobalShadows,
		OutdoorAmbient = Services.Lighting.OutdoorAmbient,
		Ambient = Services.Lighting.Ambient
	}

	function Lib.ApplyBoostFPS()
		local lighting = Services.Lighting
		pcall(function() Refs.BoostTech = gethiddenproperty(lighting, "Technology") end)
		pcall(function() sethiddenproperty(lighting, "Technology", 2) end)
		lighting.GlobalShadows = false
		lighting.FogEnd = 9e9

		local parts, materials, reflectances, decals, transparencies, effects = {}, {}, {}, {}, {}, {}
		Refs.BoostSaved = { parts, materials, reflectances, decals, transparencies, effects }

		for _, v in ipairs(Services.Workspace:GetDescendants()) do
			if v:IsA("BasePart") and not v:IsA("MeshPart") then
				local n = #parts + 1
				parts[n], materials[n], reflectances[n] = v, v.Material, v.Reflectance
				v.Material = Enum.Material.SmoothPlastic
				v.Reflectance = 0
			elseif v:IsA("Decal") or v:IsA("Texture") then
				local n = #decals + 1
				decals[n], transparencies[n] = v, v.Transparency
				v.Transparency = 1
			elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
				if v.Enabled then effects[#effects + 1] = v end
				v.Enabled = false
			end
		end
	end

	function Lib.RevertBoostFPS()
		local saved = Refs.BoostSaved
		if not saved then return end
		Refs.BoostSaved = nil
		local lighting = Services.Lighting
		if Refs.BoostTech then pcall(sethiddenproperty, lighting, "Technology", Refs.BoostTech) end
		lighting.GlobalShadows = Refs.OrigLighting.GlobalShadows
		lighting.FogEnd = Refs.OrigLighting.FogEnd
		local parts, materials, reflectances, decals, transparencies, effects = table.unpack(saved)
		for i = 1, #parts do
			local part = parts[i]
			if part.Parent then part.Material, part.Reflectance = materials[i], reflectances[i] end
		end
		for i = 1, #decals do
			local decal = decals[i]
			if decal.Parent then decal.Transparency = transparencies[i] end
		end
		for i = 1, #effects do
			local effect = effects[i]
			if effect.Parent then effect.Enabled = true end
		end
	end

	Refs.HoverBox = Lib.Create("SelectionBox", {
		Name = "Septus_HoverSelection",
		LineThickness = 0.04,
		Parent = UI.Screen
	})

	local mouse = App.Player:GetMouse()
	local activeTool = nil

	local RemoveTextureTool = Lib.Create("Tool", { Name = "Remove Texture", RequiresHandle = false, CanBeDropped = false })
	local PartDeletedTool = Lib.Create("Tool", { Name = "Part Deleted", RequiresHandle = false, CanBeDropped = false })
	local TeleportTool = Lib.Create("Tool", { Name = "Teleport Tool", RequiresHandle = false, CanBeDropped = false })

	local function BindTool(tool, toolType)
		tool.Equipped:Connect(function() activeTool = toolType end)
		tool.Unequipped:Connect(function()
			if activeTool == toolType then activeTool = nil end
			Refs.HoverBox.Adornee = nil
		end)
		tool.Activated:Connect(function()
			local target = mouse.Target
			if toolType == "TeleportTool" then
				local hitPos = mouse.Hit and mouse.Hit.Position
				local myChar = App.Player.Character
				local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso"))
				if hitPos and myRoot then
					myRoot.CFrame = CFrame.new(hitPos + Vector3.new(0, 3.5, 0))
				end
				return
			end

			if not target then return end

			if toolType == "PartDeleted" then
				if not target:IsDescendantOf(App.Player.Character) and not target:IsA("Terrain") then
					Refs.HoverBox.Adornee = nil
					pcall(function() target:Destroy() end)
				end
			elseif toolType == "RemoveTexture" then
				pcall(function()
					if target:IsA("BasePart") then target.Material = Enum.Material.SmoothPlastic end
					for _, child in ipairs(target:GetChildren()) do
						if child:IsA("Decal") or child:IsA("Texture") or child:IsA("SurfaceAppearance") then
							child:Destroy()
						end
					end
				end)
			end
		end)
	end

	BindTool(RemoveTextureTool, "RemoveTexture")
	BindTool(PartDeletedTool, "PartDeleted")
	BindTool(TeleportTool, "TeleportTool")

	Refs.Tools = {
		RemoveTextureTool = RemoveTextureTool,
		PartDeletedTool = PartDeletedTool,
		TeleportTool = TeleportTool
	}

	Lib.C(Services.Run.RenderStepped, function()
		local cam = App.Camera
		if cam.FieldOfView ~= State.FOV then cam.FieldOfView = State.FOV end

		if activeTool and activeTool ~= "TeleportTool" then
			local target = mouse.Target
			if target and target:IsA("BasePart") and not target:IsDescendantOf(App.Player.Character) and not target:IsA("Terrain") then
				Refs.HoverBox.Adornee = target
				Refs.HoverBox.Color3 = (activeTool == "PartDeleted") and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(60, 200, 255)
			else
				Refs.HoverBox.Adornee = nil
			end
		elseif Refs.HoverBox.Adornee then
			Refs.HoverBox.Adornee = nil
		end

		if not State.Fly then return end

		local char = App.Player.Character
		local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not root or not hum then return end

		if not Refs.FlyBV or Refs.FlyBV.Parent ~= root then Lib.UpdateFly(true) end
		if not Refs.FlyBV then return end

		if State.FlyAntiSit then
			if hum.Sit then hum.Sit = false end
			if not hum.PlatformStand then hum.PlatformStand = true end
		end

		local camCF = cam.CFrame
		Refs.FlyBG.CFrame = camCF

		local moveDir = hum.MoveDirection
		if moveDir.Magnitude > 0.01 then
			local relMove = camCF:VectorToObjectSpace(moveDir)
			local dir3D = (camCF.LookVector * -relMove.Z) + (camCF.RightVector * relMove.X)
			if dir3D.Magnitude > 0.01 then dir3D = dir3D.Unit end
			Refs.FlyBV.Velocity = dir3D * State.FlySpeed
		else
			Refs.FlyBV.Velocity = Vector3.zero
		end
	end)

	function Lib.UpdateFly(enable)
		local char = App.Player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")

		if Refs.FlyStateConn then Refs.FlyStateConn:Disconnect() Refs.FlyStateConn = nil end
		if Refs.FlyBV then Refs.FlyBV:Destroy() Refs.FlyBV = nil end
		if Refs.FlyBG then Refs.FlyBG:Destroy() Refs.FlyBG = nil end

		if enable then
			local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
			if not root or not hum then return end

			Refs.FlyBV = Lib.Create("BodyVelocity", { Name = "Septus_FlyBV", MaxForce = Vector3.new(1e9, 1e9, 1e9), Velocity = Vector3.zero, Parent = root })
			Refs.FlyBG = Lib.Create("BodyGyro", { Name = "Septus_FlyBG", MaxTorque = Vector3.new(1e9, 1e9, 1e9), P = 9e4, CFrame = App.Camera.CFrame, Parent = root })

			if State.FlyAntiSit then
				hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
				if hum.Sit then hum.Sit = false end
				hum.PlatformStand = true
			end

			Refs.FlyStateConn = hum.StateChanged:Connect(function(_, newState)
				if State.Fly and State.FlyAntiSit and newState ~= Enum.HumanoidStateType.PlatformStanding and newState ~= Enum.HumanoidStateType.Dead then
					hum.PlatformStand = true
				end
			end)
		elseif hum then
			hum.PlatformStand = false
			if not State.AntiSit then hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true) end
		end
	end

	Lib.C(App.Player.CharacterAdded, function()
		if State.Fly then
			task.wait(0.3)
			Lib.UpdateFly(true)
		end
	end)

	local flingParts, flingClock = {}, 0

	Lib.C(Services.Run.Heartbeat, function()
		local char = App.Player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not hum then return end

		if Refs.OrigHum ~= hum then
			Refs.OrigHum, Refs.OrigWS, Refs.OrigJP, Refs.OrigUJP = hum, hum.WalkSpeed, hum.JumpPower, hum.UseJumpPower
		end
		if hum.WalkSpeed ~= State.WalkSpeed and not State.FakeLagSuspension then hum.WalkSpeed = State.WalkSpeed end
		if not hum.UseJumpPower then hum.UseJumpPower = true end
		if hum.JumpPower ~= State.JumpPower then hum.JumpPower = State.JumpPower end

		local root = char:FindFirstChild("HumanoidRootPart")
		if not root then return end

		if State.AntiFling then
			if root.AssemblyLinearVelocity.Magnitude > 150 then root.AssemblyLinearVelocity = Vector3.zero end
			if root.AssemblyAngularVelocity.Magnitude > 150 then root.AssemblyAngularVelocity = Vector3.zero end

			local now = os.clock()
			if now - flingClock > 1.5 then
				flingClock = now
				table.clear(flingParts)
				for _, plr in ipairs(Services.Players:GetPlayers()) do
					local other = plr ~= App.Player and plr.Character
					if other then
						for _, part in ipairs(other:GetDescendants()) do
							if part:IsA("BasePart") then flingParts[#flingParts + 1] = part end
						end
					end
				end
			end
			for i = 1, #flingParts do
				local part = flingParts[i]
				if part.CanCollide then part.CanCollide = false end
			end
		end

		if State.AntiSit then
			if hum.Sit then hum.Sit = false end
			hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
		end

		if State.AntiVoid then
			local destroyHeight = Services.Workspace.FallenPartsDestroyHeight + 45
			if root.Position.Y > destroyHeight + 10 then
				Refs.LastSafeCF = root.CFrame
			elseif root.Position.Y <= destroyHeight then
				if Refs.LastSafeCF then
					root.CFrame = Refs.LastSafeCF + Vector3.new(0, 3, 0)
					root.AssemblyLinearVelocity = Vector3.zero
				else
					root.CFrame = CFrame.new(0, 50, 0)
				end
			end
		end

		if State.AntiStun or State.AntiRagdoll then
			if hum.PlatformStand and not State.Fly then hum.PlatformStand = false end
			hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
			hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
			hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

			local state = hum:GetState()
			if state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown or state == Enum.HumanoidStateType.Physics then
				hum:ChangeState(Enum.HumanoidStateType.GettingUp)
			end
		end
	end)

	Refs.ShaderFolder = Lib.Create("Folder", { Name = "Septus_Shaders", Parent = Services.Lighting })
	Refs.LightApplied = {}

	local LightProps = { "Brightness", "ClockTime", "FogStart", "FogEnd", "FogColor", "GlobalShadows", "OutdoorAmbient", "Ambient" }
	local syncingLight = false

	function Lib.SyncLighting()
		if syncingLight then return end
		syncingLight = true
		local lighting = Services.Lighting
		for _, prop in ipairs(LightProps) do
			local value = Refs.LightFB and Refs.LightFB[prop]
			if value == nil and Refs.LightShader then value = Refs.LightShader[prop] end
			if value ~= nil then
				Refs.LightApplied[prop] = true
				if lighting[prop] ~= value then lighting[prop] = value end
			elseif Refs.LightApplied[prop] then
				Refs.LightApplied[prop] = nil
				lighting[prop] = Refs.OrigLighting[prop]
			end
		end
		syncingLight = false
	end

	for _, prop in ipairs(LightProps) do
		Lib.C(Services.Lighting:GetPropertyChangedSignal(prop), Lib.SyncLighting)
	end

	local function SetShader(props, effects)
		Refs.ShaderFolder:ClearAllChildren()
		Refs.LightShader = props
		Lib.SyncLighting()
		for _, effect in ipairs(effects) do
			effect[2].Parent = Refs.ShaderFolder
			Lib.Create(effect[1], effect[2])
		end
	end

	function Lib.ResetShaders()
		Refs.ShaderFolder:ClearAllChildren()
		Refs.LightShader = nil
		Lib.SyncLighting()
	end

	function Lib.ApplyRTXShader()
		pcall(function() sethiddenproperty(Services.Lighting, "Technology", 3) end)
		SetShader({
			GlobalShadows = true,
			Brightness = 2.8,
			ClockTime = 14,
			OutdoorAmbient = Color3.fromRGB(75, 75, 80),
			Ambient = Color3.fromRGB(45, 45, 50),
			FogStart = 100,
			FogEnd = 1500,
			FogColor = Color3.fromRGB(200, 215, 230)
		}, {
			{ "SunRaysEffect", { Intensity = 0.16, Spread = 0.88 } },
			{ "BloomEffect", { Intensity = 0.45, Size = 28, Threshold = 0.92 } },
			{ "ColorCorrectionEffect", { Brightness = 0.03, Contrast = 0.22, Saturation = 0.15, TintColor = Color3.fromRGB(255, 252, 248) } },
			{ "DepthOfFieldEffect", { FarIntensity = 0.35, FocusDistance = 35, InFocusRadius = 30, NearIntensity = 0.05 } },
			{ "Atmosphere", { Density = 0.28, Offset = 0.25, Color = Color3.fromRGB(195, 215, 235), Decay = Color3.fromRGB(105, 120, 140), Glare = 0.35, Haze = 0.45 } }
		})
	end

	function Lib.ApplyCyberpunkShader()
		SetShader({
			ClockTime = 0,
			Brightness = 1.2,
			OutdoorAmbient = Color3.fromRGB(45, 10, 65),
			Ambient = Color3.fromRGB(25, 10, 35),
			FogStart = 50,
			FogEnd = 500,
			FogColor = Color3.fromRGB(30, 0, 50),
			GlobalShadows = true
		}, {
			{ "BloomEffect", { Intensity = 1.35, Size = 38, Threshold = 0.4 } },
			{ "ColorCorrectionEffect", { Brightness = -0.02, Contrast = 0.38, Saturation = 0.55, TintColor = Color3.fromRGB(240, 190, 255) } },
			{ "SunRaysEffect", { Intensity = 0.12, Spread = 0.9 } }
		})
	end

	function Lib.ApplySilentHillShader()
		SetShader({
			ClockTime = 6.2,
			Brightness = 0.9,
			FogStart = 5,
			FogEnd = 95,
			FogColor = Color3.fromRGB(150, 155, 155),
			OutdoorAmbient = Color3.fromRGB(120, 125, 125),
			Ambient = Color3.fromRGB(80, 80, 80),
			GlobalShadows = false
		}, {
			{ "ColorCorrectionEffect", { Brightness = -0.06, Contrast = 0.18, Saturation = -0.7, TintColor = Color3.fromRGB(210, 215, 210) } },
			{ "BlurEffect", { Size = 2 } }
		})
	end

	do
		local Run, UIS, Players = Services.Run, Services.UserInputService, Services.Players
		local Panel, Values, Beat, StartClock, Frames, LastTick
		local Pos, Goal, Origin, Anchor, Loop
		local Dragging = false
		local Names = { "AFK Time", "Players", "FPS" }
		local Width, Height = 176, 78

		local function Clamp(v)
			local view = UI.Screen.AbsoluteSize
			return Vector2.new(math.clamp(v.X, 0, math.max(view.X - Width, 0)), math.clamp(v.Y, 0, math.max(view.Y - Height, 0)))
		end

		local function Step(dt)
			Pos = Pos:Lerp(Goal, 1 - math.exp(-dt * 24))
			if not Dragging and (Pos - Goal).Magnitude < 0.4 then
				Pos = Goal
				Loop:Disconnect()
				Loop = nil
			end
			Panel.Position = UDim2.fromOffset(Pos.X, Pos.Y)
		end

		local function Build()
			Panel = Lib.Create("CanvasGroup", {
				Name = "AntiAFKStats",
				Size = UDim2.fromOffset(Width, Height),
				BackgroundColor3 = Lib.Theme.Card,
				GroupTransparency = 1,
				Visible = false,
				ZIndex = 140,
				Parent = UI.Screen
			})
			Lib.RegisterThemeElement(Panel, "BackgroundColor3", 0.5)
			Lib.BindCorner(Panel, "StatsCorner")
			Lib.Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center, Parent = Panel })
			Lib.Create("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), Parent = Panel })

			Values = {}
			for i, name in ipairs(Names) do
				local row = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, LayoutOrder = i, Parent = Panel })
				local label = Lib.Create("TextLabel", {
					Size = UDim2.fromScale(0.5, 1), BackgroundTransparency = 1, Text = name, TextSize = 11,
					TextColor3 = Lib.Palette.Secondary, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, Parent = row
				})
				Lib.RegisterThemeText(label, "Secondary")
				local value = Lib.Create("TextLabel", {
					Size = UDim2.fromScale(0.5, 1), Position = UDim2.fromScale(0.5, 0), BackgroundTransparency = 1, Text = "--", TextSize = 12,
					TextColor3 = Lib.Palette.Primary, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Right, Parent = row
				})
				Lib.RegisterThemeText(value, "Primary")
				Values[i] = value
			end

			Pos = Clamp(Vector2.new(16, UI.Screen.AbsoluteSize.Y - Height - 16))
			Goal = Pos
			Panel.Position = UDim2.fromOffset(Pos.X, Pos.Y)

			Panel.InputBegan:Connect(function(input)
				local kind = input.UserInputType
				if kind ~= Enum.UserInputType.MouseButton1 and kind ~= Enum.UserInputType.Touch then return end
				Dragging, Origin, Anchor, Goal = true, input.Position, Pos, Pos
				if not Loop then Loop = Run.RenderStepped:Connect(Step) end
				local move
				move = UIS.InputChanged:Connect(function(changed)
					local moved = changed.UserInputType
					if moved == Enum.UserInputType.MouseMovement or moved == Enum.UserInputType.Touch then
						local delta = changed.Position - Origin
						Goal = Clamp(Anchor + Vector2.new(delta.X, delta.Y))
					end
				end)
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						Dragging = false
						move:Disconnect()
					end
				end)
			end)
		end

		local function Format(elapsed)
			local total = math.floor(elapsed)
			return string.format("%02d:%02d:%02d", total // 3600, total // 60 % 60, total % 60)
		end

		local function Refresh(now)
			Values[1].Text = Format(now - StartClock)
			Values[2].Text = tostring(#Players:GetPlayers())
		end

		local function Start()
			if Beat then Beat:Disconnect() end
			StartClock = os.clock()
			LastTick, Frames = StartClock, 0
			Refresh(StartClock)
			Values[3].Text = "--"
			Beat = Run.RenderStepped:Connect(function()
				Frames = Frames + 1
				local now = os.clock()
				local span = now - LastTick
				if span < 0.5 then return end
				Values[3].Text = tostring(math.floor(Frames / span + 0.5))
				Refresh(now)
				Frames, LastTick = 0, now
			end)
		end

		function Lib.SetAntiAFKStats(on)
			if on then
				if not Panel then Build() end
				Pos = Clamp(Pos)
				Goal = Pos
				Panel.Position = UDim2.fromOffset(Pos.X, Pos.Y)
				Start()
				Panel.Visible = true
				Lib.Tween(Panel, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { GroupTransparency = 0 })
				return
			end
			if Beat then
				Beat:Disconnect()
				Beat = nil
			end
			if Panel then
				Lib.Tween(Panel, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { GroupTransparency = 1 }).Completed:Connect(function()
					if not State.AntiAFK then Panel.Visible = false end
				end)
			end
		end
	end

	Lib.C(App.Player.Idled, function()
		if State.AntiAFK then
			pcall(function()
				Services.VirtualUser:CaptureController()
				Services.VirtualUser:ClickButton2(Vector2.new(0, 0))
			end)
		end
	end)

	local noclipParts, noclipChar, noclipClock = {}, nil, 0

	Lib.C(Services.Run.Stepped, function()
		if not State.Noclip then return end
		local char = App.Player.Character
		if not char then return end

		local now = os.clock()
		if char ~= noclipChar or now - noclipClock > 1 then
			noclipChar, noclipClock = char, now
			table.clear(noclipParts)
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then noclipParts[#noclipParts + 1] = part end
			end
		end

		for i = 1, #noclipParts do
			local part = noclipParts[i]
			if part.CanCollide then part.CanCollide = false end
		end
	end)

	Lib.C(Services.GuiService.ErrorMessageChanged, function()
		if State.AutoReconnect then
			task.wait(0.5)
			pcall(function() Services.Teleport:Teleport(game.PlaceId, App.Player) end)
		end
	end)

	function Lib.SetFEInvis(enable)
		if enable then
			local char = App.Player.Character
			if not char or not char:FindFirstChild("HumanoidRootPart") then return end

			for _, v in ipairs(char:GetDescendants()) do
				if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
					v.LocalTransparencyModifier = 0.5
				end
			end

			Refs.InvisConn = Services.Run.Heartbeat:Connect(function()
				if not State.InvisFE or not App.Player.Character or not App.Player.Character:FindFirstChild("HumanoidRootPart") then
					if Refs.InvisConn then Refs.InvisConn:Disconnect() end
					return
				end
				local c = App.Player.Character
				local h = c and c:FindFirstChild("HumanoidRootPart")
				if h then
					local vel = h.AssemblyLinearVelocity
					h.AssemblyLinearVelocity = Vector3.new(vel.X, 0, vel.Z)
				end
			end)
		else
			if Refs.InvisConn then Refs.InvisConn:Disconnect() end
			local char = App.Player.Character
			if char then
				for _, v in ipairs(char:GetDescendants()) do
					if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
						v.LocalTransparencyModifier = 0
					end
				end
			end
		end
	end

	Lib.C(App.Player.CharacterAdded, function()
		if State.InvisFE then
			task.wait(0.3)
			Lib.SetFEInvis(true)
		end
	end)
end

do
	local UIS = Services.UserInputService
	local zTop = 10

	function Lib.CreateModal(title, width, height)
		local backdrop = Lib.Create("TextButton", {
			Name = (title:gsub("%s", "")) .. "Backdrop", Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1,
			Text = "", AutoButtonColor = false, Visible = false, ZIndex = 30, Parent = UI.Main
		})
		local window = Lib.Create("Frame", {
			Size = UDim2.fromOffset(width, height), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(16, 16, 16), ClipsDescendants = true, ZIndex = 31, Parent = backdrop,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
			Lib.Create("UIStroke", { Color = Color3.fromRGB(40, 40, 40), Thickness = 1, Transparency = 0.4 })
		})
		Lib.RegisterThemeElement(window, "BackgroundColor3", 0.5)
		local heading = Lib.Create("TextLabel", {
			Size = UDim2.new(1, -60, 0, 35), Position = UDim2.fromOffset(16, 8), BackgroundTransparency = 1, Text = title,
			TextColor3 = Color3.new(1, 1, 1), TextSize = 15, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 32, Parent = window
		})
		Lib.RegisterThemeText(heading, "Primary")
		local closeBtn = Lib.Create("TextButton", {
			Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, -38, 0, 10), BackgroundColor3 = Color3.new(1, 1, 1), Text = "×", TextColor3 = Color3.new(0, 0, 0),
			TextSize = 16, Font = Enum.Font.GothamBold, ZIndex = 32, Parent = window, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
		})
		local content = Lib.Create("ScrollingFrame", {
			Size = UDim2.new(1, -24, 1, -55), Position = UDim2.fromOffset(12, 45), BackgroundTransparency = 1, ScrollBarThickness = 2,
			ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80), BorderSizePixel = 0, ZIndex = 32, Parent = window
		})
		local layout = Lib.Create("UIListLayout", { Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder, Parent = content })
		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			content.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
		end)

		local isOpen = false
		local modal = { Backdrop = backdrop, Window = window, Content = content }

		function modal.Open()
			if isOpen then return end
			isOpen = true
			window.Size = UDim2.fromOffset(width - 40, height - 40)
			Lib.GlassOpen(backdrop)
			Lib.Tween(window, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Size = UDim2.fromOffset(width, height) })
		end

		function modal.Close()
			if not isOpen then return end
			isOpen = false
			Lib.Tween(window, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In, { Size = UDim2.fromOffset(width - 60, height - 60) })
			Lib.GlassClose(backdrop, function()
				if not isOpen then backdrop.Visible = false end
			end)
		end

		closeBtn.MouseButton1Click:Connect(function()
			Lib.PlayClick()
			modal.Close()
		end)
		return modal
	end

	function Lib.CreateWindow(options)
		local width, height, headerHeight = options.Width, options.Height, 36
		local viewport = UI.Screen.AbsoluteSize
		local pos = Vector2.new(
			math.max((viewport.X - width) / 2 + (options.OffsetX or 0), 8),
			math.max((viewport.Y - height) / 2 + (options.OffsetY or 0), 8)
		)
		zTop = math.min(zTop + 1, 99)

		local root = Lib.Create("CanvasGroup", {
			Name = options.Name, Size = UDim2.fromOffset(width, height), Position = UDim2.fromOffset(pos.X, pos.Y),
			BackgroundColor3 = Color3.fromRGB(15, 15, 15), GroupTransparency = 1, Visible = false, ZIndex = zTop, Parent = UI.Screen,
			Lib.Create("UIStroke", { Color = Color3.fromRGB(45, 45, 45), Thickness = 1, Transparency = 0.3 })
		})
		Lib.BindCorner(root, "WindowCorner")
		Lib.RegisterThemeElement(root, "BackgroundColor3", 0.5)
		local scale = Lib.Create("UIScale", { Scale = 0.94, Parent = root })

		local header = Lib.Create("Frame", {
			Name = "Header", Size = UDim2.new(1, 0, 0, headerHeight), BackgroundColor3 = Color3.fromRGB(22, 22, 22), Active = true, ZIndex = 2, Parent = root
		})
		Lib.RegisterThemeElement(header, "BackgroundColor3", 0.7)
		local titleLabel = Lib.Create("TextLabel", {
			Size = UDim2.new(1, -130, 1, 0), Position = UDim2.fromOffset(14, 0), BackgroundTransparency = 1, Text = options.Title,
			TextColor3 = Color3.new(1, 1, 1), TextSize = 13, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3, Parent = header
		})
		Lib.RegisterThemeText(titleLabel, "Primary")

		local function HeaderButton(text, offsetX)
			local button = Lib.Create("TextButton", {
				Size = UDim2.fromOffset(26, 26), Position = UDim2.new(1, offsetX, 0.5, -13), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1,
				Text = text, TextColor3 = Color3.fromRGB(150, 150, 150), TextSize = 16, Font = Enum.Font.GothamMedium, AutoButtonColor = false, ZIndex = 3, Parent = header,
				Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
			})
			Lib.RegisterThemeText(button, "Secondary")
			button.MouseEnter:Connect(function()
				Lib.Tween(button, 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundTransparency = 0.88 })
			end)
			button.MouseLeave:Connect(function()
				Lib.Tween(button, 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundTransparency = 1 })
			end)
			return button
		end

		local closeBtn = HeaderButton("×", -34)
		local minBtn = HeaderButton("—", -64)
		local gearBtn
		if options.Gear then
			gearBtn = HeaderButton("", -94)
			Lib.RegisterThemeImage(Lib.Create("ImageLabel", {
				Size = UDim2.fromOffset(16, 16), Position = UDim2.new(0.5, -8, 0.5, -8), BackgroundTransparency = 1,
				Image = "rbxassetid://119430435918970", ScaleType = Enum.ScaleType.Fit, ZIndex = 4, Parent = gearBtn
			}))
		end

		local body = Lib.Create("Frame", {
			Name = "Body", Size = UDim2.new(1, 0, 1, -headerHeight), Position = UDim2.fromOffset(0, headerHeight),
			BackgroundTransparency = 1, ClipsDescendants = true, Parent = root
		})

		local win = { Root = root, Body = body, GearBtn = gearBtn }
		local token = 0
		local minimized = false

		function win.IsVisible()
			return root.Visible and token % 2 == 1
		end

		function win.Show()
			token = token + 1
			if token % 2 == 0 then token = token + 1 end
			local base = Lib.MenuBaseScale or 1
			zTop = math.min(zTop + 1, 99)
			root.ZIndex = zTop
			scale.Scale = 0.94 * base
			root.Visible = true
			Lib.Tween(root, 0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, { GroupTransparency = 0 })
			Lib.Tween(scale, 0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Scale = base })
			if options.OnVisibility then options.OnVisibility(true) end
		end

		function win.Hide()
			if token % 2 == 0 then return end
			token = token + 1
			local mine = token
			Lib.Tween(scale, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In, { Scale = 0.94 * (Lib.MenuBaseScale or 1) })
			Lib.Tween(root, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In, { GroupTransparency = 1 }).Completed:Connect(function()
				if token == mine then root.Visible = false end
			end)
			if options.OnVisibility then options.OnVisibility(false) end
		end

		function win.Toggle()
			if win.IsVisible() then win.Hide() else win.Show() end
		end

		closeBtn.MouseButton1Click:Connect(function()
			Lib.PlayClick()
			win.Hide()
		end)

		minBtn.MouseButton1Click:Connect(function()
			Lib.PlayClick()
			minimized = not minimized
			if not minimized then body.Visible = true end
			local tween = Lib.Tween(root, 0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut, { Size = UDim2.fromOffset(width, minimized and headerHeight or height) })
			if minimized then
				tween.Completed:Connect(function()
					if minimized then body.Visible = false end
				end)
			end
		end)

		root.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				zTop = math.min(zTop + 1, 99)
				root.ZIndex = zTop
			end
		end)

		local dragging, origin, startPos, goal, loop = false, nil, nil, pos, nil

		local function Clamp(v)
			local view = UI.Screen.AbsoluteSize
			local w = root.AbsoluteSize.X
			return Vector2.new(math.clamp(v.X, 80 - w, view.X - 80), math.clamp(v.Y, 0, view.Y - 40))
		end

		local function Step(dt)
			pos = pos:Lerp(goal, 1 - math.exp(-dt * 24))
			if not dragging and (pos - goal).Magnitude < 0.4 then
				pos = goal
				loop:Disconnect()
				loop = nil
			end
			root.Position = UDim2.fromOffset(pos.X, pos.Y)
		end

		header.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				origin = input.Position
				startPos = pos
				goal = pos
				if not loop then loop = Services.Run.RenderStepped:Connect(Step) end
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then dragging = false end
				end)
			end
		end)

		Lib.C(UIS.InputChanged, function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local delta = input.Position - origin
				goal = Clamp(startPos + Vector2.new(delta.X, delta.Y))
			end
		end)

		return win
	end

	function Lib.CreateOverlay(win)
		local overlay = Lib.Create("Frame", {
			Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(15, 15, 15), Visible = false, ZIndex = 20, Parent = win.Body
		})
		Lib.RegisterThemeElement(overlay, "BackgroundColor3", 0.5)
		local scroll = Lib.Create("ScrollingFrame", {
			Size = UDim2.new(1, -20, 1, -16), Position = UDim2.fromOffset(10, 8), BackgroundTransparency = 1, ScrollBarThickness = 2,
			ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80), BorderSizePixel = 0, ZIndex = 21, Parent = overlay
		})
		local layout = Lib.Create("UIListLayout", { Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder, Parent = scroll })
		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
		end)
		win.GearBtn.MouseButton1Click:Connect(function()
			Lib.PlayClick()
			overlay.Visible = not overlay.Visible
		end)
		return scroll
	end

	function Lib.MakeChip(parent, text, size, position)
		local chip = Lib.Create("TextButton", {
			Size = size, Position = position, BackgroundColor3 = Color3.new(1, 1, 1), Text = text, TextColor3 = Color3.new(0, 0, 0),
			TextSize = 12, Font = Enum.Font.GothamBold, AutoButtonColor = false, Parent = parent, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
		})
		chip.MouseEnter:Connect(function()
			Lib.Tween(chip, 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Color3.fromRGB(210, 210, 210) })
		end)
		chip.MouseLeave:Connect(function()
			Lib.Tween(chip, 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Color3.new(1, 1, 1) })
		end)
		return chip
	end
end

function Lib.BuildBunnyHop(group)
	local UIS = Services.UserInputService
	local momentum = 0

	Lib.C(Services.Run.Heartbeat, function(dt)
		if not State.BunnyHop then
			momentum = 0
			return
		end
		local char = App.Player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local root = hum and hum.RootPart
		if not root or hum.Health <= 0 then return end

		local wish = hum.MoveDirection
		local vel = root.AssemblyLinearVelocity
		local flat = Vector3.new(vel.X, 0, vel.Z)
		local speed = flat.Magnitude
		local limit = State.BunnyNoLimit and 1500 or State.BunnyMaxSpeed

		if hum.FloorMaterial ~= Enum.Material.Air then
			if wish.Magnitude > 0 and (State.BunnyAutoJump or UIS:IsKeyDown(Enum.KeyCode.Space)) then
				momentum = math.min(math.max(momentum, speed), limit)
				if momentum > speed then
					root.AssemblyLinearVelocity = Vector3.new(wish.X * momentum, vel.Y, wish.Z * momentum)
				end
				hum:ChangeState(Enum.HumanoidStateType.Jumping)
			else
				momentum = speed
			end
		elseif wish.Magnitude > 0 then
			if speed < momentum * 0.6 then momentum = speed end
			local dir = speed > 0.1 and flat.Unit:Lerp(wish, math.min(dt * 5, 1)) or wish
			dir = dir.Magnitude > 0.001 and dir.Unit or wish
			momentum = math.min(momentum + 24 * dt, limit)
			root.AssemblyLinearVelocity = Vector3.new(dir.X * momentum, vel.Y, dir.Z * momentum)
		else
			momentum = speed
		end
	end)

	local modal = Lib.CreateModal("Bunny Hop Settings", 340, 290)
	local speedGroup = Lib.CreateFeatureGroup(modal.Content, "Speed", 1)
	Lib.CreateSettingSliderItem(speedGroup, "Max Speed", "Maximum horizontal speed in studs per second", 16, 400, State.BunnyMaxSpeed, function(val)
		State.BunnyMaxSpeed = val
	end)
	Lib.CreateSettingToggleItem(speedGroup, "Disable Speed Limit", "Ignores the max speed value completely", State.BunnyNoLimit, function(val)
		State.BunnyNoLimit = val
	end)
	Lib.CreateSettingToggleItem(speedGroup, "Auto Jump", "Jumps automatically on every landing while moving", State.BunnyAutoJump, function(val)
		State.BunnyAutoJump = val
	end, true)

	local item = Lib.CreateSettingToggleItem(group, "Bunny Hop", "Chains jumps to build up speed", State.BunnyHop, function(val)
		State.BunnyHop = val
	end, true)
	local gear = Lib.Create("ImageButton", {
		Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, -98, 0.5, -14), BackgroundColor3 = Color3.fromRGB(22, 22, 22), AutoButtonColor = false,
		Image = "rbxassetid://119430435918970", ImageColor3 = Color3.fromRGB(180, 180, 180), ScaleType = Enum.ScaleType.Fit, Parent = item,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
		Lib.Create("UIPadding", { PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5), PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5) })
	})
	Lib.RegisterThemeElement(gear, "BackgroundColor3", 0.7)
	gear.MouseButton1Click:Connect(function()
		Lib.PlayClick()
		modal.Open()
	end)
end

function Lib.BuildCombat(scroll)
	local Players, UIS, Workspace, Run = Services.Players, Services.UserInputService, Services.Workspace, Services.Run
	local LocalPlayer = App.Player
	local lookAt = CFrame.lookAt
	local reg, live = {}, {}

	local function Words(source)
		local set = {}
		for word in source:gmatch("%S+") do set[word] = true end
		return set
	end

	local AMMO = Words([[
			acsclientammoingun acsammoingun acsammo acsclipammo acsclip acsgunammo acsgunclip
			acsbulletcount acsbullets acsrounds acsammoleft acsmagammo ammoingun ammoinmag ammoinclip
			ammoinchamber ammoincylinder ammoinbarrel ammocount ammocountgun ammogun ammoleft ammoleftgun
			ammoleftingun ammoremaining ammoremain ammoloaded ammochamber ammobarrel ammomag ammomagazine
			ammoclip ammodrum ammopouch ammobelt currentammo currentclip currentrounds currentbullets
			currentshot currentmag currentchamber currentloaded currentingun clipammo clipcount clipleft
			cliprounds clipbullets clipcurrent clippingun clipmag clipmagazine magammo magcount magleft
			magrounds magbullets magcurrent magazineammo magazinecount magazineleft magazinerounds
			magazinebullets magazinecurrent magazineingun magazinemag bulletcount bulletsleft
			bulletsremaining bulletsingun bulletmag bulletclip bulletchamber bulletinmag roundsleft
			roundsremaining roundsingun roundsinmag roundsinclip roundsinchamber roundscount roundsloaded
			shellleft shellsin shellcount shellchamber shellscount shellschamber shellsloaded chambered
			chamberedbullet chambercount chamberhas chamberfull chamberloaded chamberround loadedammo
			loadedbullets loadedrounds loadedshot loadedmag loadedclip loadedgun loadedweapon gunammo
			gunbullets gunrounds gunmag gunclip guncurrent gunloaded gunshot shotsleft shotcount
			shotremaining shotloaded shotsingun shotbullets weaponammo weaponbullets weaponrounds
			weaponclip weaponmag weaponloaded weaponcurrent weaponshot патроныворужии патронывобойме
			патронывмагазине патронывстволе заряженопатронов патроновзаряжено патроноввобойме
			патроновворужии патроноввмагазине осталосьпатронов текущиепатроны текущийпатрон
	]])
	local AMMO_STOP = Words([[
			storedammo maxstoredammo reserveammo ammostorage ammoreserve totalammo ammototal ammopool
			ammobackup ammobank ammocache ammowarehouse ammoinventory ammosupply ammosupplies ammoreservoir
			spareammo extraammo backupammo sparerounds extrarounds backuprrounds maxammo ammomax maxclip
			maxmag clipmax magmax maxbullet maxround maxshell maxcartridge maxcapacity maxload maxstored
			maxreserve clipcapacity magcapacity magazinecapacity gunmaxammo weaponmaxammo toolmaxammo
			ammocapacity weaponcapacity clipmaxammo magmaxammo magazinemaxammo isreloading reloading
			reloadtime reloadprogress reloadstate reloadspeed reloadstart reloadend hasammo noammo
			outofammo emptygun ammotype ammoname ammoid ammokind ammodamage ammospeed ammopower ammoweight
			ammosize ammocaliber ammogauge
	]])
	local JAM = Words([[
			jammed isjammed isjam jam jamstate jamstatus gunjammed weaponjammed tooljammed playerjammed
			gunjam weaponjam tooljam jammedstate jammedstatus jammedvalue jammedflag jamflag jamvalue
			jamamount jamcount isgunjammed isweaponjammed istooljammed hasjam hasjammed getjammed setjammed
			acsclientjammed acsjam acsjammed weaponisjammed gunisjammed toolisjammed isjamming jamming
			jammedbool
	]])
	local JAM_STOP = Words([[
			jammer jamsound jamanim jamsfx
	]])
	local ZERO = Words([[
			recoil spread inaccuracy kickback kick recoilpower spreadpower recoilamount spreadamount
			aiminaccuracy aimspread aimrecoil hipspread hiprecoil adsspread adsrecoil gunrecoil gunspread
			camrecoil camspread weaponrecoil weaponspread minrecoil maxrecoil minspread maxspread recoilup
			recoildown recoilleft recoilright recoiltilt recoilx recoily recoilhorizontal recoilvertical
			spreadx spready spreadhorizontal spreadvertical inaccuracystep inaccuracydecrease
			aiminaccuracystep aiminaccuracydecrease recoilpowerstep recoilpowerstepamount recoilstep
			recoilstepamount spreadstep spreadstepamount recoilreduction spreadreduction recoildecrease
			spreaddecrease recoilrecovery spreadrecovery recoildecay spreaddecay recoilcontrol
			spreadcontrol verticalrecoil horizontalrecoil verticalspread horizontalspread camerarecoil
			cameraspread walkrecoil walkspread jumprecoil jumpspread crouchrecoil crouchspread pronerecoil
			pronespread bulletspread bulletrecoil bulletinaccuracy
	]])

	local AMMO_ATTRS = {
		"ACSClientAmmoInGun", "AmmoInGun", "CurrentAmmo", "ClipAmmo", "MagAmmo", "Ammo",
		"AmmoCount", "BulletsInGun", "RoundsInGun", "BulletsLeft", "RoundsLeft", "ShellsInGun"
	}
	local JAM_ATTRS = { "ACSClientJammed", "Jammed", "IsJammed", "JammedState", "IsJam", "GunJammed", "WeaponJammed" }
	local WALL_KEYS = Words("penetration penetrationpower wallpenetration penetrationamount penetrationdepth")
	local FOLDERS = { "NPCs", "Npcs", "npcs", "Enemies", "Mobs", "Monsters", "Bots" }
	local MUZZLE_ATTACHMENTS = { "Muzzle", "muzzle", "MuzzlePoint", "muzzlePoint", "BarrelPoint", "Tip", "tip" }
	local MUZZLE_PARTS = { "Muzzle", "muzzle", "Barrel", "barrel", "Tip", "tip", "MuzzlePoint" }
	local PARTS_ALL, PARTS_BOTH, PARTS_HEAD, PARTS_TORSO = { "Head", "Torso", "Center" }, { "Head", "Torso" }, { "Head" }, { "Torso" }

	local ZPATHS = {}
	for path in ([[
		gunRecoil.gunRecoilUp.1 gunRecoil.gunRecoilUp.2 gunRecoil.gunRecoilLeft.1 gunRecoil.gunRecoilLeft.2
		gunRecoil.gunRecoilRight.1 gunRecoil.gunRecoilRight.2 gunRecoil.gunRecoilTilt.1 gunRecoil.gunRecoilTilt.2
		camRecoil.camRecoilUp.1 camRecoil.camRecoilUp.2 camRecoil.camRecoilLeft.1 camRecoil.camRecoilLeft.2
		camRecoil.camRecoilRight.1 camRecoil.camRecoilRight.2 camRecoil.camRecoilTilt.1 camRecoil.camRecoilTilt.2
		MinSpread MaxSpread MinRecoilPower MaxRecoilPower RecoilPowerStepAmount AimInaccuracyStepAmount AimInaccuracyDecrease
	]]):gmatch("%S+") do
		local parts = {}
		for piece in path:gmatch("[^%.]+") do parts[#parts + 1] = tonumber(piece) or piece end
		ZPATHS[#ZPATHS + 1] = { parts = parts, spread = path:find("Spread", 1, true) ~= nil or path:find("Inaccuracy", 1, true) ~= nil }
	end

	local C = {
		SA = false, AutoFire = true, BlockMouse = true, SnapDelay = 0.02, HoldAfter = 0.001, Clicks = 1, ClickInterval = 0.02,
		LoopSpeed = 1, Repeat = "RPM", FixedTime = 0.5, TargetPart = "Head", WallCheck = true, ShowFOV = true, FOV = 300,
		NPCs = true, Players = false, TeamCheck = true, MaxDistance = 1000, AimCheck = true, AimKey = Enum.UserInputType.MouseButton2,
		CheckAmmo = true, CheckJammed = true, ZeroRecoil = false, ZeroSpread = false,
		WallMode = "muzzle", WallMult = 1, WallOverride = false, WallOverrideVal = 10, MaxThickness = 10,
		TB = false, TBHold = 0.02, TBCooldown = 0.1, TBWall = true, TBParts = { Head = true }
	}
	local function NewAim(speed)
		return { On = false, Speed = speed, Loop = false, Locked = nil, Targets = { Player = true }, Part = "Head", Predict = "Custom", Ms = 50, Wall = true, Buf = {} }
	end
	local Cf, Ms = NewAim(50), NewAim(25)

	local kinds = {}
	local function Kind(name)
		local kind = kinds[name]
		if kind == nil then
			local key = name:lower():gsub("[%s_%-]", "")
			if AMMO[key] and not AMMO_STOP[key] then
				kind = "ammo"
			elseif JAM[key] and not JAM_STOP[key] then
				kind = "jam"
			elseif ZERO[key] then
				kind = (key:find("spread", 1, true) or key:find("inaccuracy", 1, true)) and "spread" or "recoil"
			else
				kind = false
			end
			kinds[name] = kind
		end
		return kind
	end

	local function Dig(tbl, parts)
		local cur = tbl
		for i = 1, #parts do
			if type(cur) ~= "table" then return nil end
			cur = cur[parts[i]]
		end
		return cur
	end

	local function Put(tbl, parts, value)
		local cur = tbl
		for i = 1, #parts - 1 do
			cur = cur[parts[i]]
			if type(cur) ~= "table" then return end
		end
		local key = parts[#parts]
		if cur[key] ~= nil then cur[key] = value end
	end

	local function WallScan(tbl, depth)
		if depth > 4 then return nil end
		for key, value in pairs(tbl) do
			if type(key) == "string" and type(value) == "number" then
				local name = key:lower():gsub("[%s_%-]", "")
				if not name:find("bulletpen", 1, true) and (name:find("wallbang", 1, true) or WALL_KEYS[name]) then return value, key end
			end
			if type(value) == "table" then
				local found, foundKey = WallScan(value, depth + 1)
				if found then return found, foundKey end
			end
		end
		return nil
	end

	local cache = setmetatable({}, { __mode = "k" })

	local function Build(tool)
		local data = { Zero = {}, Paths = {} }
		for _, attr in ipairs(AMMO_ATTRS) do
			if type(tool:GetAttribute(attr)) == "number" then
				data.AmmoAttr = attr
				break
			end
		end
		for _, attr in ipairs(JAM_ATTRS) do
			if tool:GetAttribute(attr) ~= nil then
				data.JamAttr = attr
				break
			end
		end
		local roots = { tool }
		local char = LocalPlayer.Character
		local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
		if char then roots[#roots + 1] = char end
		if backpack then roots[#roots + 1] = backpack end
		local seen = {}
		for _, root in ipairs(roots) do
			for _, inst in ipairs(root:GetDescendants()) do
				if not seen[inst] then
					seen[inst] = true
					local kind = Kind(inst.Name)
					if kind == "ammo" then
						if not data.AmmoAttr and not data.AmmoInst and (inst:IsA("IntValue") or inst:IsA("NumberValue")) then data.AmmoInst = inst end
					elseif kind == "jam" then
						if not data.JamAttr and not data.JamInst and inst:IsA("ValueBase") then data.JamInst = inst end
					elseif kind and (inst:IsA("IntValue") or inst:IsA("NumberValue")) then
						data.Zero[inst] = { inst.Value, kind == "spread" }
					end
				end
			end
		end
		local module = tool:FindFirstChild("ACS_Settings")
		if module then
			local ok, settings = pcall(require, module)
			if ok and type(settings) == "table" then
				data.Settings = settings
				data.RPM = settings.ShootRate or settings.FireRate or settings.RPM
				for _, path in ipairs(ZPATHS) do
					local value = Dig(settings, path.parts)
					if value ~= nil then data.Paths[path] = { value, path.spread } end
				end
			end
		end
		cache[tool] = data
		return data
	end

	local function Data(tool)
		return cache[tool] or Build(tool)
	end

	local function Equipped()
		local char = LocalPlayer.Character
		return char and char:FindFirstChildOfClass("Tool")
	end

	local function Ammo(tool)
		local data = Data(tool)
		if data.AmmoAttr then
			local value = tool:GetAttribute(data.AmmoAttr)
			if type(value) == "number" then return value, "attr:" .. data.AmmoAttr end
		end
		local inst = data.AmmoInst
		if inst and inst.Parent then return inst.Value, "val:" .. inst.Name end
		return nil
	end

	local function Jammed(tool)
		local data = Data(tool)
		local value
		if data.JamAttr then value = tool:GetAttribute(data.JamAttr) end
		if value == nil and data.JamInst and data.JamInst.Parent then value = data.JamInst.Value end
		if type(value) == "boolean" then return value end
		if type(value) == "number" then return value ~= 0 end
		return false
	end

	local function CanShoot(tool)
		if not tool then return false end
		if C.CheckJammed and Jammed(tool) then return false end
		if C.CheckAmmo then
			local ammo = Ammo(tool)
			if ammo and ammo <= 0 then return false end
		end
		return true
	end

	local function Zero(tool)
		local data = Data(tool)
		local recoil, spread = C.ZeroRecoil, C.ZeroSpread
		for inst, info in pairs(data.Zero) do
			if inst.Parent and (info[2] and spread or not info[2] and recoil) then inst.Value = 0 end
		end
		if data.Settings then
			for path, info in pairs(data.Paths) do
				if info[2] and spread or not info[2] and recoil then pcall(Put, data.Settings, path.parts, 0) end
			end
		end
	end

	local function Restore(tool)
		local data = cache[tool]
		if not data then return end
		for inst, info in pairs(data.Zero) do
			if inst.Parent then inst.Value = info[1] end
		end
		if data.Settings then
			for path, info in pairs(data.Paths) do pcall(Put, data.Settings, path.parts, info[1]) end
		end
		cache[tool] = nil
	end

	local zeroLinks = {}
	local function UnlinkZero()
		for _, link in ipairs(zeroLinks) do link:Disconnect() end
		table.clear(zeroLinks)
	end

	local function HookChar(char)
		zeroLinks[#zeroLinks + 1] = char.ChildAdded:Connect(function(child)
			if child:IsA("Tool") then Zero(child) end
		end)
		zeroLinks[#zeroLinks + 1] = char.ChildRemoved:Connect(function(child)
			if child:IsA("Tool") then Restore(child) end
		end)
	end

	local function SyncZero()
		local tool = Equipped()
		if tool then
			Restore(tool)
			if C.ZeroRecoil or C.ZeroSpread then Zero(tool) end
		end
		UnlinkZero()
		if C.ZeroRecoil or C.ZeroSpread then
			local char = LocalPlayer.Character
			if char then HookChar(char) end
			zeroLinks[#zeroLinks + 1] = LocalPlayer.CharacterAdded:Connect(HookChar)
		end
	end

	local blocked, savedBehavior, savedIcon = false, nil, nil
	local function Block()
		if blocked then return end
		blocked = true
		savedBehavior, savedIcon = UIS.MouseBehavior, UIS.MouseIconEnabled
		pcall(function()
			UIS.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
			UIS.MouseIconEnabled = false
		end)
	end
	local function Unblock()
		if not blocked then return end
		blocked = false
		pcall(function()
			UIS.MouseBehavior = savedBehavior
			UIS.MouseIconEnabled = savedIcon
		end)
	end

	local VIM
	local function Click()
		if type(mouse1click) == "function" then return mouse1click() end
		if type(mouse1press) == "function" and type(mouse1release) == "function" then
			mouse1press()
			task.wait(0.01)
			mouse1release()
			return
		end
		VIM = VIM or game:GetService("VirtualInputManager")
		local loc = UIS:GetMouseLocation()
		pcall(VIM.SendMouseButtonEvent, VIM, loc.X, loc.Y, 0, true, game, 1)
		task.wait(0.01)
		pcall(VIM.SendMouseButtonEvent, VIM, loc.X, loc.Y, 0, false, game, 1)
	end

	local held = false
	live[#live + 1] = UIS.InputBegan:Connect(function(input, processed)
		if processed then return end
		local key = C.AimKey
		if input.UserInputType == key or input.KeyCode == key then held = true end
	end)
	live[#live + 1] = UIS.InputEnded:Connect(function(input)
		local key = C.AimKey
		if input.UserInputType == key or input.KeyCode == key then held = false end
	end)
	local function Held()
		return not C.AimCheck or held
	end

	local npcs, npcOn = {}, false
	local function Track(inst)
		if inst.ClassName == "Humanoid" then
			local model = inst.Parent
			if model and model.ClassName == "Model" then npcs[model] = inst end
		end
	end
	local function StartNpc()
		if npcOn then return end
		npcOn = true
		for _, inst in ipairs(Workspace:GetDescendants()) do Track(inst) end
		live[#live + 1] = Workspace.DescendantAdded:Connect(Track)
	end

	local folderModels, folderStamp = {}, 0
	local function FolderModels()
		local now = os.clock()
		if now - folderStamp > 1 then
			folderStamp = now
			table.clear(folderModels)
			for _, name in ipairs(FOLDERS) do
				local folder = Workspace:FindFirstChild(name, true)
				if folder then
					for _, inst in ipairs(folder:GetDescendants()) do
						if inst.ClassName == "Model" and inst:FindFirstChild("HumanoidRootPart") then folderModels[#folderModels + 1] = inst end
					end
				end
			end
		end
		return folderModels
	end

	local function NpcLive(model, hum)
		if hum.Parent ~= model or not model:IsDescendantOf(Workspace) then return nil end
		if Players:GetPlayerFromCharacter(model) or model == LocalPlayer.Character then return false end
		return hum.Health > 0
	end

	local function Alive(model)
		if not model or not model.Parent then return false end
		local hum = model:FindFirstChildOfClass("Humanoid")
		return hum ~= nil and hum.Health > 0
	end

	local function PartOf(model, kind)
		if not model.Parent then return nil end
		if kind == "Head" then return model:FindFirstChild("Head") end
		local root = model:FindFirstChild("HumanoidRootPart")
		local torso = model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso") or model:FindFirstChild("LowerTorso") or root
		if kind == "Torso" then return torso end
		return root or torso or model:FindFirstChild("Head")
	end

	local function Cam()
		return Workspace.CurrentCamera
	end

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.IgnoreWater = true
	local filterBuf = {}
	local function Filter(a, b)
		table.clear(filterBuf)
		local char = LocalPlayer.Character
		if char then filterBuf[#filterBuf + 1] = char end
		if a then filterBuf[#filterBuf + 1] = a end
		if b then filterBuf[#filterBuf + 1] = b end
		rayParams.FilterDescendantsInstances = filterBuf
	end

	local function Clear(from, part)
		Filter(part.Parent)
		return Workspace:Raycast(from, part.Position - from, rayParams) == nil
	end

	local function Predict(part, mode, ms)
		local velocity = part.AssemblyLinearVelocity
		local time = mode == "Custom" and ms or math.clamp(velocity.Magnitude * 4, 0, 200)
		return part.Position + velocity * (time / 1000)
	end

	local function AimTargets(aim)
		local out, T = aim.Buf, aim.Targets
		table.clear(out)
		if T.Player then
			for _, plr in ipairs(Players:GetPlayers()) do
				local char = plr.Character
				if plr ~= LocalPlayer and char then
					local hum = char:FindFirstChildOfClass("Humanoid")
					if hum and hum.Health > 0 then out[#out + 1] = char end
				end
			end
		end
		if T.Npc_Humanoid then
			StartNpc()
			for model, hum in pairs(npcs) do
				local alive = NpcLive(model, hum)
				if alive == nil then
					npcs[model] = nil
				elseif alive and model:FindFirstChild("HumanoidRootPart") and model:FindFirstChild("Head")
					and (model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso") or model:FindFirstChild("LowerTorso")) then
					out[#out + 1] = model
				end
			end
		end
		if T.Npc_Workspace then
			for _, model in ipairs(FolderModels()) do out[#out + 1] = model end
		end
		return out
	end

	local function Valid(aim, part)
		local model = part.Parent
		if not model then return false end
		local hum = model:FindFirstChildOfClass("Humanoid")
		if hum and hum.Health <= 0 then return false end
		local cam = Cam()
		if not cam then return false end
		local origin = cam.CFrame.Position
		if aim.Wall and not Clear(origin, part) then return false end
		local _, onScreen = cam:WorldToViewportPoint(part.Position)
		return onScreen and (part.Position - origin).Magnitude <= 1000
	end

	local function Best(aim)
		if aim.Loop and aim.Locked then
			if Valid(aim, aim.Locked) then return aim.Locked end
			aim.Locked = nil
		end
		local cam = Cam()
		if not cam then return nil end
		local list = AimTargets(aim)
		local origin, size = cam.CFrame.Position, cam.ViewportSize
		local cx, cy = size.X / 2, size.Y / 2
		local best, bestDist = nil, math.huge
		for i = 1, #list do
			local part = PartOf(list[i], aim.Part)
			if part then
				local point, onScreen = cam:WorldToViewportPoint(part.Position)
				if onScreen then
					local dx, dy = point.X - cx, point.Y - cy
					local dist = dx * dx + dy * dy
					if dist < bestDist and (not aim.Wall or Clear(origin, part)) then best, bestDist = part, dist end
				end
			end
		end
		if best and aim.Loop then aim.Locked = best end
		return best
	end

	local aimLink
	local function AimStep()
		local cam = Cam()
		if not cam then return end
		if Cf.On then
			local part = Best(Cf)
			if part then
				local current = cam.CFrame
				cam.CFrame = current:Lerp(CFrame.new(current.Position, Predict(part, Cf.Predict, Cf.Ms)), math.clamp(Cf.Speed / 100, 0.001, 1))
			end
		end
		if Ms.On then
			local part = Best(Ms)
			if part then
				local point, onScreen = cam:WorldToViewportPoint(Predict(part, Ms.Predict, Ms.Ms))
				if onScreen then
					local size = cam.ViewportSize
					local factor = math.clamp(Ms.Speed / 50, 0.001, 1)
					local dx, dy = (point.X - size.X / 2) * factor, (point.Y - size.Y / 2) * factor
					if mousemoverel then
						mousemoverel(dx, dy)
					elseif mousemoveabs then
						mousemoveabs(size.X / 2 + dx, size.Y / 2 + dy)
					end
				end
			end
		end
	end
	local function RefreshAim()
		local need = Cf.On or Ms.On
		if need and not aimLink then
			aimLink = Run.RenderStepped:Connect(AimStep)
		elseif not need and aimLink then
			aimLink:Disconnect()
			aimLink = nil
		end
	end

	local candList, candStamp = {}, 0
	local function Cands()
		local now = os.clock()
		if now - candStamp > 0.05 then
			candStamp = now
			table.clear(candList)
			if C.NPCs then
				StartNpc()
				for model, hum in pairs(npcs) do
					local alive = NpcLive(model, hum)
					if alive == nil then
						npcs[model] = nil
					elseif alive then
						candList[#candList + 1] = model
					end
				end
			end
			if C.Players then
				local team = C.TeamCheck and LocalPlayer.Team
				for _, plr in ipairs(Players:GetPlayers()) do
					local char = plr.Character
					if plr ~= LocalPlayer and char and char ~= LocalPlayer.Character and not (team and plr.Team == team) then
						local hum = char:FindFirstChildOfClass("Humanoid")
						if hum and hum.Health > 0 then candList[#candList + 1] = char end
					end
				end
			end
		end
		return candList
	end

	local function Root()
		local char = LocalPlayer.Character
		return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head"))
	end

	local function FindMuzzle(tool)
		for _, name in ipairs(MUZZLE_ATTACHMENTS) do
			local found = tool:FindFirstChild(name, true)
			if found and found:IsA("Attachment") then return found end
		end
		for _, name in ipairs(MUZZLE_PARTS) do
			local found = tool:FindFirstChild(name, true)
			if found and found:IsA("BasePart") then return found end
		end
		local handle = tool:FindFirstChild("Handle")
		if handle and handle:IsA("BasePart") then return handle end
		return nil
	end

	local function MuzzlePos(tool)
		local data = Data(tool)
		local ref = data.Muzzle
		if ref == nil then
			ref = FindMuzzle(tool) or false
			data.Muzzle = ref
		end
		if not ref or not ref.Parent then return nil end
		if ref:IsA("Attachment") then return ref.WorldPosition end
		if ref.Name == "Handle" then return ref.Position + ref.CFrame.LookVector * 1.5 end
		return ref.Position
	end

	local function Thickness(enter, dir, hit, owner)
		local unit = dir.Unit
		Filter(owner, hit)
		local exit = Workspace:Raycast(enter + unit * 0.05, unit * 50, rayParams)
		if not exit then return 50 end
		return (exit.Position - enter).Magnitude
	end

	local function Walls(root, part)
		local owner = part.Parent
		local origin = root.Position
		if C.WallMode == "muzzle" then
			local tool = Equipped()
			local pos = tool and MuzzlePos(tool)
			if pos then origin = pos end
		elseif C.WallMode == "camera" then
			origin = Cam().CFrame.Position
		end
		local target = part.Position
		local dir = target - origin
		local total, single, last = 0, 0, nil
		for _ = 1, 32 do
			Filter(owner)
			local result = Workspace:Raycast(origin, dir, rayParams)
			if not result then break end
			local inst = result.Instance
			if inst == last then
				local skip = result.Position + dir.Unit * 0.5
				dir = target - skip
				if dir.Magnitude < 0.1 then break end
				origin = skip
			else
				last = inst
				local thick = Thickness(result.Position, dir, inst, owner)
				if thick > single then single = thick end
				if thick > C.MaxThickness then return total, true, single end
				total = total + thick
				local nextOrigin = result.Position + dir.Unit * (thick + 0.2) + result.Normal * 0.05
				dir = target - nextOrigin
				if dir.Magnitude < 0.1 then break end
				origin = nextOrigin
			end
		end
		return total, false, single
	end

	local function WallPower(tool)
		if C.WallOverride then return C.WallOverrideVal, "override" end
		if not tool then return 0, "0" end
		local data = Data(tool)
		if not data.Settings then return 0, "0" end
		if data.WallBase == nil then
			local value, key = WallScan(data.Settings, 0)
			data.WallBase, data.WallKey = type(value) == "number" and value or 0, key or "0"
		end
		return data.WallBase * C.WallMult, data.WallKey
	end

	local function CanHit(part)
		if not C.WallCheck then return true, 0, "wallcheck_off" end
		local root = Root()
		if not root then return false, 0, "no_root" end
		local total, thick, single = Walls(root, part)
		if thick then return false, total, "too_thick_wall", single end
		if total <= 0.01 then return true, 0, "clear" end
		local power = WallPower(Equipped())
		if power <= 0 then return false, total, "no_wallbang" end
		if total <= power then return true, total, "wb_ok" end
		return false, total, "too_thick"
	end

	local lastTarget, lastInfo = nil, "—"
	local function FindSilent()
		local root, cam = Root(), Cam()
		if not root or not cam then return nil end
		local mouse = UIS:GetMouseLocation()
		local origin = root.Position
		local list = Cands()
		local best, bestDist, reason, blockReason = nil, C.FOV, "—", nil
		for i = 1, #list do
			local model = list[i]
			if Alive(model) then
				local part = PartOf(model, C.TargetPart)
				if part and (part.Position - origin).Magnitude <= C.MaxDistance then
					local point, onScreen = cam:WorldToViewportPoint(part.Position)
					if onScreen then
						local dist = (Vector2.new(point.X, point.Y) - mouse).Magnitude
						if dist < bestDist then
							local ok, total, why, single = CanHit(part)
							if ok then
								best, bestDist, reason = part, dist, string.format("%s (%.1f)", why, total)
							else
								blockReason = single and string.format("%s (single=%.1f)", why, single) or why
							end
						end
					end
				end
			end
		end
		lastTarget = best
		lastInfo = (not best and blockReason) and ("BLOCKED: " .. blockReason) or reason
		return best
	end

	local firing, savedCF = false, nil

	local function Hold(part, seconds)
		local stop = os.clock() + seconds
		repeat
			if State.Unloaded or not Alive(part.Parent) then return false end
			local cam = Cam()
			cam.CFrame = lookAt(cam.CFrame.Position, part.Position)
			task.wait()
		until os.clock() >= stop
		return true
	end

	local function Fire(part)
		if firing then return end
		firing = true
		local ok = pcall(function()
			local model = part.Parent
			if not Alive(model) or not CanShoot(Equipped()) then return end
			local cam = Cam()
			if C.BlockMouse then Block() end
			savedCF = cam.CFrame
			Hold(part, C.SnapDelay)
			if Alive(model) and CanShoot(Equipped()) then
				for _ = 1, C.Clicks do
					if State.Unloaded or not Alive(model) then break end
					cam.CFrame = lookAt(cam.CFrame.Position, part.Position)
					task.wait(C.ClickInterval)
					if State.Unloaded or not Alive(model) then break end
					cam.CFrame = lookAt(cam.CFrame.Position, part.Position)
					if C.AutoFire then Click() end
				end
				Hold(part, math.max(0.001, C.HoldAfter))
				if C.ZeroRecoil or C.ZeroSpread then
					local tool = Equipped()
					if tool then Zero(tool) end
				end
			end
			cam.CFrame = savedCF
			savedCF = nil
			Unblock()
		end)
		if not ok then
			if savedCF then pcall(function() Cam().CFrame = savedCF end) end
			savedCF = nil
			Unblock()
		end
		firing = false
	end

	local function Pause(seconds, model)
		local stop = os.clock() + seconds
		while os.clock() < stop and C.SA and not State.Unloaded and Alive(model) do task.wait(0.02) end
	end

	local saActive = false
	local function SilentLoop()
		if saActive then return end
		saActive = true
		task.spawn(function()
			while C.SA and not State.Unloaded do
				local speed = math.max(0.1, C.LoopSpeed)
				local part = Held() and not firing and FindSilent()
				if part and Alive(part.Parent) then
					local model = part.Parent
					Fire(part)
					if C.Repeat == "Time" then
						if C.FixedTime <= 0 then
							while C.SA and not State.Unloaded and Alive(model) do task.wait(0.02) end
						else
							Pause(C.FixedTime / speed, model)
						end
					else
						local tool = Equipped()
						local rpm = tool and Data(tool).RPM
						if type(rpm) ~= "number" or rpm <= 0 then rpm = 600 end
						Pause(60 / rpm / speed, model)
					end
				else
					task.wait(0.1 / speed)
				end
				task.wait()
			end
			saActive = false
		end)
	end

	local function OnCrosshair()
		local root, cam = Root(), Cam()
		if not root or not cam then return false end
		local parts = C.TBParts
		local kindsList = parts.All and PARTS_ALL or (parts.Head and parts.Torso and PARTS_BOTH) or (parts.Head and PARTS_HEAD) or (parts.Torso and PARTS_TORSO)
		if not kindsList then return false end
		local mouse = UIS:GetMouseLocation()
		local origin = root.Position
		local list = Cands()
		for i = 1, #list do
			local model = list[i]
			if Alive(model) then
				for j = 1, #kindsList do
					local part = PartOf(model, kindsList[j])
					if part and (part.Position - origin).Magnitude <= C.MaxDistance then
						local point, onScreen = cam:WorldToViewportPoint(part.Position)
						if onScreen and (Vector2.new(point.X, point.Y) - mouse).Magnitude < 30 and (not C.TBWall or Clear(origin, part)) then return true end
					end
				end
			end
		end
		return false
	end

	local tbActive = false
	local function TriggerLoop()
		if tbActive then return end
		tbActive = true
		task.spawn(function()
			while C.TB and not State.Unloaded do
				if not Held() then
					task.wait(0.05)
				else
					local tool = Equipped()
					if tool and not CanShoot(tool) then
						task.wait(0.05)
					elseif OnCrosshair() then
						task.wait(C.TBHold)
						if State.Unloaded or not C.TB then break end
						if OnCrosshair() then
							Click()
							task.wait(C.TBCooldown)
						end
					else
						task.wait(0.02)
					end
				end
			end
			tbActive = false
		end)
	end

	local fov = Lib.Create("Frame", {
		Name = "CombatFOV", AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Size = UDim2.fromOffset(600, 600),
		Visible = false, ZIndex = 0, Parent = UI.Screen,
		Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
		Lib.Create("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
	})
	local fovLink
	local function RefreshFov()
		local show = C.SA and C.ShowFOV
		fov.Visible = show
		fov.Size = UDim2.fromOffset(C.FOV * 2, C.FOV * 2)
		if show and not fovLink then
			fovLink = Run.RenderStepped:Connect(function()
				local mouse = UIS:GetMouseLocation()
				fov.Position = UDim2.fromOffset(mouse.X, mouse.Y)
			end)
		elseif not show and fovLink then
			fovLink:Disconnect()
			fovLink = nil
		end
	end

	function Lib.StopCombat()
		C.SA, C.TB, Cf.On, Ms.On = false, false, false, false
		RefreshAim()
		RefreshFov()
		UnlinkZero()
		if savedCF then pcall(function() Cam().CFrame = savedCF end) savedCF = nil end
		Unblock()
		for tool in pairs(cache) do Restore(tool) end
		for _, link in ipairs(live) do link:Disconnect() end
		table.clear(live)
		fov:Destroy()
	end

	local function Toggle(group, title, desc, tbl, key, last, after)
		local item = Lib.CreateSettingToggleItem(group, title, desc, tbl[key], function(value)
			tbl[key] = value
			if after then after(value) end
		end, last)
		reg[#reg + 1] = { title, "T", function() return tbl[key] end }
		return item
	end

	local function Slider(group, title, desc, min, max, tbl, key, step, suffix, last, after)
		local item = Lib.CreateSettingSliderItem(group, title, desc, min, max, tbl[key], function(value)
			tbl[key] = value
			if after then after(value) end
		end, last, suffix, step)
		reg[#reg + 1] = { title, "S", function() return tbl[key] end }
		return item
	end

	local function Choice(group, title, options, default, apply, last, multi)
		local item = Lib.CreateSettingChoiceItem(group, title, options, default, apply, last, multi)
		reg[#reg + 1] = { title, "C" }
		return item
	end

	local function Gear(item, modal)
		local gear = Lib.Create("ImageButton", {
			Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, -98, 0.5, -14), BackgroundColor3 = Color3.fromRGB(22, 22, 22), AutoButtonColor = false,
			Image = "rbxassetid://119430435918970", ImageColor3 = Color3.fromRGB(180, 180, 180), ScaleType = Enum.ScaleType.Fit, Parent = item,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
			Lib.Create("UIPadding", { PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5), PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5) })
		})
		Lib.RegisterThemeElement(gear, "BackgroundColor3", 0.7)
		gear.MouseButton1Click:Connect(function()
			Lib.PlayClick()
			modal.Open()
		end)
	end

	local TARGET_OPTIONS = { { "Players", "Player" }, { "NPC Humanoid", "Npc_Humanoid" }, { "NPC Folders", "Npc_Workspace" } }
	local PART_OPTIONS = { "Head", "Torso", "Center" }

	local function AimModal(aim, name, maxSpeed)
		local modal = Lib.CreateModal(name .. " Settings", 430, 460)
		local behavior = Lib.CreateFeatureGroup(modal.Content, "Behavior", 1)
		Slider(behavior, name .. " Speed", "Aim smoothing speed", 0, maxSpeed, aim, "Speed", 1, nil, false)
		Toggle(behavior, name .. " Loop Target", "Keeps the locked target until it dies or leaves view", aim, "Loop", true, function(value)
			if not value then aim.Locked = nil end
		end)
		local targets = Lib.CreateFeatureGroup(modal.Content, "Targets", 2)
		Choice(targets, name .. " Targets", TARGET_OPTIONS, { "Player" }, function(set) aim.Targets = set end, false, true)
		Choice(targets, name .. " Target Part", PART_OPTIONS, aim.Part, function(value) aim.Part = value end, true)
		local prediction = Lib.CreateFeatureGroup(modal.Content, "Prediction", 3)
		Choice(prediction, name .. " Predict Mode", { "Custom", "Auto" }, aim.Predict, function(value) aim.Predict = value end)
		Slider(prediction, name .. " Predict", "Prediction time", 1, 100, aim, "Ms", 1, "ms", false)
		Toggle(prediction, name .. " Wall Check", "Ignore targets behind walls", aim, "Wall", true)
		return modal
	end

	local cfModal, msModal = AimModal(Cf, "Cframe", 100), AimModal(Ms, "Mouse", 50)

	local saModal = Lib.CreateModal("Silent Aim Settings", 430, 520)
	local firingGroup = Lib.CreateFeatureGroup(saModal.Content, "Firing", 1)
	Toggle(firingGroup, "Block Mouse", "Locks the cursor while the shot is fired", C, "BlockMouse", false)
	Slider(firingGroup, "Snap Delay", "Time the camera is held on target before the shot", 0.001, 5, C, "SnapDelay", 0.001, "s", false)
	Slider(firingGroup, "Hold After Shot", "Time the camera stays on target after the shot", 0.001, 5, C, "HoldAfter", 0.001, "s", false)
	Slider(firingGroup, "Clicks Count", "Clicks fired per cycle", 1, 5, C, "Clicks", 1, nil, false)
	Slider(firingGroup, "Click Interval", "Pause before every click", 0.001, 1, C, "ClickInterval", 0.001, "s", true)
	local loopGroup = Lib.CreateFeatureGroup(saModal.Content, "Loop", 2)
	Slider(loopGroup, "Loop Speed", "Speed multiplier of the aim loop", 0.1, 5, C, "LoopSpeed", 0.1, "x", false)
	Choice(loopGroup, "Repeat Mode", { "RPM", "Time" }, C.Repeat, function(value) C.Repeat = value end)
	Slider(loopGroup, "Fixed Time", "Pause between shots in Time mode, 0 = until death", 0, 5, C, "FixedTime", 0.01, "s", true)
	local aimGroupModal = Lib.CreateFeatureGroup(saModal.Content, "Targeting", 3)
	Choice(aimGroupModal, "Silent Target Part", { "Head", "Torso" }, C.TargetPart, function(value) C.TargetPart = value end)
	Toggle(aimGroupModal, "Wall Check", "Skips targets that cannot be hit through walls", C, "WallCheck", true)

	local tbModal = Lib.CreateModal("Trigger Bot Settings", 430, 340)
	local tbGroup = Lib.CreateFeatureGroup(tbModal.Content, "Trigger", 1)
	Slider(tbGroup, "Hold Before Shot", "Delay between target detection and the shot", 0.001, 1, C, "TBHold", 0.001, "s", false)
	Slider(tbGroup, "Shot Cooldown", "Pause between shots", 0.01, 2, C, "TBCooldown", 0.01, "s", false)
	Toggle(tbGroup, "Trigger Wall Check", "Ignores targets behind walls", C, "TBWall", false)
	Choice(tbGroup, "Trigger Parts", { "Head", "Torso", "All" }, { "Head" }, function(set) C.TBParts = set end, true, true)

	local wbModal = Lib.CreateModal("Wallbang Settings", 430, 400)
	local wbGroup = Lib.CreateFeatureGroup(wbModal.Content, "Wallbang", 1)
	Slider(wbGroup, "Wallbang Multiplier", "Multiplies the weapon wallbang power", 0, 20, C, "WallMult", 0.5, "x", false)
	Toggle(wbGroup, "Wallbang Override", "Replaces the weapon value with your own", C, "WallOverride", false)
	Slider(wbGroup, "Override Value", "Custom wallbang power", 0, 100, C, "WallOverrideVal", 1, " studs", false)
	Slider(wbGroup, "Max Wall Thickness", "Maximum thickness of a single wall", 0.1, 100, C, "MaxThickness", 0.5, " studs", false)
	Choice(wbGroup, "Wall Origin", { "muzzle", "camera", "root" }, C.WallMode, function(value) C.WallMode = value end, true)

	local diagModal = Lib.CreateModal("Combat Diagnostics", 380, 440)
	local diagGroup = Lib.CreateFeatureGroup(diagModal.Content, "Live", 1)
	local function InfoRow(title, last)
		local row = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, Parent = diagGroup })
		local name = Lib.Create("TextLabel", {
			Size = UDim2.new(0.4, -14, 1, 0), Position = UDim2.fromOffset(14, 0), BackgroundTransparency = 1, Text = title, TextColor3 = Color3.fromRGB(240, 240, 240),
			TextSize = 12, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, Parent = row
		})
		Lib.RegisterThemeText(name, "Primary")
		local value = Lib.Create("TextLabel", {
			Size = UDim2.new(0.6, -14, 1, 0), Position = UDim2.new(0.4, 0, 0, 0), BackgroundTransparency = 1, Text = "—", TextColor3 = Color3.fromRGB(150, 150, 150),
			TextSize = 12, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Right, TextTruncate = Enum.TextTruncate.AtEnd, Parent = row
		})
		Lib.RegisterThemeText(value, "Secondary")
		if not last then
			Lib.Create("Frame", {
				Size = UDim2.new(1, -28, 0, 1), Position = UDim2.new(0, 14, 1, -1), BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 0.9, BorderSizePixel = 0, Parent = row
			})
		end
		return value
	end
	local dTarget, dWall, dAmmo, dJam, dWb = InfoRow("Target"), InfoRow("Wall"), InfoRow("Ammo"), InfoRow("Jammed"), InfoRow("Wallbang")
	local dNpc, dMouse, dTools, dAim, dTrigger = InfoRow("NPC"), InfoRow("Mouse"), InfoRow("Cached Tools"), InfoRow("Aim Check"), InfoRow("Trigger Bot", true)

	local function Count(tbl)
		local count = 0
		for _ in pairs(tbl) do count += 1 end
		return count
	end

	local function RefreshDiag()
		dTarget.Text = lastTarget and lastTarget.Parent and (lastTarget.Parent.Name .. " → " .. lastTarget.Name) or "—"
		dWall.Text = lastInfo
		local tool = Equipped()
		if tool then
			local ammo, source = Ammo(tool)
			dAmmo.Text = ammo and (ammo .. " (" .. source .. ")") or "—"
			dJam.Text = tostring(Jammed(tool))
			local power, key = WallPower(tool)
			dWb.Text = string.format("%.1f studs (%s)", power, tostring(key))
		else
			dAmmo.Text, dJam.Text, dWb.Text = "—", "—", "—"
		end
		dNpc.Text = tostring(Count(npcs))
		dMouse.Text = blocked and "LOCKED" or "free"
		dTools.Text = tostring(Count(cache))
		dAim.Text = C.AimCheck and (held and "HELD" or "NOT HELD") or "disabled"
		dTrigger.Text = C.TB and "ENABLED" or "disabled"
	end

	local diagActive = false
	local function OpenDiag()
		diagModal.Open()
		if diagActive then return end
		diagActive = true
		task.spawn(function()
			while not State.Unloaded do
				RefreshDiag()
				task.wait(0.5)
				if not diagModal.Backdrop.Visible then break end
			end
			diagActive = false
		end)
	end

	local aimGroup = Lib.CreateFeatureGroup(scroll, "Aim Assist", 1)
	Gear(Toggle(aimGroup, "Cframe Aim", "Smoothly rotates the camera towards the closest target", Cf, "On", false, function(value)
		if not value then Cf.Locked = nil end
		RefreshAim()
	end), cfModal)
	Gear(Toggle(aimGroup, "Mouse Aim", "Moves the mouse towards the closest target", Ms, "On", true, function(value)
		if not value then Ms.Locked = nil end
		RefreshAim()
	end), msModal)

	local silentGroup = Lib.CreateFeatureGroup(scroll, "Silent Aim", 2)
	Gear(Toggle(silentGroup, "Silent Aim", "Snaps the camera to the target, fires and returns it back", C, "SA", false, function(value)
		RefreshFov()
		if value then SilentLoop() end
	end), saModal)
	Toggle(silentGroup, "Auto-Fire", "Clicks automatically when a target is locked", C, "AutoFire", false)
	Toggle(silentGroup, "Show FOV Circle", "Draws the Silent Aim FOV around the cursor", C, "ShowFOV", false, RefreshFov)
	Slider(silentGroup, "FOV Radius", "Silent Aim field of view radius", 10, 800, C, "FOV", 1, "px", true, RefreshFov)

	local triggerGroup = Lib.CreateFeatureGroup(scroll, "Trigger Bot", 3)
	Gear(Toggle(triggerGroup, "Trigger Bot", "Fires automatically when the crosshair is on a target", C, "TB", true, function(value)
		if value then TriggerLoop() end
	end), tbModal)

	local weaponGroup = Lib.CreateFeatureGroup(scroll, "Weapon", 4)
	Toggle(weaponGroup, "Zero Recoil", "Removes weapon recoil", C, "ZeroRecoil", false, SyncZero)
	Toggle(weaponGroup, "Zero Spread", "Removes weapon spread and inaccuracy", C, "ZeroSpread", false, SyncZero)
	Toggle(weaponGroup, "Check Ammo", "Does not shoot with an empty magazine", C, "CheckAmmo", false)
	Toggle(weaponGroup, "Check Jammed", "Does not shoot with a jammed weapon", C, "CheckJammed", false)
	Lib.CreateSettingButtonItem(weaponGroup, "Wallbang Settings", "Power, thickness limit and origin of wallbang checks", function() wbModal.Open() end, true)

	local targetGroup = Lib.CreateFeatureGroup(scroll, "Targeting", 5)
	Toggle(targetGroup, "Target NPCs", "Silent Aim and Trigger Bot target NPCs", C, "NPCs", false)
	Toggle(targetGroup, "Target Players", "Silent Aim and Trigger Bot target players", C, "Players", false)
	Toggle(targetGroup, "Team Check", "Ignores players from your team", C, "TeamCheck", false)
	Slider(targetGroup, "Max Distance", "Maximum target distance", 100, 5000, C, "MaxDistance", 50, "m", false)
	Toggle(targetGroup, "Aim Check", "Works only while the aim key is held", C, "AimCheck", false)
	Choice(targetGroup, "Aim Key", { { "RMB", "MouseButton2" }, { "LMB", "MouseButton1" }, "E", "Q", "F", { "L-Alt", "LeftAlt" }, { "R-Alt", "RightAlt" }, { "L-Shift", "LeftShift" } }, "MouseButton2", function(name)
		C.AimKey = name:find("MouseButton", 1, true) and Enum.UserInputType[name] or Enum.KeyCode[name]
		held = false
	end, true)

	local toolsGroup = Lib.CreateFeatureGroup(scroll, "Tools", 6)
	Lib.CreateSettingButtonItem(toolsGroup, "Combat Diagnostics", "Live target, ammo, wallbang and aim state", OpenDiag, true)

	Lib.ConfigExtras = Lib.ConfigExtras or {}
	Lib.ConfigExtras.Combat = {
		Dump = function()
			local dump = {}
			for _, entry in ipairs(reg) do
				local title, kind, getter = entry[1], entry[2], entry[3]
				if kind == "C" then
					dump[title] = Lib.ChoiceControls[title].Get()
				else
					dump[title] = getter()
				end
			end
			return dump
		end,
		Apply = function(data)
			for _, entry in ipairs(reg) do
				local title, kind = entry[1], entry[2]
				local value = data[title]
				if value ~= nil then
					if kind == "T" then
						local control = Lib.ToggleControls[title]
						if control and type(value) == "boolean" then control.Set(value) end
					elseif kind == "S" then
						local control = Lib.SliderControls[title]
						if control and type(value) == "number" then control(value) end
					else
						local control = Lib.ChoiceControls[title]
						if control then control.Set(value) end
					end
				end
			end
		end
	}
end

function Lib.BuildDevConsole()
	local LogService = game:GetService("LogService")
	local cfg = { Output = true, Info = true, Warning = true, Error = true, HidePlace = false }
	local MAX_ENTRIES = 300
	local Kinds = {
		[Enum.MessageType.MessageOutput] = "Output",
		[Enum.MessageType.MessageInfo] = "Info",
		[Enum.MessageType.MessageWarning] = "Warning",
		[Enum.MessageType.MessageError] = "Error"
	}
	local Colors = {
		Output = Color3.fromRGB(235, 235, 235),
		Info = Color3.fromRGB(90, 170, 255),
		Warning = Color3.fromRGB(255, 200, 60),
		Error = Color3.fromRGB(255, 85, 85)
	}
	local Roots = { "Workspace", "ReplicatedStorage", "ReplicatedFirst", "StarterGui", "StarterPack", "StarterPlayer", "Players", "Lighting", "SoundService", "Chat", "TextChatService" }

	local entries, nextId = {}, 0
	local queue, head, tail = {}, 1, 0
	local totals = { Warning = 0, Error = 0, PlaceError = 0 }
	local window, list, listLayout, warnLabel, errLabel, memLabel
	local stick, acc = true, 0
	local api = {}

	local function IsPlaceMessage(text)
		if text:find("SeptusHub", 1, true) then return false end
		if text:find("^Stack Begin") or text:find("^Stack End") or text:find("^Script '") then return true end
		for _, root in ipairs(Roots) do
			if text:find("^" .. root .. "[%.:]") or text:find("%s" .. root .. "%.[%w_%.%s]*:%d+") then return true end
		end
		return false
	end

	local function Passes(entry)
		if not cfg[entry.kind] then return false end
		return not (cfg.HidePlace and entry.place)
	end

	local function RowText(entry)
		local text = string.format("[%s] %s", os.date("%H:%M:%S", entry.time), entry.text)
		return entry.count > 1 and (text .. "  ×" .. entry.count) or text
	end

	local function UpdateLabels()
		if not warnLabel then return end
		local errors = totals.Error - (cfg.HidePlace and totals.PlaceError or 0)
		warnLabel.Text = "Warnings: " .. totals.Warning
		errLabel.Text = "Errors: " .. errors
		local ok, mb = pcall(Services.Stats.GetTotalMemoryUsageMb, Services.Stats)
		memLabel.Text = string.format("Client Memory: %d MB", ok and mb or 0)
	end

	local function EnsureRow(entry)
		if entry.row or not list then return end
		entry.row = Lib.Create("TextLabel", {
			Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Text = RowText(entry), TextColor3 = Colors[entry.kind],
			TextSize = 12, Font = Enum.Font.Code, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
			LayoutOrder = entry.id, Visible = Passes(entry), Parent = list
		})
	end

	local function Refresh()
		for _, entry in ipairs(entries) do
			if entry.row then entry.row.Visible = Passes(entry) end
		end
		UpdateLabels()
	end

	local function Push(text, kind, time)
		tail = tail + 1
		queue[tail] = { text = text, kind = kind, time = time }
		if tail - head > 600 then
			for i = head, head + 200 do queue[i] = nil end
			head = head + 201
		end
	end

	local function Add(item)
		local last = entries[#entries]
		if last and last.text == item.text and last.kind == item.kind then
			last.count = last.count + 1
			if last.row then last.row.Text = RowText(last) end
		else
			nextId = nextId + 1
			local place = (item.kind == "Error" and IsPlaceMessage(item.text)) or item.text:find("^Stack ") ~= nil or item.text:find("^Script '") ~= nil
			local entry = { id = nextId, text = item.text, kind = item.kind, time = item.time, count = 1, place = place }
			entries[#entries + 1] = entry
			if #entries > MAX_ENTRIES then
				local old = table.remove(entries, 1)
				if old.row then old.row:Destroy() end
			end
			if window and window.IsVisible() then EnsureRow(entry) end
		end
		if item.kind == "Warning" then
			totals.Warning = totals.Warning + 1
		elseif item.kind == "Error" then
			totals.Error = totals.Error + 1
			if IsPlaceMessage(item.text) then totals.PlaceError = totals.PlaceError + 1 end
		end
	end

	local function Build()
		window = Lib.CreateWindow({ Name = "SeptusDevConsole", Title = "Developer Console", Width = 580, Height = 340, Gear = true, OffsetX = 30, OffsetY = 20, OnVisibility = function(visible)
			if api.OnVisibility then api.OnVisibility(visible) end
		end })
		local body = window.Body

		local top = Lib.Create("Frame", {
			Size = UDim2.new(1, -16, 0, 30), Position = UDim2.fromOffset(8, 8), BackgroundColor3 = Color3.fromRGB(22, 22, 22), Parent = body,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
		})
		Lib.RegisterThemeElement(top, "BackgroundColor3", 0.7)

		local function Stat(xScale, width, color)
			return Lib.Create("TextLabel", {
				Size = UDim2.new(width, 0, 1, 0), Position = UDim2.new(xScale, 10, 0, 0), BackgroundTransparency = 1, Text = "", TextColor3 = color,
				TextSize = 12, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, Parent = top
			})
		end
		warnLabel = Stat(0, 0.24, Colors.Warning)
		errLabel = Stat(0.24, 0.22, Colors.Error)
		memLabel = Stat(0.46, 0.32, Color3.fromRGB(235, 235, 235))
		Lib.RegisterThemeText(memLabel, "Primary")

		local clearBtn = Lib.MakeChip(top, "Clear", UDim2.fromOffset(56, 22), UDim2.new(1, -62, 0.5, -11))

		list = Lib.Create("ScrollingFrame", {
			Size = UDim2.new(1, -16, 1, -54), Position = UDim2.fromOffset(8, 46), BackgroundColor3 = Color3.fromRGB(12, 12, 12), ScrollBarThickness = 3,
			ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100), BorderSizePixel = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollingDirection = Enum.ScrollingDirection.Y, Parent = body,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
			Lib.Create("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6) })
		})
		Lib.RegisterThemeElement(list, "BackgroundColor3", 0.5)
		listLayout = Lib.Create("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = list })

		list:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
			stick = list.CanvasPosition.Y >= list.AbsoluteCanvasSize.Y - list.AbsoluteSize.Y - 10
		end)
		listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			if stick then list.CanvasPosition = Vector2.new(0, 1e6) end
		end)

		clearBtn.MouseButton1Click:Connect(function()
			Lib.PlayClick()
			for _, entry in ipairs(entries) do
				if entry.row then entry.row:Destroy() end
			end
			table.clear(entries)
			totals.Warning, totals.Error, totals.PlaceError = 0, 0, 0
			UpdateLabels()
		end)

		local settings = Lib.CreateOverlay(window)
		local typeGroup = Lib.CreateFeatureGroup(settings, "Message Types", 1)
		Lib.CreateSettingToggleItem(typeGroup, "Show Output", "Regular print() output", cfg.Output, function(val) cfg.Output = val Refresh() end)
		Lib.CreateSettingToggleItem(typeGroup, "Show Information", "Informational engine messages", cfg.Info, function(val) cfg.Info = val Refresh() end)
		Lib.CreateSettingToggleItem(typeGroup, "Show Warnings", "Warning messages", cfg.Warning, function(val) cfg.Warning = val Refresh() end)
		Lib.CreateSettingToggleItem(typeGroup, "Show Errors", "Error messages", cfg.Error, function(val) cfg.Error = val Refresh() end, true)
		local filterGroup = Lib.CreateFeatureGroup(settings, "Filters", 2)
		Lib.CreateSettingToggleItem(filterGroup, "Hide Place Errors", "Hides errors and stack traces that come from the game's own scripts", cfg.HidePlace, function(val)
			cfg.HidePlace = val
			Refresh()
		end, true)

		for _, entry in ipairs(entries) do EnsureRow(entry) end
		UpdateLabels()
	end

	local history = LogService:GetLogHistory()
	for i = math.max(#history - 200, 1), #history do
		local item = history[i]
		Push(item.message, Kinds[item.messageType] or "Output", item.timestamp or os.time())
	end
	local msgConn = LogService.MessageOut:Connect(function(message, messageType)
		Push(message, Kinds[messageType] or "Output", os.time())
	end)

	local beatConn = Services.Run.Heartbeat:Connect(function(dt)
		local budget = 30
		while head <= tail and budget > 0 do
			local item = queue[head]
			queue[head] = nil
			head = head + 1
			budget = budget - 1
			Add(item)
		end
		if window and window.IsVisible() then
			acc = acc + dt
			if acc >= 0.5 then
				acc = 0
				UpdateLabels()
			end
		end
	end)

	UI.Screen.Destroying:Connect(function()
		msgConn:Disconnect()
		beatConn:Disconnect()
	end)

	function api.Toggle()
		if not window then
			Build()
			window.Show()
			for _, entry in ipairs(entries) do EnsureRow(entry) end
			return
		end
		if not window.IsVisible() then
			for _, entry in ipairs(entries) do EnsureRow(entry) end
		end
		window.Toggle()
	end
	return api
end

function Lib.BuildRemoteSpy()
	local Run = Services.Run
	local cfg = {
		RemoteEvent = true, RemoteFunction = true, BindableEvent = false, BindableFunction = false,
		Outgoing = true, Incoming = true, Actors = true, Tracing = true,
		Filters = true, AutoClean = true, Spoof = true
	}
	local MAX_CALLS, SPAM_RATE = 250, 12
	local ClassKey = { RemoteEvent = "RemoteEvent", UnreliableRemoteEvent = "RemoteEvent", RemoteFunction = "RemoteFunction", BindableEvent = "BindableEvent", BindableFunction = "BindableFunction" }
	local Expect = { FireServer = "RemoteEvent", InvokeServer = "RemoteFunction", Fire = "BindableEvent", Invoke = "BindableFunction" }
	local IsFunction = { RemoteFunction = true, BindableFunction = true }
	local KeyBadge = { RemoteEvent = "RE", RemoteFunction = "RF", BindableEvent = "BE", BindableFunction = "BF" }
	local DirColors = { OUT = Color3.fromRGB(46, 213, 115), IN = Color3.fromRGB(90, 170, 255) }
	local checkCaller = type(checkcaller) == "function" and checkcaller or function() return false end
	local wrapC = type(newcclosure) == "function" and newcclosure or function(fn) return fn end
	local setMethod = type(setnamecallmethod) == "function" and setnamecallmethod or function() end
	local callingScript = type(getcallingscript) == "function" and getcallingscript or nil
	local actorSupported = type(getactors) == "function" and type(run_on_actor) == "function" and type(create_comm_channel) == "function"

	local calls, nextId = {}, 0
	local queue, head, tail = {}, 1, 0
	local dirty = {}
	local ignoredInst = setmetatable({}, { __mode = "k" })
	local ignoredName = {}
	local spoofs = setmetatable({}, { __mode = "k" })
	local rate = setmetatable({}, { __mode = "k" })
	local tracked = setmetatable({}, { __mode = "k" })
	local functions = setmetatable({}, { __mode = "k" })
	local wrapped = setmetatable({}, { __mode = "k" })
	local inConns = {}
	local hooksInstalled, paused, stick = false, false, true
	local window, listScroll, listLayout, detailScroll, detailText, searchBox, pauseBtn
	local spoofRow, spoofBox, spoofBtn
	local selected, selectedRow

	local function Esc(text)
		text = text:gsub("&", "&amp;")
		text = text:gsub("<", "&lt;")
		text = text:gsub(">", "&gt;")
		return text
	end

	local function GetPath(inst)
		local ok, full = pcall(inst.GetFullName, inst)
		return ok and full or tostring(inst)
	end

	local function PathCode(inst)
		local chain, cur = {}, inst
		while cur and cur ~= game do
			table.insert(chain, 1, cur)
			cur = cur.Parent
		end
		if cur ~= game or #chain == 0 then return "nil" end
		local out = 'game:GetService("' .. chain[1].ClassName .. '")'
		local start = 2
		if chain[1].ClassName == "Players" and chain[2] == App.Player then
			out = out .. ".LocalPlayer"
			start = 3
		end
		for i = start, #chain do
			local name = chain[i].Name
			out = out .. (name:match("^[%a_][%w_]*$") and ("." .. name) or ("[" .. string.format("%q", name) .. "]"))
		end
		return out
	end

	local function Serialize(value, depth, seen)
		local kind = typeof(value)
		if kind == "string" then
			return string.format("%q", value)
		elseif kind == "number" then
			if value ~= value then return "0/0" end
			if value == math.huge then return "math.huge" end
			if value == -math.huge then return "-math.huge" end
			return tostring(value)
		elseif kind == "boolean" or kind == "nil" then
			return tostring(value)
		elseif kind == "Instance" then
			return PathCode(value)
		elseif kind == "Vector3" then
			return string.format("Vector3.new(%s, %s, %s)", value.X, value.Y, value.Z)
		elseif kind == "Vector2" then
			return string.format("Vector2.new(%s, %s)", value.X, value.Y)
		elseif kind == "CFrame" then
			return "CFrame.new(" .. table.concat({ value:GetComponents() }, ", ") .. ")"
		elseif kind == "Color3" then
			return string.format("Color3.new(%s, %s, %s)", value.R, value.G, value.B)
		elseif kind == "UDim2" then
			return string.format("UDim2.new(%s, %s, %s, %s)", value.X.Scale, value.X.Offset, value.Y.Scale, value.Y.Offset)
		elseif kind == "EnumItem" then
			return tostring(value)
		elseif kind == "table" then
			if depth > 4 or seen[value] then return "{}" end
			seen[value] = true
			local parts, count = {}, 0
			local length = #value
			for i = 1, length do
				count = count + 1
				if count > 60 then break end
				parts[#parts + 1] = Serialize(value[i], depth + 1, seen)
			end
			for key, item in pairs(value) do
				if not (type(key) == "number" and key >= 1 and key <= length and key % 1 == 0) then
					count = count + 1
					if count > 60 then
						parts[#parts + 1] = "..."
						break
					end
					local keyText = (type(key) == "string" and key:match("^[%a_][%w_]*$")) and key or ("[" .. Serialize(key, depth + 1, seen) .. "]")
					parts[#parts + 1] = keyText .. " = " .. Serialize(item, depth + 1, seen)
				end
			end
			seen[value] = nil
			return "{" .. table.concat(parts, ", ") .. "}"
		end
		return tostring(value)
	end

	local function FormatArgs(packed)
		if not packed or (packed.n or 0) == 0 then return "(none)" end
		local lines = {}
		for i = 1, packed.n do
			local text = Serialize(packed[i], 0, {})
			if #text > 600 then text = text:sub(1, 600) .. "..." end
			lines[i] = string.format("[%d] %s", i, text)
		end
		return table.concat(lines, "\n")
	end

	local function Inline(packed)
		local parts = {}
		for i = 1, (packed.n or 0) do
			parts[i] = Serialize(packed[i], 0, {})
			if #parts[i] > 120 then parts[i] = parts[i]:sub(1, 120) end
		end
		return table.concat(parts, ", ")
	end

	local function SameArgs(a, b)
		if a.n ~= b.n then return false end
		for i = 1, a.n do
			if a[i] ~= b[i] then return false end
		end
		return true
	end

	local function GenerateCode(entry)
		local args = {}
		for i = 1, entry.args.n do args[i] = Serialize(entry.args[i], 0, {}) end
		local target = PathCode(entry.remote)
		local joined = table.concat(args, ", ")
		if entry.dir == "OUT" then
			return target .. ":" .. entry.method .. "(" .. joined .. ")"
		end
		if entry.key == "RemoteEvent" then
			return "firesignal(" .. target .. ".OnClientEvent" .. (joined ~= "" and (", " .. joined) or "") .. ")"
		end
		return "local args = {" .. joined .. "}"
	end

	local function Record(remote, class, dir, method, packed, actor, scriptRef, trace)
		if paused then return nil end
		local key = ClassKey[class]
		if not key or not cfg[key] then return nil end
		if dir == "OUT" then
			if not cfg.Outgoing then return nil end
		elseif not cfg.Incoming then
			return nil
		end
		local name = remote.Name
		if cfg.Filters and (ignoredInst[remote] or ignoredName[name]) then return nil end
		packed.n = packed.n or #packed
		local now = os.clock()

		if cfg.AutoClean then
			local r = rate[remote]
			if not r then
				r = { start = now, n = 0 }
				rate[remote] = r
			end
			if now - r.start >= 1 then
				if r.spam and r.n < 6 then r.spam = nil end
				r.start, r.n = now, 0
			end
			r.n = r.n + 1
			local target = r.spam or r.last
			if target and not target.removed and target.dir == dir and (r.spam or SameArgs(target.args, packed)) then
				target.count = target.count + 1
				target.args = packed
				target.inline = nil
				dirty[target] = true
				return target
			end
		end

		nextId = nextId + 1
		local entry = {
			id = nextId, remote = remote, name = name, class = class, key = key, dir = dir, method = method, args = packed,
			time = os.time(), actor = actor, script = scriptRef, trace = trace, count = 1
		}
		if cfg.AutoClean then
			local r = rate[remote]
			r.last = entry
			if r.n > SPAM_RATE then
				r.spam = entry
				entry.spam = true
			end
		end
		tail = tail + 1
		queue[tail] = entry
		return entry
	end

	local function CallSpoof(remote)
		local spoof = cfg.Spoof and spoofs[remote]
		if not spoof then return nil end
		local ok, result = pcall(function() return table.pack(spoof.fn()) end)
		return ok and result or nil
	end

	local function OnNamecall(self, ...)
		local method = getnamecallmethod()
		local want = Expect[method]
		if want and cfg.Outgoing and not checkCaller() then
			local class = self.ClassName
			if ClassKey[class] == want and cfg[want] then
				local packed = table.pack(...)
				local ok, entry = pcall(function()
					return Record(self, class, "OUT", method, packed, false, callingScript and callingScript() or nil, cfg.Tracing and debug.traceback("", 2) or nil)
				end)
				setMethod(method)
				if IsFunction[want] then
					local result = table.pack(Lib.SpyOriginal(self, ...))
					local spoofed = CallSpoof(self)
					if spoofed then result = spoofed end
					if ok and entry then
						entry.returns = result
						entry.spoofed = spoofed ~= nil
						dirty[entry] = true
					end
					return table.unpack(result, 1, result.n)
				end
			end
		end
		setMethod(method)
		return Lib.SpyOriginal(self, ...)
	end

	local function Matches(entry)
		if not cfg.Filters or not searchBox then return true end
		local needle = searchBox.Text
		if needle == "" then return true end
		needle = needle:lower()
		if entry.name:lower():find(needle, 1, true) then return true end
		if not entry.inline then entry.inline = Inline(entry.args) end
		return entry.inline:lower():find(needle, 1, true) ~= nil
	end

	local function RowName(entry)
		return entry.count > 1 and (entry.name .. "  ×" .. entry.count) or entry.name
	end

	local function BuildDetail(entry)
		local parts = {}
		parts[#parts + 1] = string.format('<b>%s</b>  <font color="#8a8a8a">%s · %s</font>', Esc(entry.name), entry.class, entry.dir == "OUT" and "Outgoing" or "Incoming")
		parts[#parts + 1] = '<font color="#8a8a8a">Path</font>\n' .. Esc(GetPath(entry.remote))
		local info = { "Method: " .. entry.method, "Time: " .. os.date("%H:%M:%S", entry.time), "Source: " .. (entry.actor and "Actor" or "Main state") }
		if entry.count > 1 then info[#info + 1] = string.format("Repeated: x%d%s", entry.count, entry.spam and " (spam, merged automatically)" or "") end
		parts[#parts + 1] = '<font color="#8a8a8a">Info</font>\n' .. Esc(table.concat(info, "\n"))
		local summary
		if entry.dir == "OUT" then
			summary = string.format("Sent %d argument(s) to %s through %s", entry.args.n or 0, entry.key:find("Bindable") and "a client script" or "the server", entry.method)
		else
			summary = string.format("Received %d argument(s) via %s", entry.args.n or 0, entry.method)
		end
		parts[#parts + 1] = '<font color="#8a8a8a">What it did</font>\n' .. Esc(summary)
		parts[#parts + 1] = '<font color="#8a8a8a">Arguments</font>\n' .. Esc(FormatArgs(entry.args))
		if IsFunction[entry.key] then
			local returns = entry.returns and FormatArgs(entry.returns) or "(waiting for return value)"
			parts[#parts + 1] = '<font color="#8a8a8a">Returned' .. (entry.spoofed and " (spoofed)" or "") .. '</font>\n' .. Esc(returns)
		end
		if entry.script then
			parts[#parts + 1] = '<font color="#8a8a8a">Calling script</font>\n' .. Esc(GetPath(entry.script))
		end
		if entry.trace and entry.trace ~= "" then
			local trace = entry.trace
			if #trace > 1500 then trace = trace:sub(1, 1500) .. "..." end
			parts[#parts + 1] = '<font color="#8a8a8a">Traceback</font>\n' .. Esc(trace)
		end
		return table.concat(parts, "\n\n")
	end

	local function ShowDetail(entry)
		if not detailText then return end
		if not entry then
			detailText.Text = '<font color="#8a8a8a">Select a call on the left to see what it did</font>'
			spoofRow.Visible = false
			return
		end
		detailText.Text = BuildDetail(entry)
		local isFunc = IsFunction[entry.key]
		spoofRow.Visible = isFunc or false
		if isFunc then
			local spoof = spoofs[entry.remote]
			spoofBox.Text = spoof and spoof.text or spoofBox.Text
			spoofBtn.Text = spoof and "Spoof: ON" or "Spoof: OFF"
		end
	end

	local function Select(entry, row)
		if selectedRow and selectedRow.Parent then
			selectedRow.BackgroundColor3 = Lib.Theme.Item
		end
		selected, selectedRow = entry, row
		if row then row.BackgroundColor3 = Lib.Lighten(Lib.Theme.Item, 0.14) end
		ShowDetail(entry)
	end

	local function EnsureRow(entry)
		if entry.row or not listScroll then return end
		local row = Lib.Create("TextButton", {
			Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = Color3.fromRGB(24, 24, 24), Text = "", AutoButtonColor = false, LayoutOrder = entry.id,
			Visible = Matches(entry), Parent = listScroll, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 5) })
		})
		Lib.RegisterThemeElement(row, "BackgroundColor3", 0.7)
		Lib.Create("Frame", {
			Size = UDim2.new(0, 3, 1, -10), Position = UDim2.fromOffset(3, 5), BackgroundColor3 = DirColors[entry.dir], BorderSizePixel = 0, Parent = row,
			Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) })
		})
		Lib.RegisterThemeText(Lib.Create("TextLabel", {
			Size = UDim2.fromOffset(56, 26), Position = UDim2.fromOffset(12, 0), BackgroundTransparency = 1, Text = os.date("%H:%M:%S", entry.time),
			TextColor3 = Color3.fromRGB(130, 130, 130), TextSize = 10, Font = Enum.Font.Code, TextXAlignment = Enum.TextXAlignment.Left, Parent = row
		}), "Secondary")
		Lib.Create("TextLabel", {
			Size = UDim2.fromOffset(22, 26), Position = UDim2.fromOffset(70, 0), BackgroundTransparency = 1, Text = KeyBadge[entry.key],
			TextColor3 = DirColors[entry.dir], TextSize = 10, Font = Enum.Font.GothamBold, Parent = row
		})
		entry.nameLabel = Lib.Create("TextLabel", {
			Size = UDim2.new(1, -100, 1, 0), Position = UDim2.fromOffset(96, 0), BackgroundTransparency = 1, Text = RowName(entry),
			TextColor3 = Color3.fromRGB(235, 235, 235), TextSize = 12, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd, Parent = row
		})
		Lib.RegisterThemeText(entry.nameLabel, "Primary")
		entry.row = row
		row.MouseButton1Click:Connect(function()
			Lib.PlayClick()
			Select(entry, row)
		end)
	end

	local function Drop(entry)
		entry.removed = true
		if entry.row then entry.row:Destroy() end
	end

	local function AddEntry(entry)
		calls[#calls + 1] = entry
		if #calls > MAX_CALLS then
			Drop(table.remove(calls, 1))
		end
		if window and window.IsVisible() then EnsureRow(entry) end
	end

	local function RefreshFilter()
		for _, entry in ipairs(calls) do
			if entry.row then entry.row.Visible = Matches(entry) end
		end
	end

	local function RemoveRemote(remote)
		for i = #calls, 1, -1 do
			local entry = calls[i]
			if entry.remote == remote then
				Drop(entry)
				table.remove(calls, i)
			end
		end
	end

	local function ApplyRemote(remote)
		local key = ClassKey[remote.ClassName]
		if not key then return end
		local want = cfg.Incoming and cfg[key]
		local conn = inConns[remote]
		if want then
			if IsFunction[key] then
				functions[remote] = true
			elseif not conn then
				local class = remote.ClassName
				if key == "RemoteEvent" then
					inConns[remote] = remote.OnClientEvent:Connect(function(...)
						Record(remote, class, "IN", "OnClientEvent", table.pack(...), false)
					end)
				else
					inConns[remote] = remote.Event:Connect(function(...)
						Record(remote, class, "IN", "Event", table.pack(...), false)
					end)
				end
			end
		else
			if conn then
				conn:Disconnect()
				inConns[remote] = nil
			end
			functions[remote] = nil
		end
	end

	local function RefreshIncoming()
		for remote in pairs(tracked) do ApplyRemote(remote) end
	end

	local function WrapCallback(remote)
		if type(getcallbackvalue) ~= "function" then return end
		local class = remote.ClassName
		local prop = class == "RemoteFunction" and "OnClientInvoke" or "OnInvoke"
		local ok, callback = pcall(getcallbackvalue, remote, prop)
		if not ok or type(callback) ~= "function" or wrapped[remote] == callback then return end
		local function wrapper(...)
			local entry = Record(remote, class, "IN", prop, table.pack(...), false)
			local result = table.pack(callback(...))
			local spoofed = CallSpoof(remote)
			if spoofed then result = spoofed end
			if entry then
				entry.returns = result
				entry.spoofed = spoofed ~= nil
				dirty[entry] = true
			end
			return table.unpack(result, 1, result.n)
		end
		wrapped[remote] = wrapper
		pcall(function() remote[prop] = wrapper end)
	end

	local function Track(inst)
		if ClassKey[inst.ClassName] then
			tracked[inst] = true
			ApplyRemote(inst)
		end
	end

	local ActorSource = [==[
local id = ...
local event = get_comm_channel(id)
local expect = { FireServer = "RemoteEvent", InvokeServer = "RemoteFunction", Fire = "BindableEvent", Invoke = "BindableFunction" }
local old
old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
	local method = getnamecallmethod()
	local want = expect[method]
	if want and not checkcaller() then
		local ok, class = pcall(function() return self.ClassName end)
		if ok and (class == want or (want == "RemoteEvent" and class == "UnreliableRemoteEvent")) then
			pcall(function() event:Fire(self, method, table.pack(...), debug.traceback("", 2)) end)
		end
	end
	setnamecallmethod(method)
	return old(self, ...)
end))
]==]

	local actorChannel, actorId
	local hookedActors = setmetatable({}, { __mode = "k" })

	local function HookActors()
		if not actorSupported or not cfg.Actors then return end
		if not actorChannel then
			local ok, id, event = pcall(create_comm_channel)
			if not ok or not event then return end
			actorId, actorChannel = id, event
			Lib.C(event.Event, function(remote, method, packed, trace)
				if typeof(remote) ~= "Instance" or type(packed) ~= "table" then return end
				Record(remote, remote.ClassName, "OUT", tostring(method), packed, true, nil, trace)
			end)
		end
		local ok, actors = pcall(getactors)
		if not ok then return end
		for _, actor in ipairs(actors) do
			if not hookedActors[actor] then
				hookedActors[actor] = true
				pcall(run_on_actor, actor, ActorSource, actorId)
			end
		end
	end

	local function InstallHooks()
		if hooksInstalled then return end
		hooksInstalled = true
		UI.Screen.Destroying:Connect(function() paused = true end)
		if type(hookmetamethod) ~= "function" or type(getnamecallmethod) ~= "function" then
			Lib.Notify({ Title = "Remote Spy", Text = "Executor lacks hookmetamethod: outgoing calls cannot be logged" })
		else
			Lib.SpyOriginal = hookmetamethod(game, "__namecall", wrapC(OnNamecall))
		end

		task.spawn(function()
			local count = 0
			for _, inst in ipairs(game:GetDescendants()) do
				Track(inst)
				count = count + 1
				if count % 2500 == 0 then task.wait() end
			end
		end)
		Lib.C(game.DescendantAdded, Track)

		task.spawn(function()
			while UI.Screen.Parent do
				task.wait(2)
				if cfg.Incoming then
					for remote in pairs(functions) do WrapCallback(remote) end
				end
				HookActors()
			end
		end)

		Lib.C(Run.Heartbeat, function()
			local budget = 20
			while head <= tail and budget > 0 do
				local entry = queue[head]
				queue[head] = nil
				head = head + 1
				budget = budget - 1
				AddEntry(entry)
			end
			if tail - head > 500 then
				for i = head, head + 250 do queue[i] = nil end
				head = head + 251
			end
			if next(dirty) then
				for entry in pairs(dirty) do
					dirty[entry] = nil
					if entry.nameLabel then entry.nameLabel.Text = RowName(entry) end
					if entry == selected then ShowDetail(entry) end
				end
			end
		end)
	end

	local function Replay(entry)
		if not entry.remote or not entry.remote.Parent then
			Lib.Notify({ Title = "Remote Spy", Text = "Remote no longer exists" })
			return
		end
		local args = entry.args
		if entry.dir == "OUT" then
			task.spawn(function()
				pcall(entry.remote[entry.method], entry.remote, table.unpack(args, 1, args.n))
			end)
		elseif entry.key == "RemoteEvent" and type(firesignal) == "function" then
			pcall(firesignal, entry.remote.OnClientEvent, table.unpack(args, 1, args.n))
		else
			Lib.Notify({ Title = "Remote Spy", Text = "Incoming calls of this type cannot be replayed" })
		end
	end

	local function Build()
		window = Lib.CreateWindow({
			Name = "SeptusRemoteSpy", Title = "Remote Spy", Width = 700, Height = 420, Gear = true, OffsetX = -20, OffsetY = 10,
			OnVisibility = function(visible)
				if visible then
					for _, entry in ipairs(calls) do EnsureRow(entry) end
				end
				if Lib.RemoteSpyApi and Lib.RemoteSpyApi.OnVisibility then Lib.RemoteSpyApi.OnVisibility(visible) end
			end
		})
		local body = window.Body

		local toolbar = Lib.Create("Frame", { Size = UDim2.new(1, -16, 0, 30), Position = UDim2.fromOffset(8, 8), BackgroundTransparency = 1, Parent = body })
		searchBox = Lib.Create("TextBox", {
			Size = UDim2.new(1, -144, 1, 0), BackgroundColor3 = Color3.fromRGB(22, 22, 22), PlaceholderText = "Search by remote name or arguments...",
			PlaceholderColor3 = Color3.fromRGB(110, 110, 110), Text = "", TextColor3 = Color3.fromRGB(240, 240, 240), TextSize = 12, Font = Enum.Font.GothamMedium,
			ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left, Parent = toolbar,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
			Lib.Create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) })
		})
		Lib.RegisterThemeElement(searchBox, "BackgroundColor3", 0.7)
		Lib.RegisterThemeText(searchBox, "Primary")
		pauseBtn = Lib.MakeChip(toolbar, "Pause", UDim2.fromOffset(68, 30), UDim2.new(1, -136, 0, 0))
		local clearBtn = Lib.MakeChip(toolbar, "Clear", UDim2.fromOffset(62, 30), UDim2.new(1, -62, 0, 0))

		local left = Lib.Create("Frame", {
			Size = UDim2.new(0, 270, 1, -54), Position = UDim2.fromOffset(8, 46), BackgroundColor3 = Color3.fromRGB(18, 18, 18), Parent = body,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
		})
		Lib.RegisterThemeElement(left, "BackgroundColor3", 0.5)
		listScroll = Lib.Create("ScrollingFrame", {
			Size = UDim2.new(1, -6, 1, -8), Position = UDim2.fromOffset(3, 4), BackgroundTransparency = 1, ScrollBarThickness = 3,
			ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100), BorderSizePixel = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollingDirection = Enum.ScrollingDirection.Y, Parent = left
		})
		listLayout = Lib.Create("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = listScroll })
		listScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
			stick = listScroll.CanvasPosition.Y >= listScroll.AbsoluteCanvasSize.Y - listScroll.AbsoluteSize.Y - 10
		end)
		listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			if stick then listScroll.CanvasPosition = Vector2.new(0, 1e6) end
		end)

		local right = Lib.Create("Frame", {
			Size = UDim2.new(1, -294, 1, -54), Position = UDim2.fromOffset(286, 46), BackgroundColor3 = Color3.fromRGB(18, 18, 18), Parent = body,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
		})
		Lib.RegisterThemeElement(right, "BackgroundColor3", 0.5)
		detailScroll = Lib.Create("ScrollingFrame", {
			Size = UDim2.new(1, -8, 1, -82), Position = UDim2.fromOffset(4, 4), BackgroundTransparency = 1, ScrollBarThickness = 3,
			ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100), BorderSizePixel = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollingDirection = Enum.ScrollingDirection.Y, Parent = right,
			Lib.Create("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), PaddingTop = UDim.new(0, 4) })
		})
		detailText = Lib.Create("TextLabel", {
			Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Text = "", RichText = true, TextWrapped = true,
			TextColor3 = Color3.fromRGB(235, 235, 235), TextSize = 12, Font = Enum.Font.Code, TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top, Parent = detailScroll
		})
		Lib.RegisterThemeText(detailText, "Primary")

		spoofRow = Lib.Create("Frame", { Size = UDim2.new(1, -8, 0, 30), Position = UDim2.new(0, 4, 1, -74), BackgroundTransparency = 1, Visible = false, Parent = right })
		spoofBox = Lib.Create("TextBox", {
			Size = UDim2.new(1, -92, 1, 0), BackgroundColor3 = Color3.fromRGB(22, 22, 22), PlaceholderText = 'Spoofed return, e.g. true  or  "ok", 5',
			PlaceholderColor3 = Color3.fromRGB(110, 110, 110), Text = "", TextColor3 = Color3.fromRGB(240, 240, 240), TextSize = 12, Font = Enum.Font.Code,
			ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left, Parent = spoofRow,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
			Lib.Create("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) })
		})
		Lib.RegisterThemeElement(spoofBox, "BackgroundColor3", 0.7)
		Lib.RegisterThemeText(spoofBox, "Primary")
		spoofBtn = Lib.MakeChip(spoofRow, "Spoof: OFF", UDim2.fromOffset(84, 30), UDim2.new(1, -84, 0, 0))

		local actionBar = Lib.Create("Frame", {
			Size = UDim2.new(1, -8, 0, 32), Position = UDim2.new(0, 4, 1, -36), BackgroundTransparency = 1, Parent = right,
			Lib.Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder })
		})
		local function Action(text, order)
			local chip = Lib.MakeChip(actionBar, text, UDim2.new(0.25, -5, 1, 0), UDim2.new())
			chip.LayoutOrder = order
			return chip
		end
		local copyBtn, replayBtn, ignoreBtn, clearIgnoreBtn = Action("Copy Code", 1), Action("Replay", 2), Action("Ignore", 3), Action("Unignore All", 4)

		searchBox:GetPropertyChangedSignal("Text"):Connect(function()
			for _, entry in ipairs(calls) do entry.inline = nil end
			RefreshFilter()
		end)

		pauseBtn.MouseButton1Click:Connect(function()
			Lib.PlayClick()
			paused = not paused
			pauseBtn.Text = paused and "Resume" or "Pause"
		end)

		clearBtn.MouseButton1Click:Connect(function()
			Lib.PlayClick()
			for _, entry in ipairs(calls) do Drop(entry) end
			table.clear(calls)
			Select(nil, nil)
		end)

		copyBtn.MouseButton1Click:Connect(function()
			Lib.PlayClick()
			if not selected then return end
			if type(setclipboard) == "function" then
				setclipboard(GenerateCode(selected))
				Lib.Notify({ Title = "Remote Spy", Text = "Call code copied" })
			else
				Lib.Notify({ Title = "Remote Spy", Text = "Executor does not support clipboard" })
			end
		end)

		replayBtn.MouseButton1Click:Connect(function()
			Lib.PlayClick()
			if selected then Replay(selected) end
		end)

		ignoreBtn.MouseButton1Click:Connect(function()
			Lib.PlayClick()
			if not selected then return end
			local remote = selected.remote
			ignoredInst[remote] = true
			Select(nil, nil)
			RemoveRemote(remote)
			Lib.Notify({ Title = "Remote Spy", Text = "Ignoring " .. remote.Name })
		end)

		clearIgnoreBtn.MouseButton1Click:Connect(function()
			Lib.PlayClick()
			table.clear(ignoredInst)
			table.clear(ignoredName)
			Lib.Notify({ Title = "Remote Spy", Text = "Ignore list cleared" })
		end)

		spoofBtn.MouseButton1Click:Connect(function()
			Lib.PlayClick()
			if not selected or not IsFunction[selected.key] then return end
			local remote = selected.remote
			if spoofs[remote] then
				spoofs[remote] = nil
				spoofBtn.Text = "Spoof: OFF"
				return
			end
			local compiler = loadstring or load
			local fn = compiler and compiler("return " .. (spoofBox.Text ~= "" and spoofBox.Text or "nil"))
			if not fn then
				Lib.Notify({ Title = "Remote Spy", Text = "Spoof value is not valid Lua" })
				return
			end
			spoofs[remote] = { fn = fn, text = spoofBox.Text }
			spoofBtn.Text = "Spoof: ON"
		end)

		local settings = Lib.CreateOverlay(window)
		local typeGroup = Lib.CreateFeatureGroup(settings, "Remote Types", 1)
		Lib.CreateSettingToggleItem(typeGroup, "Spy RemoteEvent", "FireServer and OnClientEvent", cfg.RemoteEvent, function(val) cfg.RemoteEvent = val RefreshIncoming() end)
		Lib.CreateSettingToggleItem(typeGroup, "Spy RemoteFunction", "InvokeServer and OnClientInvoke", cfg.RemoteFunction, function(val) cfg.RemoteFunction = val RefreshIncoming() end)
		Lib.CreateSettingToggleItem(typeGroup, "Spy BindableEvent", "Fire and Event between client scripts", cfg.BindableEvent, function(val) cfg.BindableEvent = val RefreshIncoming() end)
		Lib.CreateSettingToggleItem(typeGroup, "Spy BindableFunction", "Invoke and OnInvoke between client scripts", cfg.BindableFunction, function(val) cfg.BindableFunction = val RefreshIncoming() end, true)
		local logGroup = Lib.CreateFeatureGroup(settings, "Logging", 2)
		Lib.CreateSettingToggleItem(logGroup, "Log Outgoing", "FireServer, InvokeServer, Fire and Invoke calls", cfg.Outgoing, function(val) cfg.Outgoing = val end)
		Lib.CreateSettingToggleItem(logGroup, "Log Incoming", "OnClientEvent, OnClientInvoke, Event and OnInvoke", cfg.Incoming, function(val)
			cfg.Incoming = val
			RefreshIncoming()
		end)
		Lib.CreateSettingToggleItem(logGroup, "Actor Support", actorSupported and "Hooks calls made inside Actors" or "Not supported by this executor", cfg.Actors, function(val)
			cfg.Actors = val
			HookActors()
		end)
		Lib.CreateSettingToggleItem(logGroup, "Call Tracing", "Stores the calling script and the call traceback", cfg.Tracing, function(val) cfg.Tracing = val end, true)
		local filterGroup = Lib.CreateFeatureGroup(settings, "Filters and Cleanup", 3)
		Lib.CreateSettingToggleItem(filterGroup, "Use Filters", "Enables search and the ignore list", cfg.Filters, function(val)
			cfg.Filters = val
			RefreshFilter()
		end)
		Lib.CreateSettingToggleItem(filterGroup, "Auto Clean Spam", "Merges looped and repeated calls into one entry", cfg.AutoClean, function(val) cfg.AutoClean = val end)
		Lib.CreateSettingToggleItem(filterGroup, "Spoof Returns", "Allows replacing return values of functions", cfg.Spoof, function(val) cfg.Spoof = val end)
		local ignoreRow = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 44), BackgroundTransparency = 1, Parent = filterGroup })
		local ignoreBox = Lib.Create("TextBox", {
			Size = UDim2.new(1, -28, 0, 30), Position = UDim2.fromOffset(14, 7), BackgroundColor3 = Color3.fromRGB(22, 22, 22),
			PlaceholderText = "Ignore names, comma separated", PlaceholderColor3 = Color3.fromRGB(110, 110, 110), Text = "", TextColor3 = Color3.fromRGB(240, 240, 240),
			TextSize = 12, Font = Enum.Font.GothamMedium, ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left, Parent = ignoreRow,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
			Lib.Create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) })
		})
		Lib.RegisterThemeElement(ignoreBox, "BackgroundColor3", 0.7)
		Lib.RegisterThemeText(ignoreBox, "Primary")
		ignoreBox.FocusLost:Connect(function()
			table.clear(ignoredName)
			for name in ignoreBox.Text:gmatch("[^,]+") do
				name = name:match("^%s*(.-)%s*$")
				if name ~= "" then ignoredName[name] = true end
			end
			for i = #calls, 1, -1 do
				local entry = calls[i]
				if ignoredName[entry.name] then
					Drop(entry)
					table.remove(calls, i)
				end
			end
		end)

		ShowDetail(nil)
		for _, entry in ipairs(calls) do EnsureRow(entry) end
	end

	local api = {}
	Lib.RemoteSpyApi = api
	function api.Toggle()
		InstallHooks()
		if not window then
			Build()
			window.Show()
			return
		end
		window.Toggle()
	end
	return api
end

function Lib.BuildMiscUtilities(scroll)
	local bunnyGroup = Lib.CreateFeatureGroup(scroll, "Bunny Hop", 3)
	Lib.BuildBunnyHop(bunnyGroup)

	local utilityGroup = Lib.CreateFeatureGroup(scroll, "Developer Utilities", 4)

	local function UtilityRow(title, desc, isLast, onClick)
		local row = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 50), BackgroundTransparency = 1, Parent = utilityGroup })
		Lib.SearchAdd(utilityGroup, row, title)
		local titleLabel = Lib.Create("TextLabel", {
			Size = UDim2.new(1, -110, 0, 20), Position = UDim2.new(0, 14, 0, 7), BackgroundTransparency = 1, Text = title,
			TextColor3 = Color3.fromRGB(240, 240, 240), TextSize = 13, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, Parent = row
		})
		Lib.RegisterThemeText(titleLabel, "Primary")
		local descLabel = Lib.Create("TextLabel", {
			Size = UDim2.new(1, -110, 0, 16), Position = UDim2.new(0, 14, 0, 26), BackgroundTransparency = 1, Text = desc,
			TextColor3 = Color3.fromRGB(130, 130, 130), TextSize = 11, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd, Parent = row
		})
		Lib.RegisterThemeText(descLabel, "Secondary")
		if not isLast then
			Lib.Create("Frame", { Size = UDim2.new(1, -28, 0, 1), Position = UDim2.new(0, 14, 1, -1), BackgroundColor3 = Color3.fromRGB(25, 25, 25), BorderSizePixel = 0, Parent = row })
		end
		local button = Lib.MakeChip(row, "Open", UDim2.fromOffset(68, 28), UDim2.new(1, -82, 0.5, -14))
		button.MouseButton1Click:Connect(function()
			Lib.PlayClick()
			onClick()
		end)
		return button
	end

	local console
	local consoleBtn
	consoleBtn = UtilityRow("Developer Console", "Warnings, errors and client memory in a separate window", false, function()
		if not console then
			console = Lib.BuildDevConsole()
			console.OnVisibility = function(visible) consoleBtn.Text = visible and "Close" or "Open" end
		end
		console.Toggle()
	end)

	local spy
	local spyBtn
	spyBtn = UtilityRow("Remote Spy", "Logs remotes and bindables with details, filters and spoofing", true, function()
		if not spy then
			spy = Lib.BuildRemoteSpy()
			spy.OnVisibility = function(visible) spyBtn.Text = visible and "Close" or "Open" end
		end
		spy.Toggle()
	end)
end

function Lib.BuildQoL(scroll)
	local UIS = Services.UserInputService
	local Run = Services.Run
	local Http = Services.HttpService
	local KEYBIND_FILE = "SeptusHub_Keybinds.json"
	local MACRO_FOLDER = "SeptusHub_Macros"
	local SAMPLE_INTERVAL = 1 / 30
	local MAX_DURATION = 300
	local WHITE, BLACK, RED = Color3.fromRGB(255, 255, 255), Color3.fromRGB(0, 0, 0), Color3.fromRGB(220, 50, 50)

	local Macro = { Frames = {}, Recording = false, Playing = false, Endless = false, Repeats = 1 }
	local statusLabel, recordBtn, playBtn
	local placeId, placeName = game.PlaceId, game.Name
	local placeCache = {}
	task.spawn(function()
		local market = game:GetService("MarketplaceService")
		local ok, info = pcall(market.GetProductInfo, market, placeId)
		if ok and type(info) == "table" and type(info.Name) == "string" then placeName = info.Name end
	end)
	local recordConn
	local playToken = 0
	local StopPlayback

	local function Round(value, power)
		return math.floor(value * power + 0.5) / power
	end

	local function SetStatus(text)
		if statusLabel then statusLabel.Text = text end
	end

	local function GetParts()
		local char = App.Player.Character
		if not char then return end
		local root, hum = char:FindFirstChild("HumanoidRootPart"), char:FindFirstChildOfClass("Humanoid")
		if root and hum then return root, hum end
	end

	local function Style(button, active)
		button.BackgroundColor3 = active and RED or WHITE
		button.TextColor3 = active and WHITE or BLACK
	end

	local function RefreshButtons()
		if not recordBtn then return end
		recordBtn.Text = Macro.Recording and "Stop" or "Record"
		playBtn.Text = Macro.Playing and "\u{25A0}" or "\u{25B6}"
		Style(recordBtn, Macro.Recording)
		Style(playBtn, Macro.Playing)
	end

	local function StopRecording(silent)
		if not Macro.Recording then return end
		Macro.Recording = false
		if recordConn then
			recordConn:Disconnect()
			recordConn = nil
		end
		local frames = Macro.Frames
		local duration = #frames > 0 and frames[#frames].t or 0
		SetStatus(string.format("Recorded %.1fs (%d frames)", duration, #frames))
		RefreshButtons()
		if not silent then
			Lib.Notify({ Title = "Macro Recorder", Text = string.format("Recording saved in memory (%.1fs)", duration) })
		end
	end

	local function StartRecording()
		local root, hum = GetParts()
		if not root then
			Lib.Notify({ Title = "Macro Recorder", Text = "Character not found" })
			return
		end
		StopPlayback(true)
		local frames = {}
		Macro.Frames = frames
		Macro.Recording = true
		RefreshButtons()
		local startClock, lastT = os.clock(), -SAMPLE_INTERVAL
		recordConn = Run.Heartbeat:Connect(function()
			local r, h = GetParts()
			if not r then return end
			local t = os.clock() - startClock
			if t - lastT < SAMPLE_INTERVAL then return end
			lastT = t
			local count = #frames + 1
			frames[count] = { t = t, cf = r.CFrame, md = h.MoveDirection, jump = h.Jump or h:GetState() == Enum.HumanoidStateType.Jumping }
			if count % 8 == 0 then SetStatus(string.format("Recording... %.1fs", t)) end
			if t >= MAX_DURATION then StopRecording() end
		end)
	end

	function StopPlayback(silent)
		if not Macro.Playing then return end
		Macro.Playing = false
		playToken = playToken + 1
		local _, hum = GetParts()
		if hum then hum:Move(Vector3.zero, false) end
		RefreshButtons()
		if not silent then SetStatus("Stopped") end
	end

	local function StartPlayback()
		local frames = Macro.Frames
		local count = #frames
		if count < 2 then
			Lib.Notify({ Title = "Macro Recorder", Text = "Nothing recorded yet" })
			return
		end
		if not GetParts() then
			Lib.Notify({ Title = "Macro Recorder", Text = "Character not found" })
			return
		end
		StopRecording(true)
		Macro.Playing = true
		playToken = playToken + 1
		local token = playToken
		RefreshButtons()
		task.spawn(function()
			local total = frames[count].t
			local loop = 0
			while playToken == token do
				loop = loop + 1
				SetStatus(Macro.Endless and ("Playing... loop " .. loop) or string.format("Playing... %d/%d", loop, Macro.Repeats))
				local index, elapsed = 1, 0
				while playToken == token and elapsed < total do
					elapsed = elapsed + Run.Heartbeat:Wait()
					local root, hum = GetParts()
					if not root then
						StopPlayback()
						return
					end
					while index < count - 1 and frames[index + 1].t <= elapsed do index = index + 1 end
					local a, b = frames[index], frames[index + 1]
					local span = b.t - a.t
					root.CFrame = a.cf:Lerp(b.cf, span > 0 and math.clamp((elapsed - a.t) / span, 0, 1) or 1)
					root.AssemblyLinearVelocity = Vector3.zero
					hum:Move(a.md, false)
					hum.Jump = a.jump
				end
				if not Macro.Endless and loop >= Macro.Repeats then break end
			end
			if playToken == token then
				StopPlayback(true)
				SetStatus("Finished")
			end
		end)
	end

	local function ToggleRecording()
		if Macro.Recording then StopRecording() else StartRecording() end
	end

	local function TogglePlayback()
		if Macro.Playing then StopPlayback() else StartPlayback() end
	end

	function Lib.StopMacro()
		StopRecording(true)
		StopPlayback(true)
	end

	local function SwitchAction(key)
		return function()
			local control = Lib.ToggleControls[key]
			if not control then return end
			control.Set(not control.Get())
			Lib.Notify({ Title = key, Text = control.Get() and "Enabled" or "Disabled" })
		end
	end

	local actions = {
		{ id = "ToggleMenu", title = "Toggle Menu", desc = "Show or hide the hub window", run = function() Lib.ToggleMenu() end },
		{ id = "Fly", title = "Toggle Fly", desc = "Turns flight on or off", run = SwitchAction("Fly") },
		{ id = "Noclip", title = "Toggle Noclip", desc = "Turns walking through walls on or off", run = SwitchAction("Noclip") },
		{ id = "Invisibility", title = "Toggle Invisibility", desc = "Turns the invisibility glitch on or off", run = SwitchAction("Invisibility") },
		{ id = "MacroRecord", title = "Macro Record", desc = "Starts or stops recording a macro", run = ToggleRecording },
		{ id = "MacroPlay", title = "Macro Play", desc = "Starts or stops macro playback", run = TogglePlayback }
	}

	local binds, chips, capturing = {}, {}, nil

	local function KeyLabel(id)
		return binds[id] and binds[id].Name or "None"
	end

	local function SaveBinds()
		if not writefile then return end
		local out = {}
		for id, key in pairs(binds) do out[id] = key.Name end
		pcall(writefile, KEYBIND_FILE, Http:JSONEncode(out))
	end

	if isfile and readfile then
		pcall(function()
			if not isfile(KEYBIND_FILE) then return end
			for id, name in pairs(Http:JSONDecode(readfile(KEYBIND_FILE))) do
				local key = Enum.KeyCode[name]
				if key then binds[id] = key end
			end
		end)
	end

	local function MakeRow(parent, title, desc, isLast, height, textWidth)
		local row = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, height or 50), BackgroundTransparency = 1, Parent = parent })
		local titleLabel = Lib.Create("TextLabel", {
			Size = UDim2.new(1, textWidth, 0, 20), Position = UDim2.new(0, 14, 0, 7), BackgroundTransparency = 1, Text = title,
			TextColor3 = Color3.fromRGB(240, 240, 240), TextSize = 13, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, Parent = row
		})
		Lib.RegisterThemeText(titleLabel, "Primary")
		local descLabel = Lib.Create("TextLabel", {
			Size = UDim2.new(1, textWidth, 0, 16), Position = UDim2.new(0, 14, 0, 26), BackgroundTransparency = 1, Text = desc,
			TextColor3 = Color3.fromRGB(130, 130, 130), TextSize = 11, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd, Parent = row
		})
		Lib.RegisterThemeText(descLabel, "Secondary")
		if not isLast then
			Lib.Create("Frame", { Size = UDim2.new(1, -28, 0, 1), Position = UDim2.new(0, 14, 1, -1), BackgroundColor3 = Color3.fromRGB(25, 25, 25), BorderSizePixel = 0, Parent = row })
		end
		return row, descLabel, titleLabel
	end

	local function MakeChip(parent, text, size, position)
		local chip = Lib.Create("TextButton", {
			Size = size, Position = position, BackgroundColor3 = Color3.fromRGB(22, 22, 22), Text = text, TextColor3 = Color3.fromRGB(240, 240, 240),
			TextSize = 12, Font = Enum.Font.GothamBold, AutoButtonColor = false, Parent = parent, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
		})
		Lib.RegisterThemeElement(chip, "BackgroundColor3", 0.7)
		Lib.RegisterThemeText(chip, "Primary")
		return chip
	end

	local KeybindGroup = Lib.CreateFeatureGroup(scroll, "Custom Keybinds", 1)
	for i, action in ipairs(actions) do
		local row = MakeRow(KeybindGroup, action.title, action.desc, i == #actions, 50, -130)
		local chip = MakeChip(row, KeyLabel(action.id), UDim2.fromOffset(92, 28), UDim2.new(1, -106, 0.5, -14))
		chips[action.id] = chip
		chip.MouseButton1Click:Connect(function()
			Lib.PlayClick()
			if capturing == action.id then
				capturing = nil
				chip.Text = KeyLabel(action.id)
				return
			end
			if capturing then chips[capturing].Text = KeyLabel(capturing) end
			capturing = action.id
			chip.Text = "Press key..."
		end)
	end

	local inputConn = Lib.C(UIS.InputBegan, function(input, processed)
		if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
		local key = input.KeyCode
		if capturing then
			local id = capturing
			capturing = nil
			if key == Enum.KeyCode.Escape then
				chips[id].Text = KeyLabel(id)
				return
			end
			if key == Enum.KeyCode.Backspace or key == Enum.KeyCode.Delete then
				binds[id] = nil
			else
				for otherId, otherKey in pairs(binds) do
					if otherKey == key and otherId ~= id then
						binds[otherId] = nil
						chips[otherId].Text = "None"
					end
				end
				binds[id] = key
			end
			chips[id].Text = KeyLabel(id)
			SaveBinds()
			return
		end
		if processed then return end
		for _, action in ipairs(actions) do
			if binds[action.id] == key then
				action.run()
				break
			end
		end
	end)

	UI.Screen.Destroying:Connect(function()
		inputConn:Disconnect()
		StopRecording(true)
		StopPlayback(true)
	end)

	local function EncodeFrames(frames)
		local rows = table.create(#frames)
		for i, f in ipairs(frames) do
			local pos = f.cf.Position
			local rx, ry, rz = f.cf:ToOrientation()
			rows[i] = { Round(f.t, 1000), Round(pos.X, 1000), Round(pos.Y, 1000), Round(pos.Z, 1000), Round(rx, 10000), Round(ry, 10000), Round(rz, 10000), Round(f.md.X, 1000), Round(f.md.Z, 1000), f.jump and 1 or 0 }
		end
		return string.format('{"pid":%d,"pn":"%s","v":2,"rows":%s}', placeId, (placeName:gsub('[%c"\\]', "")), Http:JSONEncode(rows))
	end

	local function DecodeFrames(raw)
		local ok, data = pcall(Http.JSONDecode, Http, raw)
		if not ok or type(data) ~= "table" or type(data.rows) ~= "table" then return end
		local frames = table.create(#data.rows)
		for i, r in ipairs(data.rows) do
			frames[i] = {
				t = r[1],
				cf = CFrame.new(r[2], r[3], r[4]) * CFrame.fromOrientation(r[5], r[6], r[7]),
				md = Vector3.new(r[8], 0, r[9]),
				jump = r[10] == 1
			}
		end
		if #frames > 1 then return frames end
	end

	local canSave = type(writefile) == "function" and type(readfile) == "function" and type(listfiles) == "function"
	if canSave then
		pcall(function()
			if makefolder and not isfolder(MACRO_FOLDER) then makefolder(MACRO_FOLDER) end
		end)
	end

	local MacroGroup = Lib.CreateFeatureGroup(scroll, "Macro Recorder", 2)
	local MainRow, statusDesc = MakeRow(MacroGroup, "Movement Macro", "Idle", true, 56, -200)
	statusLabel = statusDesc

	local SettingsBtn = MakeChip(MainRow, "", UDim2.fromOffset(30, 30), UDim2.new(1, -44, 0.5, -15))
	local gearIcon = Lib.Create("ImageLabel", {
		Size = UDim2.fromOffset(18, 18), Position = UDim2.new(0.5, -9, 0.5, -9), BackgroundTransparency = 1,
		Image = "rbxassetid://119430435918970", ScaleType = Enum.ScaleType.Fit, Parent = SettingsBtn
	})
	Lib.RegisterThemeImage(gearIcon)

	playBtn = Lib.Create("TextButton", {
		Size = UDim2.fromOffset(30, 30), Position = UDim2.new(1, -82, 0.5, -15), BackgroundColor3 = WHITE, Text = "\u{25B6}", TextColor3 = BLACK,
		TextSize = 12, Font = Enum.Font.GothamBold, Parent = MainRow, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
	})
	recordBtn = Lib.Create("TextButton", {
		Size = UDim2.fromOffset(64, 30), Position = UDim2.new(1, -152, 0.5, -15), BackgroundColor3 = WHITE, Text = "Record", TextColor3 = BLACK,
		TextSize = 12, Font = Enum.Font.GothamBold, Parent = MainRow, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
	})

	recordBtn.MouseButton1Click:Connect(function()
		Lib.PlayClick()
		ToggleRecording()
	end)
	playBtn.MouseButton1Click:Connect(function()
		Lib.PlayClick()
		TogglePlayback()
	end)

	local Backdrop = Lib.Create("TextButton", {
		Name = "MacroSettingsBackdrop", Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = BLACK, BackgroundTransparency = 1,
		Text = "", AutoButtonColor = false, Visible = false, ZIndex = 30, Parent = UI.Main
	})
	local Window = Lib.Create("Frame", {
		Size = UDim2.fromOffset(360, 400), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(16, 16, 16), ClipsDescendants = true, ZIndex = 31, Parent = Backdrop,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
		Lib.Create("UIStroke", { Color = Color3.fromRGB(40, 40, 40), Thickness = 1, Transparency = 0.4 })
	})
	Lib.RegisterThemeElement(Window, "BackgroundColor3", 0.5)

	local WindowTitle = Lib.Create("TextLabel", {
		Size = UDim2.new(1, -60, 0, 35), Position = UDim2.fromOffset(16, 8), BackgroundTransparency = 1, Text = "Macro Recorder Settings",
		TextColor3 = WHITE, TextSize = 15, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 32, Parent = Window
	})
	Lib.RegisterThemeText(WindowTitle, "Primary")

	local CloseBtn = Lib.Create("TextButton", {
		Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, -38, 0, 10), BackgroundColor3 = WHITE, Text = "×", TextColor3 = BLACK,
		TextSize = 16, Font = Enum.Font.GothamBold, ZIndex = 32, Parent = Window, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
	})

	local Content = Lib.Create("ScrollingFrame", {
		Size = UDim2.new(1, -24, 1, -55), Position = UDim2.fromOffset(12, 45), BackgroundTransparency = 1, ScrollBarThickness = 2,
		ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80), BorderSizePixel = 0, ZIndex = 32, Parent = Window
	})
	local ContentLayout = Lib.Create("UIListLayout", { Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Content })
	ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		Content.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 10)
	end)

	local modalOpen = false
	local function OpenModal()
		if modalOpen then return end
		modalOpen = true
		Window.Size = UDim2.fromOffset(320, 360)
		Lib.GlassOpen(Backdrop)
		Lib.Tween(Window, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Size = UDim2.fromOffset(360, 400) })
	end
	local function CloseModal()
		if not modalOpen then return end
		modalOpen = false
		Lib.Tween(Window, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In, { Size = UDim2.fromOffset(300, 340) })
		Lib.GlassClose(Backdrop, function()
			if not modalOpen then Backdrop.Visible = false end
		end)
	end

	SettingsBtn.MouseButton1Click:Connect(function()
		Lib.PlayClick()
		OpenModal()
	end)
	CloseBtn.MouseButton1Click:Connect(function()
		Lib.PlayClick()
		CloseModal()
	end)

	local PlaybackGroup = Lib.CreateFeatureGroup(Content, "Playback", 1)
	local RepeatBox

	local function RefreshRepeatBox()
		RepeatBox.TextEditable = not Macro.Endless
		RepeatBox.TextTransparency = Macro.Endless and 0.6 or 0
	end

	Lib.CreateSettingToggleItem(PlaybackGroup, "Endless repetition", "Replays the recording until you stop it", Macro.Endless, function(value)
		Macro.Endless = value
		RefreshRepeatBox()
	end)

	local RepeatRow = MakeRow(PlaybackGroup, "Number of repetitions", "How many times the recording replays", true, 50, -100)
	RepeatBox = Lib.Create("TextBox", {
		Size = UDim2.fromOffset(60, 28), Position = UDim2.new(1, -74, 0.5, -14), BackgroundColor3 = Color3.fromRGB(22, 22, 22), Text = tostring(Macro.Repeats),
		TextColor3 = Color3.fromRGB(240, 240, 240), TextSize = 12, Font = Enum.Font.GothamBold, ClearTextOnFocus = false, Parent = RepeatRow,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
	})
	Lib.RegisterThemeElement(RepeatBox, "BackgroundColor3", 0.7)
	Lib.RegisterThemeText(RepeatBox, "Primary")
	RepeatBox.FocusLost:Connect(function()
		Macro.Repeats = math.clamp(math.floor(tonumber(RepeatBox.Text) or 1), 1, 9999)
		RepeatBox.Text = tostring(Macro.Repeats)
	end)
	RefreshRepeatBox()

	local SavedGroup = Lib.CreateFeatureGroup(Content, "Saved Movements", 2)
	local SaveRow = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 50), BackgroundTransparency = 1, Parent = SavedGroup })
	local NameBox = Lib.Create("TextBox", {
		Size = UDim2.new(1, -112, 0, 32), Position = UDim2.new(0, 14, 0, 9), BackgroundColor3 = Color3.fromRGB(22, 22, 22), PlaceholderText = "Macro name...",
		PlaceholderColor3 = Color3.fromRGB(110, 110, 110), Text = "", TextColor3 = Color3.fromRGB(240, 240, 240), TextSize = 12, Font = Enum.Font.GothamMedium,
		ClearTextOnFocus = false, Parent = SaveRow,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
		Lib.Create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) })
	})
	Lib.RegisterThemeElement(NameBox, "BackgroundColor3", 0.7)
	Lib.RegisterThemeText(NameBox, "Primary")
	local SaveBtn = Lib.Create("TextButton", {
		Size = UDim2.fromOffset(76, 32), Position = UDim2.new(1, -90, 0, 9), BackgroundColor3 = WHITE, Text = "Save", TextColor3 = BLACK,
		TextSize = 12, Font = Enum.Font.GothamBold, Parent = SaveRow, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
	})

	local SavedList = Lib.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = SavedGroup,
		Lib.Create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
		Lib.Create("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingBottom = UDim.new(0, 10) })
	})

	local function MacroPath(name)
		return MACRO_FOLDER .. "/" .. name .. ".json"
	end

	local function RebuildSaved()
		for _, child in ipairs(SavedList:GetChildren()) do
			if child:IsA("GuiObject") then child:Destroy() end
		end
		if not canSave then
			local note = Lib.Create("TextLabel", {
				Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Text = "Your executor does not support file saving",
				TextColor3 = Color3.fromRGB(130, 130, 130), TextSize = 11, Font = Enum.Font.GothamMedium, Parent = SavedList
			})
			Lib.RegisterThemeText(note, "Secondary")
			return
		end
		local files = {}
		pcall(function() files = listfiles(MACRO_FOLDER) end)
		local names = {}
		for _, path in ipairs(files) do
			local name = path:match("([^/\\]+)%.json$")
			if name then names[#names + 1] = name end
		end
		table.sort(names)
		if #names == 0 then
			local note = Lib.Create("TextLabel", {
				Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Text = "No saved movements yet",
				TextColor3 = Color3.fromRGB(130, 130, 130), TextSize = 11, Font = Enum.Font.GothamMedium, Parent = SavedList
			})
			Lib.RegisterThemeText(note, "Secondary")
			return
		end
		for i, name in ipairs(names) do
			local item = Lib.Create("Frame", {
				Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = Color3.fromRGB(22, 22, 22), LayoutOrder = i, Parent = SavedList,
				Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
			})
			Lib.RegisterThemeElement(item, "BackgroundColor3", 0.7)
			local nameLabel = Lib.Create("TextLabel", {
				Size = UDim2.new(1, -130, 0, 20), Position = UDim2.new(0, 12, 0, 5), BackgroundTransparency = 1, Text = name,
				TextColor3 = Color3.fromRGB(240, 240, 240), TextSize = 12, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd, Parent = item
			})
			Lib.RegisterThemeText(nameLabel, "Primary")
			local placeLabel = Lib.Create("TextLabel", {
				Size = UDim2.new(1, -130, 0, 14), Position = UDim2.new(0, 12, 0, 26), BackgroundTransparency = 1, Text = "Place: ...",
				TextColor3 = Color3.fromRGB(130, 130, 130), TextSize = 10, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd, Parent = item
			})
			local function ShowPlace(info)
				if not placeLabel.Parent then return end
				if info.pid then
					placeLabel.Text = string.format("Place: %s (%d)", info.pn ~= "" and info.pn or "Unknown", info.pid)
					placeLabel.TextColor3 = info.pid == placeId and Color3.fromRGB(46, 213, 115) or Color3.fromRGB(235, 170, 60)
				else
					placeLabel.Text = "Place: unknown (saved before place tracking)"
				end
			end
			if placeCache[name] then
				ShowPlace(placeCache[name])
			else
				task.spawn(function()
					local ok, raw = pcall(readfile, MacroPath(name))
					local head = ok and type(raw) == "string" and raw:sub(1, 400) or ""
					local info = { pid = tonumber(head:match('"pid":(%d+)')), pn = head:match('"pn":"(.-)"') or "" }
					placeCache[name] = info
					ShowPlace(info)
				end)
			end
			local loadBtn = Lib.Create("TextButton", {
				Size = UDim2.fromOffset(54, 26), Position = UDim2.new(1, -92, 0.5, -13), BackgroundColor3 = WHITE, Text = "Load", TextColor3 = BLACK,
				TextSize = 11, Font = Enum.Font.GothamBold, Parent = item, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
			})
			local deleteBtn = Lib.Create("TextButton", {
				Size = UDim2.fromOffset(26, 26), Position = UDim2.new(1, -34, 0.5, -13), BackgroundColor3 = RED, Text = "×", TextColor3 = WHITE,
				TextSize = 14, Font = Enum.Font.GothamBold, Parent = item, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
			})
			loadBtn.MouseButton1Click:Connect(function()
				Lib.PlayClick()
				local ok, raw = pcall(readfile, MacroPath(name))
				local frames = ok and DecodeFrames(raw)
				if not frames then
					Lib.Notify({ Title = "Macro Recorder", Text = "Failed to load \"" .. name .. "\"" })
					return
				end
				StopRecording(true)
				StopPlayback(true)
				Macro.Frames = frames
				SetStatus(string.format("Loaded \"%s\" (%.1fs)", name, frames[#frames].t))
				Lib.Notify({ Title = "Macro Recorder", Text = "Loaded \"" .. name .. "\"" })
				local info = placeCache[name]
				if info and info.pid and info.pid ~= placeId then
					Lib.Notify({ Title = "Macro Recorder", Text = "Recorded in another place: " .. (info.pn ~= "" and info.pn or tostring(info.pid)) })
				end
			end)
			deleteBtn.MouseButton1Click:Connect(function()
				Lib.PlayClick()
				if type(delfile) == "function" then pcall(delfile, MacroPath(name)) end
				placeCache[name] = nil
				RebuildSaved()
			end)
		end
	end

	SaveBtn.MouseButton1Click:Connect(function()
		Lib.PlayClick()
		if not canSave then
			Lib.Notify({ Title = "Macro Recorder", Text = "Your executor does not support file saving" })
			return
		end
		if #Macro.Frames < 2 then
			Lib.Notify({ Title = "Macro Recorder", Text = "Record a movement first" })
			return
		end
		local name = NameBox.Text:gsub("[^%w%-_ ]", ""):match("^%s*(.-)%s*$")
		if name == "" then name = "Macro " .. os.date("%H-%M-%S") end
		local ok = pcall(writefile, MacroPath(name), EncodeFrames(Macro.Frames))
		Lib.Notify({ Title = "Macro Recorder", Text = ok and ("Saved \"" .. name .. "\"") or "Failed to write the file" })
		if ok then
			placeCache[name] = nil
			NameBox.Text = ""
			RebuildSaved()
		end
	end)

	RebuildSaved()
end

do
	local FeaturesSection = Lib.Create("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, Parent = UI.ContentArea })
	UI.FeaturesSection = FeaturesSection

	local FeatTitle = Lib.Create("TextLabel", { Size = UDim2.new(1, -30, 0, 30), Position = UDim2.new(0, 20, 0, 10), BackgroundTransparency = 1, Text = "Features", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 20, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left })
	Lib.RegisterThemeText(FeatTitle, "Primary")

	local FeatSub = Lib.Create("TextLabel", { Size = UDim2.new(1, -30, 0, 20), AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 15, 1, -15), BackgroundTransparency = 1, Text = "Visuals & Utilities", TextColor3 = Color3.fromRGB(100, 100, 100), TextSize = 11, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left })
	Lib.RegisterThemeText(FeatSub, "Secondary")

	local FeaturesSideBar = Lib.Create("Frame", { Size = UDim2.new(0, 180, 1, 0), BackgroundTransparency = 1, Parent = FeaturesSection, FeatTitle, FeatSub })

	local FeaturesTabs = Lib.Create("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, -122), Position = UDim2.fromOffset(0, 80), BackgroundTransparency = 1, BorderSizePixel = 0,
		ScrollBarThickness = 2, ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100), ScrollingDirection = Enum.ScrollingDirection.Y,
		CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = FeaturesSideBar,
		Lib.Create("UIPadding", { PaddingBottom = UDim.new(0, 6) })
	})

	local MakeFeaturesTab
	Lib.SwitchFeaturesTab, MakeFeaturesTab = Lib.CreateTabSystem(FeaturesSection, FeaturesTabs, "CurrentFeaturesTab")

	local View_Visuals = MakeFeaturesTab("Visuals", 4)
	local View_Movement = MakeFeaturesTab("Movement", 44)
	local View_Protect = MakeFeaturesTab("Protect", 84)
	local View_Shaders = MakeFeaturesTab("Shaders", 124)
	local View_Funny = MakeFeaturesTab("Funny", 164)
	local View_Misc = MakeFeaturesTab("Misc", 204)
	local View_Server = MakeFeaturesTab("Server", 244)
	local View_Teleport = MakeFeaturesTab("Teleport", 284)

	local function MakeScroll(view)
		local scr = Lib.Create("ScrollingFrame", {
			Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1, ScrollBarThickness = 2,
			ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100), BorderSizePixel = 0,
			Parent = view
		})
		Lib.SearchScrolls[scr] = true
		local lyt = Lib.Create("UIListLayout", { Padding = UDim.new(0, 14), SortOrder = Enum.SortOrder.LayoutOrder, Parent = scr })
		Lib.Create("UIPadding", { PaddingTop = UDim.new(0, 5), PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 15), Parent = scr })

		lyt:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			scr.CanvasSize = UDim2.new(0, 0, 0, lyt.AbsoluteContentSize.Y + 20)
		end)
		return scr
	end

	local VisualsScroll = MakeScroll(View_Visuals)
	local MovementScroll = MakeScroll(View_Movement)
	local ProtectScroll = MakeScroll(View_Protect)
	local ShadersScroll = MakeScroll(View_Shaders)
	local FunnyScroll = MakeScroll(View_Funny)
	local MiscScroll = MakeScroll(View_Misc)
	local ServerScroll = MakeScroll(View_Server)
	local TeleportScroll = MakeScroll(View_Teleport)

	do
		local QoLView = MakeFeaturesTab("QoL", 324)
		Lib.BuildQoL(MakeScroll(QoLView))
	end

	do
		local CombatView = MakeFeaturesTab("Combat", 364)
		Lib.BuildCombat(MakeScroll(CombatView))
	end

	Lib.BuildFeatureSearch(FeaturesSection, FeaturesSideBar, FeaturesTabs)

	local ESPGroup = Lib.CreateFeatureGroup(VisualsScroll, "ESP", 1)
	Lib.CreateSettingToggleItem(ESPGroup, "Esp Name", "Display player display names with studs distance", State.ESP_Name, function(val) State.ESP_Name = val end)
	Lib.CreateSettingToggleItem(ESPGroup, "ESP Outline", "Highlight player character models through obstacles", State.ESP_Outline, function(val) State.ESP_Outline = val end)
	Lib.CreateSettingToggleItem(ESPGroup, "Box ESP", "Draw 2D bounding boxes around players", State.ESP_Box, function(val) State.ESP_Box = val end)
	Lib.CreateSettingToggleItem(ESPGroup, "Tracers", "Draw lines connecting screen bottom to players", State.ESP_Tracers, function(val) State.ESP_Tracers = val end, true)

	local BoostGroup = Lib.CreateFeatureGroup(VisualsScroll, "Boost FPS & World", 2)
	Lib.CreateSettingToggleItem(BoostGroup, "Boost FPS", "Very strong texture compression & maximum performance boost", State.BoostFPS, function(val)
		State.BoostFPS = val
		if val then Lib.ApplyBoostFPS() else Lib.RevertBoostFPS() end
	end)
	Lib.CreateSettingToggleItem(BoostGroup, "FullBright", "Disable darkness, shadows and set maximum ambient brightness", State.FullBright, function(val)
		State.FullBright = val
		Refs.LightFB = val and {
			Brightness = 2,
			ClockTime = 14,
			FogEnd = 100000,
			GlobalShadows = false,
			OutdoorAmbient = Color3.fromRGB(128, 128, 128)
		} or nil
		Lib.SyncLighting()
	end)
	Lib.CreateSettingToggleItem(BoostGroup, "Remove Texture", "Gives a tool to remove textures & decals from hovered parts", State.Tool_RemoveTexture, function(val)
		State.Tool_RemoveTexture = val
		if val then Refs.Tools.RemoveTextureTool.Parent = App.Player.Backpack else pcall(function() Refs.Tools.RemoveTextureTool.Parent = nil end) end
	end)
	Lib.CreateSettingToggleItem(BoostGroup, "Part Deleted", "Gives a tool with red hover highlight to destroy any clicked part locally", State.Tool_PartDeleted, function(val)
		State.Tool_PartDeleted = val
		if val then Refs.Tools.PartDeletedTool.Parent = App.Player.Backpack else pcall(function() Refs.Tools.PartDeletedTool.Parent = nil end) end
	end, true)

	local MoveCharGroup = Lib.CreateFeatureGroup(MovementScroll, "Character Speed & Jump", 1)
	Lib.CreateSettingSliderItem(MoveCharGroup, "Walk Speed", "Adjust character movement speed", 16, 300, State.WalkSpeed, function(val)
		State.WalkSpeed = val
		local char = App.Player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum and not State.FakeLagSuspension then hum.WalkSpeed = val end
	end)
	Lib.CreateSettingSliderItem(MoveCharGroup, "Jump Power", "Adjust jump power height", 50, 350, State.JumpPower, function(val)
		State.JumpPower = val
		local char = App.Player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.UseJumpPower = true
			hum.JumpPower = val
		end
	end, true)

	local FlyGroup = Lib.CreateFeatureGroup(MovementScroll, "Flight System", 2)
	Lib.CreateSettingToggleItem(FlyGroup, "Fly", "Free 3D flight (WASD & Mobile Joystick)", State.Fly, function(val)
		State.Fly = val
		Lib.UpdateFly(val)
	end)
	Lib.CreateSettingToggleItem(FlyGroup, "Prevent Seating in Flight", "Disables auto-sitting on chairs/cars while flying", State.FlyAntiSit, function(val)
		State.FlyAntiSit = val
	end)
	Lib.CreateSettingSliderItem(FlyGroup, "Fly Speed", "Adjust flight speed velocity", 10, 300, State.FlySpeed, function(val)
		State.FlySpeed = val
	end, true)

	local ProtectGroup = Lib.CreateFeatureGroup(ProtectScroll, "Character Defense", 1)
	Lib.CreateSettingToggleItem(ProtectGroup, "Anti Fling", "Protects you from high-velocity player collisions & flinging", State.AntiFling, function(val) State.AntiFling = val end)
	Lib.CreateSettingToggleItem(ProtectGroup, "Anti Sit", "Prevents your character from forcibly sitting down or getting seated", State.AntiSit, function(val)
		State.AntiSit = val
		if not val and App.Player.Character and App.Player.Character:FindFirstChildOfClass("Humanoid") then
			App.Player.Character:FindFirstChildOfClass("Humanoid"):SetStateEnabled(Enum.HumanoidStateType.Seated, true)
		end
	end)
	Lib.CreateSettingToggleItem(ProtectGroup, "Anti Void", "Automatically saves and teleports you back when falling into void", State.AntiVoid, function(val)
		State.AntiVoid = val
		if val and App.Player.Character and App.Player.Character:FindFirstChild("HumanoidRootPart") then
			Refs.LastSafeCF = App.Player.Character.HumanoidRootPart.CFrame
		end
	end)
	Lib.CreateSettingToggleItem(ProtectGroup, "Anti Stun", "Disables freeze/stun platform states and keeps control active", State.AntiStun, function(val) State.AntiStun = val end)
	Lib.CreateSettingToggleItem(ProtectGroup, "Anti Ragdoll", "Prevents joints breaking, ragdoll tripping and physics lock", State.AntiRagdoll, function(val)
		State.AntiRagdoll = val
		if not val and App.Player.Character and App.Player.Character:FindFirstChildOfClass("Humanoid") then
			local hum = App.Player.Character:FindFirstChildOfClass("Humanoid")
			hum:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
			hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
			hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
		end
	end, true)

	local ShadersGroup = Lib.CreateFeatureGroup(ShadersScroll, "Post-Processing & Atmosphere", 1)
	Lib.CreateSettingToggleItem(ShadersGroup, "RTX Realistic", "Dynamic sun rays, realistic soft bloom, atmosphere scattering & rich HDR", State.Shader_RTX, function(val)
		State.Shader_RTX = val
		if val then Lib.ApplyRTXShader() else Lib.ResetShaders() end
	end)
	Lib.CreateSettingToggleItem(ShadersGroup, "Cyberpunk Neon", "Midnight atmosphere, hyper-saturated neon glow & violet-cyan tone", State.Shader_Cyberpunk, function(val)
		State.Shader_Cyberpunk = val
		if val then Lib.ApplyCyberpunkShader() else Lib.ResetShaders() end
	end)
	Lib.CreateSettingToggleItem(ShadersGroup, "Silent Hill Fog", "Heavy, dense fog, low visibility & desaturated horror atmosphere", State.Shader_SilentHill, function(val)
		State.Shader_SilentHill = val
		if val then Lib.ApplySilentHillShader() else Lib.ResetShaders() end
	end, true)

	local function OpenPlayerPickerModal(title, onSelectPlayer)
		local backdrop = Lib.Create("TextButton", {
			Name = "PlayerPickerModalBackdrop",
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 40,
			Parent = UI.Main
		})

		local window = Lib.Create("Frame", {
			Size = UDim2.fromOffset(360, 360),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(16, 16, 16),
			ClipsDescendants = true,
			ZIndex = 41,
			Parent = backdrop,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
			Lib.Create("UIStroke", { Color = Color3.fromRGB(40, 40, 40), Thickness = 1, Transparency = 0.4 })
		})
		Lib.RegisterThemeElement(window, "BackgroundColor3", 0.5)

		local wTitle = Lib.Create("TextLabel", {
			Size = UDim2.new(1, -60, 0, 35),
			Position = UDim2.fromOffset(16, 8),
			BackgroundTransparency = 1,
			Text = title,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 15,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 42,
			Parent = window
		})
		Lib.RegisterThemeText(wTitle, "Primary")

		local closeBtn = Lib.Create("TextButton", {
			Size = UDim2.fromOffset(28, 28),
			Position = UDim2.new(1, -38, 0, 10),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Text = "×",
			TextColor3 = Color3.fromRGB(0, 0, 0),
			TextSize = 16,
			Font = Enum.Font.GothamBold,
			ZIndex = 42,
			Parent = window,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
		})

		local scroll = Lib.Create("ScrollingFrame", {
			Size = UDim2.new(1, -24, 1, -55),
			Position = UDim2.fromOffset(12, 45),
			BackgroundTransparency = 1,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80),
			BorderSizePixel = 0,
			ZIndex = 42,
			Parent = window
		})

		local layout = Lib.Create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = scroll })
		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
		end)

		local closed = false
		local function CloseModal()
			if closed then return end
			closed = true
			Lib.Tween(window, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In, { Size = UDim2.fromOffset(320, 320) })
			Lib.GlassClose(backdrop, function() backdrop:Destroy() end)
		end

		closeBtn.MouseButton1Click:Connect(function()
			Lib.PlayClick()
			CloseModal()
		end)

		for _, p in ipairs(Services.Players:GetPlayers()) do
			if p ~= App.Player then
				local pBtn = Lib.Create("TextButton", {
					Size = UDim2.new(1, 0, 0, 44),
					BackgroundColor3 = Color3.fromRGB(22, 22, 22),
					Text = "",
					AutoButtonColor = false,
					ZIndex = 43,
					Parent = scroll,
					Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
				})
				Lib.RegisterThemeElement(pBtn, "BackgroundColor3", 0.7)

				Lib.Create("ImageLabel", {
					Size = UDim2.fromOffset(32, 32),
					Position = UDim2.new(0, 8, 0.5, -16),
					BackgroundTransparency = 1,
					Image = "rbxthumb://type=AvatarHeadShot&id=" .. p.UserId .. "&w=100&h=100",
					ZIndex = 44,
					Parent = pBtn,
					Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) })
				})

				local nameLbl = Lib.Create("TextLabel", {
					Size = UDim2.new(1, -50, 0, 18),
					Position = UDim2.new(0, 48, 0, 6),
					BackgroundTransparency = 1,
					Text = p.DisplayName,
					TextColor3 = Color3.fromRGB(240, 240, 240),
					TextSize = 12,
					Font = Enum.Font.GothamBold,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 44,
					Parent = pBtn
				})
				Lib.RegisterThemeText(nameLbl, "Primary")

				local subLbl = Lib.Create("TextLabel", {
					Size = UDim2.new(1, -50, 0, 14),
					Position = UDim2.new(0, 48, 0, 24),
					BackgroundTransparency = 1,
					Text = "@" .. p.Name,
					TextColor3 = Color3.fromRGB(130, 130, 130),
					TextSize = 10,
					Font = Enum.Font.Gotham,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 44,
					Parent = pBtn
				})
				Lib.RegisterThemeText(subLbl, "Secondary")

				pBtn.MouseButton1Click:Connect(function()
					Lib.PlayClick()
					onSelectPlayer(p)
					CloseModal()
				end)
			end
		end

		window.Size = UDim2.fromOffset(320, 320)
		Lib.GlassOpen(backdrop)
		Lib.Tween(window, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Size = UDim2.fromOffset(360, 360) })
	end

	local StalkGroup = Lib.CreateFeatureGroup(FunnyScroll, "Stalk Mode", 1)
	local StalkPlayerBtn = Lib.CreateSettingButtonItem(StalkGroup, "Target: None", "Click to select player to stalk", function(titleLbl)
		OpenPlayerPickerModal("Select Stalk Target", function(p)
			State.StalkTarget = p
			titleLbl.Text = "Target: " .. p.DisplayName
		end)
	end)

	local function UpdateStalk()
		if Refs.StalkConn then Refs.StalkConn:Disconnect() Refs.StalkConn = nil end
		if not State.StalkActive or not State.StalkTarget then
			if App.Player.Character and App.Player.Character:FindFirstChildOfClass("Humanoid") then
				App.Camera.CameraSubject = App.Player.Character:FindFirstChildOfClass("Humanoid")
			end
			return
		end

		Refs.StalkConn = Services.Run.RenderStepped:Connect(function()
			if not State.StalkActive or not State.StalkTarget or not State.StalkTarget.Character then return end
			local targetRoot = State.StalkTarget.Character:FindFirstChild("HumanoidRootPart")
			local myChar = App.Player.Character
			local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

			if targetRoot and myRoot then
				myRoot.CFrame = targetRoot.CFrame * CFrame.new(State.StalkOffsetX, State.StalkOffsetY, State.StalkOffsetZ)
				myRoot.Anchored = State.StalkDisableMovement

				local targetHum = State.StalkTarget.Character:FindFirstChildOfClass("Humanoid")
				if targetHum then App.Camera.CameraSubject = targetHum end
			end
		end)
	end

	Lib.CreateSettingToggleItem(StalkGroup, "Stalk Active", "Locks your position relative to the target player", State.StalkActive, function(val)
		State.StalkActive = val
		UpdateStalk()
	end)
	Lib.CreateSettingSliderItem(StalkGroup, "Offset X", "Adjust horizontal lateral stalk offset", -30, 30, State.StalkOffsetX, function(val) State.StalkOffsetX = val end)
	Lib.CreateSettingSliderItem(StalkGroup, "Offset Y", "Adjust vertical stalk offset height", -30, 30, State.StalkOffsetY, function(val) State.StalkOffsetY = val end)
	Lib.CreateSettingSliderItem(StalkGroup, "Offset Z", "Adjust forward/backward distance behind target", -30, 30, State.StalkOffsetZ, function(val) State.StalkOffsetZ = val end)
	Lib.CreateSettingToggleItem(StalkGroup, "Disable Movement", "Locks character anchoring in place while stalking", State.StalkDisableMovement, function(val) State.StalkDisableMovement = val end, true)

	local FakeLagGroup = Lib.CreateFeatureGroup(FunnyScroll, "Fake Lag", 2)
	Lib.CreateSettingToggleItem(FakeLagGroup, "Complete Suspension", "Drops character movement to appear frozen to others", State.FakeLagSuspension, function(val)
		State.FakeLagSuspension = val
		local hum = App.Player.Character and App.Player.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = val and 0.5 or State.WalkSpeed end
	end)
	Lib.CreateSettingToggleItem(FakeLagGroup, "Usual Lag", "Simulates realistic high ping latency and movement stutters", State.FakeLagUsual, function(val)
		State.FakeLagUsual = val
		if not val and App.Player.Character and App.Player.Character:FindFirstChild("HumanoidRootPart") then
			App.Player.Character.HumanoidRootPart.Anchored = false
		end
	end, true)

	task.spawn(function()
		while not State.Unloaded do
			task.wait(math.random(1, 3))
			if State.FakeLagUsual and App.Player.Character and App.Player.Character:FindFirstChild("HumanoidRootPart") then
				App.Player.Character.HumanoidRootPart.Anchored = true
				task.wait(math.random(1, 2) * 0.4)
				if State.FakeLagUsual and App.Player.Character and App.Player.Character:FindFirstChild("HumanoidRootPart") then
					App.Player.Character.HumanoidRootPart.Anchored = false
				end
			end
		end
	end)

	local FlingGroup = Lib.CreateFeatureGroup(FunnyScroll, "Fling Target", 3)
	Lib.CreateSettingButtonItem(FlingGroup, "Select Target", "Choose player to fling", function(titleLbl)
		OpenPlayerPickerModal("Select Fling Target", function(p)
			State.FlingTarget = p
			titleLbl.Text = "Target: " .. p.DisplayName
		end)
	end)
	Lib.CreateSettingButtonItem(FlingGroup, "Execute Fling", "Applies high-speed rotational thrust against target", function(titleLbl)
		if not State.FlingTarget or not State.FlingTarget.Character or State.IsFlinging then return end
		local myChar = App.Player.Character
		local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
		if not myRoot then return end

		State.IsFlinging = true
		Lib.Notify({ Title = "Fling", Text = "Applying fling on " .. State.FlingTarget.DisplayName })
		local oldPos = myRoot.CFrame
		local bv = Instance.new("BodyAngularVelocity", myRoot)
		bv.AngularVelocity = Vector3.new(0, 99999, 0)
		bv.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
		bv.P = math.huge
		local bt = Instance.new("BodyThrust", myRoot)
		bt.Force = Vector3.new(9999, 9999, 9999)
		if myChar:FindFirstChildOfClass("Humanoid") then myChar:FindFirstChildOfClass("Humanoid").Sit = true end

		local fTime = 0
		local conn
		conn = Services.Run.Stepped:Connect(function(_, dt)
			fTime = fTime + dt
			if fTime > 2.5 or not State.FlingTarget or not State.FlingTarget.Character or not State.FlingTarget.Character:FindFirstChild("HumanoidRootPart") then
				if bv then bv:Destroy() end
				if bt then bt:Destroy() end
				myRoot.AssemblyLinearVelocity = Vector3.zero
				myRoot.AssemblyAngularVelocity = Vector3.zero
				myRoot.CFrame = oldPos
				if myChar:FindFirstChildOfClass("Humanoid") then myChar:FindFirstChildOfClass("Humanoid").Sit = false end
				State.IsFlinging = false
				conn:Disconnect()
				return
			end
			myRoot.CFrame = State.FlingTarget.Character.HumanoidRootPart.CFrame
		end)
	end, true)

	local BringGroup = Lib.CreateFeatureGroup(FunnyScroll, "Bring Parts", 4)
	Lib.CreateSettingButtonItem(BringGroup, "Select Target", "Choose player to bring unanchored parts to", function(titleLbl)
		OpenPlayerPickerModal("Select Bring Target", function(p)
			State.BringTarget = p
			titleLbl.Text = "Target: " .. p.DisplayName
		end)
	end)
	Refs.BringObjs = {}

	function Lib.StopBring()
		State.IsBringing = false
		if Refs.BringConn then Refs.BringConn:Disconnect() Refs.BringConn = nil end
		if Refs.DescConn then Refs.DescConn:Disconnect() Refs.DescConn = nil end
		if Refs.BringFolder then Refs.BringFolder:Destroy() Refs.BringFolder = nil end
		local objs = Refs.BringObjs
		for i = 1, #objs do objs[i]:Destroy() end
		table.clear(objs)
	end

	Lib.CreateSettingButtonItem(BringGroup, "Toggle Bring Parts", "Attaches physics parts to target", function(titleLbl)
		if State.IsBringing then
			Lib.StopBring()
			Lib.Notify({ Title = "Bring Parts", Text = "Stopped bringing parts" })
			return
		end

		if not State.BringTarget or not State.BringTarget.Character then return end
		State.IsBringing = true
		Lib.Notify({ Title = "Bring Parts", Text = "Bringing physics objects to " .. State.BringTarget.DisplayName })

		Refs.BringFolder = Instance.new("Folder", workspace)
		local attPart = Instance.new("Part", Refs.BringFolder)
		attPart.Anchored = true
		attPart.CanCollide = false
		attPart.Transparency = 1
		local Attachment1 = Instance.new("Attachment", attPart)

		local function ForcePart(v)
			if v:IsA("BasePart") and not v.Anchored and not v.Parent:FindFirstChildOfClass("Humanoid") and not v.Parent:FindFirstChild("Head") and v.Name ~= "Handle" then
				for _, x in ipairs(v:GetChildren()) do
					if x:IsA("BodyMover") or x:IsA("RocketPropulsion") then x:Destroy() end
				end
				v.CanCollide = false
				local Torque = Instance.new("Torque", v)
				Torque.Torque = Vector3.new(100000, 100000, 100000)
				local AlignPos = Instance.new("AlignPosition", v)
				local Attachment2 = Instance.new("Attachment", v)
				Torque.Attachment0 = Attachment2
				AlignPos.MaxForce = math.huge
				AlignPos.MaxVelocity = math.huge
				AlignPos.Responsiveness = 200
				AlignPos.Attachment0 = Attachment2
				AlignPos.Attachment1 = Attachment1
				local objs = Refs.BringObjs
				local n = #objs
				objs[n + 1], objs[n + 2], objs[n + 3] = Torque, AlignPos, Attachment2
			end
		end

		for _, v in ipairs(workspace:GetDescendants()) do ForcePart(v) end
		Refs.DescConn = workspace.DescendantAdded:Connect(ForcePart)

		Refs.BringConn = Services.Run.RenderStepped:Connect(function()
			if not State.IsBringing or not State.BringTarget or not State.BringTarget.Character then
				Lib.StopBring()
				return
			end
			local hrp = State.BringTarget.Character:FindFirstChild("HumanoidRootPart")
			if hrp then Attachment1.WorldCFrame = hrp.CFrame end
		end)
	end, true)

	local MiscPlayerGroup = Lib.CreateFeatureGroup(MiscScroll, "Player & Movement", 1)
	Lib.CreateSettingToggleItem(MiscPlayerGroup, "Anti-AFK", "Prevents Roblox 20-minute idle disconnect", State.AntiAFK, function(val)
		State.AntiAFK = val
		Lib.SetAntiAFKStats(val)
	end)
	Lib.CreateSettingToggleItem(MiscPlayerGroup, "Noclip", "Walk through walls, doors and solid obstacles", State.Noclip, function(val) State.Noclip = val end)
	Lib.CreateSettingToggleItem(MiscPlayerGroup, "Invisibility", "FE Server-sided invisible character glitch", State.InvisFE, function(val)
		State.InvisFE = val
		Lib.SetFEInvis(val)
	end, true)

	local MiscUtilityGroup = Lib.CreateFeatureGroup(MiscScroll, "Camera & Utilities", 2)
	Lib.CreateSettingToggleItem(MiscUtilityGroup, "Auto Reconnect", "Instantly rejoins the game upon being kicked or disconnected", State.AutoReconnect, function(val) State.AutoReconnect = val end)
	Lib.CreateSettingSliderItem(MiscUtilityGroup, "Fov Changer", "Adjust the camera field of view angle", 30, 120, State.FOV, function(val)
		State.FOV = val
		if App.Camera then App.Camera.FieldOfView = val end
	end, true)

	Lib.BuildMiscUtilities(MiscScroll)

	local TargetPlayerCard = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 140), BackgroundColor3 = Color3.fromRGB(15, 15, 15), LayoutOrder = 1, Parent = TeleportScroll, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) }), Lib.Create("UIStroke", { Color = Color3.fromRGB(30, 30, 30), Thickness = 1, Transparency = 0.5 }) })
	Lib.RegisterThemeElement(TargetPlayerCard, "BackgroundColor3", 0.5)

	local TargetAvatarContainer = Lib.Create("Frame", { Size = UDim2.fromOffset(54, 54), Position = UDim2.fromOffset(15, 15), BackgroundTransparency = 1, Parent = TargetPlayerCard })
	local TargetAvatarImage = Lib.Create("ImageLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(24, 24, 24), Image = "rbxassetid://113533839488998", Parent = TargetAvatarContainer, Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
	local TargetDisplayNameLabel = Lib.Create("TextLabel", { Size = UDim2.new(1, -90, 0, 20), Position = UDim2.fromOffset(80, 16), BackgroundTransparency = 1, Text = "No Player Selected", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 15, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = TargetPlayerCard })
	Lib.RegisterThemeText(TargetDisplayNameLabel, "Primary")

	local TargetUsernameLabel = Lib.Create("TextLabel", { Size = UDim2.new(1, -90, 0, 16), Position = UDim2.fromOffset(80, 36), BackgroundTransparency = 1, Text = "Select an active player from the menu below", TextColor3 = Color3.fromRGB(140, 140, 140), TextSize = 12, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = TargetPlayerCard })
	Lib.RegisterThemeText(TargetUsernameLabel, "Secondary")

	local TargetRegDateLabel = Lib.Create("TextLabel", { Size = UDim2.new(1, -90, 0, 16), Position = UDim2.fromOffset(80, 54), BackgroundTransparency = 1, Text = "Registered: —", TextColor3 = Color3.fromRGB(110, 110, 110), TextSize = 11, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, Parent = TargetPlayerCard })
	Lib.RegisterThemeText(TargetRegDateLabel, "Secondary")

	local ActionButtonsRow = Lib.Create("Frame", { Size = UDim2.new(1, -30, 0, 36), Position = UDim2.new(0, 15, 1, -48), BackgroundTransparency = 1, Parent = TargetPlayerCard, Lib.Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10) }) })
	local TeleportActionBtn = Lib.Create("TextButton", { Size = UDim2.new(0.5, -5, 1, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255), Text = "Teleport", TextColor3 = Color3.fromRGB(0, 0, 0), TextSize = 13, Font = Enum.Font.GothamBold, Parent = ActionButtonsRow, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }) })
	local SpectateActionBtn = Lib.Create("TextButton", { Size = UDim2.new(0.5, -5, 1, 0), BackgroundColor3 = Color3.fromRGB(26, 26, 26), Text = "Spectate", TextColor3 = Color3.fromRGB(240, 240, 240), TextSize = 13, Font = Enum.Font.GothamBold, Parent = ActionButtonsRow, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }) })

	TeleportActionBtn.MouseEnter:Connect(function() Lib.Tween(TeleportActionBtn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Color3.fromRGB(220, 220, 220) }) end)
	TeleportActionBtn.MouseLeave:Connect(function() Lib.Tween(TeleportActionBtn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Color3.fromRGB(255, 255, 255) }) end)
	SpectateActionBtn.MouseEnter:Connect(function() if not State.IsSpectating then Lib.Tween(SpectateActionBtn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Color3.fromRGB(38, 38, 38) }) end end)
	SpectateActionBtn.MouseLeave:Connect(function() if not State.IsSpectating then Lib.Tween(SpectateActionBtn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Color3.fromRGB(26, 26, 26) }) end end)

	local function StopSpectating()
		State.IsSpectating = false
		SpectateActionBtn.Text = "Spectate"
		SpectateActionBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
		SpectateActionBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
		local myHum = App.Player.Character and App.Player.Character:FindFirstChildOfClass("Humanoid")
		if myHum then App.Camera.CameraSubject = myHum end
	end

	local function SetSelectedPlayer(targetPlr)
		if not targetPlr or not targetPlr.Parent then
			State.TeleportTarget = nil
			TargetAvatarImage.Image = "rbxassetid://113533839488998"
			TargetDisplayNameLabel.Text = "No Player Selected"
			TargetUsernameLabel.Text = "Select an active player from the menu below"
			TargetRegDateLabel.Text = "Registered: —"
			if State.IsSpectating then StopSpectating() end
			return
		end

		State.TeleportTarget = targetPlr
		TargetAvatarImage.Image = "rbxthumb://type=AvatarHeadShot&id=" .. targetPlr.UserId .. "&w=150&h=150"
		TargetDisplayNameLabel.Text = targetPlr.DisplayName
		TargetUsernameLabel.Text = "@" .. targetPlr.Name
		TargetRegDateLabel.Text = "Registered: " .. os.date("%d.%m.%Y", os.time() - (targetPlr.AccountAge * 86400))

		if State.IsSpectating then
			local hum = targetPlr.Character and targetPlr.Character:FindFirstChildOfClass("Humanoid")
			if hum then App.Camera.CameraSubject = hum else StopSpectating() end
		end
	end

	TeleportActionBtn.MouseButton1Click:Connect(function()
		Lib.PlayClick()
		local targetPlr = State.TeleportTarget
		if not targetPlr then return end
		local targetChar = targetPlr.Character
		local targetRoot = targetChar and (targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("Torso"))
		local myChar = App.Player.Character
		local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso"))

		if targetRoot and myRoot then
			myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
			local prevText = TeleportActionBtn.Text
			TeleportActionBtn.Text = "Teleported! ✓"
			task.delay(1.2, function()
				if TeleportActionBtn and TeleportActionBtn.Parent then TeleportActionBtn.Text = prevText end
			end)
		end
	end)

	SpectateActionBtn.MouseButton1Click:Connect(function()
		Lib.PlayClick()
		local targetPlr = State.TeleportTarget
		if not targetPlr then return end

		if State.IsSpectating then
			StopSpectating()
		else
			local targetChar = targetPlr.Character
			local hum = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
			if hum then
				State.IsSpectating = true
				App.Camera.CameraSubject = hum
				SpectateActionBtn.Text = "Stop Spectating"
				SpectateActionBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
				SpectateActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			end
		end
	end)

	local PlayerListDropdownCard = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = Color3.fromRGB(15, 15, 15), LayoutOrder = 2, ClipsDescendants = true, Parent = TeleportScroll, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) }) })
	Lib.RegisterThemeElement(PlayerListDropdownCard, "BackgroundColor3", 0.5)

	local PlayerListHeaderBtn = Lib.Create("TextButton", { Size = UDim2.new(1, 0, 0, 50), BackgroundTransparency = 1, Text = "", Parent = PlayerListDropdownCard })
	local PlrListHeadTitle = Lib.Create("TextLabel", { Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, Text = "Select Target Player", TextColor3 = Color3.fromRGB(240, 240, 240), TextSize = 14, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, Parent = PlayerListHeaderBtn })
	Lib.RegisterThemeText(PlrListHeadTitle, "Primary")

	local PlayerListArrow = Lib.Create("TextLabel", { Size = UDim2.fromOffset(30, 30), Position = UDim2.new(1, -40, 0.5, -15), BackgroundTransparency = 1, Text = "▼", TextColor3 = Color3.fromRGB(150, 150, 150), TextSize = 12, Font = Enum.Font.GothamMedium, Parent = PlayerListHeaderBtn })
	Lib.RegisterThemeText(PlayerListArrow, "Secondary")

	local PlayerListScrollContainer = Lib.Create("ScrollingFrame", { Size = UDim2.new(1, -24, 0, 220), Position = UDim2.new(0, 12, 0, 50), BackgroundTransparency = 1, ScrollBarThickness = 2, ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80), BorderSizePixel = 0, Parent = PlayerListDropdownCard })
	local PlayerListLayout = Lib.Create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = PlayerListScrollContainer })
	PlayerListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		PlayerListScrollContainer.CanvasSize = UDim2.new(0, 0, 0, PlayerListLayout.AbsoluteContentSize.Y + 10)
	end)

	local function RefreshPlayerDropdownList()
		for _, c in ipairs(PlayerListScrollContainer:GetChildren()) do
			if c:IsA("Frame") or c:IsA("TextButton") then c:Destroy() end
		end

		local players = Services.Players:GetPlayers()
		local count = 0

		for i, plr in ipairs(players) do
			if plr ~= App.Player then
				count = count + 1
				local Item = Lib.Create("TextButton", {
					Size = UDim2.new(1, 0, 0, 52),
					BackgroundColor3 = Color3.fromRGB(22, 22, 22),
					AutoButtonColor = false,
					Text = "",
					LayoutOrder = i,
					Parent = PlayerListScrollContainer,
					Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
				})
				Lib.RegisterThemeElement(Item, "BackgroundColor3", 0.7)

				Lib.Create("ImageLabel", { Size = UDim2.fromOffset(36, 36), Position = UDim2.new(0, 10, 0.5, -18), BackgroundColor3 = Color3.fromRGB(30, 30, 30), Image = "rbxthumb://type=AvatarHeadShot&id=" .. plr.UserId .. "&w=100&h=100", Parent = Item, Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
				local pDName = Lib.Create("TextLabel", { Size = UDim2.new(1, -170, 0, 18), Position = UDim2.new(0, 56, 0, 8), BackgroundTransparency = 1, Text = plr.DisplayName, TextColor3 = Color3.fromRGB(240, 240, 240), TextSize = 13, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = Item })
				Lib.RegisterThemeText(pDName, "Primary")

				local pUName = Lib.Create("TextLabel", { Size = UDim2.new(1, -170, 0, 16), Position = UDim2.new(0, 56, 0, 26), BackgroundTransparency = 1, Text = "@" .. plr.Name, TextColor3 = Color3.fromRGB(130, 130, 130), TextSize = 11, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = Item })
				Lib.RegisterThemeText(pUName, "Secondary")

				local pReg = Lib.Create("TextLabel", { Size = UDim2.fromOffset(105, 18), Position = UDim2.new(1, -115, 0.5, -9), BackgroundTransparency = 1, Text = "Reg: " .. os.date("%d.%m.%Y", os.time() - (plr.AccountAge * 86400)), TextColor3 = Color3.fromRGB(115, 115, 115), TextSize = 11, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Right, Parent = Item })
				Lib.RegisterThemeText(pReg, "Secondary")

				Item.MouseEnter:Connect(function() Lib.Tween(Item, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Lib.Lighten(Lib.Theme.Item, 0.035) }) end)
				Item.MouseLeave:Connect(function() Lib.Tween(Item, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Lib.Theme.Item }) end)
				Item.MouseButton1Click:Connect(function()
					Lib.PlayClick()
					SetSelectedPlayer(plr)
				end)
			end
		end

		if count == 0 then
			local noPlr = Lib.Create("TextLabel", { Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Text = "No other players in this server", TextColor3 = Color3.fromRGB(120, 120, 120), TextSize = 12, Font = Enum.Font.GothamMedium, Parent = PlayerListScrollContainer })
			Lib.RegisterThemeText(noPlr, "Secondary")
		end
	end

	local isPlayerListOpen = false
	PlayerListHeaderBtn.MouseButton1Click:Connect(function()
		Lib.PlayClick()
		isPlayerListOpen = not isPlayerListOpen
		Lib.Tween(PlayerListArrow, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Rotation = isPlayerListOpen and 180 or 0 })
		Lib.Tween(PlayerListDropdownCard, 0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, { Size = isPlayerListOpen and UDim2.new(1, 0, 0, 280) or UDim2.new(1, 0, 0, 50) })
		if isPlayerListOpen then RefreshPlayerDropdownList() end
	end)

	Lib.C(Services.Players.PlayerAdded, function() if isPlayerListOpen then RefreshPlayerDropdownList() end end)
	Lib.C(Services.Players.PlayerRemoving, function(leavingPlr)
		if State.TeleportTarget == leavingPlr then SetSelectedPlayer(nil) end
		if isPlayerListOpen then RefreshPlayerDropdownList() end
	end)

	local TeleportToolsGroup = Lib.CreateFeatureGroup(TeleportScroll, "Teleport Utilities", 3)
	Lib.CreateSettingToggleItem(TeleportToolsGroup, "Teleport Tool", "Gives a tool to click anywhere on map to instantly teleport", State.Tool_Teleport, function(val)
		State.Tool_Teleport = val
		if val then Refs.Tools.TeleportTool.Parent = App.Player.Backpack else pcall(function() Refs.Tools.TeleportTool.Parent = nil end) end
	end, true)

	local ServerSettingsModalBackdrop = Lib.Create("TextButton", { Name = "ServerSettingsModalBackdrop", Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, Visible = false, ZIndex = 30, Parent = UI.Main })
	local ServerSettingsWindow = Lib.Create("Frame", { Size = UDim2.fromOffset(340, 330), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.fromRGB(16, 16, 16), ClipsDescendants = true, ZIndex = 31, Parent = ServerSettingsModalBackdrop, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 10) }), Lib.Create("UIStroke", { Color = Color3.fromRGB(40, 40, 40), Thickness = 1, Transparency = 0.4 }) })
	Lib.RegisterThemeElement(ServerSettingsWindow, "BackgroundColor3", 0.5)

	local sListSetTitle = Lib.Create("TextLabel", { Size = UDim2.new(1, -60, 0, 35), Position = UDim2.fromOffset(16, 8), BackgroundTransparency = 1, Text = "Server List Settings", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 15, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 32, Parent = ServerSettingsWindow })
	Lib.RegisterThemeText(sListSetTitle, "Primary")

	local CloseSettingsBtn = Lib.Create("TextButton", { Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, -38, 0, 10), BackgroundColor3 = Color3.fromRGB(255, 255, 255), Text = "×", TextColor3 = Color3.fromRGB(0, 0, 0), TextSize = 16, Font = Enum.Font.GothamBold, ZIndex = 32, Parent = ServerSettingsWindow, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }) })

	local SettingsContent = Lib.Create("ScrollingFrame", { Size = UDim2.new(1, -24, 1, -55), Position = UDim2.fromOffset(12, 45), BackgroundTransparency = 1, ScrollBarThickness = 2, ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80), BorderSizePixel = 0, ZIndex = 32, Parent = ServerSettingsWindow })
	local SettingsLayout = Lib.Create("UIListLayout", { Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder, Parent = SettingsContent })
	SettingsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		SettingsContent.CanvasSize = UDim2.new(0, 0, 0, SettingsLayout.AbsoluteContentSize.Y + 10)
	end)

	local function MakeModalChipGroup(title, options, currentVal, onSelect, layoutOrder)
		local Sec = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = layoutOrder, ZIndex = 32, Parent = SettingsContent })
		local secTitle = Lib.Create("TextLabel", { Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Text = title, TextColor3 = Color3.fromRGB(200, 200, 200), TextSize = 12, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 33, Parent = Sec })
		Lib.RegisterThemeText(secTitle, "Primary")

		local Grid = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Position = UDim2.new(0, 0, 0, 22), BackgroundColor3 = Color3.fromRGB(22, 22, 22), ZIndex = 33, Parent = Sec, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) }), Lib.Create("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6) }) })
		Lib.RegisterThemeElement(Grid, "BackgroundColor3", 0.7)
		Lib.Create("UIGridLayout", { CellSize = UDim2.fromOffset(92, 28), CellPadding = UDim2.fromOffset(6, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Grid })

		local btns = {}
		for i, opt in ipairs(options) do
			local isSel = (currentVal == opt)
			local btn = Lib.Create("TextButton", {
				Size = UDim2.fromOffset(92, 28),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = isSel and 0 or 1,
				Text = opt,
				TextColor3 = isSel and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(150, 150, 150),
				TextSize = 11,
				Font = Enum.Font.GothamMedium,
				LayoutOrder = i,
				ZIndex = 34,
				Parent = Grid,
				Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
			})
			btns[opt] = btn

			btn.MouseButton1Click:Connect(function()
				Lib.PlayClick()
				for o, b in pairs(btns) do
					local sel = (o == opt)
					Lib.Tween(b, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
						BackgroundTransparency = sel and 0 or 1,
						TextColor3 = sel and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(150, 150, 150)
					})
				end
				onSelect(opt)
			end)
		end
	end

	local serverModalOpen = false

	local function OpenServerSettingsModal()
		if serverModalOpen then return end
		serverModalOpen = true
		ServerSettingsWindow.Size = UDim2.fromOffset(320, 310)
		Lib.GlassOpen(ServerSettingsModalBackdrop)
		Lib.Tween(ServerSettingsWindow, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Size = UDim2.fromOffset(340, 330) })
	end

	local function CloseServerSettingsModal()
		if not serverModalOpen then return end
		serverModalOpen = false
		Lib.Tween(ServerSettingsWindow, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In, { Size = UDim2.fromOffset(300, 290) })
		Lib.GlassClose(ServerSettingsModalBackdrop, function()
			if not serverModalOpen then ServerSettingsModalBackdrop.Visible = false end
		end)
	end

	CloseSettingsBtn.MouseButton1Click:Connect(function()
		Lib.PlayClick()
		CloseServerSettingsModal()
	end)

	MakeModalChipGroup("Sort by Players", {"Most Players", "Least Players"}, State.ServerList.Sort, function(val)
		State.ServerList.Sort = val
		if State.ServerList.IsOpen and Lib.LoadServerList then Lib.LoadServerList() end
	end, 1)

	MakeModalChipGroup("Server Density / State", {"All", "Almost Empty", "Almost Full"}, State.ServerList.FillState, function(val)
		State.ServerList.FillState = val
		if State.ServerList.IsOpen and Lib.LoadServerList then Lib.LoadServerList() end
	end, 2)

	MakeModalChipGroup("Occupancy Percent", {"All", "10-20%", "30-40%", "50-60%", "70-80%"}, State.ServerList.PercentRange, function(val)
		State.ServerList.PercentRange = val
		if State.ServerList.IsOpen and Lib.LoadServerList then Lib.LoadServerList() end
	end, 3)

	local DirectJoinGroup = Lib.CreateFeatureGroup(ServerScroll, "Direct Connect (Place & Server ID)", 1)
	local DirectJoinCard = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 92), BackgroundTransparency = 1, Parent = DirectJoinGroup })

	local function CreateDirectInputRow(placeholder, yPos, onConnect)
		local box = Lib.Create("TextBox", {
			Size = UDim2.new(1, -56, 0, 36),
			Position = UDim2.new(0, 12, 0, yPos),
			BackgroundColor3 = Color3.fromRGB(22, 22, 22),
			PlaceholderText = placeholder,
			PlaceholderColor3 = Color3.fromRGB(110, 110, 110),
			TextColor3 = Color3.fromRGB(240, 240, 240),
			TextSize = 12,
			Font = Enum.Font.GothamMedium,
			Text = "",
			ClearTextOnFocus = false,
			Parent = DirectJoinCard,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
			Lib.Create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) })
		})
		Lib.RegisterThemeElement(box, "BackgroundColor3", 0.7, true)
		Lib.RegisterThemeText(box, "Primary")

		local joinBtn = Lib.Create("TextButton", {
			Size = UDim2.fromOffset(36, 36),
			Position = UDim2.new(1, -40, 0, yPos),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Text = "▶",
			TextColor3 = Color3.fromRGB(0, 0, 0),
			TextSize = 13,
			Font = Enum.Font.GothamBold,
			Parent = DirectJoinCard,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
		})

		joinBtn.MouseButton1Click:Connect(function()
			Lib.PlayClick()
			onConnect(box.Text)
		end)
	end

	CreateDirectInputRow("Enter Place ID...", 6, function(txt)
		local placeId = tonumber(txt)
		if placeId then
			Lib.Notify({ Title = "Teleport", Text = "Connecting to Place: " .. tostring(placeId) })
			Services.Teleport:Teleport(placeId, App.Player)
		end
	end)

	CreateDirectInputRow("Enter Server Job ID...", 48, function(txt)
		if txt and txt ~= "" then
			Lib.Notify({ Title = "Teleport", Text = "Connecting to Job ID..." })
			Services.Teleport:TeleportToPlaceInstance(game.PlaceId, txt, App.Player)
		end
	end)

	local ServerManagementGroup = Lib.CreateFeatureGroup(ServerScroll, "Server Management", 2)
	Lib.CreateSettingButtonItem(ServerManagementGroup, "Rejoin", "Reconnects you back to the current server", function(titleLbl)
		local oldText = titleLbl.Text
		titleLbl.Text = "Rejoining server..."
		Lib.RejoinCurrentServer()
		task.delay(3, function() titleLbl.Text = oldText end)
	end)
	Lib.CreateSettingButtonItem(ServerManagementGroup, "Server Hop", "Finds and teleports you to a random active public server", function(titleLbl)
		local oldText = titleLbl.Text
		titleLbl.Text = "Searching for a server..."
		Lib.ServerHop()
		task.delay(4, function() titleLbl.Text = oldText end)
	end, true)

	local ServerListCard = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = Color3.fromRGB(15, 15, 15), LayoutOrder = 3, ClipsDescendants = true, Parent = ServerScroll, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) }) })
	Lib.RegisterThemeElement(ServerListCard, "BackgroundColor3", 0.5)

	local ServerListHeader = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 50), BackgroundTransparency = 1, Parent = ServerListCard })
	local ServerListHeaderBtn = Lib.Create("TextButton", { Size = UDim2.new(1, -90, 1, 0), Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1, Text = "", Parent = ServerListHeader })
	local sListCardTitle = Lib.Create("TextLabel", { Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 14, 0, 0), BackgroundTransparency = 1, Text = "Server List", TextColor3 = Color3.fromRGB(240, 240, 240), TextSize = 14, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, Parent = ServerListHeaderBtn })
	Lib.RegisterThemeText(sListCardTitle, "Primary")

	local ServerGearBtn = Lib.Create("ImageButton", { Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, -78, 0.5, -14), BackgroundColor3 = Color3.fromRGB(22, 22, 22), Image = "rbxassetid://119430435918970", ImageColor3 = Color3.fromRGB(180, 180, 180), ScaleType = Enum.ScaleType.Fit, Parent = ServerListHeader, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }), Lib.Create("UIPadding", { PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5), PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5) }) })
	Lib.RegisterThemeElement(ServerGearBtn, "BackgroundColor3", 0.7)

	ServerGearBtn.MouseEnter:Connect(function() Lib.Tween(ServerGearBtn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Lib.Lighten(Lib.Theme.Item, 0.056), ImageColor3 = Color3.fromRGB(255, 255, 255) }) end)
	ServerGearBtn.MouseLeave:Connect(function() Lib.Tween(ServerGearBtn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Lib.Theme.Item, ImageColor3 = Color3.fromRGB(180, 180, 180) }) end)
	ServerGearBtn.MouseButton1Click:Connect(function()
		Lib.PlayClick()
		OpenServerSettingsModal()
	end)

	local ServerListArrow = Lib.Create("TextLabel", { Size = UDim2.fromOffset(30, 30), Position = UDim2.new(1, -40, 0.5, -15), BackgroundTransparency = 1, Text = "▼", TextColor3 = Color3.fromRGB(150, 150, 150), TextSize = 12, Font = Enum.Font.GothamMedium, Parent = ServerListHeader })
	Lib.RegisterThemeText(ServerListArrow, "Secondary")

	local ServerListBody = Lib.Create("Frame", { Size = UDim2.new(1, -24, 0, 240), Position = UDim2.new(0, 12, 0, 50), BackgroundTransparency = 1, Parent = ServerListCard })
	local ServerListScroll = Lib.Create("ScrollingFrame", { Size = UDim2.new(1, 0, 1, -10), BackgroundTransparency = 1, ScrollBarThickness = 2, ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80), BorderSizePixel = 0, Parent = ServerListBody })
	local ServerListInnerLayout = Lib.Create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = ServerListScroll })
	ServerListInnerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		ServerListScroll.CanvasSize = UDim2.new(0, 0, 0, ServerListInnerLayout.AbsoluteContentSize.Y + 10)
	end)

	local ServerStatusLabel = Lib.Create("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "Click to load servers...", TextColor3 = Color3.fromRGB(140, 140, 140), TextSize = 13, Font = Enum.Font.GothamMedium, Visible = true, Parent = ServerListBody })
	Lib.RegisterThemeText(ServerStatusLabel, "Secondary")

	local function CreateServerEntry(serverData, order)
		local Item = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 48), BackgroundColor3 = Color3.fromRGB(22, 22, 22), LayoutOrder = order, Parent = ServerListScroll, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }) })
		Lib.RegisterThemeElement(Item, "BackgroundColor3", 0.7)

		local percent = math.floor((serverData.playing / math.max(serverData.maxPlayers, 1)) * 100)
		local shortJob = tostring(serverData.id):sub(1, 8) .. "..."

		local sPlrs = Lib.Create("TextLabel", { Size = UDim2.new(0, 160, 0, 18), Position = UDim2.new(0, 12, 0, 6), BackgroundTransparency = 1, Text = "👥 " .. tostring(serverData.playing) .. " / " .. tostring(serverData.maxPlayers) .. " Players", TextColor3 = Color3.fromRGB(240, 240, 240), TextSize = 12, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, Parent = Item })
		Lib.RegisterThemeText(sPlrs, "Primary")

		local sInfo = Lib.Create("TextLabel", { Size = UDim2.new(0, 160, 0, 16), Position = UDim2.new(0, 12, 0, 24), BackgroundTransparency = 1, Text = "ID: " .. shortJob .. " • " .. tostring(percent) .. "% Full", TextColor3 = Color3.fromRGB(130, 130, 130), TextSize = 11, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, Parent = Item })
		Lib.RegisterThemeText(sInfo, "Secondary")

		local JoinBtn = Lib.Create("TextButton", { Size = UDim2.fromOffset(70, 28), Position = UDim2.new(1, -78, 0.5, -14), BackgroundColor3 = Color3.fromRGB(255, 255, 255), Text = "Join", TextColor3 = Color3.fromRGB(0, 0, 0), TextSize = 12, Font = Enum.Font.GothamBold, Parent = Item, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }) })
		JoinBtn.MouseEnter:Connect(function() Lib.Tween(JoinBtn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Color3.fromRGB(210, 210, 210) }) end)
		JoinBtn.MouseLeave:Connect(function() Lib.Tween(JoinBtn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Color3.fromRGB(255, 255, 255) }) end)
		JoinBtn.MouseButton1Click:Connect(function()
			Lib.PlayClick()
			JoinBtn.Text = "..."
			pcall(function() Services.Teleport:TeleportToPlaceInstance(game.PlaceId, serverData.id, App.Player) end)
		end)
	end

	function Lib.LoadServerList()
		if State.ServerList.Loading then return end
		State.ServerList.Loading = true

		for _, c in ipairs(ServerListScroll:GetChildren()) do
			if c:IsA("Frame") then c:Destroy() end
		end

		ServerStatusLabel.Text = "Fetching servers..."
		ServerStatusLabel.Visible = true
		ServerListScroll.Visible = false

		task.spawn(function()
			local placeId = game.PlaceId
			local currentJob = game.JobId
			local sortQuery = (State.ServerList.Sort == "Least Players") and "Asc" or "Desc"

			local endpointUrls = {
				"https://games.roproxy.com/v1/games/" .. tostring(placeId) .. "/servers/Public?sortOrder=" .. sortQuery .. "&limit=100",
				"https://games.roblox.com/v1/games/" .. tostring(placeId) .. "/servers/Public?sortOrder=" .. sortQuery .. "&limit=100",
				"https://games.roproxy.com/v1/games/" .. tostring(placeId) .. "/servers/0?sortOrder=" .. sortQuery .. "&limit=100"
			}

			local decodedData = nil

			for _, url in ipairs(endpointUrls) do
				local success, body = API.HTTPRequest(url)
				if success and body then
					local decSuccess, res = pcall(function() return Services.HttpService:JSONDecode(body) end)
					if decSuccess and res and res.data then
						decodedData = res.data
						break
					end
				end
			end

			if not decodedData then
				ServerStatusLabel.Text = "Failed to fetch servers (HTTP / Proxy error)."
				ServerStatusLabel.Visible = true
				State.ServerList.Loading = false
				return
			end

			local list = {}
			for _, s in ipairs(decodedData) do
				if s.playing and s.maxPlayers then
					local isNotCurrent = (#decodedData > 1) and (s.id ~= currentJob) or true

					if isNotCurrent then
						local pct = math.floor((s.playing / s.maxPlayers) * 100)
						local passState = true
						if State.ServerList.FillState == "Almost Empty" and pct > 25 then passState = false
						elseif State.ServerList.FillState == "Almost Full" and pct < 80 then passState = false end

						local passPercent = true
						if State.ServerList.PercentRange == "10-20%" and (pct < 10 or pct > 20) then passPercent = false
						elseif State.ServerList.PercentRange == "30-40%" and (pct < 30 or pct > 40) then passPercent = false
						elseif State.ServerList.PercentRange == "50-60%" and (pct < 50 or pct > 60) then passPercent = false
						elseif State.ServerList.PercentRange == "70-80%" and (pct < 70 or pct > 80) then passPercent = false
						end

						if passState and passPercent then table.insert(list, s) end
					end
				end
			end

			if #list > 0 then
				table.sort(list, function(a, b)
					if State.ServerList.Sort == "Least Players" then return a.playing < b.playing else return a.playing > b.playing end
				end)

				for i, s in ipairs(list) do
					CreateServerEntry(s, i)
				end

				ServerStatusLabel.Visible = false
				ServerListScroll.Visible = true
			else
				ServerStatusLabel.Text = "No servers found matching filters."
				ServerStatusLabel.Visible = true
			end

			State.ServerList.Loading = false
		end)
	end

	ServerListHeaderBtn.MouseButton1Click:Connect(function()
		Lib.PlayClick()
		State.ServerList.IsOpen = not State.ServerList.IsOpen
		Lib.Tween(ServerListArrow, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Rotation = State.ServerList.IsOpen and 180 or 0 })
		Lib.Tween(ServerListCard, 0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, { Size = State.ServerList.IsOpen and UDim2.new(1, 0, 0, 300) or UDim2.new(1, 0, 0, 50) })

		if State.ServerList.IsOpen then Lib.LoadServerList() end
	end)
end

do
	function Lib.MakeChipGroup(parentView, title, stateKey, options, callback, layoutOrder)
		local Section = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = layoutOrder, Parent = parentView })
		local secTitle = Lib.Create("TextLabel", { Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 5, 0, 0), BackgroundTransparency = 1, Text = title, TextColor3 = Color3.fromRGB(240, 240, 240), TextSize = 14, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, Parent = Section })
		Lib.RegisterThemeText(secTitle, "Primary")

		local Container = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Position = UDim2.new(0, 0, 0, 28), BackgroundColor3 = Color3.fromRGB(20, 20, 20), Parent = Section, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 10) }), Lib.Create("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }) })
		Lib.RegisterThemeElement(Container, "BackgroundColor3", 0.5)
		Lib.Create("UIGridLayout", { CellSize = UDim2.fromOffset(115, 30), CellPadding = UDim2.fromOffset(8, 8), SortOrder = Enum.SortOrder.LayoutOrder, FillDirection = Enum.FillDirection.Horizontal, Parent = Container })

		local btns = {}
		for i, opt in ipairs(options) do
			local isSel = (State[stateKey] == opt)
			local btn = Lib.Create("TextButton", { Size = UDim2.fromOffset(115, 30), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = isSel and 0 or 1, Text = opt, TextColor3 = isSel and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(150, 150, 150), TextSize = 12, Font = Enum.Font.GothamMedium, LayoutOrder = i, Parent = Container, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }) })
			btns[opt] = btn

			btn.MouseEnter:Connect(function()
				if State[stateKey] ~= opt then Lib.Tween(btn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { TextColor3 = Color3.fromRGB(220, 220, 220), BackgroundTransparency = 0.93 }) end
			end)
			btn.MouseLeave:Connect(function()
				if State[stateKey] ~= opt then Lib.Tween(btn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { TextColor3 = Color3.fromRGB(150, 150, 150), BackgroundTransparency = 1 }) end
			end)
			btn.MouseButton1Click:Connect(function()
				Lib.PlayClick()
				if State[stateKey] == opt then return end
				State[stateKey] = opt
				for o, b in pairs(btns) do
					local sel = (o == opt)
					Lib.Tween(b, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundTransparency = sel and 0 or 1, TextColor3 = sel and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(150, 150, 150) })
				end
				callback(opt)
			end)
		end
	end

	local ScriptsSection = Lib.Create("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, Parent = UI.ContentArea })
	UI.ScriptsSection = ScriptsSection

	local ScTitle = Lib.Create("TextLabel", { Size = UDim2.new(1, -30, 0, 30), Position = UDim2.new(0, 20, 0, 10), BackgroundTransparency = 1, Text = "Scripts", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 20, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left })
	Lib.RegisterThemeText(ScTitle, "Primary")

	local ScSub = Lib.Create("TextLabel", { Size = UDim2.new(1, -30, 0, 20), AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 15, 1, -15), BackgroundTransparency = 1, Text = "Powered by API", TextColor3 = Color3.fromRGB(100, 100, 100), TextSize = 11, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left })
	Lib.RegisterThemeText(ScSub, "Secondary")

	local ScriptsSideBar = Lib.Create("Frame", { Size = UDim2.new(0, 180, 1, 0), BackgroundTransparency = 1, Parent = ScriptsSection, ScTitle, ScSub })

	local function ClearScriptsCache()
		State.ScriptsCache = {}
		State.ScriptsPage = 1
		State.ScriptsTotalPages = 1
		State.ScriptsGen = State.ScriptsGen + 1
		State.ScriptsLoading = false
		State.ScriptsBackoff = 0
		if State.CurrentScriptsTab == "Browse" then Lib.LoadScriptsPage(1) end
	end

	local Src = { Order = { "Rscripts", "ScriptBlox", "HaxHell", "Roblox Scripts" }, Off = { ["Roblox Scripts"] = true } }
	Lib.ScriptStores = { Saved = Lib.MakeStore("SeptusHub_SavedScripts.json"), Recent = Lib.MakeStore("SeptusHub_RecentScripts.json", 40) }

	local MakeScriptsTab
	Lib.SwitchScriptsTab, MakeScriptsTab = Lib.CreateTabSystem(ScriptsSection, ScriptsSideBar, "CurrentScriptsTab", function(tabName)
		if tabName == "Browse" and not State.ScriptsCache[1] and not State.ScriptsLoading then
			Lib.LoadScriptsPage(1)
		end
		if Lib.OnScriptsTab then Lib.OnScriptsTab(tabName) end
	end)

	local View_Browse = MakeScriptsTab("Browse", 50)
	local View_Saved = MakeScriptsTab("Saved", 90)
	local View_Recent = MakeScriptsTab("Recent", 130)

	local BrowseScroll = Lib.Create("ScrollingFrame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ScrollBarThickness = 2, ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100), BorderSizePixel = 0, Parent = View_Browse })
	local BrowseGrid = Lib.Create("UIGridLayout", { CellSize = UDim2.fromOffset(185, 220), CellPadding = UDim2.fromOffset(15, 15), SortOrder = Enum.SortOrder.LayoutOrder, Parent = BrowseScroll })
	Lib.Create("UIPadding", { PaddingTop = UDim.new(0, 5), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 15), Parent = BrowseScroll })

	Lib.ScriptsSearch = Lib.BuildBrowseSearch(View_Browse, BrowseScroll, 0, "Search by place or script name...", function(query)
		if State.ScriptsQuery == query then return end
		State.ScriptsQuery = query
		ClearScriptsCache()
	end)

	local function CheckMore()
		if State.ScriptsLoading or not BrowseScroll.Visible or State.ScriptsPage >= State.ScriptsTotalPages or os.clock() < State.ScriptsBackoff then return end
		if BrowseScroll.CanvasPosition.Y + BrowseScroll.AbsoluteWindowSize.Y >= BrowseGrid.AbsoluteContentSize.Y - 220 then
			Lib.LoadScriptsPage(State.ScriptsPage + 1)
		end
	end

	BrowseGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		BrowseScroll.CanvasSize = UDim2.new(0, 0, 0, BrowseGrid.AbsoluteContentSize.Y + 20)
		CheckMore()
	end)
	BrowseScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(CheckMore)

	local MoreLabel = Lib.Create("TextLabel", { Size = UDim2.fromOffset(180, 26), Position = UDim2.new(0.5, 0, 1, -8), AnchorPoint = Vector2.new(0.5, 1), BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.25, Text = "Loading more scripts...", TextColor3 = Color3.fromRGB(210, 210, 210), TextSize = 12, Font = Enum.Font.GothamMedium, Visible = false, ZIndex = 5, Parent = View_Browse, Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })

	local LoadingLabel = Lib.Create("TextLabel", { Size = UDim2.new(1, 0, 1, -40), Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1, Text = "Loading scripts...", TextColor3 = Color3.fromRGB(150, 150, 150), TextSize = 15, Font = Enum.Font.GothamMedium, Visible = false, Parent = View_Browse })
	local ErrorLabel = Lib.Create("TextLabel", { Size = UDim2.new(1, 0, 1, -40), Position = UDim2.new(0, 0, 0, -10), BackgroundTransparency = 1, Text = "Failed to load scripts", TextColor3 = Color3.fromRGB(255, 80, 80), TextSize = 15, Font = Enum.Font.GothamMedium, Visible = false, Parent = View_Browse })
	local RetryBtn = Lib.Create("TextButton", { Size = UDim2.fromOffset(100, 34), Position = UDim2.new(0.5, -50, 0.5, 10), BackgroundColor3 = Color3.fromRGB(255, 255, 255), Text = "Retry", TextColor3 = Color3.fromRGB(0, 0, 0), TextSize = 13, Font = Enum.Font.GothamBold, Visible = false, Parent = View_Browse, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }) })
	RetryBtn.MouseEnter:Connect(function() Lib.Tween(RetryBtn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Color3.fromRGB(210, 210, 210) }) end)
	RetryBtn.MouseLeave:Connect(function() Lib.Tween(RetryBtn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Color3.fromRGB(255, 255, 255) }) end)

	function Src.Decode(url)
		local success, body = API.HTTPRequest(url)
		if not (success and body) then return nil end
		local decoded
		local ok = pcall(function() decoded = Services.HttpService:JSONDecode(body) end)
		return ok and type(decoded) == "table" and decoded or nil
	end

	function Src.ParseBlox(decoded, result)
		if decoded.result and decoded.result.scripts then
			result.success = true
			result.totalPages = decoded.result.totalPages or 1
			for _, s in ipairs(decoded.result.scripts) do
				local img = s.image
				if img and img:sub(1, 1) == "/" then img = "https://scriptblox.com" .. img end
				if (not img or img == "") and s.game and s.game.imageUrl then
					img = s.game.imageUrl
					if img:sub(1, 1) == "/" then img = "https://scriptblox.com" .. img end
				end
				table.insert(result.data, {
					title = s.title,
					game = s.game and s.game.name or "Universal",
					imageUrl = img,
					hasKey = s.key,
					isVerified = s.verified,
					script = s.script or s.code or ""
				})
			end
			return true
		end
		return false
	end

	function Src.ParseR(decoded, result)
		local rawScripts = nil
		if type(decoded.data) == "table" then
			rawScripts = decoded.data
			result.totalPages = (decoded.meta and decoded.meta.totalPages) or 1
		elseif type(decoded.scripts) == "table" then
			rawScripts = decoded.scripts
			result.totalPages = decoded.totalPages or (decoded.info and decoded.info.maxPages) or 1
		end

		if rawScripts and #rawScripts > 0 then
			result.success = true
			for _, s in ipairs(rawScripts) do
				local img = s.imageUrl or s.image
				if (not img or img == "") and s.game and (s.game.thumbnailUrl or s.game.imageUrl) then
					img = s.game.thumbnailUrl or s.game.imageUrl
				end
				local code = type(s.script) == "string" and s.script or type(s.code) == "string" and s.code or ""
				if code:find("^https?://%S+$") then code = "" end
				table.insert(result.data, {
					title = s.title or s.name,
					game = (s.game and (s.game.title or s.game.name)) or "Universal",
					imageUrl = img,
					hasKey = s.hasKey or s.keySystem or s.key,
					isVerified = s.isVerified or (s.risk and s.risk.level == "Safe") or (s.creator and s.creator.isVerified),
					script = code,
					raw = type(s.rawScript) == "string" and s.rawScript or "",
					id = s._id or s.id,
					origin = "Rscripts"
				})
			end
			return true
		end
		return false
	end

	function Src.ParseHax(decoded, result)
		local rows = decoded.data
		if type(rows) ~= "table" then return false end
		result.success = true
		local pg = decoded.pagination
		if pg then
			local current = pg.page or 1
			result.totalPages = pg.totalPages or (pg.hasMore and current + 1) or current
		end
		for _, s in ipairs(rows) do
			local flags, game, media = s.flags or {}, s.game or {}, s.media or {}
			result.data[#result.data + 1] = {
				title = s.title,
				game = game.name or "Universal",
				imageUrl = media.thumbnailUrl or game.thumbnailUrl,
				hasKey = flags.keySystem,
				isVerified = flags.verified,
				script = "",
				slug = s.slug,
				raw = s.links and s.links.raw or "",
				origin = "HaxHell"
			}
		end
		return true
	end

	function Src.Wrap(value)
		if type(value) ~= "string" or value == "" then return "" end
		if value:find("^https?://%S+$") then return 'loadstring(game:HttpGet("' .. value .. '"))()' end
		return value
	end

	Src.Hosts = { "rscripts.net", "rawscripts.net", "scriptblox.com" }

	function Src.IsPublisher(url)
		local host = url:match("^https?://([^/:]+)")
		if not host then return false end
		host = host:lower()
		for _, known in ipairs(Src.Hosts) do
			if host == known or host:sub(-#known - 1) == "." .. known then return true end
		end
		return false
	end

	function Src.Unwrap(code)
		for _ = 1, 3 do
			local url = code:match("^%s*loadstring%s*%(%s*game:HttpGet%w*%s*%(%s*[\"']([^\"']+)[\"'][^%)]*%)%s*%)%s*%(%s*%)%s*;?%s*$")
				or code:match("^%s*(https?://%S+)%s*$")
			if not url or not Src.IsPublisher(url) then break end
			local ok, body = API.HTTPRequest(url)
			body = ok and type(body) == "string" and body:match("^%s*(.-)%s*$") or ""
			if body == "" then break end
			code = body
		end
		return code
	end

	function Src.Resolve(data)
		local code = ""
		if data.origin == "HaxHell" and data.slug then
			local decoded = Src.Decode("https://haxhell.com/api/v1/scripts/" .. data.slug)
			local source = decoded and decoded.data and decoded.data.source
			if source then
				local inline = type(source.code) == "string" and source.code or ""
				code = (source.displayAsRawLink or inline == "") and Src.Wrap(source.rawUrl) or inline
			end
		end
		if code == "" and type(data.raw) == "string" and data.raw ~= "" then code = Src.Wrap(data.raw) end
		if code == "" and type(data.script) == "string" and data.script ~= "" and not data.script:find("^https?://%S+$") then code = data.script end
		if code == "" and data.origin == "Rscripts" and data.id then
			local decoded = Src.Decode("https://rscripts.net/api/v2/script?id=" .. data.id)
			local item = decoded and decoded.script
			item = type(item) == "table" and (item[1] or item) or nil
			if item and type(item.rawScript) == "string" then
				data.raw = item.rawScript
				code = Src.Wrap(item.rawScript)
			end
		end
		if code ~= "" then code = Src.Unwrap(code) end
		return code
	end

	function Src.Params()
		local sort, show = State.ScriptsSort, State.ScriptsShow
		local by = sort ~= "Relevance" and sort or (show == "Trending" and "Views") or (show == "New" and "Newest") or nil
		return by, State.ScriptsOrder == "Descending" and "desc" or "asc"
	end

	function Src.ScriptBlox(page, q)
		local result = { success = false, data = {}, totalPages = 1 }
		local by, order = Src.Params()
		local url
		if q ~= "" then
			url = "https://scriptblox.com/api/script/search?q=" .. Services.HttpService:UrlEncode(q) .. "&page=" .. page
		else
			url = "https://scriptblox.com/api/script/fetch?page=" .. page
			if by then
				url = url .. "&sortBy=" .. (by == "Views" and "views" or by == "Likes" and "likeCount" or "createdAt") .. "&order=" .. order
			end
		end
		local decoded = Src.Decode(url)
		if decoded then Src.ParseBlox(decoded, result) end
		return result
	end

	function Src.Rscripts(page, q)
		local result = { success = false, data = {}, totalPages = 1 }
		local by, order = Src.Params()
		local orderBy = by == "Views" and "views" or by == "Likes" and "likes" or by == "Newest" and "date" or nil
		local query = "page=" .. page .. (orderBy and ("&orderBy=" .. orderBy .. "&sort=" .. order) or "") .. (q ~= "" and ("&q=" .. Services.HttpService:UrlEncode(q)) or "")
		local urls = { "https://rscripts.net/api/v2/scripts?" .. query }
		if q == "" then
			local legacy = orderBy == "views" and "&sort=views" or orderBy == "likes" and "&sort=likes" or ""
			urls[2] = "https://rscripts.net/api/scripts?page=" .. page .. legacy
			urls[3] = "https://api.rscripts.net/v1/scripts?limit=30&page=" .. page .. legacy
		end
		for _, url in ipairs(urls) do
			local decoded = Src.Decode(url)
			if decoded and Src.ParseR(decoded, result) then break end
		end
		return result
	end

	function Src.HaxHell(page, q)
		local result = { success = false, data = {}, totalPages = 1 }
		local by = Src.Params()
		local url
		if q == "" and State.ScriptsShow == "Trending" and State.ScriptsSort == "Relevance" then
			if page > 1 then return result end
			url = "https://haxhell.com/api/v1/scripts/trending?limit=24"
		else
			url = "https://haxhell.com/api/v1/scripts?page=" .. page .. "&limit=30&patched=false&isPaid=false&sort=" .. (by == "Views" and "views" or "latest")
			if #q >= 2 then url ..= "&q=" .. Services.HttpService:UrlEncode(q) end
		end
		local decoded = Src.Decode(url)
		if decoded then Src.ParseHax(decoded, result) end
		return result
	end

	function Src.Fetch(page)
		local q = State.ScriptsQuery ~= "" and State.ScriptsQuery or State.ScriptsGame
		local jobs = {}
		for _, name in ipairs(Src.Order) do
			if State.ScriptsSources[name] and Src[name] and not Src.Off[name] then jobs[#jobs + 1] = name end
		end
		local results, pending = {}, #jobs
		for index, name in ipairs(jobs) do
			task.spawn(function()
				local ok, res = pcall(Src[name], page, q)
				results[index] = ok and res or nil
				pending -= 1
			end)
		end
		local started = os.clock()
		while pending > 0 and os.clock() - started < 45 do task.wait(0.05) end

		local merged, lists, longest = { success = false, data = {}, totalPages = 1 }, {}, 0
		for index = 1, #jobs do
			local res = results[index]
			if res and res.success then
				merged.success = true
				merged.totalPages = math.max(merged.totalPages, res.totalPages or 1)
				lists[#lists + 1] = res.data
				longest = math.max(longest, #res.data)
			end
		end
		if not merged.success and State.ScriptsSources.Rscripts then
			local fallback = Src.ScriptBlox(page, q)
			if fallback.success then return fallback end
		end
		for index = 1, longest do
			for _, list in ipairs(lists) do
				if list[index] then merged.data[#merged.data + 1] = list[index] end
			end
		end
		return merged
	end

	function Src.Count()
		local sources, count = State.ScriptsSources, 0
		for _, name in ipairs(Src.Order) do
			if (sources[name] == true) ~= (name == "Rscripts") then
				count += 1
				break
			end
		end
		if State.ScriptsGame ~= "" then count += 1 end
		if State.ScriptsShow ~= "New" then count += 1 end
		if State.ScriptsSort ~= "Relevance" then count += 1 end
		if State.ScriptsOrder ~= "Descending" then count += 1 end
		return count
	end

	Src.Modal = Lib.BuildFilterModal("Script Filters", "Refine how the hub is browsed")
	Src.Button = Lib.MakeFilterButton(ScriptsSideBar, function() Src.Modal.Open() end)

	function Src.Changed()
		Src.Button.SetCount(Src.Count())
		ClearScriptsCache()
	end

	Lib.MakeFilterChips(Src.Modal.Content, "Sources (pick one or more)", Src.Order, function(option)
		return State.ScriptsSources[option] == true
	end, function(option)
		if Src.Off[option] then
			Lib.Notify({ Title = "Sources", Text = option .. " is not connected yet" })
			return
		end
		local sources, active = State.ScriptsSources, 0
		for _, on in pairs(sources) do
			if on then active += 1 end
		end
		if sources[option] and active == 1 then return end
		sources[option] = not sources[option] or nil
		Src.Changed()
	end, 1, 172, Src.Off)

	do
		local section = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 56), BackgroundTransparency = 1, LayoutOrder = 2, Parent = Src.Modal.Content })
		local heading = Lib.Create("TextLabel", {
			Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Text = "Game", TextColor3 = Color3.fromRGB(200, 200, 200), TextSize = 12,
			Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, Parent = section
		})
		Lib.RegisterThemeText(heading, "Primary")
		Lib.MakeSearchBox(section, "Search a Roblox game...", UDim2.fromOffset(0, 22), UDim2.new(1, 0, 0, 32), 0.6, function(text)
			if State.ScriptsGame == text then return end
			State.ScriptsGame = text
			Src.Changed()
		end)
	end

	for index, spec in ipairs({
		{ "Show", "ScriptsShow", { "New", "Trending", "All" }, 112 },
		{ "Sort by", "ScriptsSort", { "Relevance", "Views", "Newest", "Likes" }, 82 },
		{ "Order", "ScriptsOrder", { "Descending", "Ascending" }, 172 }
	}) do
		Lib.MakeFilterChips(Src.Modal.Content, spec[1], spec[3], function(option)
			return State[spec[2]] == option
		end, function(option)
			State[spec[2]] = option
			Src.Changed()
		end, index + 2, spec[4])
	end
	Src.Button.SetCount(Src.Count())

	local function CreateScriptCard(data, order, parent, onChange)
		local Card = Lib.Create("Frame", {
			Size = UDim2.fromOffset(185, 220),
			BackgroundColor3 = Color3.fromRGB(15, 15, 15),
			LayoutOrder = order,
			ClipsDescendants = true,
			Parent = parent or BrowseScroll,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) })
		})
		Lib.RegisterThemeElement(Card, "BackgroundColor3", 0.5)

		local CardStroke = Lib.Create("UIStroke", {
			Color = Color3.fromRGB(35, 35, 35),
			Thickness = 1,
			Transparency = 0.5,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Parent = Card
		})

		local imgUrl = (data.imageUrl and data.imageUrl ~= "") and data.imageUrl or "rbxassetid://113533839488998"

		local Image = Lib.Create("ImageLabel", {
			Size = UDim2.new(1, 0, 0, 120),
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			Image = imgUrl,
			ScaleType = Enum.ScaleType.Crop,
			ClipsDescendants = true,
			Parent = Card,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) })
		})
		Lib.RegisterThemeElement(Image, "BackgroundColor3", 0.7)

		local Badges = Lib.Create("Frame", {
			Size = UDim2.new(1, -12, 0, 20),
			Position = UDim2.new(0, 6, 0, 6),
			BackgroundTransparency = 1,
			ZIndex = 3,
			Parent = Image,
			Lib.Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder })
		})

		local function MakeBadge(text)
			Lib.Create("TextLabel", {
				Size = UDim2.new(0, 0, 1, 0),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Text = text,
				TextColor3 = Color3.fromRGB(0, 0, 0),
				TextSize = 10,
				Font = Enum.Font.GothamMedium,
				ZIndex = 4,
				Parent = Badges,
				Lib.Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
				Lib.Create("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6) })
			})
		end

		if data.hasKey then MakeBadge("Key System") end
		if data.isVerified then MakeBadge("Verified") end

		local key = tostring(data.game) .. "|" .. tostring(data.title)
		Lib.MakeStar(Image, UDim2.new(1, -30, 0, 6), Lib.ScriptStores.Saved.Has(key), function()
			local on = Lib.ScriptStores.Saved.Toggle(key, data)
			if onChange then task.defer(onChange) end
			return on
		end)

		local Overlay = Lib.Create("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 1,
			ZIndex = 5,
			Parent = Image
		})

		local CopyBtn = Lib.Create("TextButton", {
			Size = UDim2.new(0.85, 0, 0, 32),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			Text = "Copy Script",
			TextColor3 = Color3.fromRGB(0, 0, 0),
			TextTransparency = 1,
			TextSize = 12,
			Font = Enum.Font.GothamBold,
			ZIndex = 6,
			Parent = Overlay,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
		})

		local gameName = (data.game and data.game ~= "") and data.game or "Universal"
		local gLabel = Lib.Create("TextLabel", {
			Size = UDim2.new(1, -20, 0, 15),
			Position = UDim2.new(0, 10, 0, 130),
			BackgroundTransparency = 1,
			Text = gameName,
			TextColor3 = Color3.fromRGB(150, 150, 150),
			TextSize = 12,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = Card
		})
		Lib.RegisterThemeText(gLabel, "Secondary")

		local tLabel = Lib.Create("TextLabel", {
			Size = UDim2.new(1, -20, 0, 36),
			Position = UDim2.new(0, 10, 0, 148),
			BackgroundTransparency = 1,
			Text = data.title or "Unknown Script",
			TextColor3 = Color3.fromRGB(240, 240, 240),
			TextSize = 13,
			Font = Enum.Font.GothamMedium,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = Card
		})
		Lib.RegisterThemeText(tLabel, "Primary")

		Card.MouseEnter:Connect(function()
			Lib.Tween(Card, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Lib.Lighten(Lib.Theme.Card, 0.04) })
			Lib.Tween(CardStroke, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Color = Color3.fromRGB(90, 90, 90), Transparency = 0.1 })
			Lib.Tween(Overlay, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundTransparency = 0.4 })
			Lib.Tween(CopyBtn, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundTransparency = 0, TextTransparency = 0 })
		end)

		Card.MouseLeave:Connect(function()
			Lib.Tween(Card, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Lib.Theme.Card })
			Lib.Tween(CardStroke, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Color = Color3.fromRGB(35, 35, 35), Transparency = 0.5 })
			Lib.Tween(Overlay, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundTransparency = 1 })
			Lib.Tween(CopyBtn, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundTransparency = 1, TextTransparency = 1 })
		end)

		CopyBtn.MouseEnter:Connect(function()
			Lib.Tween(CopyBtn, 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Color3.fromRGB(220, 220, 220) })
		end)
		CopyBtn.MouseLeave:Connect(function()
			Lib.Tween(CopyBtn, 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Color3.fromRGB(255, 255, 255) })
		end)

		local busy = false
		CopyBtn.MouseButton1Click:Connect(function()
			Lib.PlayClick()
			if busy then return end
			busy = true
			CopyBtn.Text = "Copying..."
			task.spawn(function()
				local ok, code = pcall(Src.Resolve, data)
				local failed = not ok or code == ""
				if failed then
					Lib.Notify({ Title = "Scripts", Text = "Failed to get the script loadstring" })
				else
					local copyFunc = setclipboard or toclipboard or set_clipboard
					if copyFunc then copyFunc(code) end
					Lib.ScriptStores.Recent.Add(key, data)
				end
				if not CopyBtn.Parent then return end
				CopyBtn.Text = failed and "Failed" or "Copied! ✓"
				CopyBtn.BackgroundColor3 = failed and Color3.fromRGB(220, 80, 80) or Color3.fromRGB(80, 220, 120)
				CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
				task.wait(1.5)
				if CopyBtn.Parent then
					CopyBtn.Text = "Copy Script"
					CopyBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					CopyBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
				end
				busy = false
			end)
		end)
	end

	function Lib.LoadScriptsPage(page)
		if State.ScriptsLoading then return end
		State.ScriptsLoading = true
		local gen = State.ScriptsGen
		local first = page == 1

		ErrorLabel.Visible = false
		RetryBtn.Visible = false

		if first then
			for _, child in ipairs(BrowseScroll:GetChildren()) do
				if child:IsA("Frame") then child:Destroy() end
			end
			State.ScriptsCount = 0
			BrowseScroll.Visible = false
			LoadingLabel.Text = "Loading scripts..."
			LoadingLabel.Visible = true
		else
			MoreLabel.Visible = true
		end

		task.spawn(function()
			local result = Src.Fetch(page)
			if gen ~= State.ScriptsGen then return end

			LoadingLabel.Visible = false
			MoreLabel.Visible = false

			local query = State.ScriptsQuery:lower()
			local gameQuery = State.ScriptsGame:lower()
			local filtered = query ~= "" or gameQuery ~= ""
			if first then
				Lib.ScriptsSearch.SetSuggestions(query ~= "" and result.success and Lib.CollectPlaces(result.data, query) or nil)
			end
			if filtered and result.success then
				local kept = {}
				for _, s in ipairs(result.data) do
					local gameName, title = (s.game or ""):lower(), (s.title or ""):lower()
					if (query == "" or gameName:find(query, 1, true) or title:find(query, 1, true)) and (gameQuery == "" or gameName:find(gameQuery, 1, true)) then
						kept[#kept + 1] = s
					end
				end
				result.data = kept
				if #kept == 0 and page < result.totalPages and page < 4 then
					State.ScriptsLoading = false
					return Lib.LoadScriptsPage(page + 1)
				end
			end

			if result.success and #result.data > 0 then
				local base = State.ScriptsCount
				State.ScriptsCache[page] = true
				State.ScriptsPage = page
				State.ScriptsTotalPages = result.totalPages or 1
				for i, sData in ipairs(result.data) do
					CreateScriptCard(sData, base + i)
				end
				State.ScriptsCount = base + #result.data
				BrowseScroll.Visible = true
			elseif first then
				if filtered and result.success then
					LoadingLabel.Text = "No scripts found"
					LoadingLabel.Visible = true
				else
					ErrorLabel.Visible = true
					RetryBtn.Visible = true
				end
			else
				State.ScriptsBackoff = os.clock() + 4
				if State.ScriptsCount == 0 and filtered then
					LoadingLabel.Text = "No scripts found"
					LoadingLabel.Visible = true
				end
			end

			State.ScriptsLoading = false
		end)
	end

	do
		local cell, gap = UDim2.fromOffset(185, 220), UDim2.fromOffset(15, 15)
		local savedScroll, savedEmpty = Lib.MakeCardList(View_Saved, "No saved scripts yet\nTap the star on a script card to save it", cell, gap, 10)
		local recentScroll, recentEmpty = Lib.MakeCardList(View_Recent, "No recent scripts yet\nScripts you copy will appear here", cell, gap, 10)

		local function Fill(scroll, empty, store, onChange)
			for _, child in ipairs(scroll:GetChildren()) do
				if child:IsA("Frame") then child:Destroy() end
			end
			local list = store.List()
			for index, entry in ipairs(list) do CreateScriptCard(entry.data, index, scroll, onChange) end
			empty.Visible = #list == 0
		end

		local function FillSaved() Fill(savedScroll, savedEmpty, Lib.ScriptStores.Saved, FillSaved) end

		function Lib.OnScriptsTab(tabName)
			if tabName == "Saved" then
				FillSaved()
			elseif tabName == "Recent" then
				Fill(recentScroll, recentEmpty, Lib.ScriptStores.Recent)
			end
		end
	end

	RetryBtn.MouseButton1Click:Connect(function()
		Lib.PlayClick()
		Lib.LoadScriptsPage(1)
	end)
end

do
	local EmotesSection = Lib.Create("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, Parent = UI.ContentArea })
	UI.EmotesSection = EmotesSection

	local EmTitle = Lib.Create("TextLabel", { Size = UDim2.new(1, -30, 0, 30), Position = UDim2.new(0, 20, 0, 10), BackgroundTransparency = 1, Text = "Emotes", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 20, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left })
	Lib.RegisterThemeText(EmTitle, "Primary")

	local EmSub = Lib.Create("TextLabel", { Size = UDim2.new(1, -30, 0, 20), AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 15, 1, -15), BackgroundTransparency = 1, Text = "Roblox Marketplace", TextColor3 = Color3.fromRGB(100, 100, 100), TextSize = 11, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left })
	Lib.RegisterThemeText(EmSub, "Secondary")

	local EmotesSideBar = Lib.Create("Frame", { Size = UDim2.new(0, 180, 1, 0), BackgroundTransparency = 1, Parent = EmotesSection, EmTitle, EmSub })

	local function ClearEmotesDataCache()
		State.EmotesCache = {}
		State.AnimationPacksCache = {}
		State.EmotesPage = 1
		State.EmotesLoading = false
		State.EmotesGen = State.EmotesGen + 1
		if State.CurrentEmotesTab == "Browse" and Lib.LoadEmotesPage then Lib.LoadEmotesPage(1) end
	end

	Lib.EmoteStores = { Saved = Lib.MakeStore("SeptusHub_SavedEmotes.json"), Recent = Lib.MakeStore("SeptusHub_RecentEmotes.json", 40) }

	local MakeEmotesTab
	Lib.SwitchEmotesTab, MakeEmotesTab = Lib.CreateTabSystem(EmotesSection, EmotesSideBar, "CurrentEmotesTab", function(tabName)
		if tabName == "Browse" and not State.EmotesLoading then
			local currentCache = (State.EmotesCategory == "Emotes") and State.EmotesCache or State.AnimationPacksCache
			if not currentCache[State.EmotesPage] then
				Lib.LoadEmotesPage(State.EmotesPage)
			end
		end
		if Lib.OnEmotesTab then Lib.OnEmotesTab(tabName) end
	end)

	local View_EmotesBrowse = MakeEmotesTab("Browse", 50)
	local View_EmotesSaved = MakeEmotesTab("Saved", 90)
	local View_EmotesRecent = MakeEmotesTab("Recent", 130)

	local EmFilter = {}
	function EmFilter.Count()
		local count = 0
		if State.EmotesCategory ~= "Emotes" then count += 1 end
		if State.EmotesSort ~= "Most Liked" then count += 1 end
		return count
	end
	EmFilter.Modal = Lib.BuildFilterModal("Emote Filters", "Refine how the hub is browsed")
	EmFilter.Button = Lib.MakeFilterButton(EmotesSideBar, function() EmFilter.Modal.Open() end)
	function EmFilter.Changed()
		EmFilter.Button.SetCount(EmFilter.Count())
		ClearEmotesDataCache()
	end
	for index, spec in ipairs({
		{ "Category", "EmotesCategory", { "Emotes", "Animation Packs" }, 172 },
		{ "Sort by", "EmotesSort", { "Most Liked", "Least Liked", "Most Viewed", "Least Viewed", "Newest", "Oldest" }, 112 }
	}) do
		Lib.MakeFilterChips(EmFilter.Modal.Content, spec[1], spec[3], function(option)
			return State[spec[2]] == option
		end, function(option)
			State[spec[2]] = option
			EmFilter.Changed()
		end, index, spec[4])
	end
	EmFilter.Button.SetCount(EmFilter.Count())

	local EmotesScroll = Lib.Create("ScrollingFrame", { Size = UDim2.new(1, 0, 1, -40), Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1, ScrollBarThickness = 2, ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100), BorderSizePixel = 0, Parent = View_EmotesBrowse })
	local EmotesGrid = Lib.Create("UIGridLayout", { CellSize = UDim2.fromOffset(185, 230), CellPadding = UDim2.fromOffset(12, 12), SortOrder = Enum.SortOrder.LayoutOrder, Parent = EmotesScroll })
	Lib.Create("UIPadding", { PaddingTop = UDim.new(0, 5), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 15), Parent = EmotesScroll })

	EmotesGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		EmotesScroll.CanvasSize = UDim2.new(0, 0, 0, EmotesGrid.AbsoluteContentSize.Y + 20)
	end)

	Lib.EmotesSearch = Lib.BuildBrowseSearch(View_EmotesBrowse, EmotesScroll, 40, "Search emotes by name...", function(query)
		if State.EmotesQuery == query then return end
		State.EmotesQuery = query
		ClearEmotesDataCache()
	end)

	local EmotesPaginationPanel = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 1, -30), BackgroundTransparency = 1, Parent = View_EmotesBrowse })
	local EmotesPrevBtn = Lib.Create("TextButton", { Size = UDim2.fromOffset(30, 30), Position = UDim2.new(0.5, -70, 0, 0), BackgroundColor3 = Color3.fromRGB(15, 15, 15), Text = "‹", TextColor3 = Color3.fromRGB(200, 200, 200), TextSize = 16, Font = Enum.Font.GothamMedium, Parent = EmotesPaginationPanel, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }) })
	Lib.RegisterThemeElement(EmotesPrevBtn, "BackgroundColor3", 0.5)

	local EmotesPageLabel = Lib.Create("TextLabel", { Size = UDim2.fromOffset(80, 30), Position = UDim2.new(0.5, -40, 0, 0), BackgroundTransparency = 1, Text = "Page 1 / 1", TextColor3 = Color3.fromRGB(200, 200, 200), TextSize = 12, Font = Enum.Font.GothamMedium, Parent = EmotesPaginationPanel })
	Lib.RegisterThemeText(EmotesPageLabel, "Secondary")

	local EmotesNextBtn = Lib.Create("TextButton", { Size = UDim2.fromOffset(30, 30), Position = UDim2.new(0.5, 40, 0, 0), BackgroundColor3 = Color3.fromRGB(15, 15, 15), Text = "›", TextColor3 = Color3.fromRGB(200, 200, 200), TextSize = 16, Font = Enum.Font.GothamMedium, Parent = EmotesPaginationPanel, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }) })
	Lib.RegisterThemeElement(EmotesNextBtn, "BackgroundColor3", 0.5)

	local EmotesLoadingLabel = Lib.Create("TextLabel", { Size = UDim2.new(1, 0, 1, -40), Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1, Text = "Loading emotes...", TextColor3 = Color3.fromRGB(150, 150, 150), TextSize = 15, Font = Enum.Font.GothamMedium, Visible = false, Parent = View_EmotesBrowse })
	Lib.RegisterThemeText(EmotesLoadingLabel, "Secondary")

	local EmotesErrorLabel = Lib.Create("TextLabel", { Size = UDim2.new(1, -40, 0, 120), AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 20, 0.5, 0), BackgroundTransparency = 1, Text = "Failed to load emotes", TextColor3 = Color3.fromRGB(255, 80, 80), TextSize = 13, Font = Enum.Font.GothamMedium, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Bottom, Visible = false, Parent = View_EmotesBrowse })
	local EmotesRetryBtn = Lib.Create("TextButton", { Size = UDim2.fromOffset(100, 34), Position = UDim2.new(0.5, -50, 0.5, 10), BackgroundColor3 = Color3.fromRGB(255, 255, 255), Text = "Retry", TextColor3 = Color3.fromRGB(0, 0, 0), TextSize = 13, Font = Enum.Font.GothamBold, Visible = false, Parent = View_EmotesBrowse, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }) })
	EmotesRetryBtn.MouseEnter:Connect(function() Lib.Tween(EmotesRetryBtn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Color3.fromRGB(210, 210, 210) }) end)
	EmotesRetryBtn.MouseLeave:Connect(function() Lib.Tween(EmotesRetryBtn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Color3.fromRGB(255, 255, 255) }) end)

	local function CreateEmoteCard(data, order, parent, onChange)
		local Card = Lib.Create("Frame", { Size = UDim2.fromOffset(185, 230), BackgroundColor3 = Color3.fromRGB(15, 15, 15), LayoutOrder = order, Parent = parent or EmotesScroll, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) }) })
		Lib.RegisterThemeElement(Card, "BackgroundColor3", 0.5)

		local thumbType = (data.itemType == "Bundle") and "BundleThumbnail" or "Asset"
		local thumbUrl = "rbxthumb://type=" .. thumbType .. "&id=" .. tostring(data.thumbnailId) .. "&w=420&h=420"

		Lib.RegisterThemeElement(Lib.Create("ImageLabel", { Size = UDim2.new(1, -16, 0, 110), Position = UDim2.new(0, 8, 0, 8), BackgroundColor3 = Color3.fromRGB(22, 22, 22), Image = thumbUrl, ScaleType = Enum.ScaleType.Fit, Parent = Card, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }) }), "BackgroundColor3", 0.7)
		local key = tostring(data.id)
		Lib.MakeStar(Card, UDim2.new(1, -36, 0, 14), Lib.EmoteStores.Saved.Has(key), function()
			local on = Lib.EmoteStores.Saved.Toggle(key, { id = data.id, itemType = data.itemType, name = data.name, price = data.price, thumbnailId = data.thumbnailId })
			if onChange then task.defer(onChange) end
			return on
		end)

		local eName = Lib.Create("TextLabel", { Size = UDim2.new(1, -16, 0, 18), Position = UDim2.new(0, 8, 0, 124), BackgroundTransparency = 1, Text = data.name, TextColor3 = Color3.fromRGB(240, 240, 240), TextSize = 13, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = Card })
		Lib.RegisterThemeText(eName, "Primary")

		local isFree = data.price == "Free"
		local ePrice = Lib.Create("TextLabel", { Size = UDim2.new(1, -16, 0, 16), Position = UDim2.new(0, 8, 0, 144), BackgroundTransparency = 1, Text = data.price, TextColor3 = isFree and Color3.fromRGB(80, 220, 120) or Color3.fromRGB(160, 160, 160), TextSize = 12, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, Parent = Card })
		if not isFree then Lib.RegisterThemeText(ePrice, "Secondary") end

		local isPlaying = (State.CurrentPlayingAssetId == data.id)
		local actionBtn = Lib.Create("TextButton", {
			Size = UDim2.new(1, -16, 0, 30), Position = UDim2.new(0, 8, 1, -38),
			BackgroundColor3 = isPlaying and Color3.fromRGB(220, 50, 50) or Color3.fromRGB(255, 255, 255),
			Text = isPlaying and "Stop" or "Play",
			TextColor3 = isPlaying and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0),
			TextSize = 12, Font = Enum.Font.GothamBold, Parent = Card,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
		})

		if isPlaying then State.CurrentEmoteButton = actionBtn end

		actionBtn.MouseButton1Click:Connect(function()
			Lib.PlayClick()
			if State.CurrentPlayingAssetId ~= data.id then
				Lib.EmoteStores.Recent.Add(key, { id = data.id, itemType = data.itemType, name = data.name, price = data.price, thumbnailId = data.thumbnailId })
			end
			Lib.PlayEmote(data.id, data.itemType, actionBtn)
		end)
	end

	do
		local cell, gap = UDim2.fromOffset(185, 230), UDim2.fromOffset(12, 12)
		local savedScroll, savedEmpty = Lib.MakeCardList(View_EmotesSaved, "No saved emotes yet\nTap the star on an emote card to save it", cell, gap, 8)
		local recentScroll, recentEmpty = Lib.MakeCardList(View_EmotesRecent, "No recent emotes yet\nEmotes you play will appear here", cell, gap, 8)

		local function Fill(scroll, empty, store, onChange)
			for _, child in ipairs(scroll:GetChildren()) do
				if child:IsA("Frame") then child:Destroy() end
			end
			local list = store.List()
			for index, entry in ipairs(list) do CreateEmoteCard(entry.data, index, scroll, onChange) end
			empty.Visible = #list == 0
		end

		local function FillSaved() Fill(savedScroll, savedEmpty, Lib.EmoteStores.Saved, FillSaved) end

		function Lib.OnEmotesTab(tabName)
			if tabName == "Saved" then
				FillSaved()
			elseif tabName == "Recent" then
				Fill(recentScroll, recentEmpty, Lib.EmoteStores.Recent)
			end
		end
	end

	function Lib.LoadEmotesPage(page)
		if State.EmotesLoading then return end
		State.EmotesLoading = true
		local gen = State.EmotesGen

		for _, child in ipairs(EmotesScroll:GetChildren()) do
			if child:IsA("Frame") then child:Destroy() end
		end

		EmotesLoadingLabel.Text = (State.EmotesCategory == "Emotes") and "Loading emotes..." or "Loading animation packs..."
		EmotesLoadingLabel.Visible = true
		EmotesErrorLabel.Visible = false
		EmotesRetryBtn.Visible = false
		EmotesPaginationPanel.Visible = false
		EmotesScroll.Visible = false

		task.spawn(function()
			local isPack = (State.EmotesCategory == "Animation Packs")
			local currentCache = isPack and State.AnimationPacksCache or State.EmotesCache

			local result = currentCache[page]
			if not result then
				local ok, fetched = Lib.Timed(function()
					return (isPack and API.FetchAnimationPacks or API.FetchEmotes)(page, State.EmotesSort)
				end, 90)
				result = ok and fetched or { success = false, error = "script error: " .. tostring(fetched) }
				if result.success then currentCache[page] = result end
			end
			if gen ~= State.EmotesGen then return end

			if result and result.success and result.data and #result.data > 0 then
				State.EmotesPage = page
				State.EmotesTotalPages = result.totalPages or 1
				EmotesPageLabel.Text = "Page " .. tostring(page) .. " / " .. tostring(State.EmotesTotalPages)

				for i, eData in ipairs(result.data) do
					CreateEmoteCard(eData, i)
				end
				EmotesScroll.CanvasPosition = Vector2.new(0, 0)

				if page == 1 then
					local query = State.EmotesQuery:lower()
					local suggestions
					if query ~= "" then
						suggestions = {}
						for _, e in ipairs(result.data) do
							local name = e.name:lower()
							if name:sub(1, #query) == query or name:find(" " .. query, 1, true) then
								suggestions[#suggestions + 1] = {
									Name = e.name,
									Sub = e.price,
									Image = "rbxthumb://type=" .. (e.itemType == "Bundle" and "BundleThumbnail" or "Asset") .. "&id=" .. tostring(e.thumbnailId) .. "&w=150&h=150"
								}
								if #suggestions == 10 then break end
							end
						end
					end
					Lib.EmotesSearch.SetSuggestions(suggestions)
				end

				EmotesLoadingLabel.Visible = false
				EmotesScroll.Visible = true
				EmotesPaginationPanel.Visible = true
			elseif result and result.empty then
				Lib.EmotesSearch.SetSuggestions(nil)
				EmotesLoadingLabel.Text = "Nothing found"
				EmotesLoadingLabel.Visible = true
			else
				EmotesLoadingLabel.Visible = false
				local reason = result and result.error
				EmotesErrorLabel.Text = "Failed to load " .. ((State.EmotesCategory == "Emotes") and "emotes" or "animation packs") .. ((reason and reason ~= "") and ("\n" .. reason:sub(1, 420)) or "\nNo items returned")
				EmotesErrorLabel.Visible = true
				EmotesRetryBtn.Visible = true
			end

			State.EmotesLoading = false
		end)
	end

	EmotesPrevBtn.MouseButton1Click:Connect(function()
		Lib.PlayClick()
		if State.EmotesPage > 1 and not State.EmotesLoading then Lib.LoadEmotesPage(State.EmotesPage - 1) end
	end)
	EmotesNextBtn.MouseButton1Click:Connect(function()
		Lib.PlayClick()
		if State.EmotesPage < State.EmotesTotalPages and not State.EmotesLoading then Lib.LoadEmotesPage(State.EmotesPage + 1) end
	end)
	EmotesRetryBtn.MouseButton1Click:Connect(function()
		Lib.PlayClick()
		Lib.LoadEmotesPage(State.EmotesPage)
	end)
end

do
	local Asset = game:GetService("AssetService")
	local token, pending, failedId = 0, 0, nil
	local dst, source, current

	local function Free()
		token = token + 1
		if dst then pcall(dst.Destroy, dst) end
		dst, source, current = nil, nil, nil
	end

	Lib.ReleaseBgSaturation = Free

	function Lib.RefreshBgSaturation()
		token = token + 1
		local mine, image, id = token, UI.CustomBgImage, Lib.BgAssetId
		if State.BgSaturation == 100 or not id or not image.Visible then
			if dst then
				if image.Visible and Lib.BgResolved then image.Image = Lib.BgResolved end
				Free()
			end
			return
		end
		if failedId == id then return end

		task.spawn(function()
			local ok = pcall(function()
				if current ~= id then
					if dst then pcall(dst.Destroy, dst) dst = nil end
					local editable = Asset:CreateEditableImageAsync(Content.fromAssetId(tonumber(id)))
					dst, current = editable, id
					source = editable:ReadPixelsBuffer(Vector2.zero, editable.Size)
				end
				local size = dst.Size
				local width, height, saturation = size.X, size.Y, State.BgSaturation / 100
				local out = buffer.create(buffer.len(source))
				local readu8, writeu8 = buffer.readu8, buffer.writeu8
				for y = 0, height - 1 do
					for offset = y * width * 4, (y + 1) * width * 4 - 4, 4 do
						local r, g, b = readu8(source, offset), readu8(source, offset + 1), readu8(source, offset + 2)
						local luma = r * 0.299 + g * 0.587 + b * 0.114
						writeu8(out, offset, math.clamp(luma + (r - luma) * saturation, 0, 255) // 1)
						writeu8(out, offset + 1, math.clamp(luma + (g - luma) * saturation, 0, 255) // 1)
						writeu8(out, offset + 2, math.clamp(luma + (b - luma) * saturation, 0, 255) // 1)
						writeu8(out, offset + 3, readu8(source, offset + 3))
					end
					if y % 48 == 47 then
						task.wait()
						if mine ~= token then return end
					end
				end
				dst:WritePixelsBuffer(Vector2.zero, size, out)
				image.ImageContent = Content.fromObject(dst)
			end)
			if not ok and mine == token then
				failedId = id
				Lib.Notify({ Title = "Background", Text = "Saturation is not supported for this image or executor" })
			end
		end)
	end

	function Lib.QueueBgSaturation()
		pending = pending + 1
		local mine = pending
		task.delay(0.35, function()
			if mine == pending and not State.Unloaded then Lib.RefreshBgSaturation() end
		end)
	end
end

function Lib.BuildMusic(group)
	local Http, Run, UIS = Services.HttpService, Services.Run, Services.UserInputService
	local Market = game:GetService("MarketplaceService")
	local FILE, FOLDER, BARS = "SeptusHub_Music.json", "SeptusHub_Music", 14
	local WHITE, BLACK = Color3.fromRGB(255, 255, 255), Color3.fromRGB(0, 0, 0)
	local request = request or http_request or (syn and syn.request)
	local list, order, rows = {}, {}, {}
	local mode, cur, loading, failed, autoPaused, token = "Asset ID", nil, false, false, false, 0
	local Refresh, Play, Toggle, Step, Rebuild

	local sound = Lib.Create("Sound", { Name = "SeptusMusic", Volume = State.MusicVolume / 100, Parent = Services.SoundService })

	if isfile and readfile then
		pcall(function()
			if not isfile(FILE) then return end
			for _, entry in ipairs(Http:JSONDecode(readfile(FILE))) do
				if type(entry) == "table" and type(entry.value) == "string" and (entry.kind == "id" or entry.kind == "url") then
					list[#list + 1] = { kind = entry.kind, value = entry.value, name = tostring(entry.name or entry.value), fav = entry.fav == true }
				end
			end
		end)
	end
	pcall(function()
		if makefolder and not isfolder(FOLDER) then makefolder(FOLDER) end
	end)

	local function Save()
		if not writefile then return end
		local out = {}
		for i, entry in ipairs(list) do
			out[i] = { kind = entry.kind, value = entry.value, name = entry.name, fav = entry.fav }
		end
		pcall(writefile, FILE, Http:JSONEncode(out))
	end

	local function Hash(text)
		local h = 5381
		for i = 1, #text do h = (h * 33 + text:byte(i)) % 4294967296 end
		return h
	end

	local function Resolve(entry)
		if entry.kind == "id" then return "rbxassetid://" .. entry.value end
		if not (request and writefile and isfile and getcustomasset) then return nil end
		local ext = entry.value:gsub("[?#].*$", ""):match("%.(%a%w?%w?%w?)$") or "mp3"
		local path = FOLDER .. "/m_" .. Hash(entry.value) .. "." .. ext
		if not isfile(path) then
			local response = request({ Url = entry.value, Method = "GET" })
			if not response or (response.StatusCode or 200) >= 400 or not response.Body or #response.Body == 0 then return nil end
			writefile(path, response.Body)
		end
		return getcustomasset(path)
	end

	local function Row(height)
		return Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, height), BackgroundTransparency = 1, Parent = group })
	end

	local top = Row(58)
	top.ZIndex = 5

	local modeBtn = Lib.Create("TextButton", {
		Size = UDim2.fromOffset(96, 36), Position = UDim2.fromOffset(12, 11), BackgroundColor3 = Color3.fromRGB(22, 22, 22),
		Text = "Asset ID", TextColor3 = Color3.fromRGB(240, 240, 240), TextSize = 12, Font = Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false, Parent = top,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
		Lib.Create("UIPadding", { PaddingLeft = UDim.new(0, 10) })
	})
	Lib.RegisterThemeElement(modeBtn, "BackgroundColor3", 0.7, true)
	Lib.RegisterThemeText(modeBtn, "Primary")

	local chevron = Lib.Create("TextLabel", {
		Size = UDim2.fromOffset(16, 36), Position = UDim2.new(1, -20, 0, 0), BackgroundTransparency = 1, Text = "▾",
		TextColor3 = Color3.fromRGB(150, 150, 150), TextSize = 12, Font = Enum.Font.GothamBold, Parent = modeBtn
	})
	Lib.RegisterThemeText(chevron, "Secondary")

	local input = Lib.Create("TextBox", {
		Size = UDim2.new(1, -188, 0, 36), Position = UDim2.fromOffset(116, 11), BackgroundColor3 = Color3.fromRGB(22, 22, 22),
		PlaceholderText = "Paste an Asset ID...", PlaceholderColor3 = Color3.fromRGB(110, 110, 110), TextColor3 = Color3.fromRGB(240, 240, 240),
		TextSize = 12, Font = Enum.Font.GothamMedium, Text = "", ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left, Parent = top,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
		Lib.Create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) })
	})
	Lib.RegisterThemeElement(input, "BackgroundColor3", 0.7, true)
	Lib.RegisterThemeText(input, "Primary")

	local addBtn = Lib.Create("TextButton", {
		Size = UDim2.fromOffset(56, 36), Position = UDim2.new(1, -68, 0, 11), BackgroundColor3 = WHITE,
		Text = "Add", TextColor3 = BLACK, TextSize = 12, Font = Enum.Font.GothamBold, AutoButtonColor = false, Parent = top,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
	})

	local popup = Lib.Create("Frame", {
		Size = UDim2.fromOffset(96, 66), Position = UDim2.fromOffset(12, 50), BackgroundColor3 = Color3.fromRGB(22, 22, 22),
		Visible = false, ZIndex = 10, Parent = top,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
		Lib.Create("UIStroke", { Color = Color3.fromRGB(60, 60, 60), Thickness = 1, Transparency = 0.4 })
	})
	Lib.RegisterThemeElement(popup, "BackgroundColor3", 0.7)

	local function SetMode(value)
		mode = value
		modeBtn.Text = value
		input.PlaceholderText = value == "URL" and "Paste an audio URL..." or "Paste an Asset ID..."
		popup.Visible = false
	end

	for i, label in ipairs({ "Asset ID", "URL" }) do
		local option = Lib.Create("TextButton", {
			Size = UDim2.new(1, -8, 0, 28), Position = UDim2.fromOffset(4, 3 + (i - 1) * 30), BackgroundTransparency = 1,
			Text = label, TextColor3 = Color3.fromRGB(240, 240, 240), TextSize = 12, Font = Enum.Font.GothamMedium,
			TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false, ZIndex = 11, Parent = popup,
			Lib.Create("UIPadding", { PaddingLeft = UDim.new(0, 6) })
		})
		Lib.RegisterThemeText(option, "Primary")
		option.MouseButton1Click:Connect(function()
			Lib.PlayClick()
			SetMode(label)
		end)
	end

	modeBtn.MouseButton1Click:Connect(function()
		Lib.PlayClick()
		popup.Visible = not popup.Visible
	end)

	local playerRow = Row(66)
	local box = Lib.Create("Frame", {
		Size = UDim2.new(1, -24, 0, 56), Position = UDim2.fromOffset(12, 0), BackgroundColor3 = Color3.fromRGB(22, 22, 22), Parent = playerRow,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) })
	})
	Lib.RegisterThemeElement(box, "BackgroundColor3", 0.7, true)

	local function IconButton(text, x)
		return Lib.Create("TextButton", {
			Size = UDim2.fromOffset(28, 28), Position = UDim2.new(0, x, 0.5, -14), BackgroundTransparency = 1, Text = text,
			TextColor3 = Color3.fromRGB(150, 150, 150), TextSize = 10, Font = Enum.Font.GothamBold, AutoButtonColor = false, Parent = box
		})
	end

	local prevBtn = IconButton("◀◀", 10)
	local nextBtn = IconButton("▶▶", 86)
	local playBtn = Lib.Create("TextButton", {
		Size = UDim2.fromOffset(36, 36), Position = UDim2.new(0, 42, 0.5, -18), BackgroundColor3 = WHITE, Text = "▶", TextColor3 = BLACK,
		TextSize = 14, Font = Enum.Font.GothamBold, AutoButtonColor = false, Parent = box,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) })
	})

	local titleLabel = Lib.Create("TextLabel", {
		Size = UDim2.new(1, -140, 0, 18), Position = UDim2.fromOffset(126, 11), BackgroundTransparency = 1, Text = "Nothing playing",
		TextColor3 = Color3.fromRGB(240, 240, 240), TextSize = 13, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = box
	})
	Lib.RegisterThemeText(titleLabel, "Primary")

	local statusLabel = Lib.Create("TextLabel", {
		Size = UDim2.new(1, -140, 0, 14), Position = UDim2.fromOffset(126, 31), BackgroundTransparency = 1, Text = "NO TRACK",
		TextColor3 = Color3.fromRGB(130, 130, 130), TextSize = 10, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, Parent = box
	})
	Lib.RegisterThemeText(statusLabel, "Secondary")

	local listFrame = Lib.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = group,
		Lib.Create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }),
		Lib.Create("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingBottom = UDim.new(0, 8) })
	})

	function Refresh()
		local status
		if loading then
			status = "LOADING"
		elseif failed then
			status = "ERROR"
		elseif not cur then
			status = "NO TRACK"
		elseif sound.IsPlaying then
			status = "PLAYING"
		else
			status = "PAUSED"
		end
		local playing = status == "PLAYING"
		titleLabel.Text = cur and cur.name or "Nothing playing"
		statusLabel.Text = status
		playBtn.Text = playing and "II" or "▶"
		for entry, button in pairs(rows) do
			local active = entry == cur
			button.Text = (active and playing) and "II" or "▶"
			button.TextColor3 = active and Lib.Palette.Primary or Lib.Palette.Secondary
		end
	end

	function Play(entry)
		cur, loading, failed, autoPaused = entry, true, false, false
		token = token + 1
		local mine = token
		sound:Stop()
		Refresh()
		task.spawn(function()
			local ok, src = pcall(Resolve, entry)
			if mine ~= token then return end
			loading = false
			if not ok or not src then
				failed = true
				Refresh()
				Lib.Notify({ Title = "Music", Text = "Failed to load the track" })
				return
			end
			sound.SoundId = src
			sound.TimePosition = 0
			sound:Play()
			Refresh()
			task.delay(10, function()
				if mine == token and not sound.IsLoaded then
					failed = true
					Refresh()
				end
			end)
		end)
	end

	function Toggle()
		if not cur then
			if order[1] then Play(order[1]) end
		elseif loading then
			return
		elseif failed then
			Play(cur)
		elseif sound.IsPlaying then
			sound:Pause()
		elseif sound.IsPaused then
			sound:Resume()
		else
			sound:Play()
		end
		Refresh()
	end

	function Step(direction)
		local count = #order
		if count == 0 then return end
		local position = cur and table.find(order, cur) or (direction > 0 and 0 or count + 1)
		Play(order[(position - 1 + direction) % count + 1])
	end

	local function Remove(entry)
		if cur == entry then
			token = token + 1
			cur, loading, failed = nil, false, false
			sound:Stop()
		end
		local position = table.find(list, entry)
		if position then table.remove(list, position) end
		Save()
		Rebuild()
	end

	function Rebuild()
		for _, child in ipairs(listFrame:GetChildren()) do
			if child:IsA("GuiObject") then child:Destroy() end
		end
		table.clear(rows)
		table.clear(order)
		for _, entry in ipairs(list) do
			if entry.fav then order[#order + 1] = entry end
		end
		for _, entry in ipairs(list) do
			if not entry.fav then order[#order + 1] = entry end
		end

		if #order == 0 then
			local empty = Lib.Create("TextLabel", {
				Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, Text = "Playlist is empty", TextColor3 = Color3.fromRGB(120, 120, 120),
				TextSize = 12, Font = Enum.Font.GothamMedium, Parent = listFrame
			})
			Lib.RegisterThemeText(empty, "Secondary")
			Refresh()
			return
		end

		for i, entry in ipairs(order) do
			local item = Lib.Create("Frame", {
				Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = Color3.fromRGB(22, 22, 22), LayoutOrder = i, Parent = listFrame,
				Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) })
			})
			Lib.RegisterThemeElement(item, "BackgroundColor3", 0.7, true)

			local play = Lib.Create("TextButton", {
				Size = UDim2.fromOffset(28, 28), Position = UDim2.new(0, 8, 0.5, -14), BackgroundTransparency = 1, Text = "▶",
				TextColor3 = Lib.Palette.Secondary, TextSize = 11, Font = Enum.Font.GothamBold, AutoButtonColor = false, Parent = item
			})
			local name = Lib.Create("TextLabel", {
				Size = UDim2.new(1, -112, 1, 0), Position = UDim2.fromOffset(42, 0), BackgroundTransparency = 1, Text = entry.name,
				TextColor3 = Color3.fromRGB(240, 240, 240), TextSize = 12, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd, Parent = item
			})
			Lib.RegisterThemeText(name, "Primary")
			local star = Lib.Create("TextButton", {
				Size = UDim2.fromOffset(24, 24), Position = UDim2.new(1, -64, 0.5, -12), BackgroundTransparency = 1,
				Text = entry.fav and "★" or "☆", TextColor3 = entry.fav and Color3.fromRGB(255, 205, 50) or Color3.fromRGB(150, 150, 150),
				TextSize = 14, Font = Enum.Font.GothamBold, AutoButtonColor = false, Parent = item
			})
			local remove = Lib.Create("TextButton", {
				Size = UDim2.fromOffset(24, 24), Position = UDim2.new(1, -34, 0.5, -12), BackgroundTransparency = 1, Text = "×",
				TextColor3 = Color3.fromRGB(150, 150, 150), TextSize = 16, Font = Enum.Font.GothamBold, AutoButtonColor = false, Parent = item
			})

			rows[entry] = play
			play.MouseButton1Click:Connect(function()
				Lib.PlayClick()
				if cur == entry then Toggle() else Play(entry) end
			end)
			star.MouseButton1Click:Connect(function()
				Lib.PlayClick()
				entry.fav = not entry.fav
				Save()
				Rebuild()
			end)
			remove.MouseButton1Click:Connect(function()
				Lib.PlayClick()
				Remove(entry)
			end)
		end
		Refresh()
	end

	local function Add()
		local text = input.Text:match("^%s*(.-)%s*$")
		if text == "" then return end
		local entry
		if mode == "Asset ID" then
			local id = tonumber(text) and text or text:match("rbxassetid://(%d+)") or text:match("[?&]id=(%d+)") or text:match("/library/(%d+)") or text:match("(%d%d%d%d+)")
			if not id then
				Lib.Notify({ Title = "Music", Text = "Invalid Asset ID" })
				return
			end
			entry = { kind = "id", value = id, name = "Asset " .. id, fav = false }
		else
			if not text:match("^https?://") then
				Lib.Notify({ Title = "Music", Text = "Enter a valid http(s) URL" })
				return
			end
			if not (request and writefile and getcustomasset) then
				Lib.Notify({ Title = "Music", Text = "This executor cannot play audio from URLs" })
				return
			end
			local base = text:gsub("[?#].*$", ""):match("([^/]+)$") or text
			base = base:gsub("%.%w+$", "")
			base = base:gsub("%%(%x%x)", function(hex) return string.char(tonumber(hex, 16)) end)
			entry = { kind = "url", value = text, name = base ~= "" and base or text, fav = false }
		end
		for _, other in ipairs(list) do
			if other.kind == entry.kind and other.value == entry.value then
				Lib.Notify({ Title = "Music", Text = "Already in the playlist" })
				return
			end
		end
		if #list >= 100 then
			Lib.Notify({ Title = "Music", Text = "Playlist is full" })
			return
		end
		list[#list + 1] = entry
		input.Text = ""
		popup.Visible = false
		Save()
		Rebuild()
		if entry.kind == "id" then
			task.spawn(function()
				local ok, info = pcall(Market.GetProductInfo, Market, tonumber(entry.value))
				if ok and type(info) == "table" and info.Name and info.Name ~= "" and table.find(list, entry) then
					entry.name = info.Name
					Save()
					Rebuild()
				end
			end)
		end
	end

	addBtn.MouseButton1Click:Connect(function()
		Lib.PlayClick()
		Add()
	end)
	input.FocusLost:Connect(function(enter)
		if enter then Add() end
	end)
	prevBtn.MouseButton1Click:Connect(function()
		Lib.PlayClick()
		Step(-1)
	end)
	nextBtn.MouseButton1Click:Connect(function()
		Lib.PlayClick()
		Step(1)
	end)
	playBtn.MouseButton1Click:Connect(function()
		Lib.PlayClick()
		Toggle()
	end)

	sound.Ended:Connect(function()
		if #order > 1 then Step(1) else Refresh() end
	end)
	sound.Loaded:Connect(function()
		failed = false
		Refresh()
	end)
	for _, signal in ipairs({ sound.Played, sound.Paused, sound.Resumed, sound.Stopped }) do
		signal:Connect(Refresh)
	end

	Lib.CreateSettingSliderItem(group, "Volume", "Adjust the music volume", 0, 100, State.MusicVolume, function(value)
		State.MusicVolume = value
		sound.Volume = value / 100
	end, false, "%")
	Lib.CreateSettingToggleItem(group, "Only When Focused", "Pause the music when the window loses focus", State.MusicFocus, function(value)
		State.MusicFocus = value
	end)
	Lib.CreateSettingToggleItem(group, "Titlebar Visualizer", "Show bars for the playing track in the title bar", State.MusicVisualizer, function(value)
		State.MusicVisualizer = value
	end, true)

	Lib.C(UIS.WindowFocusReleased, function()
		if State.MusicFocus and sound.IsPlaying then
			autoPaused = true
			sound:Pause()
		end
	end)
	Lib.C(UIS.WindowFocused, function()
		if autoPaused then
			autoPaused = false
			sound:Resume()
		end
	end)

	local holder = Lib.Create("Frame", {
		Name = "MusicVisualizer", Size = UDim2.fromOffset(BARS * 6, 28), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -140, 0, 29),
		BackgroundTransparency = 1, Visible = false, ZIndex = 3, Parent = UI.Main
	})
	local bars, levels = {}, {}
	for i = 1, BARS do
		levels[i] = 0.1
		bars[i] = Lib.Create("Frame", {
			Size = UDim2.new(0, 4, 0.1, 0), AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, (i - 1) * 6, 1, 0),
			BackgroundColor3 = Lib.Palette.Primary, BorderSizePixel = 0, ZIndex = 3, Parent = holder,
			Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) })
		})
	end

	local accumulator = 0
	Lib.C(Run.RenderStepped, function(dt)
		local want = State.MusicVisualizer and sound.IsPlaying
		if holder.Visible ~= want then holder.Visible = want end
		if not want then return end
		accumulator = accumulator + dt
		if accumulator < 0.033 then return end
		accumulator = 0
		table.remove(levels, 1)
		levels[BARS] = math.clamp(sound.PlaybackLoudness / 400, 0.08, 1)
		local phase, color = os.clock() * 8, Lib.Palette.Primary
		for i = 1, BARS do
			local bar = bars[i]
			bar.Size = UDim2.new(0, 4, math.clamp(levels[i] * (0.7 + 0.3 * math.sin(phase + i * 1.3)), 0.08, 1), 0)
			bar.BackgroundColor3 = color
		end
	end)

	function Lib.StopMusic()
		token = token + 1
		sound:Destroy()
	end

	Rebuild()
end

do
	local SettingsSection = Lib.Create("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, Parent = UI.ContentArea })
	UI.SettingsSection = SettingsSection

	local SetTitle = Lib.Create("TextLabel", { Size = UDim2.new(1, -30, 0, 30), Position = UDim2.new(0, 20, 0, 10), BackgroundTransparency = 1, Text = "Settings", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 20, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left })
	Lib.RegisterThemeText(SetTitle, "Primary")

	local SetSub = Lib.Create("TextLabel", { Size = UDim2.new(1, -30, 0, 20), AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 15, 1, -15), BackgroundTransparency = 1, Text = "App Configuration", TextColor3 = Color3.fromRGB(100, 100, 100), TextSize = 11, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left })
	Lib.RegisterThemeText(SetSub, "Secondary")

	local SettingsSideBar = Lib.Create("Frame", { Size = UDim2.new(0, 180, 1, 0), BackgroundTransparency = 1, Parent = SettingsSection, SetTitle, SetSub })

	local MakeSettingsTab
	Lib.SwitchSettingsTab, MakeSettingsTab = Lib.CreateTabSystem(SettingsSection, SettingsSideBar, "CurrentSettingsTab")

	local View_Appearance = MakeSettingsTab("Appearance", 50, 92865789131206)
	local View_Config = MakeSettingsTab("Config", 90, 92450542426061)

	local AppearanceScroll = Lib.Create("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1, ScrollBarThickness = 2,
		ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100), BorderSizePixel = 0,
		Parent = View_Appearance
	})
	local AppLayout = Lib.Create("UIListLayout", { Padding = UDim.new(0, 16), SortOrder = Enum.SortOrder.LayoutOrder, Parent = AppearanceScroll })
	Lib.Create("UIPadding", { PaddingTop = UDim.new(0, 5), PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 15), Parent = AppearanceScroll })

	AppLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		AppearanceScroll.CanvasSize = UDim2.new(0, 0, 0, AppLayout.AbsoluteContentSize.Y + 20)
	end)

	local THEMES_FILE = "SeptusHub_Themes.json"
	local THEME_KEYS = { "Background", "Surface", "Text", "Accent", "Item", "Muted", "SwitchOff" }

	local function SaveCustomThemes()
		if not writefile then return end
		local out = {}
		for i, theme in ipairs(State.CustomThemes) do
			local entry = { Name = theme.Name }
			for _, key in ipairs(THEME_KEYS) do
				entry[key] = theme[key]:ToHex()
			end
			out[i] = entry
		end
		pcall(writefile, THEMES_FILE, Services.HttpService:JSONEncode(out))
	end

	local function LoadCustomThemes()
		if not (isfile and readfile) then return end
		pcall(function()
			if not isfile(THEMES_FILE) then return end
			for _, entry in ipairs(Services.HttpService:JSONDecode(readfile(THEMES_FILE))) do
				local theme = { Name = tostring(entry.Name or "Custom") }
				for _, key in ipairs(THEME_KEYS) do
					theme[key] = Color3.fromHex(entry[key])
				end
				table.insert(State.CustomThemes, theme)
			end
		end)
	end

	local function BindDrag(area, onMove)
		area.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
			onMove(input.Position)
			local moveConn, endConn
			moveConn = Services.UserInputService.InputChanged:Connect(function(changed)
				if changed.UserInputType == Enum.UserInputType.MouseMovement or changed.UserInputType == Enum.UserInputType.Touch then
					onMove(changed.Position)
				end
			end)
			endConn = Services.UserInputService.InputEnded:Connect(function(ended)
				if ended.UserInputType == Enum.UserInputType.MouseButton1 or ended.UserInputType == Enum.UserInputType.Touch then
					moveConn:Disconnect()
					endConn:Disconnect()
				end
			end)
		end)
	end

	local function OpenThemeEditor(onAdd)
		local WIN_W, WIN_H, ROWS_Y, POPUP_W, POPUP_H = 380, 480, 184, 232, 240
		local original = State.CustomTheme or State.ThemeColor
		local alive, pending = true, false

		local draft = {
			Background = Color3.fromHex("282929"),
			Surface = Color3.fromHex("333333"),
			Text = Color3.fromHex("ececee"),
			Accent = Color3.fromHex("d4d4d8")
		}
		draft.Item = Lib.Lighten(draft.Surface, 0.05)
		draft.Muted = draft.Text:Lerp(draft.Surface, 0.45)
		draft.SwitchOff = draft.Item:Lerp(draft.Text, 0.12)

		local function Preview()
			if pending then return end
			pending = true
			task.delay(0.04, function()
				pending = false
				if alive then Lib.ApplyTheme(draft, true) end
			end)
		end

		local backdrop = Lib.Create("TextButton", {
			Name = "ThemeEditorBackdrop",
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			Visible = false,
			ZIndex = 40,
			Parent = UI.Main
		})

		local window = Lib.Create("Frame", {
			Size = UDim2.fromOffset(WIN_W - 40, WIN_H - 40),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Lib.Theme.Card,
			ClipsDescendants = true,
			ZIndex = 41,
			Parent = backdrop,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 12) }),
			Lib.Create("UIStroke", { Color = Color3.fromRGB(70, 70, 70), Thickness = 1, Transparency = 0.5 })
		})
		Lib.RegisterThemeElement(window, "BackgroundColor3", 0.5)

		local function Label(parent, text, size, position, textSize, role, align)
			local label = Lib.Create("TextLabel", {
				Size = size,
				Position = position,
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = Lib.Palette[role],
				TextSize = textSize,
				Font = Enum.Font.GothamBold,
				TextXAlignment = align or Enum.TextXAlignment.Left,
				ZIndex = 43,
				Parent = parent
			})
			Lib.RegisterThemeText(label, role)
			return label
		end

		local iconBox = Lib.Create("Frame", {
			Size = UDim2.fromOffset(48, 48),
			Position = UDim2.fromOffset(16, 16),
			BackgroundColor3 = Lib.Theme.Item,
			ZIndex = 42,
			Parent = window,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 10) })
		})
		Lib.RegisterThemeElement(iconBox, "BackgroundColor3", 0.7)

		local iconCells = {}
		for i, key in ipairs({ "Background", "Surface", "Text", "Accent" }) do
			iconCells[key] = Lib.Create("Frame", {
				Size = UDim2.fromOffset(18, 18),
				Position = UDim2.fromOffset(5 + ((i - 1) % 2) * 20, 5 + math.floor((i - 1) / 2) * 20),
				BackgroundColor3 = draft[key],
				ZIndex = 43,
				Parent = iconBox,
				Lib.Create("UICorner", { CornerRadius = UDim.new(0, 5) })
			})
		end

		Label(window, "New Theme", UDim2.new(1, -90, 0, 24), UDim2.fromOffset(78, 17), 18, "Primary")
		Label(window, "Changes preview live across the app.", UDim2.new(1, -90, 0, 16), UDim2.fromOffset(78, 42), 11, "Secondary")
		Label(window, "NAME", UDim2.new(1, -32, 0, 14), UDim2.fromOffset(16, 76), 10, "Secondary")

		local nameBox = Lib.Create("TextBox", {
			Size = UDim2.new(1, -32, 0, 34),
			Position = UDim2.fromOffset(16, 94),
			BackgroundColor3 = Lib.Theme.Item,
			Text = "Custom " .. (#State.CustomThemes + 1),
			PlaceholderText = "Theme name",
			PlaceholderColor3 = Lib.Palette.Secondary,
			TextColor3 = Lib.Palette.Primary,
			TextSize = 13,
			Font = Enum.Font.GothamMedium,
			TextXAlignment = Enum.TextXAlignment.Left,
			ClearTextOnFocus = false,
			ZIndex = 42,
			Parent = window,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
			Lib.Create("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) })
		})
		Lib.RegisterThemeElement(nameBox, "BackgroundColor3", 0.7)
		Lib.RegisterThemeText(nameBox, "Primary")
		nameBox.FocusLost:Connect(function()
			nameBox.Text = nameBox.Text:sub(1, 24)
		end)

		local tabBar = Lib.Create("Frame", {
			Size = UDim2.new(1, -32, 0, 34),
			Position = UDim2.fromOffset(16, 138),
			BackgroundColor3 = Lib.Theme.Item,
			ZIndex = 42,
			Parent = window,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
			Lib.Create("UIPadding", { PaddingTop = UDim.new(0, 3), PaddingBottom = UDim.new(0, 3), PaddingLeft = UDim.new(0, 3), PaddingRight = UDim.new(0, 3) })
		})
		Lib.RegisterThemeElement(tabBar, "BackgroundColor3", 0.7)

		local pages, tabButtons = {}, {}
		local swatches, hexBoxes, rowIndexOf = {}, {}, {}
		local picker = { Key = nil, H = 0, S = 0, V = 0 }
		local LoadPicker

		local function SetColor(key, color, fromPicker)
			draft[key] = color
			swatches[key].BackgroundColor3 = color
			hexBoxes[key].Text = "#" .. color:ToHex()
			if iconCells[key] then iconCells[key].BackgroundColor3 = color end
			if not fromPicker and picker.Key == key then LoadPicker(color) end
			Preview()
		end

		local catcher = Lib.Create("TextButton", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			Visible = false,
			ZIndex = 59,
			Parent = window
		})

		local popup = Lib.Create("Frame", {
			Size = UDim2.fromOffset(POPUP_W, POPUP_H),
			BackgroundColor3 = Lib.Theme.Item,
			Visible = false,
			ZIndex = 60,
			Parent = window,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
			Lib.Create("UIStroke", { Color = Color3.fromRGB(90, 90, 90), Thickness = 1, Transparency = 0.5 })
		})
		Lib.RegisterThemeElement(popup, "BackgroundColor3", 0.7)

		local svArea = Lib.Create("Frame", {
			Size = UDim2.fromOffset(216, 128),
			Position = UDim2.fromOffset(8, 8),
			BackgroundColor3 = Color3.new(1, 0, 0),
			ZIndex = 61,
			Parent = popup,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
		})
		Lib.Create("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			ZIndex = 62,
			Parent = svArea,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
			Lib.Create("UIGradient", { Transparency = NumberSequence.new(0, 1) })
		})
		Lib.Create("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
			ZIndex = 63,
			Parent = svArea,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
			Lib.Create("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(1, 0) })
		})
		local svKnob = Lib.Create("Frame", {
			Size = UDim2.fromOffset(14, 14),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			ZIndex = 65,
			Parent = svArea,
			Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
			Lib.Create("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
		})
		local svHit = Lib.Create("TextButton", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 66,
			Parent = svArea
		})

		local preview = Lib.Create("Frame", {
			Size = UDim2.fromOffset(28, 28),
			Position = UDim2.fromOffset(8, 146),
			ZIndex = 61,
			Parent = popup,
			Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
			Lib.Create("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 1, Transparency = 0.8 })
		})

		local hueSteps = {}
		for i = 0, 6 do
			hueSteps[#hueSteps + 1] = ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6, 1, 1))
		end
		local hueBar = Lib.Create("Frame", {
			Size = UDim2.fromOffset(172, 12),
			Position = UDim2.fromOffset(46, 154),
			BackgroundColor3 = Color3.new(1, 1, 1),
			ZIndex = 61,
			Parent = popup,
			Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
			Lib.Create("UIGradient", { Color = ColorSequence.new(hueSteps) })
		})
		local hueKnob = Lib.Create("Frame", {
			Size = UDim2.fromOffset(14, 14),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.new(1, 1, 1),
			ZIndex = 63,
			Parent = hueBar,
			Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
			Lib.Create("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1, Transparency = 0.6 })
		})
		local hueHit = Lib.Create("TextButton", {
			Size = UDim2.new(1, 0, 0, 24),
			Position = UDim2.new(0, 0, 0.5, -12),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 64,
			Parent = hueBar
		})

		local rgbBoxes = {}
		for i, letter in ipairs({ "R", "G", "B" }) do
			local x = 8 + (i - 1) * 76
			local box = Lib.Create("TextBox", {
				Size = UDim2.fromOffset(64, 30),
				Position = UDim2.fromOffset(x, 182),
				BackgroundColor3 = Lib.Theme.Card,
				Text = "0",
				TextColor3 = Lib.Palette.Primary,
				TextSize = 12,
				Font = Enum.Font.GothamMedium,
				ClearTextOnFocus = false,
				ZIndex = 61,
				Parent = popup,
				Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
			})
			Lib.RegisterThemeElement(box, "BackgroundColor3", 0.5)
			Lib.RegisterThemeText(box, "Primary")
			Label(popup, letter, UDim2.fromOffset(64, 14), UDim2.fromOffset(x, 214), 11, "Secondary", Enum.TextXAlignment.Center).ZIndex = 61
			rgbBoxes[i] = box
		end

		local function PickerVisuals()
			local color = Color3.fromHSV(picker.H, picker.S, picker.V)
			svArea.BackgroundColor3 = Color3.fromHSV(picker.H, 1, 1)
			svKnob.Position = UDim2.fromScale(picker.S, 1 - picker.V)
			hueKnob.Position = UDim2.new(picker.H, 0, 0.5, 0)
			preview.BackgroundColor3 = color
			rgbBoxes[1].Text = tostring(math.round(color.R * 255))
			rgbBoxes[2].Text = tostring(math.round(color.G * 255))
			rgbBoxes[3].Text = tostring(math.round(color.B * 255))
			return color
		end

		function LoadPicker(color)
			local h, s, v = color:ToHSV()
			if s > 0 and v > 0 then picker.H = h end
			picker.S, picker.V = s, v
			PickerVisuals()
		end

		local function PickerApply()
			SetColor(picker.Key, PickerVisuals(), true)
		end

		BindDrag(svHit, function(position)
			picker.S = math.clamp((position.X - svArea.AbsolutePosition.X) / svArea.AbsoluteSize.X, 0, 1)
			picker.V = 1 - math.clamp((position.Y - svArea.AbsolutePosition.Y) / svArea.AbsoluteSize.Y, 0, 1)
			PickerApply()
		end)

		BindDrag(hueHit, function(position)
			picker.H = math.clamp((position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
			PickerApply()
		end)

		for i, box in ipairs(rgbBoxes) do
			box.FocusLost:Connect(function()
				local current = Color3.fromHSV(picker.H, picker.S, picker.V)
				local channels = { math.round(current.R * 255), math.round(current.G * 255), math.round(current.B * 255) }
				local typed = tonumber(box.Text)
				if typed then channels[i] = math.clamp(math.round(typed), 0, 255) end
				local color = Color3.fromRGB(channels[1], channels[2], channels[3])
				LoadPicker(color)
				SetColor(picker.Key, color, true)
			end)
		end

		local function HidePicker()
			picker.Key = nil
			popup.Visible = false
			catcher.Visible = false
		end
		catcher.MouseButton1Click:Connect(HidePicker)

		local function ShowPicker(key)
			local rowTop = ROWS_Y + (rowIndexOf[key] - 1) * 52
			local y = rowTop + 48
			if y + POPUP_H > WIN_H - 6 then y = rowTop - POPUP_H - 4 end
			popup.Position = UDim2.fromOffset(WIN_W - POPUP_W - 16, math.max(y, 6))
			picker.Key = key
			LoadPicker(draft[key])
			catcher.Visible = true
			popup.Visible = true
		end

		local function MakeRow(page, key, text, index)
			rowIndexOf[key] = index
			local row = Lib.Create("Frame", {
				Size = UDim2.new(1, 0, 0, 44),
				Position = UDim2.fromOffset(0, (index - 1) * 52),
				BackgroundColor3 = Lib.Theme.Item,
				ZIndex = 42,
				Parent = page,
				Lib.Create("UICorner", { CornerRadius = UDim.new(0, 10) })
			})
			Lib.RegisterThemeElement(row, "BackgroundColor3", 0.7)
			Label(row, text, UDim2.new(1, -160, 1, 0), UDim2.fromOffset(14, 0), 13, "Primary")

			local swatch = Lib.Create("TextButton", {
				Size = UDim2.fromOffset(32, 32),
				Position = UDim2.new(1, -146, 0.5, -16),
				BackgroundColor3 = draft[key],
				Text = "",
				AutoButtonColor = false,
				ZIndex = 43,
				Parent = row,
				Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
				Lib.Create("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 1, Transparency = 0.85 })
			})
			local hexBox = Lib.Create("TextBox", {
				Size = UDim2.fromOffset(88, 32),
				Position = UDim2.new(1, -102, 0.5, -16),
				BackgroundColor3 = Lib.Theme.Card,
				Text = "#" .. draft[key]:ToHex(),
				TextColor3 = Lib.Palette.Primary,
				TextSize = 12,
				Font = Enum.Font.GothamMedium,
				ClearTextOnFocus = false,
				ZIndex = 43,
				Parent = row,
				Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) })
			})
			Lib.RegisterThemeElement(hexBox, "BackgroundColor3", 0.5)
			Lib.RegisterThemeText(hexBox, "Primary")

			swatches[key], hexBoxes[key] = swatch, hexBox

			swatch.MouseButton1Click:Connect(function()
				Lib.PlayClick()
				ShowPicker(key)
			end)

			hexBox.FocusLost:Connect(function()
				local ok, color = pcall(Color3.fromHex, hexBox.Text)
				if ok then
					SetColor(key, color)
				else
					hexBox.Text = "#" .. draft[key]:ToHex()
				end
			end)
		end

		for name, rows in pairs({
			Basic = { { "Background", "Background" }, { "Surface", "Surface" }, { "Text", "Text" }, { "Accent", "Accent" } },
			Advanced = { { "Item", "Item" }, { "Muted", "Secondary Text" }, { "SwitchOff", "Switch Off" } }
		}) do
			local page = Lib.Create("Frame", {
				Size = UDim2.new(1, -32, 0, 4 * 52 - 8),
				Position = UDim2.fromOffset(16, ROWS_Y),
				BackgroundTransparency = 1,
				Visible = false,
				ZIndex = 42,
				Parent = window
			})
			pages[name] = page
			for index, row in ipairs(rows) do
				MakeRow(page, row[1], row[2], index)
			end
		end

		local function SelectTab(name)
			HidePicker()
			for tabName, page in pairs(pages) do
				page.Visible = tabName == name
			end
			for tabName, button in pairs(tabButtons) do
				local on = tabName == name
				button.BackgroundTransparency = on and 0 or 1
				button.TextColor3 = on and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(140, 140, 140)
			end
		end

		for i, name in ipairs({ "Basic", "Advanced" }) do
			tabButtons[name] = Lib.Create("TextButton", {
				Size = UDim2.new(0.5, 0, 1, 0),
				Position = UDim2.new((i - 1) * 0.5, 0, 0, 0),
				BackgroundColor3 = Color3.fromRGB(240, 240, 242),
				Text = name,
				TextSize = 12,
				Font = Enum.Font.GothamBold,
				AutoButtonColor = false,
				ZIndex = 43,
				Parent = tabBar,
				Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
			})
			tabButtons[name].MouseButton1Click:Connect(function()
				Lib.PlayClick()
				SelectTab(name)
			end)
		end

		local function Close(revert)
			if not alive then return end
			alive = false
			if revert then Lib.ApplyTheme(original) end
			Lib.Tween(window, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In, { Size = UDim2.fromOffset(WIN_W - 40, WIN_H - 40) })
			Lib.GlassClose(backdrop, function() backdrop:Destroy() end)
		end

		local cancelBtn = Lib.Create("TextButton", {
			Size = UDim2.new(0.5, -20, 0, 40),
			Position = UDim2.new(0, 16, 1, -56),
			BackgroundColor3 = Lib.Theme.Item,
			Text = "Cancel",
			TextColor3 = Lib.Palette.Primary,
			TextSize = 13,
			Font = Enum.Font.GothamBold,
			AutoButtonColor = false,
			ZIndex = 42,
			Parent = window,
			Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) })
		})
		Lib.RegisterThemeElement(cancelBtn, "BackgroundColor3", 0.7)
		Lib.RegisterThemeText(cancelBtn, "Primary")

		local addBtn = Lib.Create("TextButton", {
			Size = UDim2.new(0.5, -20, 0, 40),
			Position = UDim2.new(0.5, 4, 1, -56),
			BackgroundColor3 = Color3.fromRGB(240, 240, 242),
			Text = "Add",
			TextColor3 = Color3.fromRGB(20, 20, 20),
			TextSize = 13,
			Font = Enum.Font.GothamBold,
			AutoButtonColor = false,
			ZIndex = 42,
			Parent = window,
			Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) })
		})

		cancelBtn.MouseButton1Click:Connect(function()
			Lib.PlayClick()
			Close(true)
		end)

		addBtn.MouseButton1Click:Connect(function()
			Lib.PlayClick()
			local name = string.match(nameBox.Text, "^%s*(.-)%s*$")
			if name == "" then name = "Custom " .. (#State.CustomThemes + 1) end
			local theme = { Name = name:sub(1, 24) }
			for _, key in ipairs(THEME_KEYS) do
				theme[key] = draft[key]
			end
			onAdd(theme)
			Close(false)
		end)

		SelectTab("Basic")
		Lib.GlassOpen(backdrop)
		Lib.Tween(window, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Size = UDim2.fromOffset(WIN_W, WIN_H) })
	end

	local function CreateThemePicker(parent, layoutOrder)
		local DESC = "Overall colour scheme applied to the application background"

		local ThemeSection = Lib.Create("Frame", {
			Size = UDim2.new(1, 0, 0, 105),
			BackgroundColor3 = Color3.fromRGB(15, 15, 15),
			LayoutOrder = layoutOrder,
			Parent = parent,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) })
		})
		Lib.RegisterThemeElement(ThemeSection, "BackgroundColor3", 0.5)

		Lib.Create("ImageLabel", {
			Size = UDim2.fromOffset(18, 18),
			Position = UDim2.new(0, 14, 0, 12),
			BackgroundTransparency = 1,
			Image = "rbxassetid://92865789131206",
			ImageColor3 = Color3.fromRGB(220, 220, 220),
			ScaleType = Enum.ScaleType.Fit,
			Parent = ThemeSection
		})

		local thTitle = Lib.Create("TextLabel", {
			Size = UDim2.new(1, -50, 0, 18),
			Position = UDim2.new(0, 40, 0, 12),
			BackgroundTransparency = 1,
			Text = "Theme",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 14,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = ThemeSection
		})
		Lib.RegisterThemeText(thTitle, "Primary")

		local thDesc = Lib.Create("TextLabel", {
			Size = UDim2.new(1, -50, 0, 16),
			Position = UDim2.new(0, 40, 0, 30),
			BackgroundTransparency = 1,
			Text = DESC,
			TextColor3 = Color3.fromRGB(130, 130, 130),
			TextSize = 11,
			Font = Enum.Font.GothamMedium,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = ThemeSection
		})
		Lib.RegisterThemeText(thDesc, "Secondary")

		local ThemeHolder = Lib.Create("Frame", {
			Size = UDim2.new(1, -28, 0, 36),
			Position = UDim2.fromOffset(14, 52),
			BackgroundTransparency = 1,
			Parent = ThemeSection
		})
		local ThemeGrid = Lib.Create("UIGridLayout", {
			CellSize = UDim2.fromOffset(36, 36),
			CellPadding = UDim2.fromOffset(8, 8),
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = ThemeHolder
		})
		ThemeGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			local height = ThemeGrid.AbsoluteContentSize.Y
			ThemeHolder.Size = UDim2.new(1, -28, 0, height)
			ThemeSection.Size = UDim2.new(1, 0, 0, height + 68)
		end)

		local records = {}
		local plusBtn
		local Rebuild

		local function UpdateSelection()
			for index, record in pairs(records) do
				local selected = State.SelectedThemeIndex == index
				record.Badge.Visible = selected
				record.Stroke.Transparency = selected and 0 or 1
			end
		end

		function Lib.SelectTheme(index)
			local spec = Lib.ResolveTheme(index)
			if not spec then return end
			State.SelectedThemeIndex = index
			Lib.ApplyTheme(spec)
			UpdateSelection()
		end

		local function DeleteCustom(theme)
			local position = table.find(State.CustomThemes, theme)
			if not position then return end
			local index = #Lib.ThemePresets + position
			table.remove(State.CustomThemes, position)
			SaveCustomThemes()
			Rebuild()
			if State.SelectedThemeIndex == index then
				Lib.SelectTheme(1)
			elseif State.SelectedThemeIndex > index then
				State.SelectedThemeIndex = State.SelectedThemeIndex - 1
				UpdateSelection()
			end
		end

		local function AddSwatch(index, order, color, theme)
			local light = theme and Lib.Luma(theme.Background) > 0.6 or (not theme and color.R > 0.9 and color.G > 0.9 and color.B > 0.9)

			local Item = Lib.Create("TextButton", {
				Size = UDim2.fromOffset(36, 36),
				BackgroundColor3 = theme and Color3.new(1, 1, 1) or color,
				Text = "",
				AutoButtonColor = false,
				LayoutOrder = order,
				Parent = ThemeHolder,
				Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) })
			})

			if theme then
				Lib.Create("UIGradient", {
					Rotation = 45,
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, theme.Background),
						ColorSequenceKeypoint.new(0.4, theme.Background),
						ColorSequenceKeypoint.new(0.401, theme.Surface),
						ColorSequenceKeypoint.new(0.7, theme.Surface),
						ColorSequenceKeypoint.new(0.701, theme.Accent),
						ColorSequenceKeypoint.new(1, theme.Accent)
					}),
					Parent = Item
				})
			end

			if theme and theme.Halloween then
				Lib.Create("TextLabel", {
					Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "🎃", TextSize = 18, Font = Enum.Font.GothamBold, Parent = Item
				})
			end

			local Stroke = Lib.Create("UIStroke", {
				Color = light and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255),
				Thickness = 2,
				Transparency = 1,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Parent = Item
			})

			local CheckBadge = Lib.Create("Frame", {
				Size = UDim2.fromOffset(14, 14),
				Position = UDim2.new(0, 2, 0, 2),
				BackgroundColor3 = light and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0),
				Visible = false,
				Parent = Item,
				Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
				Lib.Create("TextLabel", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text = "✓",
					TextColor3 = light and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255),
					TextSize = 10,
					Font = Enum.Font.GothamBold
				})
			})

			records[index] = { Stroke = Stroke, Badge = CheckBadge }

			Item.MouseButton1Click:Connect(function()
				Lib.PlayClick()
				Lib.SelectTheme(index)
			end)

			if theme then
				local builtin = theme.Halloween
				Item.MouseEnter:Connect(function()
					thDesc.Text = builtin and theme.Name or (theme.Name .. "  ·  right-click to delete")
				end)
				Item.MouseLeave:Connect(function()
					thDesc.Text = DESC
				end)
				if not builtin then
					Item.MouseButton2Click:Connect(function()
						DeleteCustom(theme)
					end)
				end
			end
		end

		function Rebuild()
			for _, child in ipairs(ThemeHolder:GetChildren()) do
				if child:IsA("GuiButton") and child ~= plusBtn then child:Destroy() end
			end
			table.clear(records)
			thDesc.Text = DESC
			local presetCount = #Lib.ThemePresets
			for i, color in ipairs(Lib.ThemePresets) do
				AddSwatch(i, i, color)
			end
			AddSwatch(0, presetCount + 1, nil, Lib.HalloweenTheme)
			for k, theme in ipairs(State.CustomThemes) do
				AddSwatch(presetCount + k, presetCount + 2 + k, nil, theme)
			end
			UpdateSelection()
		end

		plusBtn = Lib.Create("TextButton", {
			Size = UDim2.fromOffset(36, 36),
			BackgroundTransparency = 1,
			Text = "+",
			TextColor3 = Lib.Palette.Secondary,
			TextSize = 22,
			Font = Enum.Font.GothamMedium,
			AutoButtonColor = false,
			LayoutOrder = #Lib.ThemePresets + 2,
			Parent = ThemeHolder,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
			Lib.Create("UIStroke", { Color = Color3.fromRGB(130, 130, 130), Thickness = 1, Transparency = 0.35, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
		})
		Lib.RegisterThemeText(plusBtn, "Secondary")

		plusBtn.MouseButton1Click:Connect(function()
			Lib.PlayClick()
			OpenThemeEditor(function(theme)
				table.insert(State.CustomThemes, theme)
				SaveCustomThemes()
				Rebuild()
				Lib.SelectTheme(#Lib.ThemePresets + #State.CustomThemes)
			end)
		end)

		LoadCustomThemes()
		Rebuild()
	end

	local function CreateFontPicker(parent, layoutOrder)
		local FontSection = Lib.Create("Frame", {
			Size = UDim2.new(1, 0, 0, 105),
			BackgroundColor3 = Color3.fromRGB(15, 15, 15),
			LayoutOrder = layoutOrder,
			Parent = parent,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) })
		})
		Lib.RegisterThemeElement(FontSection, "BackgroundColor3", 0.5)

		local fontIcon = Lib.Create("TextLabel", {
			Size = UDim2.fromOffset(18, 18),
			Position = UDim2.new(0, 14, 0, 12),
			BackgroundTransparency = 1,
			Text = "Aa",
			TextColor3 = Color3.fromRGB(220, 220, 220),
			TextSize = 13,
			Font = Enum.Font.GothamBold,
			Parent = FontSection
		})
		Lib.RegisterThemeText(fontIcon, "Primary")

		local fontTitle = Lib.Create("TextLabel", {
			Size = UDim2.new(1, -50, 0, 18),
			Position = UDim2.new(0, 40, 0, 12),
			BackgroundTransparency = 1,
			Text = "App Font",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 14,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = FontSection
		})
		Lib.RegisterThemeText(fontTitle, "Primary")

		local fontDesc = Lib.Create("TextLabel", {
			Size = UDim2.new(1, -50, 0, 16),
			Position = UDim2.new(0, 40, 0, 30),
			BackgroundTransparency = 1,
			Text = "Font used throughout the entire application",
			TextColor3 = Color3.fromRGB(130, 130, 130),
			TextSize = 11,
			Font = Enum.Font.GothamMedium,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = FontSection
		})
		Lib.RegisterThemeText(fontDesc, "Secondary")

		local FontListScroll = Lib.Create("ScrollingFrame", {
			Size = UDim2.new(1, -28, 0, 42),
			Position = UDim2.new(0, 14, 0, 52),
			BackgroundTransparency = 1,
			ScrollBarThickness = 0,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			Parent = FontSection
		})

		local FontListLayout = Lib.Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = FontListScroll
		})

		FontListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			FontListScroll.CanvasSize = UDim2.new(0, FontListLayout.AbsoluteContentSize.X + 10, 0, 0)
		end)

		local FontItems = {
			{ name = "Gotham", regular = Enum.Font.GothamMedium, bold = Enum.Font.GothamBold },
			{ name = "Ubuntu", regular = Enum.Font.Ubuntu, bold = Enum.Font.Ubuntu },
			{ name = "JosefinSans", regular = Enum.Font.JosefinSans, bold = Enum.Font.JosefinSans },
			{ name = "FredokaOne", regular = Enum.Font.FredokaOne, bold = Enum.Font.FredokaOne },
			{ name = "SciFi", regular = Enum.Font.SciFi, bold = Enum.Font.SciFi },
			{ name = "BuilderSans", regular = Enum.Font.BuilderSansMedium, bold = Enum.Font.BuilderSansBold },
			{ name = "Roboto", regular = Enum.Font.Roboto, bold = Enum.Font.Roboto },
			{ name = "Nunito", regular = Enum.Font.Nunito, bold = Enum.Font.Nunito },
			{ name = "Oswald", regular = Enum.Font.Oswald, bold = Enum.Font.Oswald },
			{ name = "Titillium", regular = Enum.Font.TitilliumWeb, bold = Enum.Font.TitilliumWeb },
			{ name = "Michroma", regular = Enum.Font.Michroma, bold = Enum.Font.Michroma },
			{ name = "Jura", regular = Enum.Font.Jura, bold = Enum.Font.Jura },
			{ name = "SourceSans", regular = Enum.Font.SourceSans, bold = Enum.Font.SourceSansBold },
			{ name = "Merriweather", regular = Enum.Font.Merriweather, bold = Enum.Font.Merriweather }
		}

		local fontBtns = {}

		for i, fData in ipairs(FontItems) do
			local isSelected = (State.SelectedFontIndex == i)

			local Item = Lib.Create("TextButton", {
				Size = UDim2.fromOffset(36, 36),
				BackgroundColor3 = Color3.fromRGB(22, 22, 22),
				Text = "Aa",
				TextColor3 = Color3.fromRGB(240, 240, 240),
				TextSize = 14,
				Font = fData.bold,
				AutoButtonColor = false,
				LayoutOrder = i,
				Parent = FontListScroll,
				Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) })
			})
			Lib.RegisterThemeElement(Item, "BackgroundColor3", 0.7)
			Lib.RegisterThemeText(Item, "Primary")

			local Stroke = Lib.Create("UIStroke", {
				Color = Color3.fromRGB(255, 255, 255),
				Thickness = 1.5,
				Transparency = isSelected and 0 or 1,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Parent = Item
			})

			local CheckBadge = Lib.Create("Frame", {
				Size = UDim2.fromOffset(13, 13),
				Position = UDim2.new(0, 1, 0, 1),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Visible = isSelected,
				Parent = Item,
				Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
				Lib.Create("TextLabel", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text = "✓",
					TextColor3 = Color3.fromRGB(0, 0, 0),
					TextSize = 9,
					Font = Enum.Font.GothamBold
				})
			})

			fontBtns[i] = { Item = Item, Stroke = Stroke, Badge = CheckBadge, Data = fData }

			Lib.FontSelectors[i] = function()
				State.SelectedFontIndex = i
				for idx, btnInfo in ipairs(fontBtns) do
					local sel = (idx == i)
					btnInfo.Badge.Visible = sel
					btnInfo.Stroke.Transparency = sel and 0 or 1
				end
				Lib.ApplyGlobalFont(fData.regular, fData.bold)
			end

			Item.MouseButton1Click:Connect(function()
				Lib.PlayClick()
				Lib.FontSelectors[i]()
			end)
		end
	end

	CreateThemePicker(AppearanceScroll, 1)
	CreateFontPicker(AppearanceScroll, 2)

	local WindowStyleGroup = Lib.CreateFeatureGroup(AppearanceScroll, "Window Customization", 3)
	Lib.CreateSettingSliderItem(WindowStyleGroup, "Corner Radius", "Adjust the roundness of the main window corners", 0, 28, State.CornerRadius, function(val)
		Lib.SetCornerRadius(val)
	end)
	Lib.CreateSettingSliderItem(WindowStyleGroup, "Window Transparency", "Adjust overall background window opacity", 0, 80, State.WindowTransparency, function(val)
		State.WindowTransparency = val
		UI.Main.BackgroundTransparency = val / 100
	end)
	Lib.CreateSettingSliderItem(WindowStyleGroup, "Panel Transparency", "Adjust opacity of the setting panels and cards", 0, 70, State.PanelTransparency, function(val)
		if val == State.PanelTransparency then return end
		State.PanelTransparency = val
		Lib.ApplyPanelTransparency()
	end)
	Lib.CreateSettingToggleItem(WindowStyleGroup, "Hide Logo", "Hides the icon in the main window header", State.HideLogo, function(val)
		State.HideLogo = val
		Lib.ApplyHeader()
	end)
	Lib.CreateSettingToggleItem(WindowStyleGroup, "Hide Name", "Hides the title next to the logo in the main window header", State.HideName, function(val)
		State.HideName = val
		Lib.ApplyHeader()
	end)
	Lib.CreateSettingChoiceItem(WindowStyleGroup, "Menu Animation", { "Standard", "Slide Up", "Unfold" }, State.MenuAnim, function(value)
		State.MenuAnim = value
	end, true)
	Lib.ConfigExtras.MenuAnim = {
		Dump = function() return { Value = State.MenuAnim } end,
		Apply = function(data)
			local control = Lib.ChoiceControls["Menu Animation"]
			if control and data.Value then control.Set(data.Value) end
		end
	}

	local NotificationSettingsGroup = Lib.CreateFeatureGroup(AppearanceScroll, "Notification System", 4)
	Lib.CreateSettingToggleItem(NotificationSettingsGroup, "System Notifications", "Enable or disable custom GUI notifications popup", State.NotificationsEnabled, function(val)
		State.NotificationsEnabled = val
	end)
	Lib.CreateSettingToggleItem(NotificationSettingsGroup, "Player Activity Notifications", "Show alerts when players join or leave the server", State.PlayerNotifsEnabled, function(val)
		State.PlayerNotifsEnabled = val
	end, true)

	local CustomBgGroup = Lib.CreateFeatureGroup(AppearanceScroll, "Custom & Animated Background", 5)
	local BgCard = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 52), BackgroundTransparency = 1, Parent = CustomBgGroup })

	local bgInput = Lib.Create("TextBox", {
		Size = UDim2.new(1, -166, 0, 36),
		Position = UDim2.new(0, 12, 0, 8),
		BackgroundColor3 = Color3.fromRGB(22, 22, 22),
		PlaceholderText = "Paste Asset ID or Image URL...",
		PlaceholderColor3 = Color3.fromRGB(110, 110, 110),
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextSize = 12,
		Font = Enum.Font.GothamMedium,
		Text = State.CustomBackgroundId,
		ClearTextOnFocus = false,
		Parent = BgCard,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
		Lib.Create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) })
	})
	Lib.RegisterThemeElement(bgInput, "BackgroundColor3", 0.7, true)
	Lib.RegisterThemeText(bgInput, "Primary")

	local function UpdateBg()
		local val = bgInput.Text:match("^%s*(.-)%s*$")
		State.CustomBackgroundId = val
		local image = UI.CustomBgImage
		if val == "" then
			image.Visible = false
			Lib.BgAssetId, Lib.BgResolved = nil, nil
			Lib.RefreshBgSaturation()
			return
		end
		local resolved, id = Lib.ResolveImage(val)
		image.Image = resolved
		image.Visible = true
		Lib.BgResolved, Lib.BgAssetId = resolved, id
		Lib.RefreshBgSaturation()
		if id then
			task.delay(2, function()
				if image.Image == resolved and not image.IsLoaded then
					image.Image = "rbxthumb://type=Asset&id=" .. id .. "&w=420&h=420"
				end
			end)
		end
	end

	do
		local FILE = "SeptusHub_Backgrounds.json"
		local saved = {}

		if isfile and readfile then
			pcall(function()
				if not isfile(FILE) then return end
				for _, value in ipairs(Services.HttpService:JSONDecode(readfile(FILE))) do
					if type(value) == "string" and value ~= "" then saved[#saved + 1] = value end
				end
			end)
		end

		local function Persist()
			if writefile then pcall(writefile, FILE, Services.HttpService:JSONEncode(saved)) end
		end

		local applyBtn = Lib.Create("TextButton", {
			Size = UDim2.fromOffset(70, 36), Position = UDim2.new(1, -148, 0, 8), BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Text = "Apply", TextColor3 = Color3.fromRGB(0, 0, 0), TextSize = 12, Font = Enum.Font.GothamBold, Parent = BgCard,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
		})
		local saveBtn = Lib.Create("TextButton", {
			Size = UDim2.fromOffset(60, 36), Position = UDim2.new(1, -72, 0, 8), BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Text = "Save", TextColor3 = Color3.fromRGB(0, 0, 0), TextSize = 12, Font = Enum.Font.GothamBold, Parent = BgCard,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
		})

		local SavedFrame = Lib.Create("Frame", {
			Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = CustomBgGroup,
			Lib.Create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
			Lib.Create("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingBottom = UDim.new(0, 10) })
		})

		local function Rebuild()
			for _, child in ipairs(SavedFrame:GetChildren()) do
				if child:IsA("GuiObject") then child:Destroy() end
			end

			local header = Lib.Create("TextLabel", {
				Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Text = #saved == 0 and "No saved backgrounds yet" or "Saved Asset IDs",
				TextColor3 = Color3.fromRGB(150, 150, 150), TextSize = 11, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left,
				LayoutOrder = 0, Parent = SavedFrame
			})
			Lib.RegisterThemeText(header, "Secondary")

			for i, id in ipairs(saved) do
				local resolved, numeric = Lib.ResolveImage(id)
				local item = Lib.Create("Frame", {
					Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = Color3.fromRGB(22, 22, 22), LayoutOrder = i, Parent = SavedFrame,
					Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
				})
				Lib.RegisterThemeElement(item, "BackgroundColor3", 0.7, true)

				Lib.Create("ImageLabel", {
					Size = UDim2.fromOffset(38, 38), Position = UDim2.fromOffset(6, 6), BackgroundColor3 = Color3.fromRGB(40, 40, 40),
					Image = numeric and ("rbxthumb://type=Asset&id=" .. numeric .. "&w=150&h=150") or resolved,
					ScaleType = Enum.ScaleType.Crop, Parent = item,
					Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
				})

				local label = Lib.Create("TextLabel", {
					Size = UDim2.new(1, -152, 1, 0), Position = UDim2.fromOffset(54, 0), BackgroundTransparency = 1, Text = numeric or id,
					TextColor3 = Color3.fromRGB(240, 240, 240), TextSize = 12, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd, Parent = item
				})
				Lib.RegisterThemeText(label, "Primary")

				local useBtn = Lib.Create("TextButton", {
					Size = UDim2.fromOffset(50, 28), Position = UDim2.new(1, -88, 0.5, -14), BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Text = "Use", TextColor3 = Color3.fromRGB(0, 0, 0), TextSize = 11, Font = Enum.Font.GothamBold, Parent = item,
					Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
				})
				local deleteBtn = Lib.Create("TextButton", {
					Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, -34, 0.5, -14), BackgroundColor3 = Color3.fromRGB(220, 50, 50),
					Text = "×", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 14, Font = Enum.Font.GothamBold, Parent = item,
					Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
				})

				useBtn.MouseButton1Click:Connect(function()
					Lib.PlayClick()
					bgInput.Text = id
					UpdateBg()
					Lib.Notify({ Title = "Background", Text = "Custom background applied!" })
				end)
				deleteBtn.MouseButton1Click:Connect(function()
					Lib.PlayClick()
					table.remove(saved, i)
					Persist()
					Rebuild()
				end)
			end
		end

		applyBtn.MouseButton1Click:Connect(function()
			Lib.PlayClick()
			UpdateBg()
			Lib.Notify({ Title = "Background", Text = "Custom background applied!" })
		end)

		saveBtn.MouseButton1Click:Connect(function()
			Lib.PlayClick()
			local val = bgInput.Text:match("^%s*(.-)%s*$")
			if val == "" then
				Lib.Notify({ Title = "Background", Text = "Enter an Asset ID first" })
			elseif table.find(saved, val) then
				Lib.Notify({ Title = "Background", Text = "Already saved" })
			elseif #saved >= 40 then
				Lib.Notify({ Title = "Background", Text = "Saved list is full" })
			else
				saved[#saved + 1] = val
				Persist()
				Rebuild()
				Lib.Notify({ Title = "Background", Text = "Asset ID saved" })
			end
		end)

		Rebuild()
	end

	Lib.CreateSettingToggleItem(CustomBgGroup, "Animated Drift Effect", "Slowly pans and animates the custom background image", State.AnimatedBgEnabled, function(val)
		State.AnimatedBgEnabled = val
		if not val then
			Lib.Tween(UI.CustomBgImage, 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, { Position = UDim2.fromScale(0.5, 0.5), Size = Lib.BgSize(1) })
		end
	end)
	Lib.CreateSettingSliderItem(CustomBgGroup, "Background Opacity", "How visible the custom background image is", 10, 100, State.BgOpacity, function(val)
		State.BgOpacity = val
		UI.CustomBgImage.ImageTransparency = (100 - val) / 100
	end)
	Lib.CreateSettingSliderItem(CustomBgGroup, "Background Zoom", "Enlarges the image so corners baked into it get cropped by the window", 100, 160, State.BgZoom, function(val)
		State.BgZoom = val
		if not State.AnimatedBgEnabled then UI.CustomBgImage.Size = Lib.BgSize(1) end
	end)
	Lib.CreateSettingSliderItem(CustomBgGroup, "Background Saturation", "Color intensity of the custom background image", 0, 200, State.BgSaturation, function(val)
		State.BgSaturation = val
		Lib.QueueBgSaturation()
	end, true, "%")

do
	local FILE = "SeptusHub_Sounds.json"
	local Http, Market, Debris = Services.HttpService, game:GetService("MarketplaceService"), game:GetService("Debris")
	local Presets = {
		{ "Default", "rbxassetid://6895079853", 1, 0.5 },
		{ "Soft Tick", "rbxassetid://6895079853", 1.35, 0.35 },
		{ "Deep Tap", "rbxassetid://6895079853", 0.78, 0.45 },
		{ "Airy", "rbxassetid://6895079853", 1.7, 0.3 },
		{ "Switch", "rbxasset://sounds/switch.ogg", 1, 0.4 },
		{ "Snap", "rbxasset://sounds/snap.mp3", 1, 0.3 },
		{ "Ping", "rbxasset://sounds/electronicpingshort.wav", 1, 0.25 },
		{ "Off", "", 1, 0 }
	}
	local custom, selected, busy, Rebuild = {}, "p:Default", false, nil

	local function Resolve(key)
		local kind, value = key:match("^(%a):(.+)$")
		if kind == "p" then
			for _, preset in ipairs(Presets) do
				if preset[1] == value then return preset[2], preset[3], preset[4] end
			end
		elseif kind == "c" then
			for _, entry in ipairs(custom) do
				if entry.id == value then return "rbxassetid://" .. value, 1, 0.5 end
			end
		end
	end

	local function Persist()
		if not writefile then return end
		local out = {}
		for i, entry in ipairs(custom) do out[i] = { id = entry.id, name = entry.name } end
		pcall(writefile, FILE, Http:JSONEncode({ selected = selected, custom = out }))
	end

	local function Apply()
		local id, speed, volume = Resolve(selected)
		ClickSound.SoundId, ClickSound.PlaybackSpeed, ClickSound.Volume = id, speed, volume
	end

	local function Preview(key)
		local id, speed, volume = Resolve(key)
		if not id or id == "" then return end
		local sound = Instance.new("Sound")
		sound.SoundId, sound.PlaybackSpeed, sound.Volume = id, speed, volume
		sound.Parent = Services.SoundService
		sound:Play()
		Debris:AddItem(sound, 6)
	end

	local function Probe(id)
		local probe = Instance.new("Sound")
		probe.SoundId, probe.Volume = "rbxassetid://" .. id, 0
		probe.Parent = Services.SoundService
		local deadline = os.clock() + 5
		while not probe.IsLoaded and os.clock() < deadline do task.wait(0.1) end
		local loaded, length = probe.IsLoaded, probe.TimeLength
		probe:Destroy()
		return loaded and length > 0, length
	end

	if isfile and readfile then
		pcall(function()
			if not isfile(FILE) then return end
			local data = Http:JSONDecode(readfile(FILE))
			for _, entry in ipairs(data.custom or {}) do
				if type(entry) == "table" and tostring(entry.id):match("^%d+$") then
					custom[#custom + 1] = { id = tostring(entry.id), name = tostring(entry.name or entry.id) }
				end
			end
			if type(data.selected) == "string" then selected = data.selected end
		end)
	end
	if not Resolve(selected) then selected = "p:Default" end
	Apply()

	function Lib.SelectClickSound(key)
		if not Resolve(key) then return false end
		selected = key
		Apply()
		Persist()
		Rebuild()
		return true
	end

	function Lib.GetClickSoundKey()
		return selected
	end

	local SoundGroup = Lib.CreateFeatureGroup(AppearanceScroll, "Interface Sounds", 6)

	local AddCard = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 52), BackgroundTransparency = 1, LayoutOrder = 1, Parent = SoundGroup })
	local input = Lib.Create("TextBox", {
		Size = UDim2.new(1, -96, 0, 36), Position = UDim2.fromOffset(12, 8), BackgroundColor3 = Color3.fromRGB(22, 22, 22),
		PlaceholderText = "Paste a Sound Asset ID...", PlaceholderColor3 = Color3.fromRGB(110, 110, 110), TextColor3 = Color3.fromRGB(240, 240, 240),
		TextSize = 12, Font = Enum.Font.GothamMedium, Text = "", ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left, Parent = AddCard,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
		Lib.Create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) })
	})
	Lib.RegisterThemeElement(input, "BackgroundColor3", 0.7, true)
	Lib.RegisterThemeText(input, "Primary")

	local addBtn = Lib.Create("TextButton", {
		Size = UDim2.fromOffset(60, 36), Position = UDim2.new(1, -72, 0, 8), BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Text = "Add", TextColor3 = Color3.fromRGB(0, 0, 0), TextSize = 12, Font = Enum.Font.GothamBold, AutoButtonColor = false, Parent = AddCard,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
	})

	local list = Lib.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = 2, Parent = SoundGroup,
		Lib.Create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
		Lib.Create("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingBottom = UDim.new(0, 10) })
	})

	local function Row(label, key, order, removable)
		local active = key == selected
		local id = Resolve(key)
		local item = Lib.Create("Frame", {
			Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = Color3.fromRGB(22, 22, 22), LayoutOrder = order, Parent = list,
			Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
		})
		Lib.RegisterThemeElement(item, "BackgroundColor3", 0.7, true)

		local pick = Lib.Create("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, Parent = item })

		local dot = Lib.Create("TextLabel", {
			Size = UDim2.fromOffset(20, 40), Position = UDim2.fromOffset(10, 0), BackgroundTransparency = 1, Text = active and "\u{25CF}" or "\u{25CB}",
			TextColor3 = Color3.fromRGB(150, 150, 150), TextSize = 12, Font = Enum.Font.GothamBold, Parent = item
		})
		Lib.RegisterThemeText(dot, active and "Primary" or "Secondary")

		local name = Lib.Create("TextLabel", {
			Size = UDim2.new(1, removable and -112 or -82, 1, 0), Position = UDim2.fromOffset(38, 0), BackgroundTransparency = 1, Text = label,
			TextColor3 = Color3.fromRGB(240, 240, 240), TextSize = 12, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd, Parent = item
		})
		Lib.RegisterThemeText(name, "Primary")

		pick.MouseButton1Click:Connect(function()
			if key ~= selected and Lib.SelectClickSound(key) then Preview(key) end
		end)

		if id ~= "" then
			local play = Lib.Create("TextButton", {
				Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, removable and -66 or -36, 0.5, -14), BackgroundTransparency = 1, Text = "\u{25B6}",
				TextColor3 = Color3.fromRGB(150, 150, 150), TextSize = 11, Font = Enum.Font.GothamBold, AutoButtonColor = false, Parent = item
			})
			Lib.RegisterThemeText(play, "Secondary")
			play.MouseButton1Click:Connect(function() Preview(key) end)
		end

		if removable then
			local remove = Lib.Create("TextButton", {
				Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, -34, 0.5, -14), BackgroundTransparency = 1, Text = "\u{00D7}",
				TextColor3 = Color3.fromRGB(150, 150, 150), TextSize = 16, Font = Enum.Font.GothamBold, AutoButtonColor = false, Parent = item
			})
			Lib.RegisterThemeText(remove, "Secondary")
			remove.MouseButton1Click:Connect(function()
				Lib.PlayClick()
				local value = key:sub(3)
				for i, entry in ipairs(custom) do
					if entry.id == value then
						table.remove(custom, i)
						break
					end
				end
				if selected == key then
					selected = "p:Default"
					Apply()
				end
				Persist()
				Rebuild()
			end)
		end
	end

	function Rebuild()
		for _, child in ipairs(list:GetChildren()) do
			if child:IsA("GuiObject") then child:Destroy() end
		end
		local header = Lib.Create("TextLabel", {
			Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Text = "Click sound", LayoutOrder = 0,
			TextColor3 = Color3.fromRGB(150, 150, 150), TextSize = 11, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, Parent = list
		})
		Lib.RegisterThemeText(header, "Secondary")
		local order = 0
		for _, preset in ipairs(Presets) do
			order += 1
			Row(preset[1], "p:" .. preset[1], order, false)
		end
		for _, entry in ipairs(custom) do
			order += 1
			Row(entry.name, "c:" .. entry.id, order, true)
		end
	end

	addBtn.MouseButton1Click:Connect(function()
		Lib.PlayClick()
		if busy then return end
		local text = input.Text:match("^%s*(.-)%s*$")
		local id = text:match("^%d+$") or text:match("rbxassetid://(%d+)") or text:match("[?&]id=(%d+)") or text:match("/library/(%d+)") or text:match("(%d%d%d%d+)")
		if not id then
			Lib.Notify({ Title = "Sounds", Text = "Invalid Asset ID" })
			return
		end
		for _, entry in ipairs(custom) do
			if entry.id == id then
				Lib.Notify({ Title = "Sounds", Text = "Already saved" })
				return
			end
		end
		if #custom >= 30 then
			Lib.Notify({ Title = "Sounds", Text = "Saved list is full" })
			return
		end
		busy = true
		task.spawn(function()
			local ok, length = Probe(id)
			busy = false
			if State.Unloaded then return end
			if not ok then
				Lib.Notify({ Title = "Sounds", Text = "Sound failed to load" })
				return
			end
			if length > 5 then
				Lib.Notify({ Title = "Sounds", Text = "Sound is too long (max 5 seconds)" })
				return
			end
			local entry = { id = id, name = "Sound " .. id }
			custom[#custom + 1] = entry
			input.Text = ""
			Persist()
			Rebuild()
			Preview("c:" .. id)
			Lib.Notify({ Title = "Sounds", Text = "Sound saved" })
			local good, info = pcall(Market.GetProductInfo, Market, tonumber(id))
			if good and type(info) == "table" and info.Name and info.Name ~= "" and table.find(custom, entry) then
				entry.name = info.Name
				Persist()
				Rebuild()
			end
		end)
	end)

	Rebuild()
end
	Lib.BuildMusic(Lib.CreateFeatureGroup(AppearanceScroll, "Music", 7))

	task.spawn(function()
		while not State.Unloaded do
			if State.AnimatedBgEnabled and UI.CustomBgImage.Visible then
				Lib.Tween(UI.CustomBgImage, 4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, { Position = UDim2.fromScale(0.47, 0.47), Size = Lib.BgSize(1.1) })
				task.wait(4)
				Lib.Tween(UI.CustomBgImage, 4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, { Position = UDim2.fromScale(0.5, 0.5), Size = Lib.BgSize(1) })
				task.wait(4)
			else
				task.wait(1)
			end
		end
	end)

	local ConfigScroll = Lib.Create("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1, ScrollBarThickness = 2,
		ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100), BorderSizePixel = 0,
		Parent = View_Config
	})
	local CfgLayout = Lib.Create("UIListLayout", { Padding = UDim.new(0, 16), SortOrder = Enum.SortOrder.LayoutOrder, Parent = ConfigScroll })
	Lib.Create("UIPadding", { PaddingTop = UDim.new(0, 5), PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 15), Parent = ConfigScroll })

	CfgLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		ConfigScroll.CanvasSize = UDim2.new(0, 0, 0, CfgLayout.AbsoluteContentSize.Y + 20)
	end)

	local ManageConfigGroup = Lib.CreateFeatureGroup(ConfigScroll, "Create & Save Configuration", 1)
	local CreateCfgCard = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 50), BackgroundTransparency = 1, Parent = ManageConfigGroup })

	local cfgNameInput = Lib.Create("TextBox", {
		Size = UDim2.new(1, -110, 0, 36),
		Position = UDim2.new(0, 12, 0, 7),
		BackgroundColor3 = Color3.fromRGB(22, 22, 22),
		PlaceholderText = "Enter config name...",
		PlaceholderColor3 = Color3.fromRGB(110, 110, 110),
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextSize = 12,
		Font = Enum.Font.GothamMedium,
		Text = "",
		ClearTextOnFocus = false,
		Parent = CreateCfgCard,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
		Lib.Create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) })
	})
	Lib.RegisterThemeElement(cfgNameInput, "BackgroundColor3", 0.7, true)
	Lib.RegisterThemeText(cfgNameInput, "Primary")

	local saveCfgBtn = Lib.Create("TextButton", {
		Size = UDim2.fromOffset(90, 36),
		Position = UDim2.new(1, -94, 0, 7),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Text = "Save",
		TextColor3 = Color3.fromRGB(0, 0, 0),
		TextSize = 12,
		Font = Enum.Font.GothamBold,
		Parent = CreateCfgCard,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
	})

	local SavedConfigsGroup = Lib.CreateFeatureGroup(ConfigScroll, "Saved Profiles", 2)
	local SavedListContainer = Lib.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = SavedConfigsGroup,
		Lib.Create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder })
	})

	local CONFIG_FOLDER = "SeptusHub_Configs"
	local AUTO_FILE = "SeptusHub_AutoLoad.txt"
	local autoName
	pcall(function()
		if isfile and isfile(AUTO_FILE) then
			local saved = readfile(AUTO_FILE):match("^%s*(.-)%s*$")
			autoName = saved ~= "" and saved or nil
		end
	end)
	pcall(function()
		if makefolder and not isfolder(CONFIG_FOLDER) then
			makefolder(CONFIG_FOLDER)
		end
	end)

	local ConfigFields = {
		{ "CornerRadius", "CornerRadius", "Corner Radius" },
		{ "WindowTransparency", "WindowTransparency", "Window Transparency" },
		{ "PanelTransparency", "PanelTransparency", "Panel Transparency" },
		{ "BgOpacity", "BgOpacity", "Background Opacity" },
		{ "BgZoom", "BgZoom", "Background Zoom" },
		{ "BgSaturation", "BgSaturation", "Background Saturation" },
		{ "MusicVolume", "MusicVolume", "Volume" },
		{ "WalkSpeed", "WalkSpeed", "Walk Speed" },
		{ "JumpPower", "JumpPower", "Jump Power" },
		{ "FlySpeed", "FlySpeed", "Fly Speed" },
		{ "FOV", "FOV", "Fov Changer" },
		{ "HideLogo", "HideLogo", "Hide Logo", true },
		{ "HideName", "HideName", "Hide Name", true },
		{ "AnimatedBg", "AnimatedBgEnabled", "Animated Drift Effect", true },
		{ "NotificationsEnabled", "NotificationsEnabled", "System Notifications", true },
		{ "PlayerNotifsEnabled", "PlayerNotifsEnabled", "Player Activity Notifications", true },
		{ "FlyAntiSit", "FlyAntiSit", "Prevent Seating in Flight", true },
		{ "MusicFocus", "MusicFocus", "Only When Focused", true },
		{ "MusicVisualizer", "MusicVisualizer", "Titlebar Visualizer", true }
	}

	local function GetStateDump()
		local dump = { ThemeIndex = State.SelectedThemeIndex, FontIndex = State.SelectedFontIndex, CustomBg = State.CustomBackgroundId, ClickSound = Lib.GetClickSoundKey() }
		for _, field in ipairs(ConfigFields) do
			dump[field[1]] = State[field[2]]
		end
		local extras = {}
		for name, hook in pairs(Lib.ConfigExtras) do extras[name] = hook.Dump() end
		dump.Extras = extras
		return dump
	end

	local function ApplyStateDump(data)
		if type(data) ~= "table" then return end
		if data.ThemeIndex and Lib.ResolveTheme(data.ThemeIndex) then
			Lib.SelectTheme(data.ThemeIndex)
		end
		local selectFont = data.FontIndex and Lib.FontSelectors[data.FontIndex]
		if selectFont then selectFont() end
		if type(data.ClickSound) == "string" then Lib.SelectClickSound(data.ClickSound) end
		for _, field in ipairs(ConfigFields) do
			local value = data[field[1]]
			if value ~= nil then
				local toggle = field[4]
				local control = (toggle and Lib.ToggleControls or Lib.SliderControls)[field[3]]
				if not control then
					State[field[2]] = value
				elseif toggle then
					control.Set(value)
				else
					control(value)
				end
			end
		end
		if type(data.Extras) == "table" then
			for name, hook in pairs(Lib.ConfigExtras) do
				if type(data.Extras[name]) == "table" then hook.Apply(data.Extras[name]) end
			end
		end
		if data.CustomBg ~= nil then
			State.CustomBackgroundId = data.CustomBg
			bgInput.Text = data.CustomBg
			UpdateBg()
		end
	end

	local function RefreshConfigsList()
		for _, c in ipairs(SavedListContainer:GetChildren()) do
			if c:IsA("Frame") then c:Destroy() end
		end

		if not listfiles then return end
		local files = {}
		pcall(function() files = listfiles(CONFIG_FOLDER) end)

		local count = 0
		for _, f in ipairs(files) do
			if f:match("%.json$") then
				count = count + 1
				local cName = f:match("([^/\\]+)%.json$") or f
				local item = Lib.Create("Frame", {
					Size = UDim2.new(1, 0, 0, 44),
					BackgroundColor3 = Color3.fromRGB(22, 22, 22),
					Parent = SavedListContainer,
					Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
				})
				Lib.RegisterThemeElement(item, "BackgroundColor3", 0.7, true)

				local nameLabel = Lib.Create("TextLabel", {
					Size = UDim2.new(1, -255, 1, 0),
					Position = UDim2.new(0, 14, 0, 0),
					BackgroundTransparency = 1,
					Text = cName,
					TextColor3 = Color3.fromRGB(240, 240, 240),
					TextSize = 12,
					Font = Enum.Font.GothamBold,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = item
				})
				Lib.RegisterThemeText(nameLabel, "Primary")

				local loadBtn = Lib.Create("TextButton", {
					Size = UDim2.fromOffset(65, 28),
					Position = UDim2.new(1, -145, 0.5, -14),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Text = "Load",
					TextColor3 = Color3.fromRGB(0, 0, 0),
					TextSize = 11,
					Font = Enum.Font.GothamBold,
					Parent = item,
					Lib.Create("UICorner", { CornerRadius = UDim.new(0, 4) })
				})

				local isAuto = autoName == cName
				local autoLabel = Lib.Create("TextLabel", {
					Size = UDim2.fromOffset(60, 28),
					Position = UDim2.new(1, -241, 0.5, -14),
					BackgroundTransparency = 1,
					Text = "Auto Load",
					TextColor3 = Color3.fromRGB(150, 150, 150),
					TextSize = 11,
					Font = Enum.Font.GothamMedium,
					TextXAlignment = Enum.TextXAlignment.Right,
					Parent = item
				})
				Lib.RegisterThemeText(autoLabel, "Secondary")

				local autoBox = Lib.Create("TextButton", {
					Size = UDim2.fromOffset(20, 20),
					Position = UDim2.new(1, -173, 0.5, -10),
					BackgroundColor3 = isAuto and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(35, 35, 35),
					Text = isAuto and "\u{2713}" or "",
					TextColor3 = Color3.fromRGB(0, 0, 0),
					TextSize = 13,
					Font = Enum.Font.GothamBold,
					AutoButtonColor = false,
					Parent = item,
					Lib.Create("UICorner", { CornerRadius = UDim.new(0, 5) })
				})

				autoBox.MouseButton1Click:Connect(function()
					Lib.PlayClick()
					autoName = (not isAuto) and cName or nil
					if writefile then pcall(writefile, AUTO_FILE, autoName or "") end
					RefreshConfigsList()
					Lib.Notify({ Title = "Config", Text = autoName and ("Auto-load: " .. cName) or "Auto-load disabled" })
				end)

				local deleteBtn = Lib.Create("TextButton", {
					Size = UDim2.fromOffset(65, 28),
					Position = UDim2.new(1, -74, 0.5, -14),
					BackgroundColor3 = Color3.fromRGB(35, 35, 35),
					Text = "Delete",
					TextColor3 = Color3.fromRGB(220, 80, 80),
					TextSize = 11,
					Font = Enum.Font.GothamBold,
					Parent = item,
					Lib.Create("UICorner", { CornerRadius = UDim.new(0, 4) })
				})

				loadBtn.MouseButton1Click:Connect(function()
					Lib.PlayClick()
					pcall(function()
						local content = readfile(f)
						local dump = Services.HttpService:JSONDecode(content)
						ApplyStateDump(dump)
						Lib.Notify({ Title = "Config", Text = "Loaded config: " .. cName })
					end)
				end)

				deleteBtn.MouseButton1Click:Connect(function()
					Lib.PlayClick()
					pcall(function()
						if delfile then delfile(f) end
						if autoName == cName then
							autoName = nil
							pcall(writefile, AUTO_FILE, "")
						end
						RefreshConfigsList()
						Lib.Notify({ Title = "Config", Text = "Deleted config: " .. cName })
					end)
				end)
			end
		end

		if count == 0 then
			local empty = Lib.Create("TextLabel", {
				Size = UDim2.new(1, 0, 0, 36),
				BackgroundTransparency = 1,
				Text = "No saved configs found.",
				TextColor3 = Color3.fromRGB(120, 120, 120),
				TextSize = 12,
				Font = Enum.Font.GothamMedium,
				Parent = SavedListContainer
			})
			Lib.RegisterThemeText(empty, "Secondary")
		end
	end

	saveCfgBtn.MouseButton1Click:Connect(function()
		Lib.PlayClick()
		local name = cfgNameInput.Text
		if name == "" then name = "Default" end
		if writefile then
			local dump = GetStateDump()
			local json = Services.HttpService:JSONEncode(dump)
			pcall(writefile, CONFIG_FOLDER .. "/" .. name .. ".json", json)
			RefreshConfigsList()
			Lib.Notify({ Title = "Config", Text = "Saved config: " .. name })
		end
	end)

	RefreshConfigsList()

	if autoName then
		task.defer(function()
			pcall(function()
				local path = CONFIG_FOLDER .. "/" .. autoName .. ".json"
				if isfile(path) then
					ApplyStateDump(Services.HttpService:JSONDecode(readfile(path)))
					Lib.Notify({ Title = "Config", Text = "Auto-loaded config: " .. autoName })
				end
			end)
		end)
	end
end

Lib.FeatureToggles = {
	"Bunny Hop", "Esp Name", "ESP Outline", "Box ESP", "Tracers", "Boost FPS", "FullBright", "Remove Texture", "Part Deleted",
	"Fly", "Anti Fling", "Anti Sit", "Anti Void", "Anti Stun", "Anti Ragdoll", "RTX Realistic", "Cyberpunk Neon", "Silent Hill Fog",
	"Stalk Active", "Complete Suspension", "Usual Lag", "Anti-AFK", "Noclip", "Invisibility", "Auto Reconnect", "Teleport Tool",
	"Cframe Aim", "Mouse Aim", "Silent Aim", "Trigger Bot", "Zero Recoil", "Zero Spread"
}

function Lib.Unload()
	if State.Unloaded then return end
	local unanchor = State.StalkActive or State.FakeLagUsual
	State.Unloaded = true

	for _, title in ipairs(Lib.FeatureToggles) do
		local control = Lib.ToggleControls[title]
		if control and control.Get() then pcall(control.Set, false) end
	end

	State.FlingTarget = nil
	for _, name in ipairs({ "StopBring", "StopMacro", "StopCurrentEmote", "ClearAllESP", "StopMusic", "ReleaseBgSaturation", "StopCombat" }) do
		local cleanup = Lib[name]
		if cleanup then pcall(cleanup) end
	end

	for _, tool in pairs(Refs.Tools) do pcall(tool.Destroy, tool) end
	if Refs.ShaderFolder then Refs.ShaderFolder:Destroy() end

	local char = App.Player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if root and unanchor then root.Anchored = false end
	if hum then
		if Refs.OrigHum == hum then
			hum.WalkSpeed, hum.UseJumpPower, hum.JumpPower = Refs.OrigWS, Refs.OrigUJP, Refs.OrigJP
		end
		App.Camera.CameraSubject = hum
	end
	App.Camera.FieldOfView = Refs.OrigFOV

	for _, connection in ipairs(Lib.Conns) do connection:Disconnect() end
	table.clear(Lib.Conns)
	ClickSound:Destroy()
end

function Lib.SwitchMainTab(tab)
	if State.ActiveMain == tab then return end
	State.ActiveMain = tab
	Lib.RecalculateNavPositions()

	UI.HomeSection.Visible = (tab == "Home")
	UI.FeaturesSection.Visible = (tab == "Features")
	UI.ScriptsSection.Visible = (tab == "Scripts")
	UI.EmotesSection.Visible = (tab == "Emotes")
	UI.SettingsSection.Visible = (tab == "Settings")

	if tab == "Scripts" then
		if not State.ScriptsCache[1] and not State.ScriptsLoading and Lib.LoadScriptsPage then
			Lib.LoadScriptsPage(1)
		end
	elseif tab == "Emotes" then
		local currentCache = (State.EmotesCategory == "Emotes") and State.EmotesCache or State.AnimationPacksCache
		if not currentCache[1] and not State.EmotesLoading and Lib.LoadEmotesPage then
			Lib.LoadEmotesPage(1)
		end
	end
end

local function StartLoadingSequence(Blur)
	Blur = Blur or Lib.Create("BlurEffect", { Name = "RavenScall_IntroBlur", Size = 0, Parent = Services.Lighting })
	Refs.IntroBlur = Blur

	Lib.Tween(Blur, 0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Size = 28 })

	local SplashModal = Lib.Create("CanvasGroup", {
		Name = "RavenScall_Splash",
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(10, 12, 18),
		BackgroundTransparency = 0.3,
		GroupTransparency = 1,
		ZIndex = 50,
		Parent = UI.Screen
	})

	local BgContainer = Lib.Create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		ZIndex = 50,
		Parent = SplashModal
	})

	local MonoGlow1 = Lib.Create("ImageLabel", {
		Size = UDim2.fromOffset(550, 550),
		Position = UDim2.new(0.2, 0, 0.3, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = "rbxassetid://1316045217",
		ImageColor3 = Color3.fromRGB(255, 255, 255),
		ImageTransparency = 0.93,
		ZIndex = 50,
		Parent = BgContainer
	})

	local MonoGlow2 = Lib.Create("ImageLabel", {
		Size = UDim2.fromOffset(600, 600),
		Position = UDim2.new(0.8, 0, 0.7, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = "rbxassetid://1316045217",
		ImageColor3 = Color3.fromRGB(180, 180, 180),
		ImageTransparency = 0.95,
		ZIndex = 50,
		Parent = BgContainer
	})

	local GridImage = Lib.Create("ImageLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Image = "rbxassetid://6071575925",
		ImageColor3 = Color3.fromRGB(255, 255, 255),
		ImageTransparency = 0.94,
		ScaleType = Enum.ScaleType.Tile,
		TileSize = UDim2.fromOffset(40, 40),
		ZIndex = 51,
		Parent = BgContainer
	})

	local Scanline = Lib.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 2),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.6,
		BorderSizePixel = 0,
		ZIndex = 52,
		Parent = BgContainer
	})
	Lib.Create("UIStroke", {
		Color = Color3.fromRGB(255, 255, 255),
		Thickness = 1,
		Transparency = 0.6,
		Parent = Scanline
	})

	local GlitchBarsContainer = Lib.Create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ZIndex = 51,
		Parent = BgContainer
	})

	local glitchBars = {}
	for i = 1, 6 do
		local bar = Lib.Create("Frame", {
			Size = UDim2.new(0, 0, 0, math.random(2, 5)),
			Position = UDim2.new(0, 0, math.random(5, 95) / 100, 0),
			BackgroundColor3 = (i % 2 == 0) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(120, 120, 120),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 51,
			Parent = GlitchBarsContainer
		})
		glitchBars[i] = bar
	end

	local CenterBox = Lib.Create("Frame", {
		Size = UDim2.fromOffset(460, 420),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		ZIndex = 53,
		Parent = SplashModal
	})

	local LogoContainer = Lib.Create("Frame", {
		Size = UDim2.fromOffset(130, 130),
		Position = UDim2.new(0.5, 0, 0.22, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		ZIndex = 54,
		Parent = CenterBox
	})

	local LogoGlow = Lib.Create("ImageLabel", {
		Size = UDim2.fromOffset(165, 165),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = "rbxassetid://113533839488998",
		ImageColor3 = Color3.fromRGB(255, 255, 255),
		ImageTransparency = 0.8,
		ScaleType = Enum.ScaleType.Fit,
		ZIndex = 54,
		Parent = LogoContainer
	})

	local LogoImg = Lib.Create("ImageLabel", {
		Size = UDim2.fromOffset(120, 120),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = "rbxassetid://113533839488998",
		ImageColor3 = Color3.fromRGB(255, 255, 255),
		ImageTransparency = 1,
		ScaleType = Enum.ScaleType.Fit,
		ZIndex = 55,
		Parent = LogoContainer
	})

	local TextGlitchContainer = Lib.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 90),
		Position = UDim2.new(0.5, 0, 0.58, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		ZIndex = 55,
		Parent = CenterBox
	})

	local TitleGhost1 = Lib.Create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 42),
		Position = UDim2.new(0.5, -2, 0, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Text = "RAVENSCALL",
		TextColor3 = Color3.fromRGB(100, 100, 100),
		TextSize = 34,
		Font = Enum.Font.SciFi,
		TextTransparency = 0.5,
		ZIndex = 55,
		Parent = TextGlitchContainer
	})

	local TitleGhost2 = Lib.Create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 42),
		Position = UDim2.new(0.5, 2, 0, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Text = "RAVENSCALL",
		TextColor3 = Color3.fromRGB(180, 180, 180),
		TextSize = 34,
		Font = Enum.Font.SciFi,
		TextTransparency = 0.5,
		ZIndex = 55,
		Parent = TextGlitchContainer
	})

	local TitleMain = Lib.Create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 42),
		Position = UDim2.new(0.5, 0, 0, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Text = "RAVENSCALL",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 34,
		Font = Enum.Font.SciFi,
		ZIndex = 56,
		Parent = TextGlitchContainer
	})

	local SubtitleProject = Lib.Create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 22),
		Position = UDim2.new(0.5, 0, 0.46, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Text = "—  M I N I M A L I S T I C  I N T E R F A C E  —",
		TextColor3 = Color3.fromRGB(160, 160, 160),
		TextSize = 11,
		Font = Enum.Font.RobotoMono,
		TextTransparency = 1,
		ZIndex = 56,
		Parent = TextGlitchContainer
	})

	local isMobileVersion = false

	local MobileToggleContainer = Lib.Create("TextButton", {
		Size = UDim2.fromOffset(180, 24),
		Position = UDim2.new(0.5, 0, 0.75, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 56,
		Parent = CenterBox
	})

	local MobileCheckbox = Lib.Create("Frame", {
		Size = UDim2.fromOffset(18, 18),
		Position = UDim2.new(0, 0, 0.5, -9),
		BackgroundColor3 = Color3.fromRGB(18, 18, 22),
		ZIndex = 57,
		Parent = MobileToggleContainer,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
		Lib.Create("UIStroke", { Color = Color3.fromRGB(100, 100, 100), Thickness = 1.2 })
	})

	local MobileCheckMark = Lib.Create("TextLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "✓",
		TextColor3 = Color3.fromRGB(0, 0, 0),
		TextSize = 12,
		Font = Enum.Font.GothamBold,
		Visible = false,
		ZIndex = 58,
		Parent = MobileCheckbox
	})

	local MobileToggleText = Lib.Create("TextLabel", {
		Size = UDim2.new(1, -26, 1, 0),
		Position = UDim2.new(0, 26, 0, 0),
		BackgroundTransparency = 1,
		Text = "Mobile Version (1.5x Smaller)",
		TextColor3 = Color3.fromRGB(190, 190, 190),
		TextSize = 11,
		Font = Enum.Font.RobotoMono,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 57,
		Parent = MobileToggleContainer
	})

	MobileToggleContainer.MouseButton1Click:Connect(function()
		Lib.PlayClick()
		isMobileVersion = not isMobileVersion
		MobileCheckMark.Visible = isMobileVersion
		Lib.Tween(MobileCheckbox, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
			BackgroundColor3 = isMobileVersion and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(18, 18, 22)
		})
		MobileToggleText.TextColor3 = isMobileVersion and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(190, 190, 190)
	end)

	local ButtonsRow = Lib.Create("Frame", {
		Size = UDim2.new(1, -40, 0, 44),
		Position = UDim2.new(0.5, 0, 0.88, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		ZIndex = 56,
		Parent = CenterBox,
		Lib.Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim.new(0, 16) })
	})

	local StartBtn = Lib.Create("TextButton", {
		Size = UDim2.fromOffset(160, 42),
		BackgroundColor3 = Color3.fromRGB(10, 10, 10),
		Text = "[ START_SYSTEM ]",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 12,
		Font = Enum.Font.RobotoMono,
		AutoButtonColor = false,
		ZIndex = 57,
		Parent = ButtonsRow,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
	})

	local StartStroke = Lib.Create("UIStroke", {
		Color = Color3.fromRGB(255, 255, 255),
		Thickness = 1.2,
		Transparency = 0.2,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = StartBtn
	})

	local GithubBtn = Lib.Create("TextButton", {
		Size = UDim2.fromOffset(160, 42),
		BackgroundColor3 = Color3.fromRGB(10, 10, 10),
		Text = "[ GITHUB_REPO ]",
		TextColor3 = Color3.fromRGB(200, 200, 200),
		TextSize = 12,
		Font = Enum.Font.RobotoMono,
		AutoButtonColor = false,
		ZIndex = 57,
		Parent = ButtonsRow,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
	})

	local GithubStroke = Lib.Create("UIStroke", {
		Color = Color3.fromRGB(120, 120, 120),
		Thickness = 1.2,
		Transparency = 0.4,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = GithubBtn
	})

	local function SetupCyberBtn(btn, stroke)
		btn.MouseEnter:Connect(function()
			Lib.Tween(btn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				TextColor3 = Color3.fromRGB(0, 0, 0),
				Size = UDim2.fromOffset(166, 44)
			})
			Lib.Tween(stroke, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
				Color = Color3.fromRGB(255, 255, 255),
				Transparency = 0
			})
		end)
		btn.MouseLeave:Connect(function()
			Lib.Tween(btn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
				BackgroundColor3 = Color3.fromRGB(10, 10, 10),
				TextColor3 = Color3.fromRGB(240, 240, 240),
				Size = UDim2.fromOffset(160, 42)
			})
			Lib.Tween(stroke, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
				Color = (btn == StartBtn) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(120, 120, 120),
				Transparency = (btn == StartBtn) and 0.2 or 0.4
			})
		end)
		btn.MouseButton1Down:Connect(function()
			Lib.PlayClick()
			Lib.Tween(btn, 0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
				Size = UDim2.fromOffset(154, 38)
			})
		end)
		btn.MouseButton1Up:Connect(function()
			Lib.Tween(btn, 0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
				Size = UDim2.fromOffset(166, 44)
			})
		end)
	end

	SetupCyberBtn(StartBtn, StartStroke)
	SetupCyberBtn(GithubBtn, GithubStroke)

	local isGlitching = true
	local glitchCharacters = {"0", "1", "/", "X", "[", "]", "#", "_", "%", "$", "§", "▓", "▒"}
	local baseTitleText = "RAVENSCALL"

	task.spawn(function()
		while isGlitching do
			Lib.Tween(MonoGlow1, 3.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, {
				Position = UDim2.new(0.28, 0, 0.35, 0),
				ImageTransparency = 0.88
			})
			Lib.Tween(MonoGlow2, 3.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, {
				Position = UDim2.new(0.72, 0, 0.65, 0),
				ImageTransparency = 0.90
			})
			task.wait(3.5)
			if not isGlitching then break end

			Lib.Tween(MonoGlow1, 3.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, {
				Position = UDim2.new(0.15, 0, 0.22, 0),
				ImageTransparency = 0.94
			})
			Lib.Tween(MonoGlow2, 3.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, {
				Position = UDim2.new(0.85, 0, 0.78, 0),
				ImageTransparency = 0.95
			})
			task.wait(3.5)
		end
	end)

	task.spawn(function()
		while isGlitching do
			Scanline.Position = UDim2.new(0, 0, -0.05, 0)
			local scanTween = Lib.Tween(Scanline, 3.6, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, {
				Position = UDim2.new(0, 0, 1.05, 0)
			})
			scanTween.Completed:Wait()
		end
	end)

	task.spawn(function()
		while isGlitching do
			task.wait(math.random(6, 18) / 10)
			if not isGlitching then break end

			for _, b in ipairs(glitchBars) do
				if math.random(1, 3) == 1 then
					local barWidth = math.random(60, 260)
					local barX = math.random(0, 80) / 100
					local barY = math.random(5, 95) / 100
					b.Position = UDim2.new(barX, 0, barY, 0)
					b.Size = UDim2.fromOffset(barWidth, math.random(2, 5))
					b.BackgroundTransparency = math.random(2, 5) / 10

					task.delay(math.random(4, 10) / 100, function()
						if b and b.Parent then
							b.BackgroundTransparency = 1
						end
					end)
				end
			end
		end
	end)

	task.spawn(function()
		while isGlitching do
			task.wait(math.random(15, 40) / 10)
			if not isGlitching then break end

			for _ = 1, math.random(3, 6) do
				local offsetX = math.random(-5, 5)
				local offsetY = math.random(-2, 2)

				TitleGhost1.Position = UDim2.new(0.5, -2 + offsetX, 0, offsetY)
				TitleGhost2.Position = UDim2.new(0.5, 2 - offsetX, 0, -offsetY)
				TitleGhost1.TextTransparency = math.random(15, 50) / 100
				TitleGhost2.TextTransparency = math.random(15, 50) / 100

				if math.random(1, 2) == 1 then
					local scrambled = ""
					for c = 1, #baseTitleText do
						if math.random(1, 4) == 1 then
							scrambled = scrambled .. glitchCharacters[math.random(1, #glitchCharacters)]
						else
							scrambled = scrambled .. baseTitleText:sub(c, c)
						end
					end
					TitleMain.Text = scrambled
				end

				LogoGlow.Size = UDim2.fromOffset(math.random(160, 180), math.random(160, 180))
				task.wait(0.04)
			end

			TitleMain.Text = baseTitleText
			TitleGhost1.Position = UDim2.new(0.5, -2, 0, 0)
			TitleGhost2.Position = UDim2.new(0.5, 2, 0, 0)
			TitleGhost1.TextTransparency = 0.5
			TitleGhost2.TextTransparency = 0.5
			LogoGlow.Size = UDim2.fromOffset(165, 165)
		end
	end)

	Lib.RecalculateNavPositions()
	Lib.SwitchTab("Overview")
	Lib.SwitchFeaturesTab("Visuals")
	Lib.SwitchScriptsTab("Browse")
	Lib.SwitchEmotesTab("Browse")
	Lib.SwitchSettingsTab("Appearance")
	Lib.SwitchMainTab("Home")
	Lib.ApplyTheme(State.ThemeColor)

	Lib.Tween(SplashModal, 0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { GroupTransparency = 0 })
	Lib.Tween(LogoImg, 0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { ImageTransparency = 0, Size = UDim2.fromOffset(125, 125) })
	Lib.Tween(SubtitleProject, 0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { TextTransparency = 0 })

	GithubBtn.MouseButton1Click:Connect(function()
		Lib.PlayClick()
		local link = "github.com/CherryCalCor"
		local copyFunc = setclipboard or toclipboard or set_clipboard
		if copyFunc then
			copyFunc(link)
		end

		local prevText = GithubBtn.Text
		GithubBtn.Text = "[ COPIED_URL ✓ ]"
		GithubBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		GithubBtn.TextColor3 = Color3.fromRGB(0, 0, 0)

		task.delay(1.5, function()
			if GithubBtn and GithubBtn.Parent then
				GithubBtn.Text = prevText
				GithubBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
				GithubBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
			end
		end)
	end)

	StartBtn.MouseButton1Click:Connect(function()
		Lib.PlayClick()
		isGlitching = false
		Lib.Tween(Blur, 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In, { Size = 0 })
		local fadeOut = Lib.Tween(SplashModal, 0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { GroupTransparency = 1 })

		fadeOut.Completed:Connect(function()
			SplashModal:Destroy()
			Blur:Destroy()

			local scaleObj = UI.Main:FindFirstChild("SeptusScale") or Instance.new("UIScale")
			scaleObj.Name = "SeptusScale"
			scaleObj.Scale = isMobileVersion and (1 / 1.5) or 1
			scaleObj.Parent = UI.Main
			UI.MainScale = scaleObj
			Lib.MenuBaseScale = scaleObj.Scale

			UI.Main.Size = UDim2.fromOffset(760, 510)
			UI.Main.Visible = true
			Lib.Tween(UI.Main, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
				Size = State.OriginalSize
			})

			if UI.SHToggleButton then
				UI.SHToggleButton.Visible = true
			end
		end)
	end)
end

local function PlayCinematicIntro(onComplete)
	local IntroBlur = Lib.Create("BlurEffect", { Name = "RavenScall_IntroBlur", Size = 0, Parent = Services.Lighting })
	Refs.IntroBlur = IntroBlur
	Lib.Tween(IntroBlur, 1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Size = 30 })

	local IntroGui = Lib.Create("CanvasGroup", {
		Name = "RavenScall_CinematicIntro",
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		GroupTransparency = 0,
		ZIndex = 100,
		Parent = UI.Screen,
		Lib.Create("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0.32,
			BorderSizePixel = 0,
			ZIndex = 100,
			Lib.Create("UIGradient", {
				Rotation = 45,
				Color = ColorSequence.new(Color3.fromRGB(64, 74, 104), Color3.fromRGB(10, 12, 20))
			})
		}),
		Lib.Create("Frame", {
			Size = UDim2.new(1, 0, 0.55, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
			ZIndex = 100,
			Lib.Create("UIGradient", {
				Rotation = 90,
				Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.88), NumberSequenceKeypoint.new(1, 1) })
			})
		})
	})

	task.spawn(function()
		local Stage1 = Lib.Create("CanvasGroup", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, GroupTransparency = 0, ZIndex = 101, Parent = IntroGui })

		local OrbA = Lib.Create("ImageLabel", { Size = UDim2.fromOffset(640, 640), Position = UDim2.new(0.2, 0, 0.3, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Image = "rbxassetid://1316045217", ImageColor3 = Color3.fromRGB(140, 170, 255), ImageTransparency = 0.9, ZIndex = 101, Parent = Stage1 })
		local OrbB = Lib.Create("ImageLabel", { Size = UDim2.fromOffset(700, 700), Position = UDim2.new(0.82, 0, 0.78, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Image = "rbxassetid://1316045217", ImageColor3 = Color3.fromRGB(190, 150, 255), ImageTransparency = 0.92, ZIndex = 101, Parent = Stage1 })
		local drift = TweenInfo.new(6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
		Services.Tween:Create(OrbA, drift, { Position = UDim2.new(0.32, 0, 0.44, 0) }):Play()
		Services.Tween:Create(OrbB, drift, { Position = UDim2.new(0.7, 0, 0.62, 0) }):Play()

		local LogoHalo = Lib.Create("ImageLabel", { Size = UDim2.fromOffset(300, 300), Position = UDim2.new(0.5, 0, 0.42, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Image = "rbxassetid://1316045217", ImageColor3 = Color3.fromRGB(255, 255, 255), ImageTransparency = 1, ZIndex = 102, Parent = Stage1 })
		local Logo = Lib.Create("ImageLabel", { Size = UDim2.fromOffset(90, 90), Position = UDim2.new(0.5, 0, 0.42, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Image = "rbxassetid://74736110237331", ImageTransparency = 1, ScaleType = Enum.ScaleType.Fit, ZIndex = 103, Parent = Stage1 })
		local Title = Lib.Create("TextLabel", {
			Size = UDim2.fromOffset(520, 40),
			Position = UDim2.new(0.5, 0, 0.42, 108),
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			Text = "RavenScall Project",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 24,
			Font = Enum.Font.Michroma,
			TextTransparency = 1,
			ZIndex = 103,
			Parent = Stage1,
			Lib.Create("UIGradient", { Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(170, 190, 255)) })
		})
		local BarTrack = Lib.Create("Frame", { Size = UDim2.fromOffset(280, 4), Position = UDim2.new(0.5, 0, 0.42, 168), AnchorPoint = Vector2.new(0.5, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 103, Parent = Stage1, Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
		local BarFill = Lib.Create("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0, ZIndex = 104, Parent = BarTrack, Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })

		Lib.Tween(Logo, 1.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, { ImageTransparency = 0, Size = UDim2.fromOffset(124, 124) })
		Lib.Tween(LogoHalo, 1.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { ImageTransparency = 0.86 })
		task.wait(0.6)
		Lib.Tween(Title, 1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, { TextTransparency = 0, Position = UDim2.new(0.5, 0, 0.42, 92) })
		task.wait(0.5)
		Lib.Tween(BarTrack, 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundTransparency = 0.85 })
		task.wait(0.3)
		Lib.Tween(BarFill, 0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Size = UDim2.new(0.4, 0, 1, 0) }).Completed:Wait()
		Lib.Tween(BarFill, 1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, { Size = UDim2.new(0.78, 0, 1, 0) }).Completed:Wait()
		Lib.Tween(BarFill, 0.8, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, { Size = UDim2.new(1, 0, 1, 0) }).Completed:Wait()
		task.wait(0.35)

		Lib.Tween(Stage1, 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { GroupTransparency = 1 }).Completed:Wait()
		Stage1:Destroy()

		local WarnBox = Lib.Create("CanvasGroup", {
			Size = UDim2.fromOffset(540, 120),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			GroupTransparency = 0,
			ZIndex = 104,
			Parent = IntroGui
		})

		Lib.Create("TextLabel", {
			Size = UDim2.new(1, 0, 0, 28),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1,
			Text = "⚠  SECURITY WARNING  ⚠",
			TextColor3 = Color3.fromRGB(255, 60, 60),
			TextSize = 15,
			Font = Enum.Font.GothamBold,
			ZIndex = 105,
			Parent = WarnBox
		})

		local WarnText = Lib.Create("TextLabel", {
			Size = UDim2.new(1, -20, 0, 65),
			Position = UDim2.new(0.5, 0, 0.32, 0),
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			Text = "We strongly advise against using this script in games with powerful anti-cheats for the safety of your progress.",
			TextColor3 = Color3.fromRGB(255, 75, 75),
			TextSize = 14,
			Font = Enum.Font.GothamMedium,
			TextWrapped = true,
			TextTransparency = 1,
			ZIndex = 105,
			Parent = WarnBox
		})

		Lib.Tween(WarnText, 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { TextTransparency = 0 })

		task.wait(4.0)

		local fadeIntro = Lib.Tween(IntroGui, 0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { GroupTransparency = 1 })
		fadeIntro.Completed:Connect(function()
			IntroGui:Destroy()
			if onComplete then
				onComplete(IntroBlur)
			end
		end)
	end)
end

PlayCinematicIntro(StartLoadingSequence)

do
	local history = { FPS = {}, Ping = {}, Players = {} }
	for i = 1, 15 do history.FPS[i], history.Ping[i], history.Players[i] = 0.1, 0.1, 0.1 end

	local function PushGraph(key, val, text, barsData, divider)
		UI.Labels[key].Text = text
		table.remove(history[key], 1)
		table.insert(history[key], math.clamp(val / divider, 0.05, 1))
		for i, bar in ipairs(barsData) do bar.Size = UDim2.new(1/15, -3, history[key][i], 0) end
	end

	local lastT, frames = tick(), 0
	Lib.C(Services.Run.RenderStepped, function()
		frames = frames + 1
		local curT = tick()
		if curT - lastT >= 1 then
			local fps = math.floor(frames / (curT - lastT))
			local ping = pcall(function() return math.floor(Services.Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end) and math.floor(Services.Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) or 0
			local plrs = #Services.Players:GetPlayers()

			PushGraph("FPS", fps, fps .. " FPS", UI.Graphs.FPS, 120)
			PushGraph("Ping", ping, ping .. " ms", UI.Graphs.Ping, 300)
			PushGraph("Players", plrs, plrs .. " Players", UI.Graphs.Players, 100)

			frames, lastT = 0, curT
		end
	end)
end

do
	local SHButton = Lib.Create("TextButton", {
		Name = "SH_FloatingToggle",
		Size = UDim2.fromOffset(46, 46),
		Position = UDim2.new(0, 20, 0.5, -23),
		BackgroundColor3 = Color3.fromRGB(18, 18, 18),
		Text = "SH",
		TextColor3 = Color3.fromRGB(245, 245, 245),
		TextSize = 16,
		Font = Enum.Font.GothamBold,
		AutoButtonColor = false,
		Visible = false,
		ZIndex = 120,
		Parent = UI.Screen,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
		Lib.Create("UIStroke", {
			Color = Color3.fromRGB(60, 60, 60),
			Thickness = 1.5,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		})
	})
	Lib.RegisterThemeElement(SHButton, "BackgroundColor3", 0.5)
	Lib.RegisterThemeText(SHButton, "Primary")
	UI.SHToggleButton = SHButton

	local dragging = false
	local dragStart = nil
	local startPos = nil
	local hasMoved = false

	SHButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			hasMoved = false
			dragStart = input.Position
			startPos = SHButton.Position

			Lib.Tween(SHButton, 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
				Size = UDim2.fromOffset(40, 40)
			})
		end
	end)

	Lib.C(Services.UserInputService.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			if delta.Magnitude > 4 then
				hasMoved = true
			end
			SHButton.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)

	local function OnRelease()
		if dragging then
			dragging = false

			Lib.Tween(SHButton, 0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
				Size = UDim2.fromOffset(46, 46)
			})

			if not hasMoved then
				Lib.PlayClick()
				Lib.ToggleMenu()
			end
		end
	end

	SHButton.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			OnRelease()
		end
	end)
end
