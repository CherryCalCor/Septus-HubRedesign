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
	UserInputService = game:GetService("UserInputService")
}

local Player = Services.Players.LocalPlayer
local Camera = Services.Workspace.CurrentCamera

local function HTTPRequest(url)
	local headers = {
		["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
	}
	
	local req = (syn and syn.request) or http_request or request or (fluxus and fluxus.request) or (http and http.request)
	
	if type(req) == "function" then
		local res = nil
		pcall(function() res = req({ Url = url, Method = "GET", Headers = headers }) end)
		if res and res.Body and (not res.StatusCode or (res.StatusCode >= 200 and res.StatusCode < 300)) then 
			return true, res.Body 
		end
	end
	
	if type(game.HttpGet) == "function" then
		local success, body = pcall(function() return game:HttpGet(url) end)
		if success and type(body) == "string" and #body > 0 then return true, body end
	end
	
	if url:find("roblox%.com") then
		local proxyUrl = url:gsub("roblox%.com", "roproxy.com")
		if type(req) == "function" then
			local res = nil
			pcall(function() res = req({ Url = proxyUrl, Method = "GET", Headers = headers }) end)
			if res and res.Body and (not res.StatusCode or (res.StatusCode >= 200 and res.StatusCode < 300)) then 
				return true, res.Body 
			end
		end
		if type(game.HttpGet) == "function" then
			local success, body = pcall(function() return game:HttpGet(proxyUrl) end)
			if success and type(body) == "string" and #body > 0 then return true, body end
		end
	end
	
	return false, nil
end

local Lib = {
	UI = { 
		Views = {}, TabBtns = {}, 
		Graphs = { FPS = {}, Ping = {}, Players = {} }, Labels = {},
		ScriptsViews = {}, ScriptsTabBtns = {},
		EmotesViews = {}, EmotesTabBtns = {},
		FeaturesViews = {}, FeaturesTabBtns = {}
	},
	State = {
		Minimized = false, Maximized = false,
		ActiveMain = "",
		CurrentTab = "", CurrentScriptsTab = "", CurrentEmotesTab = "", CurrentFeaturesTab = "",
		OriginalSize = UDim2.fromOffset(800, 540),
		
		ScriptsPage = 1, ScriptsTotalPages = 1, ScriptsLoading = false, ScriptsCache = {},
		ScriptsProvider = "Rscripts", ScriptsSort = "Newest",
		
		EmotesPage = 1, EmotesTotalPages = 1, EmotesLoading = false,
		EmotesCache = {},
		AnimationPacksCache = {},
		AnimationIdCache = {},
		EmotesCategory = "Emotes",
		EmotesSort = "Most Liked",
		
		CurrentEmoteTrack = nil,
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

		ServerList = {
			IsOpen = false,
			Loading = false,
			Sort = "Most Players", 
			FillState = "All",      
			PercentRange = "All"    
		},

		TotalPlaytimeSeconds = 0,
		LastActivityTick = os.clock(),
		IsDecorActive = false,
		Ach_10Hours_Claimed = false
	}
}

function Lib.Create(className, props)
	local inst = Instance.new(className)
	for k, v in pairs(props or {}) do
		if type(k) == "number" then 
			v.Parent = inst
		elseif k ~= "Parent" then
			inst[k] = v
		end
	end
	if props and props.Parent then inst.Parent = props.Parent end
	return inst
end

function Lib.Tween(obj, time, style, dir, props)
	local tween = Services.Tween:Create(obj, TweenInfo.new(time, style, dir), props)
	tween:Play()
	return tween
end

local function GetFirstLaunch()
	local fileName, date = "SeptusHub_FirstLaunch.txt", ""
	if isfile and readfile and isfile(fileName) then
		pcall(function() date = readfile(fileName) end)
	end
	if date == "" or not date then
		date = os.date("%d.%m.%Y %H:%M")
		if writefile then pcall(writefile, fileName, date) end
	end
	return date
end

local PLAYTIME_FILE = "SeptusHub_Playtime.txt"
local ACH_FILE = "SeptusHub_Achievements.json"

local function LoadPlaytimeData()
	if isfile and readfile and isfile(PLAYTIME_FILE) then
		local content = nil
		pcall(function() content = readfile(PLAYTIME_FILE) end)
		Lib.State.TotalPlaytimeSeconds = tonumber(content) or 0
	end
	if isfile and readfile and isfile(ACH_FILE) then
		pcall(function()
			local content = readfile(ACH_FILE)
			local data = Services.HttpService:JSONDecode(content)
			Lib.State.Ach_10Hours_Claimed = data.Ach_10Hours_Claimed or false
			Lib.State.IsDecorActive = data.IsDecorActive or false
		end)
	end

	if Player.Name:lower() == "cherrycalcor" then
		Lib.State.Ach_10Hours_Claimed = true
		Lib.State.IsDecorActive = true
		if Lib.State.TotalPlaytimeSeconds < 36000 then
			Lib.State.TotalPlaytimeSeconds = 36000
		end
	end
end

local function SavePlaytimeData()
	if writefile then
		pcall(writefile, PLAYTIME_FILE, tostring(math.floor(Lib.State.TotalPlaytimeSeconds)))
		local achData = {
			Ach_10Hours_Claimed = Lib.State.Ach_10Hours_Claimed,
			IsDecorActive = Lib.State.IsDecorActive
		}
		pcall(writefile, ACH_FILE, Services.HttpService:JSONEncode(achData))
	end
end

LoadPlaytimeData()

local function RegisterUserActivity()
	Lib.State.LastActivityTick = os.clock()
end

Services.UserInputService.InputBegan:Connect(RegisterUserActivity)
Services.UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		RegisterUserActivity()
	end
end)

local PlaytimeTextLabel = nil
local AchUpdateCallback = nil

task.spawn(function()
	local saveTimer = 0
	while true do
		task.wait(1)
		if (os.clock() - Lib.State.LastActivityTick) <= 1800 then
			Lib.State.TotalPlaytimeSeconds = Lib.State.TotalPlaytimeSeconds + 1
		end

		saveTimer = saveTimer + 1
		if saveTimer >= 15 then
			saveTimer = 0
			SavePlaytimeData()
		end

		if PlaytimeTextLabel then
			local hours = math.floor(Lib.State.TotalPlaytimeSeconds / 3600)
			local mins = math.floor((Lib.State.TotalPlaytimeSeconds % 3600) / 60)
			PlaytimeTextLabel.Text = string.format("%dh %dm", hours, mins)
		end

		if AchUpdateCallback then
			AchUpdateCallback()
		end
	end
end)

local function RejoinCurrentServer()
	pcall(function()
		if #Services.Players:GetPlayers() <= 1 then
			Player:Kick("\n[Septus Hub] Rejoining server...")
			task.wait()
			Services.Teleport:Teleport(game.PlaceId, Player)
		else
			Services.Teleport:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player)
		end
	end)
end

local function ServerHop()
	task.spawn(function()
		local placeId = game.PlaceId
		local currentJob = game.JobId
		local url = "https://games.roproxy.com/v1/games/" .. tostring(placeId) .. "/servers/Public?sortOrder=Asc&limit=100"
		local success, body = HTTPRequest(url)
		
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
					Services.Teleport:TeleportToPlaceInstance(placeId, targetServerId, Player)
					return
				end
			end
		end
		
		Services.Teleport:Teleport(placeId, Player)
	end)
end

local API = {}

function API.ResolveAnimationId(assetId, itemType)
	if not assetId then return nil end
	assetId = tonumber(assetId) or assetId
	
	if Lib.State.AnimationIdCache[assetId] then
		return Lib.State.AnimationIdCache[assetId]
	end

	local resolvedAnimId = nil

	if itemType == "Bundle" or Lib.State.EmotesCategory == "Animation Packs" then
		local bundleUrl = "https://catalog.roproxy.com/v1/bundles/" .. tostring(assetId) .. "/details"
		local success, body = HTTPRequest(bundleUrl)
		if success and body then
			local decSuccess, bData = pcall(function() return Services.HttpService:JSONDecode(body) end)
			if decSuccess and bData and bData.items then
				for _, item in ipairs(bData.items) do
					if item.type == "Asset" and item.id then
						resolvedAnimId = API.ResolveAnimationId(item.id, "Asset")
						if resolvedAnimId then break end
					end
				end
			end
		end
		if resolvedAnimId then
			Lib.State.AnimationIdCache[assetId] = resolvedAnimId
			return resolvedAnimId
		end
	end

	pcall(function()
		local objects = game:GetObjects("rbxassetid://" .. tostring(assetId))
		if objects and #objects > 0 then
			local root = objects[1]
			if root:IsA("Animation") then
				local matchId = root.AnimationId:match("%d+")
				if matchId then resolvedAnimId = tonumber(matchId) end
			else
				local anim = root:FindFirstChildWhichIsA("Animation", true)
				if anim and anim.AnimationId then
					local matchId = anim.AnimationId:match("%d+")
					if matchId then resolvedAnimId = tonumber(matchId) end
				end
			end
		end
	end)

	if resolvedAnimId then
		Lib.State.AnimationIdCache[assetId] = resolvedAnimId
		return resolvedAnimId
	end

	local deliveryUrls = {
		"https://assetdelivery.roproxy.com/v1/asset/?id=" .. tostring(assetId),
		"https://assetdelivery.roblox.com/v1/asset/?id=" .. tostring(assetId)
	}
	
	for _, url in ipairs(deliveryUrls) do
		local success, body = HTTPRequest(url)
		if success and body and type(body) == "string" then
			local animId = body:match("<url>.-id=(%d+).-</url>") 
				or body:match("rbxassetid://(%d+)")
				or body:match('"assetId":(%d+)')
				or body:match('id=(%d+)')
				
			if animId and tonumber(animId) and tonumber(animId) ~= assetId then
				resolvedAnimId = tonumber(animId)
				break
			end
		end
	end

	if resolvedAnimId then
		Lib.State.AnimationIdCache[assetId] = resolvedAnimId
		return resolvedAnimId
	end

	Lib.State.AnimationIdCache[assetId] = assetId
	return assetId
end

local function GetSortParams(sortStr)
	if sortStr == "Most Viewed" then
		return "sortType=2&sortAggregation=5"
	elseif sortStr == "Least Viewed" then
		return "sortType=2&sortAggregation=1"
	elseif sortStr == "Most Liked" then
		return "sortType=1&sortAggregation=5"
	elseif sortStr == "Least Liked" then
		return "sortType=1&sortAggregation=1"
	elseif sortStr == "Newest" then
		return "sortType=3"
	elseif sortStr == "Oldest" then
		return "sortType=0"
	end
	return "sortType=1&sortAggregation=5"
end

function API.FetchEmotes(page, sortType)
	local result = { success = false, data = {}, totalPages = 1 }
	local sortQuery = GetSortParams(sortType)
	local cacheKey = "Emotes_" .. tostring(sortType)
	local cursor = Lib.State.EmotesCache[cacheKey .. "_cursor_" .. tostring(page)] or ""
	
	local urls = {
		"https://catalog.roproxy.com/v1/search/items/details?category=AvatarAnimations&subcategory=EmoteAnimations&limit=30&" .. sortQuery,
		"https://catalog.roproxy.com/v1/search/items/details?category=12&subcategory=39&limit=30&" .. sortQuery,
		"https://catalog.roblox.com/v1/search/items/details?category=12&subcategory=39&limit=30&" .. sortQuery
	}

	for _, baseUrl in ipairs(urls) do
		local url = baseUrl
		if cursor ~= "" then url = url .. "&cursor=" .. cursor end
		
		local success, body = HTTPRequest(url)
		if success and body then
			local decSuccess, decoded = pcall(function() return Services.HttpService:JSONDecode(body) end)
			if decSuccess and decoded and decoded.data and #decoded.data > 0 then
				result.success = true
				if decoded.nextPageCursor then
					Lib.State.EmotesCache[cacheKey .. "_cursor_" .. tostring(page + 1)] = decoded.nextPageCursor
					result.totalPages = page + 1
				else
					result.totalPages = page
				end

				for _, item in ipairs(decoded.data) do
					local priceText = "Off Sale"
					if item.priceStatus == "Free" or item.price == 0 then
						priceText = "Free"
					elseif item.price then
						priceText = tostring(item.price) .. " Robux"
					end

					table.insert(result.data, {
						id = item.id,
						itemType = item.itemType or "Asset",
						name = item.name or "Unknown Emote",
						price = priceText,
						thumbnailId = item.id
					})
				end
				break
			end
		end
	end
	return result
end

function API.FetchAnimationPacks(page, sortType)
	local result = { success = false, data = {}, totalPages = 1 }
	local sortQuery = GetSortParams(sortType)
	local cacheKey = "Packs_" .. tostring(sortType)
	local cursor = Lib.State.AnimationPacksCache[cacheKey .. "_cursor_" .. tostring(page)] or ""
	
	local urls = {
		"https://catalog.roproxy.com/v1/search/items/details?category=AvatarAnimations&subcategory=Bundles&limit=30&" .. sortQuery,
		"https://catalog.roproxy.com/v1/search/items/details?category=12&subcategory=38&limit=30&" .. sortQuery,
		"https://catalog.roblox.com/v1/search/items/details?category=12&subcategory=38&limit=30&" .. sortQuery
	}

	for _, baseUrl in ipairs(urls) do
		local url = baseUrl
		if cursor ~= "" then url = url .. "&cursor=" .. cursor end

		local success, body = HTTPRequest(url)
		if success and body then
			local decSuccess, decoded = pcall(function() return Services.HttpService:JSONDecode(body) end)
			if decSuccess and decoded and decoded.data and #decoded.data > 0 then
				result.success = true
				if decoded.nextPageCursor then
					Lib.State.AnimationPacksCache[cacheKey .. "_cursor_" .. tostring(page + 1)] = decoded.nextPageCursor
					result.totalPages = page + 1
				else
					result.totalPages = page
				end

				for _, item in ipairs(decoded.data) do
					local priceText = "Off Sale"
					if item.priceStatus == "Free" or item.price == 0 then
						priceText = "Free"
					elseif item.price then
						priceText = tostring(item.price) .. " Robux"
					end

					table.insert(result.data, {
						id = item.id,
						itemType = item.itemType or "Bundle",
						name = item.name or "Animation Pack",
						price = priceText,
						thumbnailId = item.id
					})
				end
				break
			end
		end
	end
	return result
