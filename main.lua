local UI = {}
local Utility = {}

local CornerSize = UDim.new(0,8)--UDim.new(0,6)
local ScrollSmoothness = 0.2
	--[[local DefaultTheme = {
		SchemeColor = Color3.fromRGB(35, 175, 100);
		Background = Color3.fromRGB(40, 40, 40);
		Topbar = Color3.fromRGB(30, 30, 30);
		Content = Color3.fromRGB(50, 50, 50);
		ScrollbarTrack = Color3.fromRGB(40, 40, 40);
		TextColor = Color3.fromRGB(255, 255, 255);
		ElementColor = Color3.fromRGB(50, 50, 50);
	}]]
local DefaultTheme = {
	SchemeColor = Color3.fromRGB(38, 175, 136);
	Background = Color3.fromRGB(31, 32, 40);
	Topbar = Color3.fromRGB(22, 23, 30);
	Content = Color3.fromRGB(41, 41, 50);
	ScrollbarTrack = Color3.fromRGB(33, 34, 40);
	TextColor = Color3.fromRGB(255, 255, 255);
	ElementColor = Color3.fromRGB(51, 51, 60);
}

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

function Utility:Tween(obj,Info,Props)
	assert(obj ~= nil,"No object given.")
	assert(Props ~= nil,"No properties given.")

	local _Tween = TweenService:Create(obj,Info or TweenInfo.new(1,Enum.EasingStyle.Linear),Props)
	_Tween:Play()
	return _Tween
end
function Utility:CallCallback(Callback,...)
	local s,r = pcall(Callback,...)
	return s == true and r ~= false
end

local Styles = {}
function Utility:ApplyTheme(obj,Property,Theme,Style)
	if not Theme then Theme = DefaultTheme end

	assert(obj ~= nil,"No object given.")
	assert(Property ~= nil,"No property given.")
	assert(Style ~= nil,"No style given.")
	assert(Theme[Style] ~= nil,"Style "..tostring(Style).." does not exist.")

	obj[Property] = Theme[Style]

	if not Styles[Style] then Styles[Style] = {} end
	Styles[Style][obj] = Property
end
function Utility:UpdateTheme(NewTheme)
	for Style,Data in pairs(Styles) do
		for obj,Property in pairs(Data) do
			obj[Property] = NewTheme[Style]
		end
	end
end

function Utility:Drag(Dragger,Move)
	local Dragging = false
	local DragInput,MousePos,FramePos

	Dragger.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			Dragging = true
			MousePos = Input.Position
			FramePos = Move.Position

			Input.Changed:Connect(function()
				if Input.UserInputState == Enum.UserInputState.End then
					Dragging = false
				end
			end)
		end
	end)

	Dragger.InputChanged:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement then
			DragInput = Input
		end
	end)

	UIS.InputChanged:Connect(function(Input)
		if Input == DragInput and Dragging then
			local Delta = Input.Position - MousePos
			Move.Position = UDim2.new(FramePos.X.Scale,math.clamp(FramePos.X.Offset + Delta.X,0,Workspace.CurrentCamera.ViewportSize.X - Move.AbsoluteSize.X),FramePos.Y.Scale,math.clamp(FramePos.Y.Offset + Delta.Y,36,Workspace.CurrentCamera.ViewportSize.Y - Move.AbsoluteSize.Y))
		end
	end)
end
function Utility:SyncCanvasSize(Scroll,UIList)
	UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		Scroll.CanvasSize = UDim2.new(Scroll.CanvasSize.X.Scale,Scroll.CanvasSize.X.Offset,0,UIList.AbsoluteContentSize.Y)
	end)
	Scroll.CanvasSize = UDim2.new(Scroll.CanvasSize.X.Scale,Scroll.CanvasSize.X.Offset,0,UIList.AbsoluteContentSize.Y)
end
function Utility:SyncSize(Scroll,UIList)
	UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		Scroll.Size = UDim2.new(Scroll.Size.X.Scale,Scroll.Size.X.Offset,0,UIList.AbsoluteContentSize.Y)
	end)
	Scroll.Size = UDim2.new(Scroll.Size.X.Scale,Scroll.Size.X.Offset,0,UIList.AbsoluteContentSize.Y)
end
function Utility:Corner(obj,Radius)
	assert(obj ~= nil,"No object given.")

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = Radius
	Corner.Parent = obj
	return Corner
end
function Utility:RemoveCorner(obj,Face,Corner)
	assert(obj ~= nil,"No object given.")
	assert(Face ~= nil,"No face given.")
	assert(Corner ~= nil,"No UICorner or CornerRadius given.")

	local Blocker = Instance.new("Frame")
	Blocker.BorderSizePixel = 0
	Blocker.ZIndex = -math.huge
	Blocker.Parent = obj

	obj.Changed:Connect(function()
		Blocker.BackgroundColor3 = obj.BackgroundColor3
	end)
	Blocker.BackgroundColor3 = obj.BackgroundColor3

	local function GetRadius()
		if typeof(Corner) == "UDim" then
			return Corner.Offset
		else
			return Corner.CornerRadius.Offset
		end
	end

	if Face == Enum.NormalId.Top then
		Blocker.AnchorPoint = Vector2.new(0,0)
		Blocker.Position = UDim2.new(0,0,0,0)
		Blocker.Size = UDim2.new(1,0,0,GetRadius())
	elseif Face == Enum.NormalId.Right then
		Blocker.AnchorPoint = Vector2.new(1,0)
		Blocker.Position = UDim2.new(1,0,0,0)
		Blocker.Size = UDim2.new(0,GetRadius(),1,0)
	elseif Face == Enum.NormalId.Bottom then
		Blocker.AnchorPoint = Vector2.new(0,1)
		Blocker.Position = UDim2.new(0,0,1,0)
		Blocker.Size = UDim2.new(1,0,0,GetRadius())
	elseif Face == Enum.NormalId.Left then
		Blocker.AnchorPoint = Vector2.new(0,0)
		Blocker.Position = UDim2.new(0,0,0,0)
		Blocker.Size = UDim2.new(0,GetRadius(),1,0)
	else
		Blocker:Destroy()
		error("Invalid face.")
	end

	return Blocker
end
function Utility:ScrollBar(Scroll)
	Scroll.TopImage = "http://www.roblox.com/asset/?id=4490132608"
	Scroll.MidImage = "http://www.roblox.com/asset/?id=4490132966"
	Scroll.BottomImage = "http://www.roblox.com/asset/?id=4490133158"
end
function Utility:ScrollTrack(Scroll,Theme)
	coroutine.wrap(function()
		if Scroll.Parent == nil then
			repeat Scroll.AncestryChanged:Wait() until Scroll.Parent ~= nil
		end

		if Scroll.Parent:FindFirstChild(Scroll.Name.."_TrackHolder") then
			Scroll.Parent:FindFirstChild(Scroll.Name.."_TrackHolder"):Destroy()
		end

		local TrackHolder = Instance.new("Frame",Scroll.Parent)
		TrackHolder.BackgroundTransparency = 1
		TrackHolder.Name = Scroll.Name.."_TrackHolder"

		local Track = Instance.new("ImageLabel",TrackHolder)
		Track.AnchorPoint = Vector2.new(1,0)
		Track.BackgroundTransparency = 1
		Track.BorderSizePixel = 1
		Track.Position = UDim2.new(1,0,0,0)
		Track.Image = "http://www.roblox.com/asset/?id=4490129735"
		Track.ScaleType = Enum.ScaleType.Slice
		Track.SliceCenter = Rect.new(0,2,4,6)
		Track.SliceScale = 1
		Track.TileSize = UDim2.new(1,0,1,0)
		Track.Name = "Track"

		Utility:ApplyTheme(Track,"ImageColor3",Theme,"ScrollbarTrack")

		local function Update()
			TrackHolder.Parent = Scroll.Parent
			TrackHolder.AnchorPoint = Scroll.AnchorPoint
			TrackHolder.Position = Scroll.Position
			TrackHolder.Rotation = Scroll.Rotation
			TrackHolder.Size = Scroll.Size
			TrackHolder.SizeConstraint = Scroll.SizeConstraint
			TrackHolder.Visible = Scroll.Visible
			TrackHolder.ZIndex = Scroll.ZIndex - 1

			Track.Size = UDim2.new(0,Scroll.ScrollBarThickness,1,0)
			Track.ZIndex = Scroll.ZIndex - 1
		end

		Update()
		TrackHolder.Changed:Connect(Update)
		Track.Changed:Connect(Update)
		Scroll.Changed:Connect(Update)
	end)()