end

local function StopCurrentEmote()
	if Lib.State.CurrentEmoteTrack then
		pcall(function()
			Lib.State.CurrentEmoteTrack:Stop()
			Lib.State.CurrentEmoteTrack:Destroy()
		end)
		Lib.State.CurrentEmoteTrack = nil
	end
	if Lib.State.CurrentEmoteButton and Lib.State.CurrentEmoteButton.Parent then
		Lib.State.CurrentEmoteButton.Text = "Play"
		Lib.State.CurrentEmoteButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Lib.State.CurrentEmoteButton.TextColor3 = Color3.fromRGB(0, 0, 0)
	end
	Lib.State.CurrentPlayingAssetId = nil
	Lib.State.CurrentEmoteButton = nil
end

local function PlayEmote(assetId, itemType, triggerBtn)
	if Lib.State.CurrentPlayingAssetId == assetId then
		StopCurrentEmote()
		return
	end

	StopCurrentEmote()

	local character = Player.Character
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	local animator = humanoid:FindFirstChildOfClass("Animator") or Lib.Create("Animator", { Parent = humanoid })

	triggerBtn.Text = "Resolving..."
	
	task.spawn(function()
		local animationId = API.ResolveAnimationId(assetId, itemType)
		
		if not animationId or animationId == "" then
			triggerBtn.Text = "Failed"
			task.delay(1.5, function()
				if triggerBtn.Parent then triggerBtn.Text = "Play" end
			end)
			return
		end

		if not Player.Character or Player.Character:FindFirstChildOfClass("Humanoid") ~= humanoid then
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
			Lib.State.CurrentEmoteTrack = track
			Lib.State.CurrentPlayingAssetId = assetId
			Lib.State.CurrentEmoteButton = triggerBtn

			track.Priority = Enum.AnimationPriority.Action
			track:Play()

			triggerBtn.Text = "Stop"
			triggerBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
			triggerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

			track.Stopped:Connect(function()
				if Lib.State.CurrentPlayingAssetId == assetId then
					StopCurrentEmote()
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

Player.CharacterAdded:Connect(function()
	StopCurrentEmote()
end)

local Screen = Lib.Create("ScreenGui", { 
	Name = "SeptusHub", 
	ResetOnSpawn = false, 
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = Player:WaitForChild("PlayerGui") 
})

local Main = Lib.Create("Frame", {
	Name = "Main", 
	Size = Lib.State.OriginalSize, 
	Position = UDim2.new(0.5, 0, 0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = Color3.fromRGB(0, 0, 0), 
	ClipsDescendants = true, 
	Visible = false,
	Parent = Screen,
	Lib.Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
	Lib.Create("ImageLabel", { Size = UDim2.fromOffset(30, 30), Position = UDim2.fromOffset(14, 14), BackgroundTransparency = 1, Image = "rbxassetid://104797361877921", ScaleType = Enum.ScaleType.Fit }),
	Lib.Create("TextLabel", { Size = UDim2.fromOffset(160, 30), Position = UDim2.fromOffset(50, 14), BackgroundTransparency = 1, Text = "Septus Hub", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 18, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left })
})

local ContentArea = Lib.Create("Frame", { Size = UDim2.new(1, 0, 1, -58), Position = UDim2.new(0, 0, 0, 58), BackgroundTransparency = 1, ClipsDescendants = true, Parent = Main })

local TopNavContainer = Lib.Create("Frame", {
	Name = "TopNavContainer",
	Size = UDim2.new(0, 380, 0, 36),
	Position = UDim2.new(0.5, 0, 0, 11),
	AnchorPoint = Vector2.new(0.5, 0),
	BackgroundTransparency = 1,
	ClipsDescendants = false,
	Parent = Main
})

local WindowBtns = Lib.Create("Frame", { Size = UDim2.fromOffset(120, 36), Position = UDim2.new(1, -125, 0, 11), BackgroundTransparency = 1, Parent = Main })
local function MakeWinBtn(name, text, pos, callback)
	local btn = Lib.Create("TextButton", { Size = UDim2.fromOffset(36, 36), Position = pos, BackgroundTransparency = 1, Text = text, TextColor3 = Color3.fromRGB(125, 125, 125), TextSize = 16, Font = Enum.Font.GothamMedium, Parent = WindowBtns })
	btn.MouseEnter:Connect(function() Lib.Tween(btn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { TextColor3 = Color3.fromRGB(255, 255, 255) }) end)
	btn.MouseLeave:Connect(function() Lib.Tween(btn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { TextColor3 = Color3.fromRGB(125, 125, 125) }) end)
	btn.MouseButton1Click:Connect(callback)
end

MakeWinBtn("Minimize", "—", UDim2.fromOffset(0, 0), function()
	Lib.State.Minimized = not Lib.State.Minimized
	if Lib.State.Minimized then
		TopNavContainer.Visible = false
		ContentArea.Visible = false
	else
		TopNavContainer.Visible = true
		ContentArea.Visible = true
	end
	
	local targetSize = Lib.State.Minimized and UDim2.fromOffset(800, 58) or (Lib.State.Maximized and UDim2.new(1, -30, 1, -30) or Lib.State.OriginalSize)
	local targetPos = Lib.State.Minimized and UDim2.new(0.5, 0, 0.5, -241) or UDim2.new(0.5, 0, 0.5, 0)
	
	Lib.Tween(Main, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { 
		Size = targetSize,
		Position = targetPos
	})
end)

MakeWinBtn("Maximize", "□", UDim2.fromOffset(40, 0), function()
	Lib.State.Maximized = not Lib.State.Maximized
	if not Lib.State.Minimized then
		TopNavContainer.Visible = true
		ContentArea.Visible = true
	end
	Lib.Tween(Main, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { 
		Size = Lib.State.Maximized and UDim2.new(1, -30, 1, -30) or Lib.State.OriginalSize,
		Position = UDim2.new(0.5, 0, 0.5, 0)
	})
end)

MakeWinBtn("Close", "×", UDim2.fromOffset(80, 0), function() 
	StopCurrentEmote()
	SavePlaytimeData()
	Screen:Destroy() 
end)

local SwitchMainTab

local NavTabsData = {
	{ id = "Home", title = "Home", icon = "rbxassetid://128407802503574", expWidth = 76 },
	{ id = "Features", title = "Features", icon = "rbxassetid://10734944449", expWidth = 94 },
	{ id = "Scripts", title = "Scripts", icon = "rbxassetid://99356660335373", expWidth = 84 },
	{ id = "Emotes", title = "Emotes", icon = "rbxassetid://132655372254315", expWidth = 84 }
}

local NavElements = {}
local currentHoveredNavIndex = nil
local BASE_TAB_WIDTH = 34
local TAB_GAP = 8

local function RecalculateNavPositions()
	local widths = {}
	local totalWidth = 0

	for i, tab in ipairs(NavTabsData) do
		local isHover = (currentHoveredNavIndex == i)
		local w = isHover and tab.expWidth or BASE_TAB_WIDTH
		widths[i] = w
		totalWidth = totalWidth + w
	end
	totalWidth = totalWidth + (#NavTabsData - 1) * TAB_GAP

	local currentX = -totalWidth / 2
	for i, tab in ipairs(NavTabsData) do
		local elem = NavElements[i]
		local w = widths[i]
		local isHover = (currentHoveredNavIndex == i)
		local isActive = (Lib.State.ActiveMain == tab.id)

		Lib.Tween(elem.Container, 0.22, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, {
			Position = UDim2.new(0.5, currentX, 0, 0),
			Size = UDim2.fromOffset(w, 36)
		})

		Lib.Tween(elem.Icon, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
			Position = isHover and UDim2.new(0, 7, 0.5, -9) or UDim2.new(0.5, -9, 0.5, -9),
			ImageColor3 = (isActive or isHover) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
		})

		Lib.Tween(elem.Text, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
			TextTransparency = isHover and 0 or 1,
			TextColor3 = (isActive or isHover) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
		})

		local lineTargetWidth = isActive and (isHover and (w - 14) or 18) or 0
		local lineTargetX = isHover and 7 or (w / 2 - lineTargetWidth / 2)
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
		Parent = TopNavContainer
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

	NavElements[i] = {
		Container = TabFrame,
		Icon = TabIcon,
		Text = TabText,
		Line = TabLine,
		Data = tab
	}

	TabFrame.MouseEnter:Connect(function()
		currentHoveredNavIndex = i
		RecalculateNavPositions()
	end)

	TabFrame.MouseLeave:Connect(function()
		if currentHoveredNavIndex == i then
			currentHoveredNavIndex = nil
			RecalculateNavPositions()
		end
	end)

	TabFrame.MouseButton1Click:Connect(function()
		SwitchMainTab(tab.id)
	end)
end

local HomeSection = Lib.Create("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, Parent = ContentArea })
local SideBar = Lib.Create("Frame", { Size = UDim2.new(0, 180, 1, 0), BackgroundTransparency = 1, Parent = HomeSection,
	Lib.Create("TextLabel", { Size = UDim2.new(1, -30, 0, 30), Position = UDim2.new(0, 20, 0, 10), BackgroundTransparency = 1, Text = "Home", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 20, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left })
})

local function SwitchTab(tabName)
	if Lib.State.CurrentTab == tabName then return end
	Lib.State.CurrentTab = tabName

	for name, view in pairs(Lib.UI.Views) do
		local btn = Lib.UI.TabBtns[name]
		local isSel = (name == tabName)

		Lib.Tween(btn, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { TextColor3 = isSel and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150), BackgroundTransparency = isSel and 0.92 or 1 })
		
		if isSel then
			view.Visible = true
			view.Position = UDim2.new(0, 195, 0, 10)
			view.GroupTransparency = 1
			Lib.Tween(view, 0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, { Position = UDim2.new(0, 180, 0, 10), GroupTransparency = 0 })
		elseif view.Visible then
			local t = Lib.Tween(view, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Position = UDim2.new(0, 170, 0, 10), GroupTransparency = 1 })
			t.Completed:Connect(function() if Lib.State.CurrentTab ~= name then view.Visible = false end end)
		end
	end
end

local function MakeTab(name, posY)
	local btn = Lib.Create("TextButton", { Size = UDim2.new(1, -30, 0, 34), Position = UDim2.new(0, 15, 0, posY), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1, Text = name, TextColor3 = Color3.fromRGB(150, 150, 150), TextSize = 14, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, Parent = SideBar,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 7) }), Lib.Create("UIPadding", { PaddingLeft = UDim.new(0, 12) })
	})
	Lib.UI.TabBtns[name] = btn

	local view = Lib.Create("CanvasGroup", { Size = UDim2.new(1, -190, 1, -20), Position = UDim2.new(0, 180, 0, 10), BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false, GroupTransparency = 1, Parent = HomeSection })
	Lib.UI.Views[name] = view

	btn.MouseEnter:Connect(function() if Lib.State.CurrentTab ~= name then Lib.Tween(btn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { TextColor3 = Color3.fromRGB(210, 210, 210), BackgroundTransparency = 0.96 }) end end)
	btn.MouseLeave:Connect(function() Lib.Tween(btn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Size = UDim2.new(1, -30, 0, 34) }) if Lib.State.CurrentTab ~= name then Lib.Tween(btn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { TextColor3 = Color3.fromRGB(150, 150, 150), BackgroundTransparency = 1 }) end end)
	btn.MouseButton1Down:Connect(function() Lib.Tween(btn, 0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Size = UDim2.new(1, -36, 0, 31) }) end)
	btn.MouseButton1Up:Connect(function() Lib.Tween(btn, 0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Size = UDim2.new(1, -30, 0, 34) }) end)
	btn.MouseButton1Click:Connect(function() SwitchTab(name) end)

	return view
end

local View_Overview = MakeTab("Overview", 50)
local View_Account = MakeTab("Account", 90)
local View_Achievements = MakeTab("Achievements", 130)
local View_Developers = MakeTab("Developers", 170)

Lib.Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 15), Parent = View_Overview })

local StatsArea = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 170), BackgroundTransparency = 1, LayoutOrder = 1, Parent = View_Overview, Lib.Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 12) }) })

local function MakeGraphCard(title, layout, typeKey)
	local card = Lib.Create("Frame", { Size = UDim2.new(0.32, -5, 1, 0), BackgroundColor3 = Color3.fromRGB(15, 15, 15), LayoutOrder = layout, Parent = StatsArea,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
		Lib.Create("TextLabel", { Size = UDim2.new(1, -20, 0, 25), Position = UDim2.new(0, 10, 0, 10), BackgroundTransparency = 1, Text = title, TextColor3 = Color3.fromRGB(150, 150, 150), TextSize = 13, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left })
	})
	Lib.UI.Labels[typeKey] = Lib.Create("TextLabel", { Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 10, 0, 35), BackgroundTransparency = 1, Text = "0", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 20, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, Parent = card })
	
	local graph = Lib.Create("Frame", { Size = UDim2.new(1, -20, 0, 75), Position = UDim2.new(0, 10, 0, 75), BackgroundTransparency = 1, Parent = card, Lib.Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0, 3) }) })
	
	for i = 1, 15 do
		Lib.UI.Graphs[typeKey][i] = Lib.Create("Frame", { Size = UDim2.new(1/15, -3, 0.1, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.3, BorderSizePixel = 0, Parent = graph, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 2) }) })
	end
end
MakeGraphCard("FPS", 1, "FPS")
MakeGraphCard("Ping", 2, "Ping")
MakeGraphCard("Players", 3, "Players")

local InfoArea = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 160), BackgroundTransparency = 1, LayoutOrder = 2, Parent = View_Overview, Lib.Create("UIListLayout", { Padding = UDim.new(0, 12) }) })
local function MakeCopyCard(title, val, layout)
	local card = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 70), BackgroundColor3 = Color3.fromRGB(15, 15, 15), LayoutOrder = layout, Parent = InfoArea, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
		Lib.Create("TextLabel", { Size = UDim2.new(0, 150, 0, 12), Position = UDim2.new(0, 15, 0, 12), BackgroundTransparency = 1, Text = title, TextColor3 = Color3.fromRGB(150, 150, 150), TextSize = 13, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left }),
		Lib.Create("TextLabel", { Size = UDim2.new(1, -120, 0, 25), Position = UDim2.new(0, 15, 0, 34), BackgroundTransparency = 1, Text = val, TextColor3 = Color3.fromRGB(220, 220, 220), TextSize = 13, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd })
	})
	local btn = Lib.Create("TextButton", { Size = UDim2.fromOffset(80, 34), Position = UDim2.new(1, -95, 0.5, -17), BackgroundColor3 = Color3.fromRGB(255, 255, 255), Text = "Copy", TextColor3 = Color3.fromRGB(0, 0, 0), TextSize = 13, Font = Enum.Font.GothamBold, Parent = card, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }) })
	btn.MouseButton1Click:Connect(function() (setclipboard or toclipboard)(tostring(val)) btn.Text = "Copied!" task.delay(1.5, function() btn.Text = "Copy" end) end)
end
MakeCopyCard("Server ID", game.JobId ~= "" and game.JobId or "Singleplayer / Studio", 1)
MakeCopyCard("Place ID", tostring(game.PlaceId), 2)

local AccountScroll = Lib.Create("ScrollingFrame", {
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	ScrollBarThickness = 2,
	ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100),
	BorderSizePixel = 0,
	Parent = View_Account
})
local AccountLayout = Lib.Create("UIListLayout", { Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder, Parent = AccountScroll })
AccountLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	AccountScroll.CanvasSize = UDim2.new(0, 0, 0, AccountLayout.AbsoluteContentSize.Y + 20)
end)

local AccountCard = Lib.Create("Frame", {
	Size = UDim2.new(1, 0, 0, 310),
	BackgroundColor3 = Color3.fromRGB(15, 15, 15),
	LayoutOrder = 1,
	Parent = AccountScroll,
	Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) })
})

local AvatarContainer = Lib.Create("Frame", {
	Size = UDim2.fromOffset(64, 64),
	Position = UDim2.fromOffset(20, 20),
	BackgroundTransparency = 1,
	Parent = AccountCard
})

local AvatarGlowRing = Lib.Create("Frame", {
	Size = UDim2.new(1, 8, 1, 8),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	BackgroundTransparency = 1,
	Visible = Lib.State.IsDecorActive,
	Parent = AvatarContainer,
	Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) })
})

local AvatarImage = Lib.Create("ImageLabel", {
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundColor3 = Color3.fromRGB(25, 25, 25),
	Image = "rbxthumb://type=AvatarHeadShot&id=" .. Player.UserId .. "&w=150&h=150",
	ZIndex = 2,
	Parent = AvatarContainer,
	Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) })
})

task.spawn(function()
	while true do
		if Lib.State.IsDecorActive and AvatarGlowRing.Visible then
			Lib.Tween(AvatarGlowRing, 0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, { BackgroundTransparency = 0.2, Size = UDim2.new(1, 10, 1, 10) })
			task.wait(0.9)
			Lib.Tween(AvatarGlowRing, 0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, { BackgroundTransparency = 0.85, Size = UDim2.new(1, 4, 1, 4) })
			task.wait(0.9)
		else
			task.wait(0.5)
		end
	end
end)

Lib.Create("TextLabel", { Size = UDim2.new(1, -120, 0, 25), Position = UDim2.fromOffset(96, 26), BackgroundTransparency = 1, Text = Player.DisplayName, TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 18, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, Parent = AccountCard })
Lib.Create("TextLabel", { Size = UDim2.new(1, -120, 0, 20), Position = UDim2.fromOffset(96, 50), BackgroundTransparency = 1, Text = "@" .. Player.Name, TextColor3 = Color3.fromRGB(150, 150, 150), TextSize = 13, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, Parent = AccountCard })
Lib.Create("Frame", { Size = UDim2.new(1, -40, 0, 1), Position = UDim2.fromOffset(20, 100), BackgroundColor3 = Color3.fromRGB(30, 30, 30), BorderSizePixel = 0, Parent = AccountCard })

Lib.Create("TextLabel", { Size = UDim2.new(1, -40, 0, 18), Position = UDim2.fromOffset(20, 115), BackgroundTransparency = 1, Text = "Registration date", TextColor3 = Color3.fromRGB(130, 130, 130), TextSize = 13, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, Parent = AccountCard })
Lib.Create("TextLabel", { Size = UDim2.new(1, -40, 0, 22), Position = UDim2.fromOffset(20, 135), BackgroundTransparency = 1, Text = os.date("%d.%m.%Y", os.time() - (Player.AccountAge * 86400)), TextColor3 = Color3.fromRGB(220, 220, 220), TextSize = 14, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, Parent = AccountCard })

Lib.Create("TextLabel", { Size = UDim2.new(1, -40, 0, 18), Position = UDim2.fromOffset(20, 170), BackgroundTransparency = 1, Text = "The first script launch", TextColor3 = Color3.fromRGB(130, 130, 130), TextSize = 13, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, Parent = AccountCard })
Lib.Create("TextLabel", { Size = UDim2.new(1, -40, 0, 22), Position = UDim2.fromOffset(20, 190), BackgroundTransparency = 1, Text = GetFirstLaunch(), TextColor3 = Color3.fromRGB(220, 220, 220), TextSize = 14, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, Parent = AccountCard })

Lib.Create("TextLabel", { Size = UDim2.new(1, -40, 0, 18), Position = UDim2.fromOffset(20, 225), BackgroundTransparency = 1, Text = "Total playtime", TextColor3 = Color3.fromRGB(130, 130, 130), TextSize = 13, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, Parent = AccountCard })
local initHours = math.floor(Lib.State.TotalPlaytimeSeconds / 3600)
local initMins = math.floor((Lib.State.TotalPlaytimeSeconds % 3600) / 60)
PlaytimeTextLabel = Lib.Create("TextLabel", { Size = UDim2.new(1, -40, 0, 22), Position = UDim2.fromOffset(20, 245), BackgroundTransparency = 1, Text = string.format("%dh %dm", initHours, initMins), TextColor3 = Color3.fromRGB(220, 220, 220), TextSize = 14, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, Parent = AccountCard })

local DecorDropdownCard = Lib.Create("Frame", {
	Size = UDim2.new(1, 0, 0, 50),
	BackgroundColor3 = Color3.fromRGB(15, 15, 15),
	LayoutOrder = 2,
	ClipsDescendants = true,
	Parent = AccountScroll,
	Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) })
})

local DecorHeaderBtn = Lib.Create("TextButton", {
	Size = UDim2.new(1, 0, 0, 50),
	BackgroundTransparency = 1,
	Text = "",
	Parent = DecorDropdownCard
})

Lib.Create("TextLabel", {
	Size = UDim2.new(1, -60, 1, 0),
	Position = UDim2.new(0, 15, 0, 0),
	BackgroundTransparency = 1,
	Text = "Profile Decorations",
	TextColor3 = Color3.fromRGB(255, 255, 255),
	TextSize = 14,
	Font = Enum.Font.GothamBold,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = DecorHeaderBtn
})

local DropdownArrow = Lib.Create("TextLabel", {
	Size = UDim2.fromOffset(30, 30),
	Position = UDim2.new(1, -40, 0.5, -15),
	BackgroundTransparency = 1,
	Text = "▼",
	TextColor3 = Color3.fromRGB(150, 150, 150),
	TextSize = 12,
	Font = Enum.Font.GothamMedium,
	Parent = DecorHeaderBtn
})

local DecorItemsContainer = Lib.Create("Frame", {
	Size = UDim2.new(1, -30, 0, 80),
	Position = UDim2.new(0, 15, 0, 50),
	BackgroundTransparency = 1,
	Parent = DecorDropdownCard
})

local PulseDecorItem = Lib.Create("Frame", {
	Size = UDim2.new(1, 0, 0, 60),
	BackgroundColor3 = Color3.fromRGB(22, 22, 22),
	Parent = DecorItemsContainer,
	Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
})

Lib.Create("TextLabel", {
	Size = UDim2.new(1, -120, 0, 20),
	Position = UDim2.new(0, 12, 0, 10),
	BackgroundTransparency = 1,
	Text = "White Pulse Glow",
	TextColor3 = Color3.fromRGB(240, 240, 240),
	TextSize = 13,
	Font = Enum.Font.GothamBold,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = PulseDecorItem
})

local PulseDescLabel = Lib.Create("TextLabel", {
	Size = UDim2.new(1, -120, 0, 18),
	Position = UDim2.new(0, 12, 0, 30),
	BackgroundTransparency = 1,
	Text = Lib.State.Ach_10Hours_Claimed and "Unlocked from 10 Hours Played" or "Locked (Reach 10h achievement)",
	TextColor3 = Lib.State.Ach_10Hours_Claimed and Color3.fromRGB(140, 140, 140) or Color3.fromRGB(220, 80, 80),
	TextSize = 11,
	Font = Enum.Font.GothamMedium,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = PulseDecorItem
})

local ToggleDecorBtn = Lib.Create("TextButton", {
	Size = UDim2.fromOffset(80, 30),
	Position = UDim2.new(1, -90, 0.5, -15),
	BackgroundColor3 = Lib.State.IsDecorActive and Color3.fromRGB(46, 213, 115) or Color3.fromRGB(40, 40, 40),
	Text = Lib.State.IsDecorActive and "Equipped" or (Lib.State.Ach_10Hours_Claimed and "Equip" or "Locked"),
	TextColor3 = Color3.fromRGB(255, 255, 255),
	TextSize = 12,
	Font = Enum.Font.GothamBold,
	Parent = PulseDecorItem,
	Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
})

local function UpdateDecorButtonState()
	if not Lib.State.Ach_10Hours_Claimed then
		ToggleDecorBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		ToggleDecorBtn.TextColor3 = Color3.fromRGB(120, 120, 120)
		ToggleDecorBtn.Text = "Locked"
		PulseDescLabel.Text = "Locked (Reach 10h achievement)"
		PulseDescLabel.TextColor3 = Color3.fromRGB(220, 80, 80)
	else
		PulseDescLabel.Text = "Unlocked from 10 Hours Played"
		PulseDescLabel.TextColor3 = Color3.fromRGB(140, 140, 140)
		if Lib.State.IsDecorActive then
			ToggleDecorBtn.BackgroundColor3 = Color3.fromRGB(46, 213, 115)
			ToggleDecorBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			ToggleDecorBtn.Text = "Equipped"
		else
			ToggleDecorBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ToggleDecorBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
			ToggleDecorBtn.Text = "Equip"
		end
	end
	AvatarGlowRing.Visible = Lib.State.IsDecorActive
end

ToggleDecorBtn.MouseButton1Click:Connect(function()
	if not Lib.State.Ach_10Hours_Claimed then return end
	Lib.State.IsDecorActive = not Lib.State.IsDecorActive
	UpdateDecorButtonState()
	SavePlaytimeData()
end)

local isDropdownOpen = false
DecorHeaderBtn.MouseButton1Click:Connect(function()
	isDropdownOpen = not isDropdownOpen
	Lib.Tween(DropdownArrow, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
		Rotation = isDropdownOpen and 180 or 0
	})
	Lib.Tween(DecorDropdownCard, 0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, {
		Size = isDropdownOpen and UDim2.new(1, 0, 0, 140) or UDim2.new(1, 0, 0, 50)
	})
end)

local AchievementsScroll = Lib.Create("ScrollingFrame", {
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	ScrollBarThickness = 2,
	ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100),
	BorderSizePixel = 0,
	Parent = View_Achievements
})
local AchievementsLayout = Lib.Create("UIListLayout", { Padding = UDim.new(0, 14), SortOrder = Enum.SortOrder.LayoutOrder, Parent = AchievementsScroll })
Lib.Create("UIPadding", { PaddingTop = UDim.new(0, 5), PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 15), Parent = AchievementsScroll })

AchievementsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	AchievementsScroll.CanvasSize = UDim2.new(0, 0, 0, AchievementsLayout.AbsoluteContentSize.Y + 20)
end)

local AchCard = Lib.Create("Frame", {
	Size = UDim2.new(1, 0, 0, 90),
	BackgroundColor3 = Color3.fromRGB(12, 12, 12),
	Parent = AchievementsScroll,
	Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
	Lib.Create("UIStroke", { Color = Color3.fromRGB(35, 35, 35), Thickness = 1, Transparency = 0.4 })
})

local AchIconSection = Lib.Create("Frame", { Size = UDim2.new(0, 80, 1, 0), BackgroundTransparency = 1, Parent = AchCard })
local AchIcon = Lib.Create("ImageLabel", {
	Size = UDim2.fromOffset(58, 58),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	Image = "rbxassetid://9241155124241",
	ScaleType = Enum.ScaleType.Fit,
	Parent = AchIconSection
})

Lib.Create("Frame", {
	Size = UDim2.new(0, 1, 1, -20),
	Position = UDim2.new(0, 80, 0.5, 0),
	AnchorPoint = Vector2.new(0, 0.5),
	BackgroundColor3 = Color3.fromRGB(30, 30, 30),
	BorderSizePixel = 0,
	Parent = AchCard
})

local AchInfoSection = Lib.Create("Frame", {
	Size = UDim2.new(1, -210, 1, 0),
	Position = UDim2.new(0, 92, 0, 0),
	BackgroundTransparency = 1,
	Parent = AchCard
})