end
function Utility:SmoothScroll(Scroll,Smoothness)
	coroutine.wrap(function()
		if Scroll.Parent == nil then
			repeat Scroll.AncestryChanged:Wait() until Scroll.Parent ~= nil
		end

		if Scroll.Parent:FindFirstChild(Scroll.Name.."_smoothinputframe") then
			Scroll.Parent:FindFirstChild(Scroll.Name.."_smoothinputframe"):Destroy()
		end

			--[[
				
				SmoothScroll
				smoother scrolling frames
				
				by Elttob
				
			]]

		Smoothness = Smoothness or 0.15
		Scroll.ScrollingEnabled = false

		-- create the 'input' scrolling frame, aka the scrolling frame which receives user input
		-- if smoothing is enabled, enable scrolling
		local input = Scroll:Clone()
		input:ClearAllChildren()
		input.BackgroundTransparency = 1
		input.ScrollBarImageTransparency = 1
		input.ZIndex = Scroll.ZIndex + 1
		input.Name = Scroll.Name.."_smoothinputframe"
		input.ScrollingEnabled = true
		input.Parent = Scroll.Parent

		-- keep input frame in sync with content frame
		local function syncProperty(prop)
			Scroll:GetPropertyChangedSignal(prop):Connect(function()
				if prop == "ZIndex" then
					-- keep the input frame on top!
					input[prop] = Scroll[prop] + 1
				else
					input[prop] = Scroll[prop]
				end
			end)
			input:GetPropertyChangedSignal(prop):Connect(function() -- Added by me ew cause yes
				if prop == "ZIndex" then
					if input[prop] - 1 ~= Scroll[prop] then
						input[prop] = Scroll[prop] + 1
					end
				else
					if input[prop] ~= Scroll[prop] then
						input[prop] = Scroll[prop]
					end
				end
			end)
		end

		syncProperty "CanvasSize"
		syncProperty "Position"
		syncProperty "Rotation"
		syncProperty "ScrollingDirection"
		syncProperty "ScrollBarThickness"
		syncProperty "BorderSizePixel"
		syncProperty "ElasticBehavior"
		syncProperty "SizeConstraint"
		syncProperty "ZIndex"
		syncProperty "BorderColor3"
		syncProperty "Size"
		syncProperty "AnchorPoint"
		syncProperty "Visible"

		-- create a render stepped connection to interpolate the content frame position to the input frame position
		local smoothConnection = game:GetService("RunService").RenderStepped:Connect(function(dt)
			local a = Scroll.CanvasPosition
			local b = input.CanvasPosition
			local c = math.min(Smoothness * (60 * dt),1) -- Made it use delta time - Ew
			local d = (b - a) * c + a
			Scroll.CanvasPosition = d
		end)

		-- destroy everything when the frame is destroyed
		Scroll.AncestryChanged:Connect(function()
			if Scroll.Parent == nil then
				input:Destroy()
				smoothConnection:Disconnect()
			end
		end)
	end)()
end

function Utility:Ripple(Item,Position,Theme)
	local Ripple = Instance.new("Frame")

	Ripple.BackgroundColor3 = Theme.SchemeColor
	Ripple.BackgroundTransparency = 0.6
	Ripple.Position = UDim2.new(0,Position.X - Item.AbsolutePosition.X,0,Position.Y - Item.AbsolutePosition.Y)
	Ripple.Size = UDim2.new(0,0,0,0)
	Ripple.ZIndex = -math.huge
	Utility:Corner(Ripple,UDim.new(1,0))
	Ripple.Parent = Item

	coroutine.wrap(function()
		local Size = Item.AbsoluteSize.X > Item.AbsoluteSize.Y and (Item.AbsoluteSize.X * 1.5) or (Item.AbsoluteSize.Y * 1.5)

		Utility:Tween(Ripple,TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{
			BackgroundTransparency = 1;
			Position = UDim2.new(0.5,-Size/2,0.5,-Size/2);
			Size = UDim2.new(0,Size,0,Size);
		}).Completed:Wait()

		Ripple:Destroy()
	end)()

	return Ripple