Lib.Create("TextLabel", { Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0, 12), BackgroundTransparency = 1, Text = "10 HOURS PLAYED", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 15, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, Parent = AchInfoSection })
Lib.Create("TextLabel", { Size = UDim2.new(1, 0, 0, 16), Position = UDim2.new(0, 0, 0, 34), BackgroundTransparency = 1, Text = "Thanks for spending 10 hours with us!", TextColor3 = Color3.fromRGB(140, 140, 140), TextSize = 11, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, Parent = AchInfoSection })

local RewardRow = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 18), Position = UDim2.new(0, 0, 0, 56), BackgroundTransparency = 1, Parent = AchInfoSection })
Lib.Create("ImageLabel", { Size = UDim2.fromOffset(13, 13), Position = UDim2.new(0, 0, 0.5, -7), BackgroundTransparency = 1, Image = "rbxassetid://10734944449", ImageColor3 = Color3.fromRGB(255, 255, 255), ScaleType = Enum.ScaleType.Fit, Parent = RewardRow })
Lib.Create("TextLabel", { Size = UDim2.new(0, 50, 1, 0), Position = UDim2.new(0, 17, 0, 0), BackgroundTransparency = 1, Text = "REWARD:", TextColor3 = Color3.fromRGB(220, 220, 220), TextSize = 10, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, Parent = RewardRow })
Lib.Create("TextLabel", { Size = UDim2.new(1, -70, 1, 0), Position = UDim2.new(0, 72, 0, 0), BackgroundTransparency = 1, Text = "Profile Decoration", TextColor3 = Color3.fromRGB(150, 150, 150), TextSize = 11, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, Parent = RewardRow })

local ClaimAchBtn = Lib.Create("TextButton", {
	Size = UDim2.fromOffset(105, 30),
	Position = UDim2.new(1, -115, 0.5, -15),
	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	Text = "Claim",
	TextColor3 = Color3.fromRGB(0, 0, 0),
	TextSize = 12,
	Font = Enum.Font.GothamBold,
	Parent = AchCard,
	Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
})

local function RefreshAchievementUI()
	local hours = Lib.State.TotalPlaytimeSeconds / 3600
	if Lib.State.Ach_10Hours_Claimed then
		ClaimAchBtn.Text = "Claimed ✓"
		ClaimAchBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
		ClaimAchBtn.TextColor3 = Color3.fromRGB(120, 120, 120)
		ClaimAchBtn.AutoButtonColor = false
	elseif hours >= 10 then
		ClaimAchBtn.Text = "Claim Reward"
		ClaimAchBtn.BackgroundColor3 = Color3.fromRGB(46, 213, 115)
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
	local hours = Lib.State.TotalPlaytimeSeconds / 3600
	if (hours >= 10 or Player.Name:lower() == "cherrycalcor") and not Lib.State.Ach_10Hours_Claimed then
		Lib.State.Ach_10Hours_Claimed = true
		Lib.State.IsDecorActive = true
		SavePlaytimeData()
		RefreshAchievementUI()
		UpdateDecorButtonState()
	end
end)

AchUpdateCallback = RefreshAchievementUI
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
	Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 65), BackgroundColor3 = Color3.fromRGB(15, 15, 15), LayoutOrder = i, Parent = View_Developers, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
		Lib.Create("TextLabel", { Size = UDim2.new(1, -30, 0, 22), Position = UDim2.fromOffset(15, 12), BackgroundTransparency = 1, Text = v[1], TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 15, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left }),
		Lib.Create("TextLabel", { Size = UDim2.new(1, -30, 0, 18), Position = UDim2.fromOffset(15, 34), BackgroundTransparency = 1, Text = v[2], TextColor3 = Color3.fromRGB(150, 150, 150), TextSize = 12, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left })
	})
end

local FeaturesSection = Lib.Create("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, Parent = ContentArea })
local FeaturesSideBar = Lib.Create("Frame", { Size = UDim2.new(0, 180, 1, 0), BackgroundTransparency = 1, Parent = FeaturesSection,
	Lib.Create("TextLabel", { Size = UDim2.new(1, -30, 0, 30), Position = UDim2.new(0, 20, 0, 10), BackgroundTransparency = 1, Text = "Features", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 20, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left }),
	Lib.Create("TextLabel", { Size = UDim2.new(1, -30, 0, 20), AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 15, 1, -15), BackgroundTransparency = 1, Text = "Visuals & Utilities", TextColor3 = Color3.fromRGB(100, 100, 100), TextSize = 11, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left })
})

local function SwitchFeaturesTab(tabName)
	if Lib.State.CurrentFeaturesTab == tabName then return end
	Lib.State.CurrentFeaturesTab = tabName

	for name, view in pairs(Lib.UI.FeaturesViews) do
		local btn = Lib.UI.FeaturesTabBtns[name]
		local isSel = (name == tabName)

		Lib.Tween(btn, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { TextColor3 = isSel and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150), BackgroundTransparency = isSel and 0.92 or 1 })
		
		if isSel then
			view.Visible = true
			view.Position = UDim2.new(0, 195, 0, 10)
			view.GroupTransparency = 1
			Lib.Tween(view, 0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, { Position = UDim2.new(0, 180, 0, 10), GroupTransparency = 0 })
		elseif view.Visible then
			local t = Lib.Tween(view, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Position = UDim2.new(0, 170, 0, 10), GroupTransparency = 1 })
			t.Completed:Connect(function() if Lib.State.CurrentFeaturesTab ~= name then view.Visible = false end end)
		end
	end
end

local function MakeFeaturesTab(name, posY)
	local btn = Lib.Create("TextButton", { Size = UDim2.new(1, -30, 0, 34), Position = UDim2.new(0, 15, 0, posY), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1, Text = name, TextColor3 = Color3.fromRGB(150, 150, 150), TextSize = 14, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, Parent = FeaturesSideBar,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 7) }), Lib.Create("UIPadding", { PaddingLeft = UDim.new(0, 12) })
	})
	Lib.UI.FeaturesTabBtns[name] = btn

	local view = Lib.Create("CanvasGroup", { Size = UDim2.new(1, -190, 1, -20), Position = UDim2.new(0, 180, 0, 10), BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false, GroupTransparency = 1, Parent = FeaturesSection })
	Lib.UI.FeaturesViews[name] = view

	btn.MouseEnter:Connect(function() if Lib.State.CurrentFeaturesTab ~= name then Lib.Tween(btn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { TextColor3 = Color3.fromRGB(210, 210, 210), BackgroundTransparency = 0.96 }) end end)
	btn.MouseLeave:Connect(function() Lib.Tween(btn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Size = UDim2.new(1, -30, 0, 34) }) if Lib.State.CurrentFeaturesTab ~= name then Lib.Tween(btn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { TextColor3 = Color3.fromRGB(150, 150, 150), BackgroundTransparency = 1 }) end end)
	btn.MouseButton1Down:Connect(function() Lib.Tween(btn, 0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Size = UDim2.new(1, -36, 0, 31) }) end)
	btn.MouseButton1Up:Connect(function() Lib.Tween(btn, 0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Size = UDim2.new(1, -30, 0, 34) }) end)
	btn.MouseButton1Click:Connect(function() SwitchFeaturesTab(name) end)

	return view
end

local View_Visuals = MakeFeaturesTab("Visuals", 50)
local View_Server = MakeFeaturesTab("Server", 90)

local VisualsScroll = Lib.Create("ScrollingFrame", {
	Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0),
	BackgroundTransparency = 1, ScrollBarThickness = 2,
	ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100), BorderSizePixel = 0,
	Parent = View_Visuals
})
local VisualsLayout = Lib.Create("UIListLayout", { Padding = UDim.new(0, 14), SortOrder = Enum.SortOrder.LayoutOrder, Parent = VisualsScroll })
Lib.Create("UIPadding", { PaddingTop = UDim.new(0, 5), PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 15), Parent = VisualsScroll })

VisualsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	VisualsScroll.CanvasSize = UDim2.new(0, 0, 0, VisualsLayout.AbsoluteContentSize.Y + 20)
end)

local ServerScroll = Lib.Create("ScrollingFrame", {
	Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0),
	BackgroundTransparency = 1, ScrollBarThickness = 2,
	ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100), BorderSizePixel = 0,
	Parent = View_Server
})
local ServerLayout = Lib.Create("UIListLayout", { Padding = UDim.new(0, 14), SortOrder = Enum.SortOrder.LayoutOrder, Parent = ServerScroll })
Lib.Create("UIPadding", { PaddingTop = UDim.new(0, 5), PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 15), Parent = ServerScroll })

ServerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	ServerScroll.CanvasSize = UDim2.new(0, 0, 0, ServerLayout.AbsoluteContentSize.Y + 20)
end)

local function CreateFeatureGroup(parentScroll, title, layoutOrder)
	local GroupContainer = Lib.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = layoutOrder,
		Parent = parentScroll
	})

	Lib.Create("TextLabel", {
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

	local Card = Lib.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Position = UDim2.new(0, 0, 0, 26),
		BackgroundColor3 = Color3.fromRGB(15, 15, 15),
		Parent = GroupContainer,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
		Lib.Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder })
	})

	return Card
end

local function CreateSettingToggleItem(parentCard, title, desc, defaultState, onToggle, isLast)
	local Item = Lib.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 50),
		BackgroundTransparency = 1,
		Parent = parentCard
	})

	Lib.Create("TextLabel", {
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

	Lib.Create("TextLabel", {
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

	local SwitchBg = Lib.Create("TextButton", {
		Size = UDim2.fromOffset(40, 22),
		Position = UDim2.new(1, -54, 0.5, -11),
		BackgroundColor3 = defaultState and Color3.fromRGB(46, 213, 115) or Color3.fromRGB(38, 38, 38),
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
	SwitchBg.MouseButton1Click:Connect(function()
		state = not state
		Lib.Tween(SwitchBg, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
			BackgroundColor3 = state and Color3.fromRGB(46, 213, 115) or Color3.fromRGB(38, 38, 38)
		})
		Lib.Tween(SwitchKnob, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
			Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
		})
		onToggle(state)
	end)

	return Item
end

local function CreateSettingButtonItem(parentCard, title, desc, onClick, isLast)
	local Item = Lib.Create("TextButton", {
		Size = UDim2.new(1, 0, 0, 52),
		BackgroundColor3 = Color3.fromRGB(15, 15, 15),
		BackgroundTransparency = 0,
		Text = "",
		AutoButtonColor = false,
		Parent = parentCard,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) })
	})

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

	Lib.Create("TextLabel", {
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

	if not isLast then
		Lib.Create("Frame", {
			Size = UDim2.new(1, -28, 0, 1),
			Position = UDim2.new(0, 14, 1, -1),
			BackgroundColor3 = Color3.fromRGB(25, 25, 25),
			BorderSizePixel = 0,
			Parent = Item
		})
	end

	Item.MouseEnter:Connect(function()
		Lib.Tween(Item, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
			BackgroundColor3 = Color3.fromRGB(28, 28, 28)
		})
	end)

	Item.MouseLeave:Connect(function()
		Lib.Tween(Item, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
			BackgroundColor3 = Color3.fromRGB(15, 15, 15)
		})
	end)

	Item.MouseButton1Down:Connect(function()
		Lib.Tween(Item, 0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
			BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		})
	end)

	Item.MouseButton1Up:Connect(function()
		Lib.Tween(Item, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
			BackgroundColor3 = Color3.fromRGB(28, 28, 28)
		})
	end)

	Item.MouseButton1Click:Connect(function()
		onClick(TitleLabel)
	end)

	return Item
end

local ESP_Storage = {}

local function ClearPlayerESP(plr)
	if ESP_Storage[plr] then
		if ESP_Storage[plr].Highlight then pcall(function() ESP_Storage[plr].Highlight:Destroy() end) end
		if ESP_Storage[plr].Billboard then pcall(function() ESP_Storage[plr].Billboard:Destroy() end) end
		if ESP_Storage[plr].BoxLines then
			for _, line in pairs(ESP_Storage[plr].BoxLines) do pcall(function() line:Remove() end) end
		end
		if ESP_Storage[plr].TracerLine then pcall(function() ESP_Storage[plr].TracerLine:Remove() end) end
		ESP_Storage[plr] = nil
	end
end

local function InitPlayerESP(plr)
	if plr == Player then return end
	ClearPlayerESP(plr)

	local data = {
		Highlight = nil,
		Billboard = nil,
		BoxLines = nil,
		TracerLine = nil
	}

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

	ESP_Storage[plr] = data
end

for _, p in ipairs(Services.Players:GetPlayers()) do
	if p ~= Player then InitPlayerESP(p) end
end
Services.Players.PlayerAdded:Connect(InitPlayerESP)
Services.Players.PlayerRemoving:Connect(ClearPlayerESP)

Services.Run.RenderStepped:Connect(function()
	for plr, esp in pairs(ESP_Storage) do
		local char = plr.Character
		local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"))
		local hum = char and char:FindFirstChildOfClass("Humanoid")

		if char and root and hum and hum.Health > 0 then
			local distance = math.floor((root.Position - Camera.CFrame.Position).Magnitude)
			local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)

			if Lib.State.ESP_Name then
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

			if Lib.State.ESP_Outline then
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
				local headPos = head and Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0)) or Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 2.5, 0))
				local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))

				local height = math.abs(headPos.Y - legPos.Y)
				local width = height * 0.65
				local topLeft = Vector2.new(screenPos.X - width / 2, screenPos.Y - height / 2)

				if Lib.State.ESP_Box and esp.BoxLines then
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

				if Lib.State.ESP_Tracers and esp.TracerLine then
					esp.TracerLine.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
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

local OriginalLighting = {
	Brightness = Services.Lighting.Brightness,
	ClockTime = Services.Lighting.ClockTime,
	FogEnd = Services.Lighting.FogEnd,
	GlobalShadows = Services.Lighting.GlobalShadows,
	OutdoorAmbient = Services.Lighting.OutdoorAmbient
}

local function ApplyBoostFPS()
	pcall(function()
		sethiddenproperty(Services.Lighting, "Technology", 2)
	end)
	Services.Lighting.GlobalShadows = false
	Services.Lighting.FogEnd = 9e9

	for _, v in ipairs(Services.Workspace:GetDescendants()) do
		if v:IsA("BasePart") and not v:IsA("MeshPart") then
			v.Material = Enum.Material.SmoothPlastic
			v.Reflectance = 0
		elseif v:IsA("Decal") or v:IsA("Texture") then
			v.Transparency = 1
		elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
			v.Enabled = false
		end
	end
end

Services.Run.RenderStepped:Connect(function()
	if Lib.State.FullBright then
		Services.Lighting.Brightness = 2
		Services.Lighting.ClockTime = 14
		Services.Lighting.FogEnd = 100000
		Services.Lighting.GlobalShadows = false
		Services.Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
	end
end)

local HoverSelectionBox = Lib.Create("SelectionBox", {
	Name = "Septus_HoverSelection",
	LineThickness = 0.04,
	Parent = Screen
})

local function CreateToolsEngine()
	local mouse = Player:GetMouse()
	local activeTool = nil

	local RemoveTextureTool = Lib.Create("Tool", { Name = "Remove Texture", RequiresHandle = false, CanBeDropped = false })
	local PartDeletedTool = Lib.Create("Tool", { Name = "Part Deleted", RequiresHandle = false, CanBeDropped = false })

	local function BindTool(tool, toolType)
		tool.Equipped:Connect(function() activeTool = toolType end)
		tool.Unequipped:Connect(function()
			if activeTool == toolType then activeTool = nil end
			HoverSelectionBox.Adornee = nil
		end)
		tool.Activated:Connect(function()
			local target = mouse.Target
			if not target then return end

			if toolType == "PartDeleted" then
				if not target:IsDescendantOf(Player.Character) and not target:IsA("Terrain") then
					HoverSelectionBox.Adornee = nil
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

	Services.Run.RenderStepped:Connect(function()
		if activeTool then
			local target = mouse.Target
			if target and target:IsA("BasePart") and not target:IsDescendantOf(Player.Character) and not target:IsA("Terrain") then
				HoverSelectionBox.Adornee = target
				HoverSelectionBox.Color3 = (activeTool == "PartDeleted") and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(60, 200, 255)
			else
				HoverSelectionBox.Adornee = nil
			end
		else
			HoverSelectionBox.Adornee = nil
		end
	end)

	return { RemoveTextureTool = RemoveTextureTool, PartDeletedTool = PartDeletedTool }
end

local ToolsEngine = CreateToolsEngine()

local ESPGroup = CreateFeatureGroup(VisualsScroll, "ESP", 1)
CreateSettingToggleItem(ESPGroup, "Esp Name", "Display player display names with studs distance", Lib.State.ESP_Name, function(val) Lib.State.ESP_Name = val end)
CreateSettingToggleItem(ESPGroup, "ESP Outline", "Highlight player character models through obstacles", Lib.State.ESP_Outline, function(val) Lib.State.ESP_Outline = val end)
CreateSettingToggleItem(ESPGroup, "Box ESP", "Draw 2D bounding boxes around players", Lib.State.ESP_Box, function(val) Lib.State.ESP_Box = val end)
CreateSettingToggleItem(ESPGroup, "Tracers", "Draw lines connecting screen bottom to players", Lib.State.ESP_Tracers, function(val) Lib.State.ESP_Tracers = val end, true)

local BoostGroup = CreateFeatureGroup(VisualsScroll, "Boost FPS & World", 2)
CreateSettingToggleItem(BoostGroup, "Boost FPS", "Very strong texture compression & maximum performance boost", Lib.State.BoostFPS, function(val)
	Lib.State.BoostFPS = val
	if val then ApplyBoostFPS() end
end)
CreateSettingToggleItem(BoostGroup, "FullBright", "Disable darkness, shadows and set maximum ambient brightness", Lib.State.FullBright, function(val)
	Lib.State.FullBright = val
	if not val then
		Services.Lighting.Brightness = OriginalLighting.Brightness
		Services.Lighting.ClockTime = OriginalLighting.ClockTime
		Services.Lighting.FogEnd = OriginalLighting.FogEnd
		Services.Lighting.GlobalShadows = OriginalLighting.GlobalShadows
		Services.Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
	end
end)
CreateSettingToggleItem(BoostGroup, "Remove Texture", "Gives a tool to remove textures & decals from hovered parts", Lib.State.Tool_RemoveTexture, function(val)
	Lib.State.Tool_RemoveTexture = val
	if val then ToolsEngine.RemoveTextureTool.Parent = Player.Backpack else pcall(function() ToolsEngine.RemoveTextureTool.Parent = nil end) end
end)
CreateSettingToggleItem(BoostGroup, "Part Deleted", "Gives a tool with red hover highlight to destroy any clicked part locally", Lib.State.Tool_PartDeleted, function(val)
	Lib.State.Tool_PartDeleted = val
	if val then ToolsEngine.PartDeletedTool.Parent = Player.Backpack else pcall(function() ToolsEngine.PartDeletedTool.Parent = nil end) end
end, true)

local ServerSettingsModalBackdrop = Lib.Create("TextButton", {
	Name = "ServerSettingsModalBackdrop",
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	BackgroundTransparency = 1,
	Text = "",
	AutoButtonColor = false,
	Visible = false,
	ZIndex = 30,
	Parent = Main
})

local ServerSettingsWindow = Lib.Create("Frame", {
	Size = UDim2.fromOffset(340, 330),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = Color3.fromRGB(16, 16, 16),
	ClipsDescendants = true,
	ZIndex = 31,
	Parent = ServerSettingsModalBackdrop,
	Lib.Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
	Lib.Create("UIStroke", { Color = Color3.fromRGB(40, 40, 40), Thickness = 1, Transparency = 0.4 })
})

Lib.Create("TextLabel", {
	Size = UDim2.new(1, -60, 0, 35),
	Position = UDim2.fromOffset(16, 8),
	BackgroundTransparency = 1,
	Text = "Server List Settings",
	TextColor3 = Color3.fromRGB(255, 255, 255),
	TextSize = 15,
	Font = Enum.Font.GothamBold,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 32,
	Parent = ServerSettingsWindow
})

local CloseSettingsBtn = Lib.Create("TextButton", {
	Size = UDim2.fromOffset(28, 28),
	Position = UDim2.new(1, -38, 0, 10),
	BackgroundColor3 = Color3.fromRGB(25, 25, 25),
	Text = "×",
	TextColor3 = Color3.fromRGB(180, 180, 180),
	TextSize = 16,
	Font = Enum.Font.GothamBold,
	ZIndex = 32,
	Parent = ServerSettingsWindow,
	Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
})

local SettingsContent = Lib.Create("ScrollingFrame", {
	Size = UDim2.new(1, -24, 1, -55),
	Position = UDim2.fromOffset(12, 45),
	BackgroundTransparency = 1,
	ScrollBarThickness = 2,
	ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80),
	BorderSizePixel = 0,
	ZIndex = 32,
	Parent = ServerSettingsWindow
})
local SettingsLayout = Lib.Create("UIListLayout", { Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder, Parent = SettingsContent })
SettingsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	SettingsContent.CanvasSize = UDim2.new(0, 0, 0, SettingsLayout.AbsoluteContentSize.Y + 10)
end)

local function MakeModalChipGroup(title, options, currentVal, onSelect, layoutOrder)
	local Sec = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = layoutOrder, ZIndex = 32, Parent = SettingsContent })
	Lib.Create("TextLabel", { Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Text = title, TextColor3 = Color3.fromRGB(200, 200, 200), TextSize = 12, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 33, Parent = Sec })
	local Grid = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Position = UDim2.new(0, 0, 0, 22), BackgroundColor3 = Color3.fromRGB(22, 22, 22), ZIndex = 33, Parent = Sec, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) }), Lib.Create("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6) }) })
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

local LoadServerList

local function OpenServerSettingsModal()
	ServerSettingsModalBackdrop.Visible = true
	ServerSettingsWindow.Size = UDim2.fromOffset(320, 310)
	Lib.Tween(ServerSettingsModalBackdrop, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundTransparency = 0.45 })
	Lib.Tween(ServerSettingsWindow, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Size = UDim2.fromOffset(340, 330) })
end

local function CloseServerSettingsModal()
	Lib.Tween(ServerSettingsWindow, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In, { Size = UDim2.fromOffset(300, 290) })
	local t = Lib.Tween(ServerSettingsModalBackdrop, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In, { BackgroundTransparency = 1 })
	t.Completed:Connect(function()
		ServerSettingsModalBackdrop.Visible = false
	end)
end

CloseSettingsBtn.MouseButton1Click:Connect(CloseServerSettingsModal)

MakeModalChipGroup("Sort by Players", {"Most Players", "Least Players"}, Lib.State.ServerList.Sort, function(val)
	Lib.State.ServerList.Sort = val
	if Lib.State.ServerList.IsOpen then LoadServerList() end
end, 1)

MakeModalChipGroup("Server Density / State", {"All", "Almost Empty", "Almost Full"}, Lib.State.ServerList.FillState, function(val)
	Lib.State.ServerList.FillState = val
	if Lib.State.ServerList.IsOpen then LoadServerList() end
end, 2)

MakeModalChipGroup("Occupancy Percent", {"All", "10-20%", "30-40%", "50-60%", "70-80%"}, Lib.State.ServerList.PercentRange, function(val)
	Lib.State.ServerList.PercentRange = val
	if Lib.State.ServerList.IsOpen then LoadServerList() end
end, 3)

local ServerManagementGroup = CreateFeatureGroup(ServerScroll, "Server Management", 1)
CreateSettingButtonItem(ServerManagementGroup, "Rejoin", "Reconnects you back to the current server", function(titleLbl)
	local oldText = titleLbl.Text
	titleLbl.Text = "Rejoining server..."
	RejoinCurrentServer()
	task.delay(3, function() titleLbl.Text = oldText end)
end)
CreateSettingButtonItem(ServerManagementGroup, "Server Hop", "Finds and teleports you to a random active public server", function(titleLbl)
	local oldText = titleLbl.Text
	titleLbl.Text = "Searching for a server..."
	ServerHop()
	task.delay(4, function() titleLbl.Text = oldText end)
end, true)

local ServerListCard = Lib.Create("Frame", {
	Size = UDim2.new(1, 0, 0, 50),
	BackgroundColor3 = Color3.fromRGB(15, 15, 15),
	LayoutOrder = 2,
	ClipsDescendants = true,
	Parent = ServerScroll,
	Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) })
})

local ServerListHeader = Lib.Create("Frame", {
	Size = UDim2.new(1, 0, 0, 50),
	BackgroundTransparency = 1,
	Parent = ServerListCard
})

local ServerListHeaderBtn = Lib.Create("TextButton", {
	Size = UDim2.new(1, -90, 1, 0),
	Position = UDim2.new(0, 0, 0, 0),
	BackgroundTransparency = 1,
	Text = "",
	Parent = ServerListHeader
})

Lib.Create("TextLabel", {
	Size = UDim2.new(1, -20, 1, 0),
	Position = UDim2.new(0, 14, 0, 0),
	BackgroundTransparency = 1,
	Text = "Server List",
	TextColor3 = Color3.fromRGB(240, 240, 240),
	TextSize = 14,
	Font = Enum.Font.GothamBold,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = ServerListHeaderBtn
})

local ServerGearBtn = Lib.Create("ImageButton", {
	Size = UDim2.fromOffset(28, 28),
	Position = UDim2.new(1, -78, 0.5, -14),
	BackgroundColor3 = Color3.fromRGB(22, 22, 22),
	Image = "rbxassetid://10734944449",
	ImageColor3 = Color3.fromRGB(180, 180, 180),
	ScaleType = Enum.ScaleType.Fit,
	Parent = ServerListHeader,
	Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
	Lib.Create("UIPadding", { PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5), PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5) })
})

ServerGearBtn.MouseEnter:Connect(function() Lib.Tween(ServerGearBtn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Color3.fromRGB(35, 35, 35), ImageColor3 = Color3.fromRGB(255, 255, 255) }) end)
ServerGearBtn.MouseLeave:Connect(function() Lib.Tween(ServerGearBtn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Color3.fromRGB(22, 22, 22), ImageColor3 = Color3.fromRGB(180, 180, 180) }) end)
ServerGearBtn.MouseButton1Click:Connect(OpenServerSettingsModal)

local ServerListArrow = Lib.Create("TextLabel", {
	Size = UDim2.fromOffset(30, 30),
	Position = UDim2.new(1, -40, 0.5, -15),
	BackgroundTransparency = 1,
	Text = "▼",
	TextColor3 = Color3.fromRGB(150, 150, 150),
	TextSize = 12,
	Font = Enum.Font.GothamMedium,
	Parent = ServerListHeader
})

local ServerListBody = Lib.Create("Frame", {
	Size = UDim2.new(1, -24, 0, 240),
	Position = UDim2.new(0, 12, 0, 50),
	BackgroundTransparency = 1,
	Parent = ServerListCard
})

local ServerListScroll = Lib.Create("ScrollingFrame", {
	Size = UDim2.new(1, 0, 1, -10),
	BackgroundTransparency = 1,
	ScrollBarThickness = 2,
	ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80),
	BorderSizePixel = 0,
	Parent = ServerListBody
})
local ServerListInnerLayout = Lib.Create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = ServerListScroll })
ServerListInnerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	ServerListScroll.CanvasSize = UDim2.new(0, 0, 0, ServerListInnerLayout.AbsoluteContentSize.Y + 10)
end)

local ServerStatusLabel = Lib.Create("TextLabel", {
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	Text = "Click to load servers...",
	TextColor3 = Color3.fromRGB(140, 140, 140),
	TextSize = 13,
	Font = Enum.Font.GothamMedium,
	Visible = true,
	Parent = ServerListBody
})