end
function Utility:ItemError(Item)

end

function Utility:CreateItem(Name,Icon,Description,Theme,BackgroundStyle)
	local Item = Instance.new("Frame")
	local NameText = Instance.new("TextLabel")
	local IconImage = (Icon and Icon ~= "") and Instance.new("ImageLabel") or nil
	local DescriptionButton = (Description and Description ~= "") and Instance.new("ImageButton") or nil

	Item.Size = UDim2.new(1,0,0,36)
	Item.ClipsDescendants = true
	Utility:Corner(Item,CornerSize)
	Utility:ApplyTheme(Item,"BackgroundColor3",Theme,BackgroundStyle)

	NameText.AnchorPoint = Vector2.new(0,0.5)
	NameText.BackgroundTransparency = 1
	NameText.BorderSizePixel = 0
	NameText.Position = UDim2.new(0,IconImage ~= nil and 36 or 7.5,0.5,0)
	NameText.Size = UDim2.new(1,-15,1,-15)
	NameText.ZIndex = 0
	NameText.Font = Enum.Font.SourceSans
	NameText.Text = Name
	NameText.TextScaled = false
	NameText.TextSize = 18
	NameText.TextWrapped = true
	NameText.TextXAlignment = Enum.TextXAlignment.Left
	Utility:ApplyTheme(NameText,"TextColor3",Theme,"TextColor")
	NameText.Parent = Item

	if IconImage then
		IconImage.AnchorPoint = Vector2.new(0,0.5)
		IconImage.BackgroundTransparency = 1
		IconImage.BorderSizePixel = 0
		IconImage.Position = UDim2.new(0,7.5,0.5,0)
		IconImage.Size = UDim2.new(1,-15,1,-15)
		IconImage.ZIndex = 0
		IconImage.Image = Icon
		Utility:ApplyTheme(IconImage,"ImageColor3",Theme,(BackgroundStyle == "SchemeColor" and "TextColor" or "SchemeColor"))
		Instance.new("UIAspectRatioConstraint",IconImage)
		IconImage.Parent = Item
	end

	local OnDisplayDescription = nil
	if DescriptionButton then
		OnDisplayDescription = Instance.new("BindableEvent")
		
		DescriptionButton.AnchorPoint = Vector2.new(1,0.5)
		DescriptionButton.BackgroundTransparency = 1
		DescriptionButton.BorderSizePixel = 0
		DescriptionButton.Position = UDim2.new(1,-7.5,0.5,0)
		DescriptionButton.Size = UDim2.new(1,-15,1,-15)
		DescriptionButton.ZIndex = 2
		DescriptionButton.Image = "rbxassetid://8318429389"
		Utility:ApplyTheme(DescriptionButton,"ImageColor3",Theme,(BackgroundStyle == "SchemeColor" and "TextColor" or "SchemeColor"))
		Instance.new("UIAspectRatioConstraint",DescriptionButton)
		DescriptionButton.Parent = Item

		DescriptionButton.MouseButton1Click:Connect(function()
			OnDisplayDescription:Fire()
		end)
	end

	return Item,(OnDisplayDescription ~= nil and OnDisplayDescription.Event or nil)
end
function Utility:AddItemButton(Item)
	local Button = Instance.new("TextButton")

	Button.BackgroundTransparency = 1
	Button.BorderSizePixel = 0
	Button.Size = UDim2.new(1,0,1,0)
	Button.Text = ""
	Button.Parent = Item

	return Button
end