local function CreateServerEntry(serverData, order)
	local Item = Lib.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 48),
		BackgroundColor3 = Color3.fromRGB(22, 22, 22),
		LayoutOrder = order,
		Parent = ServerListScroll,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
	})

	local percent = math.floor((serverData.playing / math.max(serverData.maxPlayers, 1)) * 100)
	local shortJob = tostring(serverData.id):sub(1, 8) .. "..."

	Lib.Create("TextLabel", {
		Size = UDim2.new(0, 160, 0, 18),
		Position = UDim2.new(0, 12, 0, 6),
		BackgroundTransparency = 1,
		Text = "👥 " .. tostring(serverData.playing) .. " / " .. tostring(serverData.maxPlayers) .. " Players",
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextSize = 12,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = Item
	})

	Lib.Create("TextLabel", {
		Size = UDim2.new(0, 160, 0, 16),
		Position = UDim2.new(0, 12, 0, 24),
		BackgroundTransparency = 1,
		Text = "ID: " .. shortJob .. " • " .. tostring(percent) .. "% Full",
		TextColor3 = Color3.fromRGB(130, 130, 130),
		TextSize = 11,
		Font = Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = Item
	})

	local JoinBtn = Lib.Create("TextButton", {
		Size = UDim2.fromOffset(70, 28),
		Position = UDim2.new(1, -78, 0.5, -14),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Text = "Join",
		TextColor3 = Color3.fromRGB(0, 0, 0),
		TextSize = 12,
		Font = Enum.Font.GothamBold,
		Parent = Item,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
	})

	JoinBtn.MouseEnter:Connect(function() Lib.Tween(JoinBtn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Color3.fromRGB(210, 210, 210) }) end)
	JoinBtn.MouseLeave:Connect(function() Lib.Tween(JoinBtn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Color3.fromRGB(255, 255, 255) }) end)
	
	JoinBtn.MouseButton1Click:Connect(function()
		JoinBtn.Text = "..."
		pcall(function()
			Services.Teleport:TeleportToPlaceInstance(game.PlaceId, serverData.id, Player)
		end)
	end)
end

function LoadServerList()
	if Lib.State.ServerList.Loading then return end
	Lib.State.ServerList.Loading = true

	for _, c in ipairs(ServerListScroll:GetChildren()) do
		if c:IsA("Frame") then c:Destroy() end
	end

	ServerStatusLabel.Text = "Fetching servers..."
	ServerStatusLabel.Visible = true
	ServerListScroll.Visible = false

	task.spawn(function()
		local placeId = game.PlaceId
		local currentJob = game.JobId
		local sortQuery = (Lib.State.ServerList.Sort == "Least Players") and "Asc" or "Desc"

		local endpointUrls = {
			"https://games.roproxy.com/v1/games/" .. tostring(placeId) .. "/servers/Public?sortOrder=" .. sortQuery .. "&limit=100",
			"https://games.roblox.com/v1/games/" .. tostring(placeId) .. "/servers/Public?sortOrder=" .. sortQuery .. "&limit=100",
			"https://games.roproxy.com/v1/games/" .. tostring(placeId) .. "/servers/0?sortOrder=" .. sortQuery .. "&limit=100"
		}

		local decodedData = nil
		local httpFailed = false

		for _, url in ipairs(endpointUrls) do
			local success, body = HTTPRequest(url)
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
			Lib.State.ServerList.Loading = false
			return
		end

		local list = {}
		for _, s in ipairs(decodedData) do
			if s.playing and s.maxPlayers then

				local isNotCurrent = (#decodedData > 1) and (s.id ~= currentJob) or true
				
				if isNotCurrent then
					local pct = math.floor((s.playing / s.maxPlayers) * 100)
					
					local passState = true
					if Lib.State.ServerList.FillState == "Almost Empty" and pct > 25 then
						passState = false
					elseif Lib.State.ServerList.FillState == "Almost Full" and pct < 80 then
						passState = false
					end

					local passPercent = true
					if Lib.State.ServerList.PercentRange == "10-20%" and (pct < 10 or pct > 20) then passPercent = false
					elseif Lib.State.ServerList.PercentRange == "30-40%" and (pct < 30 or pct > 40) then passPercent = false
					elseif Lib.State.ServerList.PercentRange == "50-60%" and (pct < 50 or pct > 60) then passPercent = false
					elseif Lib.State.ServerList.PercentRange == "70-80%" and (pct < 70 or pct > 80) then passPercent = false
					end

					if passState and passPercent then
						table.insert(list, s)
					end
				end
			end
		end

		if #list > 0 then
			table.sort(list, function(a, b)
				if Lib.State.ServerList.Sort == "Least Players" then
					return a.playing < b.playing
				else
					return a.playing > b.playing
				end
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

		Lib.State.ServerList.Loading = false
	end)
end

ServerListHeaderBtn.MouseButton1Click:Connect(function()
	Lib.State.ServerList.IsOpen = not Lib.State.ServerList.IsOpen
	Lib.Tween(ServerListArrow, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
		Rotation = Lib.State.ServerList.IsOpen and 180 or 0
	})
	Lib.Tween(ServerListCard, 0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, {
		Size = Lib.State.ServerList.IsOpen and UDim2.new(1, 0, 0, 300) or UDim2.new(1, 0, 0, 50)
	})

	if Lib.State.ServerList.IsOpen then
		LoadServerList()
	end
end)

local function LoadScriptsPage(page) end
local function ClearScriptsCache()
	Lib.State.ScriptsCache = {}
	Lib.State.ScriptsPage = 1
	if Lib.State.CurrentScriptsTab == "Browse" then
		LoadScriptsPage(1)
	end
end

local ScriptsSection = Lib.Create("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, Parent = ContentArea })
local ScriptsSideBar = Lib.Create("Frame", { Size = UDim2.new(0, 180, 1, 0), BackgroundTransparency = 1, Parent = ScriptsSection,
	Lib.Create("TextLabel", { Size = UDim2.new(1, -30, 0, 30), Position = UDim2.new(0, 20, 0, 10), BackgroundTransparency = 1, Text = "Scripts", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 20, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left }),
	Lib.Create("TextLabel", { Size = UDim2.new(1, -30, 0, 20), AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 15, 1, -15), BackgroundTransparency = 1, Text = "Powered by API", TextColor3 = Color3.fromRGB(100, 100, 100), TextSize = 11, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left })
})

local function SwitchScriptsTab(tabName)
	if Lib.State.CurrentScriptsTab == tabName then return end
	Lib.State.CurrentScriptsTab = tabName

	for name, view in pairs(Lib.UI.ScriptsViews) do
		local btn = Lib.UI.ScriptsTabBtns[name]
		local isSel = (name == tabName)

		Lib.Tween(btn, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { TextColor3 = isSel and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150), BackgroundTransparency = isSel and 0.92 or 1 })
		
		if isSel then
			view.Visible = true
			view.Position = UDim2.new(0, 195, 0, 10)
			view.GroupTransparency = 1
			Lib.Tween(view, 0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, { Position = UDim2.new(0, 180, 0, 10), GroupTransparency = 0 })
		elseif view.Visible then
			local t = Lib.Tween(view, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Position = UDim2.new(0, 170, 0, 10), GroupTransparency = 1 })
			t.Completed:Connect(function() if Lib.State.CurrentScriptsTab ~= name then view.Visible = false end end)
		end
	end
	
	if tabName == "Browse" and not Lib.State.ScriptsCache[Lib.State.ScriptsPage] and not Lib.State.ScriptsLoading then
		LoadScriptsPage(Lib.State.ScriptsPage)
	end
end

local function MakeScriptsTab(name, posY)
	local btn = Lib.Create("TextButton", { Size = UDim2.new(1, -30, 0, 34), Position = UDim2.new(0, 15, 0, posY), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1, Text = name, TextColor3 = Color3.fromRGB(150, 150, 150), TextSize = 14, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, Parent = ScriptsSideBar,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 7) }), Lib.Create("UIPadding", { PaddingLeft = UDim.new(0, 12) })
	})
	Lib.UI.ScriptsTabBtns[name] = btn

	local view = Lib.Create("CanvasGroup", { Size = UDim2.new(1, -190, 1, -20), Position = UDim2.new(0, 180, 0, 10), BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false, GroupTransparency = 1, Parent = ScriptsSection })
	Lib.UI.ScriptsViews[name] = view

	btn.MouseEnter:Connect(function() if Lib.State.CurrentScriptsTab ~= name then Lib.Tween(btn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { TextColor3 = Color3.fromRGB(210, 210, 210), BackgroundTransparency = 0.96 }) end end)
	btn.MouseLeave:Connect(function() Lib.Tween(btn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Size = UDim2.new(1, -30, 0, 34) }) if Lib.State.CurrentScriptsTab ~= name then Lib.Tween(btn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { TextColor3 = Color3.fromRGB(150, 150, 150), BackgroundTransparency = 1 }) end end)
	btn.MouseButton1Down:Connect(function() Lib.Tween(btn, 0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Size = UDim2.new(1, -36, 0, 31) }) end)
	btn.MouseButton1Up:Connect(function() Lib.Tween(btn, 0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Size = UDim2.new(1, -30, 0, 34) }) end)
	btn.MouseButton1Click:Connect(function() SwitchScriptsTab(name) end)

	return view
end

local View_Browse = MakeScriptsTab("Browse", 50)
local View_Settings = MakeScriptsTab("Settings", 90)

Lib.Create("UIListLayout", { Padding = UDim.new(0, 20), Parent = View_Settings })
Lib.Create("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5), Parent = View_Settings })

local function MakeChipGroup(parentView, title, stateKey, options, callback, layoutOrder)
	local Section = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = layoutOrder, Parent = parentView })
	Lib.Create("TextLabel", { Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 5, 0, 0), BackgroundTransparency = 1, Text = title, TextColor3 = Color3.fromRGB(240, 240, 240), TextSize = 14, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, Parent = Section })
	
	local Container = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Position = UDim2.new(0, 0, 0, 28), BackgroundColor3 = Color3.fromRGB(20, 20, 20), Parent = Section, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 10) }), Lib.Create("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }) })
	
	Lib.Create("UIGridLayout", { CellSize = UDim2.fromOffset(115, 30), CellPadding = UDim2.fromOffset(8, 8), SortOrder = Enum.SortOrder.LayoutOrder, FillDirection = Enum.FillDirection.Horizontal, Parent = Container })

	local btns = {}
	for i, opt in ipairs(options) do
		local isSel = (Lib.State[stateKey] == opt)
		local btn = Lib.Create("TextButton", { Size = UDim2.fromOffset(115, 30), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = isSel and 0 or 1, Text = opt, TextColor3 = isSel and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(150, 150, 150), TextSize = 12, Font = Enum.Font.GothamMedium, LayoutOrder = i, Parent = Container, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }) })
		btns[opt] = btn

		btn.MouseEnter:Connect(function()
			if Lib.State[stateKey] ~= opt then
				Lib.Tween(btn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { TextColor3 = Color3.fromRGB(220, 220, 220), BackgroundTransparency = 0.93 })
			end
		end)
		btn.MouseLeave:Connect(function()
			if Lib.State[stateKey] ~= opt then
				Lib.Tween(btn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { TextColor3 = Color3.fromRGB(150, 150, 150), BackgroundTransparency = 1 })
			end
		end)
		btn.MouseButton1Click:Connect(function()
			if Lib.State[stateKey] == opt then return end
			Lib.State[stateKey] = opt
			for o, b in pairs(btns) do
				local sel = (o == opt)
				Lib.Tween(b, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundTransparency = sel and 0 or 1, TextColor3 = sel and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(150, 150, 150) })
			end
			callback(opt)
		end)
	end
end

MakeChipGroup(View_Settings, "API Provider", "ScriptsProvider", {"Rscripts", "ScriptBlox"}, function()
	ClearScriptsCache()
end, 1)

MakeChipGroup(View_Settings, "Sort by", "ScriptsSort", {"Newest", "Most Views", "Most Likes"}, function()
	ClearScriptsCache()
end, 2)

local BrowseScroll = Lib.Create("ScrollingFrame", { Size = UDim2.new(1, 0, 1, -40), Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1, ScrollBarThickness = 2, ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100), BorderSizePixel = 0, Parent = View_Browse })
local BrowseGrid = Lib.Create("UIGridLayout", { CellSize = UDim2.fromOffset(185, 220), CellPadding = UDim2.fromOffset(15, 15), SortOrder = Enum.SortOrder.LayoutOrder, Parent = BrowseScroll })
Lib.Create("UIPadding", { PaddingTop = UDim.new(0, 5), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 15), Parent = BrowseScroll })

BrowseGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	BrowseScroll.CanvasSize = UDim2.new(0, 0, 0, BrowseGrid.AbsoluteContentSize.Y + 20)
end)

local PaginationPanel = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 1, -30), BackgroundTransparency = 1, Parent = View_Browse })
local function MakePageBtn(text, pos, parent)
	local btn = Lib.Create("TextButton", { Size = UDim2.fromOffset(30, 30), Position = pos, BackgroundColor3 = Color3.fromRGB(15, 15, 15), Text = text, TextColor3 = Color3.fromRGB(200, 200, 200), TextSize = 16, Font = Enum.Font.GothamMedium, Parent = parent, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }) })
	btn.MouseEnter:Connect(function() Lib.Tween(btn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Color3.fromRGB(25, 25, 25) }) end)
	btn.MouseLeave:Connect(function() Lib.Tween(btn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Color3.fromRGB(15, 15, 15) }) end)
	return btn
end

local PrevBtn = MakePageBtn("‹", UDim2.new(0.5, -70, 0, 0), PaginationPanel)
local PageLabel = Lib.Create("TextLabel", { Size = UDim2.fromOffset(80, 30), Position = UDim2.new(0.5, -40, 0, 0), BackgroundTransparency = 1, Text = "Page 1 / 1", TextColor3 = Color3.fromRGB(200, 200, 200), TextSize = 12, Font = Enum.Font.GothamMedium, Parent = PaginationPanel })
local NextBtn = MakePageBtn("›", UDim2.new(0.5, 40, 0, 0), PaginationPanel)

local LoadingLabel = Lib.Create("TextLabel", { Size = UDim2.new(1, 0, 1, -40), Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1, Text = "Loading scripts...", TextColor3 = Color3.fromRGB(150, 150, 150), TextSize = 15, Font = Enum.Font.GothamMedium, Visible = false, Parent = View_Browse })
local ErrorLabel = Lib.Create("TextLabel", { Size = UDim2.new(1, 0, 1, -40), Position = UDim2.new(0, 0, 0, -10), BackgroundTransparency = 1, Text = "Failed to load scripts", TextColor3 = Color3.fromRGB(255, 80, 80), TextSize = 15, Font = Enum.Font.GothamMedium, Visible = false, Parent = View_Browse })
local RetryBtn = Lib.Create("TextButton", { Size = UDim2.fromOffset(100, 34), Position = UDim2.new(0.5, -50, 0.5, 10), BackgroundColor3 = Color3.fromRGB(255, 255, 255), Text = "Retry", TextColor3 = Color3.fromRGB(0, 0, 0), TextSize = 13, Font = Enum.Font.GothamBold, Visible = false, Parent = View_Browse, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }) })
RetryBtn.MouseEnter:Connect(function() Lib.Tween(RetryBtn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Color3.fromRGB(210, 210, 210) }) end)
RetryBtn.MouseLeave:Connect(function() Lib.Tween(RetryBtn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Color3.fromRGB(255, 255, 255) }) end)

local function FetchScripts(page)
	local result = { success = false, data = {}, totalPages = 1 }
	
	local function ParseScriptBlox(decoded)
		if decoded and decoded.result and decoded.result.scripts then
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

	local function ParseRscripts(decoded)
		local rawScripts = nil
		if type(decoded.data) == "table" then
			rawScripts = decoded.data
			result.totalPages = (decoded.meta and decoded.meta.totalPages) or 1
		elseif type(decoded.scripts) == "table" then
			rawScripts = decoded.scripts
			result.totalPages = decoded.totalPages or 1
		end
		
		if rawScripts and #rawScripts > 0 then
			result.success = true
			for _, s in ipairs(rawScripts) do
				local img = s.imageUrl or s.image
				if (not img or img == "") and s.game and (s.game.thumbnailUrl or s.game.imageUrl) then 
					img = s.game.thumbnailUrl or s.game.imageUrl 
				end
				table.insert(result.data, {
					title = s.title or s.name,
					game = (s.game and (s.game.title or s.game.name)) or "Universal",
					imageUrl = img,
					hasKey = s.hasKey or s.keySystem or s.key,
					isVerified = s.isVerified or (s.risk and s.risk.level == "Safe") or (s.creator and s.creator.isVerified),
					script = s.script or s.rawScript or s.code or ""
				})
			end
			return true
		end
		return false
	end

	if Lib.State.ScriptsProvider == "ScriptBlox" then
		local url = "https://scriptblox.com/api/script/fetch?page=" .. tostring(page)
		if Lib.State.ScriptsSort == "Most Views" then url = url .. "&sortBy=views&order=desc"
		elseif Lib.State.ScriptsSort == "Most Likes" then url = url .. "&sortBy=likeCount&order=desc"
		else url = url .. "&sortBy=createdAt&order=desc" end

		local success, body = HTTPRequest(url)
		if success and body then
			local decSuccess, decoded = pcall(function() return Services.HttpService:JSONDecode(body) end)
			if decSuccess then ParseScriptBlox(decoded) end
		end
	else
		local urls = {
			"https://rscripts.net/api/scripts?page=" .. tostring(page),
			"https://api.rscripts.net/v1/scripts?limit=30&page=" .. tostring(page)
		}
		
		for _, u in ipairs(urls) do
			local sortParam = ""
			if Lib.State.ScriptsSort == "Most Views" then sortParam = "&sort=views"
			elseif Lib.State.ScriptsSort == "Most Likes" then sortParam = "&sort=likes" end
			
			local success, body = HTTPRequest(u .. sortParam)
			if success and body then
				local decSuccess, decoded = pcall(function() return Services.HttpService:JSONDecode(body) end)
				if decSuccess and type(decoded) == "table" then
					if ParseRscripts(decoded) then break end
				end
			end
		end

		if not result.success or #result.data == 0 then
			local fbUrl = "https://scriptblox.com/api/script/fetch?page=" .. tostring(page) .. "&sortBy=createdAt&order=desc"
			local success, body = HTTPRequest(fbUrl)
			if success and body then
				local decSuccess, decoded = pcall(function() return Services.HttpService:JSONDecode(body) end)
				if decSuccess then ParseScriptBlox(decoded) end
			end
		end
	end

	return result
end

local function CreateScriptCard(data, order)
	local Card = Lib.Create("Frame", {
		Size = UDim2.fromOffset(185, 220),
		BackgroundColor3 = Color3.fromRGB(15, 15, 15),
		LayoutOrder = order,
		ClipsDescendants = true,
		Parent = BrowseScroll,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) })
	})
	
	local CardStroke = Lib.Create("UIStroke", {
		Color = Color3.fromRGB(35, 35, 35),
		Thickness = 1,
		Transparency = 0.5,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = Card
	})

	local imgUrl = (data.imageUrl and data.imageUrl ~= "") and data.imageUrl or "rbxassetid://104797361877921"
	
	local Image = Lib.Create("ImageLabel", {
		Size = UDim2.new(1, 0, 0, 120),
		BackgroundColor3 = Color3.fromRGB(20, 20, 20),
		Image = imgUrl,
		ScaleType = Enum.ScaleType.Crop,
		ClipsDescendants = true,
		Parent = Card,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) })
	})

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
	Lib.Create("TextLabel", {
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

	Lib.Create("TextLabel", {
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

	local function OnHoverEnter()
		Lib.Tween(Card, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Color3.fromRGB(24, 24, 24) })
		Lib.Tween(CardStroke, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Color = Color3.fromRGB(90, 90, 90), Transparency = 0.1 })
		Lib.Tween(Overlay, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundTransparency = 0.4 })
		Lib.Tween(CopyBtn, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundTransparency = 0, TextTransparency = 0 })
	end

	local function OnHoverLeave()
		Lib.Tween(Card, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Color3.fromRGB(15, 15, 15) })
		Lib.Tween(CardStroke, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Color = Color3.fromRGB(35, 35, 35), Transparency = 0.5 })
		Lib.Tween(Overlay, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundTransparency = 1 })
		Lib.Tween(CopyBtn, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundTransparency = 1, TextTransparency = 1 })
	end

	Card.MouseEnter:Connect(OnHoverEnter)
	Card.MouseLeave:Connect(OnHoverLeave)

	CopyBtn.MouseEnter:Connect(function()
		Lib.Tween(CopyBtn, 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Color3.fromRGB(220, 220, 220) })
	end)
	CopyBtn.MouseLeave:Connect(function()
		Lib.Tween(CopyBtn, 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Color3.fromRGB(255, 255, 255) })
	end)

	local isCopied = false
	CopyBtn.MouseButton1Click:Connect(function()
		if isCopied then return end
		local scriptToCopy = (data.script and data.script ~= "") and data.script or ("-- No script source found for " .. tostring(data.title))
		local copyFunc = setclipboard or toclipboard or set_clipboard
		if copyFunc then copyFunc(scriptToCopy) end

		isCopied = true
		CopyBtn.Text = "Copied! ✓"
		CopyBtn.BackgroundColor3 = Color3.fromRGB(80, 220, 120)
		CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

		task.delay(1.5, function()
			if CopyBtn and CopyBtn.Parent then
				CopyBtn.Text = "Copy Script"
				CopyBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				CopyBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
				isCopied = false
			end
		end)
	end)
end

local function ClearScriptCards()
	for _, child in ipairs(BrowseScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
end

function LoadScriptsPage(page)
	if Lib.State.ScriptsLoading then return end
	Lib.State.ScriptsLoading = true
	
	ClearScriptCards()
	LoadingLabel.Visible = true
	ErrorLabel.Visible = false
	RetryBtn.Visible = false
	PaginationPanel.Visible = false
	BrowseScroll.Visible = false

	task.spawn(function()
		local result = Lib.State.ScriptsCache[page]
		if not result then
			result = FetchScripts(page)
			if result.success then Lib.State.ScriptsCache[page] = result end
		end

		if result and result.success and result.data and #result.data > 0 then
			Lib.State.ScriptsPage = page
			Lib.State.ScriptsTotalPages = result.totalPages or 1
			PageLabel.Text = "Page " .. tostring(page) .. " / " .. tostring(Lib.State.ScriptsTotalPages)
			
			for i, sData in ipairs(result.data) do
				CreateScriptCard(sData, i)
			end
			BrowseScroll.CanvasPosition = Vector2.new(0, 0)
			
			LoadingLabel.Visible = false
			BrowseScroll.Visible = true
			PaginationPanel.Visible = true
		else
			LoadingLabel.Visible = false
			ErrorLabel.Visible = true
			RetryBtn.Visible = true
		end
		
		Lib.State.ScriptsLoading = false
	end)
end

PrevBtn.MouseButton1Click:Connect(function()
	if Lib.State.ScriptsPage > 1 and not Lib.State.ScriptsLoading then LoadScriptsPage(Lib.State.ScriptsPage - 1) end
end)
NextBtn.MouseButton1Click:Connect(function()
	if Lib.State.ScriptsPage < Lib.State.ScriptsTotalPages and not Lib.State.ScriptsLoading then LoadScriptsPage(Lib.State.ScriptsPage + 1) end
end)
RetryBtn.MouseButton1Click:Connect(function() LoadScriptsPage(Lib.State.ScriptsPage) end)

local function LoadEmotesPage(page) end
local function ClearEmotesDataCache()
	Lib.State.EmotesCache = {}
	Lib.State.AnimationPacksCache = {}
	Lib.State.EmotesPage = 1
	if Lib.State.CurrentEmotesTab == "Browse" then
		LoadEmotesPage(1)
	end
end

local EmotesSection = Lib.Create("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, Parent = ContentArea })
local EmotesSideBar = Lib.Create("Frame", { Size = UDim2.new(0, 180, 1, 0), BackgroundTransparency = 1, Parent = EmotesSection,
	Lib.Create("TextLabel", { Size = UDim2.new(1, -30, 0, 30), Position = UDim2.new(0, 20, 0, 10), BackgroundTransparency = 1, Text = "Emotes", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 20, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left }),
	Lib.Create("TextLabel", { Size = UDim2.new(1, -30, 0, 20), AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 15, 1, -15), BackgroundTransparency = 1, Text = "Roblox Marketplace", TextColor3 = Color3.fromRGB(100, 100, 100), TextSize = 11, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left })
})

local function SwitchEmotesTab(tabName)
	if Lib.State.CurrentEmotesTab == tabName then return end
	Lib.State.CurrentEmotesTab = tabName

	for name, view in pairs(Lib.UI.EmotesViews) do
		local btn = Lib.UI.EmotesTabBtns[name]
		local isSel = (name == tabName)

		Lib.Tween(btn, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { TextColor3 = isSel and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150), BackgroundTransparency = isSel and 0.92 or 1 })
		
		if isSel then
			view.Visible = true
			view.Position = UDim2.new(0, 195, 0, 10)
			view.GroupTransparency = 1
			Lib.Tween(view, 0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, { Position = UDim2.new(0, 180, 0, 10), GroupTransparency = 0 })
		elseif view.Visible then
			local t = Lib.Tween(view, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Position = UDim2.new(0, 170, 0, 10), GroupTransparency = 1 })
			t.Completed:Connect(function() if Lib.State.CurrentTab ~= name then view.Visible = false end end)
		end
	end
	
	if tabName == "Browse" and not Lib.State.EmotesLoading then
		local currentCache = (Lib.State.EmotesCategory == "Emotes") and Lib.State.EmotesCache or Lib.State.AnimationPacksCache
		if not currentCache[Lib.State.EmotesPage] then
			LoadEmotesPage(Lib.State.EmotesPage)
		end
	end
end

local function MakeEmotesTab(name, posY)
	local btn = Lib.Create("TextButton", { Size = UDim2.new(1, -30, 0, 34), Position = UDim2.new(0, 15, 0, posY), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1, Text = name, TextColor3 = Color3.fromRGB(150, 150, 150), TextSize = 14, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, Parent = EmotesSideBar,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 7) }), Lib.Create("UIPadding", { PaddingLeft = UDim.new(0, 12) })
	})
	Lib.UI.EmotesTabBtns[name] = btn

	local view = Lib.Create("CanvasGroup", { Size = UDim2.new(1, -190, 1, -20), Position = UDim2.new(0, 180, 0, 10), BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false, GroupTransparency = 1, Parent = EmotesSection })
	Lib.UI.EmotesViews[name] = view

	btn.MouseEnter:Connect(function() if Lib.State.CurrentEmotesTab ~= name then Lib.Tween(btn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { TextColor3 = Color3.fromRGB(210, 210, 210), BackgroundTransparency = 0.96 }) end end)
	btn.MouseLeave:Connect(function() Lib.Tween(btn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Size = UDim2.new(1, -30, 0, 34) }) if Lib.State.CurrentEmotesTab ~= name then Lib.Tween(btn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { TextColor3 = Color3.fromRGB(150, 150, 150), BackgroundTransparency = 1 }) end end)
	btn.MouseButton1Down:Connect(function() Lib.Tween(btn, 0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Size = UDim2.new(1, -36, 0, 31) }) end)
	btn.MouseButton1Up:Connect(function() Lib.Tween(btn, 0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Size = UDim2.new(1, -30, 0, 34) }) end)
	btn.MouseButton1Click:Connect(function() SwitchEmotesTab(name) end)

	return view
end