function UI:CreateLib(Title,Theme,Position)
	assert(Title ~= nil,"No title given.")

	local CurrentTheme = {}
	for n,v in pairs(Theme or DefaultTheme) do
		CurrentTheme[n] = v
	end

	local LibName = HttpService:GenerateGUID(false)
	local DisplayingDescription = false

	local Gui = Instance.new("ScreenGui")
	local Main = Instance.new("Frame")
	local Topbar = Instance.new("Frame")
	local Header = Instance.new("TextLabel")
	local CloseButton = Instance.new("ImageButton")
	local Tabs = Instance.new("ScrollingFrame")
	local TabsUIList = Instance.new("UIListLayout")
	local Content = Instance.new("Frame")
	local Blur = Instance.new("Frame")
	local DescriptionHolder = Instance.new("Frame")
	local DescriptionText = Instance.new("TextLabel")

	local function ApplyTheme(obj,Property,Style)
		return Utility:ApplyTheme(obj,Property,CurrentTheme,Style)
	end
	local function CreateItem(Name,Icon,Description,BackgroundStyle)
		return Utility:CreateItem(Name,Icon,Description,CurrentTheme,BackgroundStyle)
	end
	local function DisplayDescription(Description,CanYeild)
		assert(Description ~= nil,"No description given.")

		if DisplayingDescription then
			if CanYeild == true then
				repeat RunService.RenderStepped:Wait() until DisplayingDescription == false
			else
				return
			end
		end

		DisplayingDescription = true

		pcall(function()
			local Info = TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.Out)

			DescriptionText.Text = Description

			Utility:Tween(Blur,Info,{
				BackgroundTransparency = 0.6;
			})
			Utility:Tween(DescriptionHolder,Info,{
				Position = UDim2.new(DescriptionHolder.Position.X.Scale,DescriptionHolder.Position.X.Offset,1,-10);
			}).Completed:Wait()

			task.wait(2)

			Utility:Tween(Blur,Info,{
				BackgroundTransparency = 1;
			})
			Utility:Tween(DescriptionHolder,Info,{
				Position = UDim2.new(DescriptionHolder.Position.X.Scale,DescriptionHolder.Position.X.Offset,1.5,0);
			}).Completed:Wait()
		end)

		DisplayingDescription = false
	end

	Gui.DisplayOrder = 2147483647
	Gui.Enabled = true
	Gui.IgnoreGuiInset = true
	Gui.Name = LibName
	Gui.ResetOnSpawn = false
	Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	Main.Size = UDim2.new(0,525,0,318)
	Main.ClipsDescendants = true
	Utility:Corner(Main,CornerSize)
	ApplyTheme(Main,"BackgroundColor3","Background")
	Main.Parent = Gui

	Topbar.Size = UDim2.new(1,0,0,36)
	Utility:RemoveCorner(Topbar,Enum.NormalId.Bottom,Utility:Corner(Topbar,CornerSize))
	ApplyTheme(Topbar,"BackgroundColor3","Topbar")
	Topbar.Parent = Main

	Header.AnchorPoint = Vector2.new(0,0.5)
	Header.BackgroundTransparency = 1
	Header.BorderSizePixel = 0
	Header.Position = UDim2.new(0,10,0.5,0)
	Header.Size = UDim2.new(1,-15,1,-15)
	Header.Font = Enum.Font.SourceSansSemibold
	Header.Text = Title
	Header.TextScaled = true
	Header.TextWrapped = true
	Header.TextXAlignment = Enum.TextXAlignment.Left
	ApplyTheme(Header,"TextColor3","TextColor")
	Header.Parent = Topbar

	CloseButton.AnchorPoint = Vector2.new(1,0.5)
	CloseButton.AutoButtonColor = false
	CloseButton.BackgroundTransparency = 1
	CloseButton.BorderSizePixel = 0
	CloseButton.Position = UDim2.new(1,-5,0.5,0)
	CloseButton.Size = UDim2.new(1,-10,1,-10)
	CloseButton.Image = "rbxassetid://3944676352"
	ApplyTheme(CloseButton,"ImageColor3","TextColor")
	Instance.new("UIAspectRatioConstraint",CloseButton)
	CloseButton.Parent = Topbar

	Tabs.AnchorPoint = Vector2.new(0,1)
	Tabs.BackgroundTransparency = 1
	Tabs.BorderSizePixel = 0
	Tabs.Position = UDim2.new(0,10,1,-10)
	Tabs.Size = UDim2.new(0,120,1,-56)
	Tabs.ClipsDescendants = true
	Tabs.CanvasSize = UDim2.new(0,0,0,0)
	Tabs.ScrollBarImageTransparency = 1
	Tabs.ScrollBarThickness = 0
	Utility:SmoothScroll(Tabs,ScrollSmoothness)
	ApplyTheme(Tabs,"ScrollBarImageColor3","TextColor")
	Tabs.Parent = Main

	TabsUIList.Padding = UDim.new(0,4)
	TabsUIList.FillDirection = Enum.FillDirection.Vertical
	TabsUIList.SortOrder = Enum.SortOrder.LayoutOrder
	TabsUIList.Parent = Tabs

	Content.AnchorPoint = Vector2.new(1,1)
	Content.Position = UDim2.new(1,0,1,0)
	Content.Size = UDim2.new(1,-Tabs.AbsoluteSize.X - 20,1,-Topbar.AbsoluteSize.Y)
	Utility:Corner(Content,CornerSize)
	Utility:RemoveCorner(Content,Enum.NormalId.Left,CornerSize)
	Utility:RemoveCorner(Content,Enum.NormalId.Top,CornerSize)
	ApplyTheme(Content,"BackgroundColor3","Content")
	Content.Parent = Main

	Blur.AnchorPoint = Vector2.new(0,1)
	Blur.BackgroundColor3 = Color3.fromRGB(0,0,0)
	Blur.BackgroundTransparency = 1
	Blur.BorderSizePixel = 0
	Blur.Position = UDim2.new(0,0,1,0)
	Blur.Size = UDim2.new(1,0,1,0)
	Blur.ZIndex = 2
	Utility:Corner(Blur,CornerSize)
	Blur.Parent = Main

	DescriptionHolder.AnchorPoint = Vector2.new(0.5,1)
	DescriptionHolder.Size = UDim2.new(1,-20,0,30)
	DescriptionHolder.Position = UDim2.new(0.5,0,1.5,0)
	DescriptionHolder.ZIndex = 3
	Utility:Corner(DescriptionHolder,CornerSize)
	ApplyTheme(DescriptionHolder,"BackgroundColor3","SchemeColor")
	DescriptionHolder.Parent = Main

	DescriptionText.AnchorPoint = Vector2.new(0.5,0.5)
	DescriptionText.BackgroundTransparency = 1
	DescriptionText.BorderSizePixel = 0
	DescriptionText.Position = UDim2.new(0.5,0,0.5,0)
	DescriptionText.Size = UDim2.new(1,-10,1,-10)
	DescriptionText.Font = Enum.Font.SourceSans
	DescriptionText.Text = ""
	DescriptionText.TextScaled = false
	DescriptionText.TextSize = 16
	DescriptionText.TextWrapped = true
	DescriptionText.TextXAlignment = Enum.TextXAlignment.Left
	ApplyTheme(DescriptionText,"TextColor3","TextColor")
	DescriptionText.Parent = DescriptionHolder

	Main.Position = Position or UDim2.new(0,Workspace.CurrentCamera.ViewportSize.X/2 - Main.AbsoluteSize.X/2,0,Workspace.CurrentCamera.ViewportSize.Y/2 - Main.AbsoluteSize.Y/2)
	Utility:Drag(Topbar,Main)

	if syn then
		syn.protect_gui(Gui)
	end

	if get_hidden_gui then
		Gui.Parent = get_hidden_gui()
	else
		xpcall(function()
			Gui.Parent = game:GetService("CoreGui")
		end,function()
			Gui.Parent = Player:FindFirstChildWhichIsA("PlayerGui",true)
		end)
	end

	local Lib = {}

	local SelectedTab = nil
	function Lib:NewTab(Name)
		Name = Name or "Tab "..tostring(#Tabs:GetChildren())
		if Content:FindFirstChild(Name) then error("Tab "..tostring(Name).." already exists.") end

		local First = #Tabs:GetChildren() == 1
		if First then
			SelectedTab = Name
		end

		local TabButton = Instance.new("TextButton")
		local ContentList = Instance.new("ScrollingFrame")
		local ContentUIList = Instance.new("UIListLayout")

		TabButton.AutoButtonColor = false
		TabButton.BackgroundTransparency = First and 0 or 1
		TabButton.LayoutOrder = #Tabs:GetChildren() - 1
		TabButton.Size = UDim2.new(1,0,0,30)
		TabButton.Font = Enum.Font.SourceSans
		TabButton.Text = Name
		TabButton.TextScaled = false
		TabButton.TextSize = 16
		TabButton.TextWrapped = true
		Utility:Corner(TabButton,CornerSize)
		ApplyTheme(TabButton,"BackgroundColor3","SchemeColor")
		ApplyTheme(TabButton,"TextColor3","TextColor")
		TabButton.Parent = Tabs

		ContentList.AnchorPoint = Vector2.new(0.5,0.5)
		ContentList.BackgroundTransparency = 1
		ContentList.BorderSizePixel = 0
		ContentList.Name = Name
		ContentList.Position = UDim2.new(0.5,0,0.5,0)
		ContentList.Size = UDim2.new(1,-20,1,-20)
		ContentList.Visible = First
		ContentList.ClipsDescendants = true
		ContentList.CanvasSize = UDim2.new(0,0,0,0)
		ContentList.ScrollBarThickness = 4
		Utility:ScrollBar(ContentList)
		Utility:ScrollTrack(ContentList,CurrentTheme)
		Utility:SmoothScroll(ContentList,ScrollSmoothness)
		ApplyTheme(ContentList,"ScrollBarImageColor3","TextColor")
		ContentList.Parent = Content

		ContentUIList.Padding = UDim.new(0,16)
		ContentUIList.FillDirection = Enum.FillDirection.Vertical
		ContentUIList.SortOrder = Enum.SortOrder.LayoutOrder
		ContentUIList.Parent = ContentList

		local Tab = {}

		function Tab:NewSection(Name,Description,Data)
			Name = Name or "Section"
			Data = Data or {}
			
			local SectionHolder = Instance.new("Frame")
			local SectionUIList = Instance.new("UIListLayout")
			local SectionHeader,OnDisplayDescription = CreateItem(Name,Data.Icon or nil,Description,"SchemeColor")

			SectionHolder.BackgroundTransparency = 1
			SectionHolder.BorderSizePixel = 0
			SectionHolder.LayoutOrder = 0
			SectionHolder.Size = UDim2.new(1,-ContentList.ScrollBarThickness - 10,0,0)
			SectionHolder.Parent = ContentList

			SectionUIList.Padding = UDim.new(0,8)
			SectionUIList.FillDirection = Enum.FillDirection.Vertical
			SectionUIList.SortOrder = Enum.SortOrder.LayoutOrder
			SectionUIList.Parent = SectionHolder

			SectionHeader.Parent = SectionHolder

			local Section = {}

			function Section:NewLabel(Text,Description,Data)
				Text = Text or "Label"
				Data = Data or {}
				
				local LabelItem,OnDisplayDescription = CreateItem(Text,Data.Icon or nil,Description,"ElementColor")

				LabelItem.LayoutOrder = #SectionHolder:GetChildren() - 1
				LabelItem.Parent = SectionHolder

				local Label = {}

				function Label:UpdateText(NewText)
					LabelItem:FindFirstChildOfClass("TextLabel").Text = NewText
				end
				function Label:UpdateIcon(NewIcon)
					LabelItem:FindFirstChildOfClass("ImageLabel").Image = NewIcon
				end
				
				if OnDisplayDescription then
					OnDisplayDescription:Connect(function()
						DisplayDescription(Description)
					end)
				end

				return Label
			end
			function Section:NewButton(Text,Description,Callback,Data)
				Text = Text or "Button"
				Callback = Callback or function() end
				Data = Data or {}
				
				local ButtonItem,OnDisplayDescription = CreateItem(Text,Data.Icon or "rbxassetid://8318711356",Description,"ElementColor")
				local Input = Utility:AddItemButton(ButtonItem)

				ButtonItem.LayoutOrder = #SectionHolder:GetChildren() - 1
				ButtonItem.Parent = SectionHolder

				local Button = {}

				function Button:UpdateText(NewText)
					ButtonItem:FindFirstChildOfClass("TextLabel").Text = NewText
				end

				Input.MouseButton1Click:Connect(function()
					if Utility:CallCallback(Callback) then
						Utility:Ripple(ButtonItem,Vector2.new(Mouse.X,Mouse.Y),CurrentTheme)
					else
						Utility:ItemError(ButtonItem)
					end
				end)
				
				if OnDisplayDescription then
					OnDisplayDescription:Connect(function()
						DisplayDescription(Description)
					end)
				end

				return Button
			end
			function Section:NewToggle(Text,Description,Callback,Data)
				Text = Text or "Toggle"
				Callback = Callback or function() end
				Data = Data or {}
				
				local ToggleItem,OnDisplayDescription = CreateItem(Text,"rbxassetid://8318488758",Description,"ElementColor")
				local Input = Utility:AddItemButton(ToggleItem)
				local Circle = ToggleItem:FindFirstChildOfClass("ImageLabel")
				local Checked = Instance.new("Frame")

				local State = Data.State or false

				ToggleItem.LayoutOrder = #SectionHolder:GetChildren() - 1
				ToggleItem.Parent = SectionHolder

				Checked.AnchorPoint = Vector2.new(0.5,0.5)
				Checked.BackgroundTransparency = State == true and 0 or 1
				Checked.Position = UDim2.new(0.5,0,0.5,0)
				Checked.Size = UDim2.new(1,-12,1,-12)
				Utility:Corner(Checked,UDim.new(1,0))
				ApplyTheme(Checked,"BackgroundColor3","SchemeColor")
				Checked.Parent = Circle

				local Toggle = {}

				function Toggle:UpdateText(NewText)
					ToggleItem:FindFirstChildOfClass("TextLabel").Text = NewText
				end

				function Toggle:SetState(NewState)
					State = NewState

					Utility:Tween(Checked,TweenInfo.new(0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{
						BackgroundTransparency = State == true and 0 or 1;
					})

					return Utility:CallCallback(Callback,State)
				end

				Input.MouseButton1Click:Connect(function()
					if Toggle:SetState(not State) then
						Utility:Ripple(ToggleItem,Vector2.new(Mouse.X,Mouse.Y),CurrentTheme)
					else
						Utility:ItemError(ToggleItem)
					end
				end)
				
				if OnDisplayDescription then
					OnDisplayDescription:Connect(function()
						DisplayDescription(Description)
					end)
				end
				
				Toggle:SetState(State)
				
				return Toggle
			end
			
			if OnDisplayDescription then
				OnDisplayDescription:Connect(function()
					DisplayDescription(Description)
				end)
			end

			Utility:SyncSize(SectionHolder,SectionUIList)

			return Section
		end

		TabButton.MouseButton1Click:Connect(function()
			if SelectedTab ~= Name then
				SelectedTab = Name

				for _,Tab in ipairs(Tabs:GetChildren()) do
					if Tab:IsA("TextButton") then
						Utility:Tween(Tab,TweenInfo.new(0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{BackgroundTransparency = Tab == TabButton and 0 or 1})
					end
				end
				for _,TabContent in ipairs(Content:GetChildren()) do
					if TabContent:IsA("ScrollingFrame") then
						TabContent.Visible = TabContent == ContentList and true or false
					end
				end
			end
		end)

		Utility:SyncCanvasSize(ContentList,ContentUIList)

		return Tab
	end
	function Lib:UpdateThemeColor(Style,Color)
		assert(CurrentTheme[Style] ~= nil,"Style "..tostring(Style).." does not exist.")

		CurrentTheme[Style] = Color
		Utility:UpdateTheme(CurrentTheme)
	end
	function Lib:Hint(...)
		return DisplayDescription(...)
	end

	CloseButton.MouseButton1Click:Connect(function()
		Gui:Destroy()
	end)

	Utility:SyncCanvasSize(Tabs,TabsUIList)

	return Lib
end

return UI