local View_EmotesBrowse = MakeEmotesTab("Browse", 50)
local View_EmotesSettings = MakeEmotesTab("Settings", 90)

Lib.Create("UIListLayout", { Padding = UDim.new(0, 20), Parent = View_EmotesSettings })
Lib.Create("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5), Parent = View_EmotesSettings })

MakeChipGroup(View_EmotesSettings, "Category", "EmotesCategory", {"Emotes", "Animation Packs"}, function()
	ClearEmotesDataCache()
end, 1)

MakeChipGroup(View_EmotesSettings, "Sort by", "EmotesSort", {"Most Liked", "Least Liked", "Most Viewed", "Least Viewed", "Newest", "Oldest"}, function()
	ClearEmotesDataCache()
end, 2)

local EmotesScroll = Lib.Create("ScrollingFrame", { Size = UDim2.new(1, 0, 1, -40), Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1, ScrollBarThickness = 2, ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100), BorderSizePixel = 0, Parent = View_EmotesBrowse })
local EmotesGrid = Lib.Create("UIGridLayout", { CellSize = UDim2.fromOffset(185, 230), CellPadding = UDim2.fromOffset(12, 12), SortOrder = Enum.SortOrder.LayoutOrder, Parent = EmotesScroll })
Lib.Create("UIPadding", { PaddingTop = UDim.new(0, 5), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 15), Parent = EmotesScroll })

EmotesGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	EmotesScroll.CanvasSize = UDim2.new(0, 0, 0, EmotesGrid.AbsoluteContentSize.Y + 20)
end)

local EmotesPaginationPanel = Lib.Create("Frame", { Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 1, -30), BackgroundTransparency = 1, Parent = View_EmotesBrowse })
local EmotesPrevBtn = MakePageBtn("‹", UDim2.new(0.5, -70, 0, 0), EmotesPaginationPanel)
local EmotesPageLabel = Lib.Create("TextLabel", { Size = UDim2.fromOffset(80, 30), Position = UDim2.new(0.5, -40, 0, 0), BackgroundTransparency = 1, Text = "Page 1 / 1", TextColor3 = Color3.fromRGB(200, 200, 200), TextSize = 12, Font = Enum.Font.GothamMedium, Parent = EmotesPaginationPanel })
local EmotesNextBtn = MakePageBtn("›", UDim2.new(0.5, 40, 0, 0), EmotesPaginationPanel)

local EmotesLoadingLabel = Lib.Create("TextLabel", { Size = UDim2.new(1, 0, 1, -40), Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1, Text = "Loading emotes...", TextColor3 = Color3.fromRGB(150, 150, 150), TextSize = 15, Font = Enum.Font.GothamMedium, Visible = false, Parent = View_EmotesBrowse })
local EmotesErrorLabel = Lib.Create("TextLabel", { Size = UDim2.new(1, 0, 1, -40), Position = UDim2.new(0, 0, 0, -10), BackgroundTransparency = 1, Text = "Failed to load emotes", TextColor3 = Color3.fromRGB(255, 80, 80), TextSize = 15, Font = Enum.Font.GothamMedium, Visible = false, Parent = View_EmotesBrowse })
local EmotesRetryBtn = Lib.Create("TextButton", { Size = UDim2.fromOffset(100, 34), Position = UDim2.new(0.5, -50, 0.5, 10), BackgroundColor3 = Color3.fromRGB(255, 255, 255), Text = "Retry", TextColor3 = Color3.fromRGB(0, 0, 0), TextSize = 13, Font = Enum.Font.GothamBold, Visible = false, Parent = View_EmotesBrowse, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }) })
EmotesRetryBtn.MouseEnter:Connect(function() Lib.Tween(EmotesRetryBtn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Color3.fromRGB(210, 210, 210) }) end)
EmotesRetryBtn.MouseLeave:Connect(function() Lib.Tween(EmotesRetryBtn, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = Color3.fromRGB(255, 255, 255) }) end)

local function CreateEmoteCard(data, order)
	local Card = Lib.Create("Frame", { Size = UDim2.fromOffset(185, 230), BackgroundColor3 = Color3.fromRGB(15, 15, 15), LayoutOrder = order, Parent = EmotesScroll, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 8) }) })
	
	local thumbType = (data.itemType == "Bundle") and "BundleThumbnail" or "Asset"
	local thumbUrl = "rbxthumb://type=" .. thumbType .. "&id=" .. tostring(data.thumbnailId) .. "&w=420&h=420"
	
	Lib.Create("ImageLabel", { Size = UDim2.new(1, -16, 0, 110), Position = UDim2.new(0, 8, 0, 8), BackgroundColor3 = Color3.fromRGB(22, 22, 22), Image = thumbUrl, ScaleType = Enum.ScaleType.Fit, Parent = Card, Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) }) })

	Lib.Create("TextLabel", { Size = UDim2.new(1, -16, 0, 18), Position = UDim2.new(0, 8, 0, 124), BackgroundTransparency = 1, Text = data.name, TextColor3 = Color3.fromRGB(240, 240, 240), TextSize = 13, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = Card })

	local isFree = data.price == "Free"
	Lib.Create("TextLabel", { Size = UDim2.new(1, -16, 0, 16), Position = UDim2.new(0, 8, 0, 144), BackgroundTransparency = 1, Text = data.price, TextColor3 = isFree and Color3.fromRGB(80, 220, 120) or Color3.fromRGB(160, 160, 160), TextSize = 12, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, Parent = Card })

	local isPlaying = (Lib.State.CurrentPlayingAssetId == data.id)
	local actionBtn = Lib.Create("TextButton", {
		Size = UDim2.new(1, -16, 0, 30), Position = UDim2.new(0, 8, 1, -38),
		BackgroundColor3 = isPlaying and Color3.fromRGB(220, 50, 50) or Color3.fromRGB(255, 255, 255),
		Text = isPlaying and "Stop" or "Play",
		TextColor3 = isPlaying and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0),
		TextSize = 12, Font = Enum.Font.GothamBold, Parent = Card,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 6) })
	})

	if isPlaying then Lib.State.CurrentEmoteButton = actionBtn end

	actionBtn.MouseButton1Click:Connect(function()
		PlayEmote(data.id, data.itemType, actionBtn)
	end)
end

function LoadEmotesPage(page)
	if Lib.State.EmotesLoading then return end
	Lib.State.EmotesLoading = true

	for _, child in ipairs(EmotesScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	EmotesLoadingLabel.Text = (Lib.State.EmotesCategory == "Emotes") and "Loading emotes..." or "Loading animation packs..."
	EmotesLoadingLabel.Visible = true
	EmotesErrorLabel.Visible = false
	EmotesRetryBtn.Visible = false
	EmotesPaginationPanel.Visible = false
	EmotesScroll.Visible = false

	task.spawn(function()
		local isPack = (Lib.State.EmotesCategory == "Animation Packs")
		local currentCache = isPack and Lib.State.AnimationPacksCache or Lib.State.EmotesCache
		
		local result = currentCache[page]
		if not result then
			if isPack then
				result = API.FetchAnimationPacks(page, Lib.State.EmotesSort)
			else
				result = API.FetchEmotes(page, Lib.State.EmotesSort)
			end
			if result.success then currentCache[page] = result end
		end

		if result and result.success and result.data and #result.data > 0 then
			Lib.State.EmotesPage = page
			Lib.State.EmotesTotalPages = result.totalPages or 1
			EmotesPageLabel.Text = "Page " .. tostring(page) .. " / " .. tostring(Lib.State.EmotesTotalPages)

			for i, eData in ipairs(result.data) do
				CreateEmoteCard(eData, i)
			end
			EmotesScroll.CanvasPosition = Vector2.new(0, 0)

			EmotesLoadingLabel.Visible = false
			EmotesScroll.Visible = true
			EmotesPaginationPanel.Visible = true
		else
			EmotesLoadingLabel.Visible = false
			EmotesErrorLabel.Text = "Failed to load " .. ((Lib.State.EmotesCategory == "Emotes") and "emotes" or "animation packs")
			EmotesErrorLabel.Visible = true
			EmotesRetryBtn.Visible = true
		end

		Lib.State.EmotesLoading = false
	end)
end

EmotesPrevBtn.MouseButton1Click:Connect(function()
	if Lib.State.EmotesPage > 1 and not Lib.State.EmotesLoading then LoadEmotesPage(Lib.State.EmotesPage - 1) end
end)
EmotesNextBtn.MouseButton1Click:Connect(function()
	if Lib.State.EmotesPage < Lib.State.EmotesTotalPages and not Lib.State.EmotesLoading then LoadEmotesPage(Lib.State.EmotesPage + 1) end
end)
EmotesRetryBtn.MouseButton1Click:Connect(function() LoadEmotesPage(Lib.State.EmotesPage) end)

function SwitchMainTab(tab)
	if Lib.State.ActiveMain == tab then return end
	Lib.State.ActiveMain = tab
	RecalculateNavPositions()
	
	HomeSection.Visible = (tab == "Home")
	FeaturesSection.Visible = (tab == "Features")
	ScriptsSection.Visible = (tab == "Scripts")
	EmotesSection.Visible = (tab == "Emotes")

	if tab == "Scripts" then
		if not Lib.State.ScriptsCache[1] and not Lib.State.ScriptsLoading then
			LoadScriptsPage(1)
		end
	elseif tab == "Emotes" then
		local currentCache = (Lib.State.EmotesCategory == "Emotes") and Lib.State.EmotesCache or Lib.State.AnimationPacksCache
		if not currentCache[1] and not Lib.State.EmotesLoading then
			LoadEmotesPage(1)
		end
	end
end

local function StartLoadingSequence()
	local splashSize = UDim2.fromOffset(534, 360)

	local Splash = Lib.Create("CanvasGroup", {
		Name = "LoadingScreen",
		Size = splashSize,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		GroupTransparency = 1,
		Parent = Screen,
		Lib.Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
		Lib.Create("UIStroke", { Color = Color3.fromRGB(35, 35, 35), Thickness = 1, Transparency = 0.5 })
	})

	local SplashLogo = Lib.Create("ImageLabel", {
		Size = UDim2.fromOffset(65, 65),
		Position = UDim2.new(0.5, 0, 0.38, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = "rbxassetid://104797361877921",
		ImageTransparency = 1,
		ScaleType = Enum.ScaleType.Fit,
		Parent = Splash
	})

	local SplashTitle = Lib.Create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 24),
		Position = UDim2.new(0.5, 0, 0.54, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Text = "Septus Hub",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 18,
		Font = Enum.Font.GothamBold,
		TextTransparency = 1,
		Parent = Splash
	})

	local SplashSubtitle = Lib.Create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 16),
		Position = UDim2.new(0.5, 0, 0.61, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Text = "Initializing modules...",
		TextColor3 = Color3.fromRGB(130, 130, 130),
		TextSize = 12,
		Font = Enum.Font.GothamMedium,
		TextTransparency = 1,
		Parent = Splash
	})

	local BarContainer = Lib.Create("Frame", {
		Size = UDim2.new(0, 280, 0, 4),
		Position = UDim2.new(0.5, 0, 0.78, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(22, 22, 22),
		BorderSizePixel = 0,
		Parent = Splash,
		Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) })
	})

	local BarProgress = Lib.Create("Frame", {
		Size = UDim2.new(0, 0, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		Parent = BarContainer,
		Lib.Create("UICorner", { CornerRadius = UDim.new(1, 0) })
	})

	RecalculateNavPositions()
	SwitchTab("Overview")
	SwitchFeaturesTab("Visuals")
	SwitchScriptsTab("Browse")
	SwitchEmotesTab("Browse")
	SwitchMainTab("Home")

	Lib.Tween(Splash, 0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { GroupTransparency = 0 })
	Lib.Tween(SplashLogo, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { ImageTransparency = 0, Size = UDim2.fromOffset(75, 75) })
	Lib.Tween(SplashTitle, 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { TextTransparency = 0 })
	Lib.Tween(SplashSubtitle, 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { TextTransparency = 0 })

	local progressTween = Lib.Tween(BarProgress, 6.0, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, {
		Size = UDim2.new(1, 0, 1, 0)
	})

	progressTween.Completed:Connect(function()
		SplashSubtitle.Text = "Welcome!"
		task.wait(0.2)

		local fadeOut = Lib.Tween(Splash, 0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
			GroupTransparency = 1,
			Size = UDim2.fromOffset(500, 340)
		})

		fadeOut.Completed:Connect(function()
			Splash:Destroy()
			
			Main.Size = UDim2.fromOffset(760, 510)
			Main.Visible = true
			Lib.Tween(Main, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
				Size = Lib.State.OriginalSize
			})
		end)
	end)
end

StartLoadingSequence()

local history = { FPS = {}, Ping = {}, Players = {} }
for i = 1, 15 do history.FPS[i], history.Ping[i], history.Players[i] = 0.1, 0.1, 0.1 end

local function PushGraph(key, val, text, barsData, divider)
	Lib.UI.Labels[key].Text = text
	table.remove(history[key], 1)
	table.insert(history[key], math.clamp(val / divider, 0.05, 1))
	for i, bar in ipairs(barsData) do bar.Size = UDim2.new(1/15, -3, history[key][i], 0) end
end

local lastT, frames = tick(), 0
Services.Run.RenderStepped:Connect(function()
	frames = frames + 1
	local curT = tick()
	if curT - lastT >= 1 then
		local fps = math.floor(frames / (curT - lastT))
		local ping = pcall(function() return math.floor(Services.Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end) and math.floor(Services.Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) or 0
		local plrs = #Services.Players:GetPlayers()
		
		PushGraph("FPS", fps, fps .. " FPS", Lib.UI.Graphs.FPS, 120)
		PushGraph("Ping", ping, ping .. " ms", Lib.UI.Graphs.Ping, 300)
		PushGraph("Players", plrs, plrs .. " Players", Lib.UI.Graphs.Players, 100)
		
		frames, lastT = 0, curT
	end
end)
