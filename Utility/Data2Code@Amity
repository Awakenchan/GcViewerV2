--[[
	DataToCode - Make DataTypes actually readable

	Created by: https://github.com/78n
	License: https://github.com/78n/Roblox/blob/main/LICENSE | Covered by MIT

	A little background about the coding style:
		I sometimes use next to avoid invoking __call/__iter in tables that I dont know the orgin of
		This has been rewritten like 3 seperate times
		The reason I don't use string interpolation is because it is very slow
		I dont use a giant if then elseif in my Serializer function as it is not as maintainable/scaleable as a dictionary of methods
]]
--!optimize 2
--!native

local assert, type, typeof, rawset, getmetatable, tostring = assert, type, typeof, rawset, getmetatable, tostring
local print, warn, pack, unpack, next = print, warn, table.pack, unpack, next

local IsSharedFrozen, SharedSize = SharedTable.isFrozen, SharedTable.size
local bufftostring, fromstring, readu8 = buffer.tostring, buffer.fromstring, buffer.readu8
local isfrozen, concat = table.isfrozen, table.concat
local info = debug.info

local DefaultMethods = {}
local Methods = setmetatable({}, {__index = DefaultMethods})
local Class = {
	Methods = Methods,
	_tostringUnsupported = false, -- whether or not to tostring unsupported types
	_Serializeinf = false,
	__VERSION = "1.0"
}

local Keywords = {
	["local"] = "\"local\"",
	["function"] = "\"function\"",
	--	["type"] = "\"type\"",
	--	["typeof"] = "\"typeof\"",
	--	["export"] = "\"export\"",
	--	["continue"] = "\"continue\"",
	["and"] = "\"and\"",
	["break"] = "\"break\"",
	["not"] = "\"not\"",
	["or"] = "\"or\"",
	["else"] = "\"else\"",
	["elseif"] = "\"elseif\"",
	["if"] = "\"if\"",
	["then"] = "\"then\"",
	["until"] = "\"until\"",
	["repeat"] = "\"repeat\"",
	["while"] = "\"while\"",
	["do"] = "\"do\"",
	["for"] = "\"for\"",
	["in"] = "\"in\"",
	["end"] = "\"end\"",
	["return"] = "\"return\"",
	["true"] = "\"true\"",
	["false"] = "\"false\"",
	["nil"] = "\"nil\""
}

local weakkeys = {__mode = "k"}

local islclosure = islclosure or function<func>(Function : func)
	return info(Function, "l") ~= -1
end

local DefaultVectors, DefaultCFrames = {}, {} do
	local function ExtractTypes<Library>(DataTypeLibrary : Library, Path : string, DataType : string, Storage : {[any] : string})
		for i,v in next, DataTypeLibrary do
			if typeof(v) == DataType and not Storage[v] and type(i) == "string" and not Keywords[i] or not i:match("[a-Z_][a-Z_0-9]") then
				Storage[v] = Path.."."..i
			end
		end
	end

	ExtractTypes(vector, "vector", "Vector3", DefaultVectors)
	ExtractTypes(Vector3, "Vector3", "Vector3", DefaultVectors)
	ExtractTypes(CFrame, "CFrame", "CFrame", DefaultCFrames)

	Class.DefaultTypes = {
		Vector3 = DefaultVectors,
		CFrame = DefaultCFrames,
	}
end

local function Serialize<Type>(DataStructure : Type, format : boolean?, indents : string, CyclicList : {[{[any] : any?}] : boolean | nil}?, InComment : boolean?)
	local DataHandler = Methods[typeof(DataStructure)]

	return if DataHandler then DataHandler(DataStructure, format, indents, CyclicList, InComment) else "nil --["..(if InComment then "" else "=").."[ Unsupported Data Type | "..typeof(DataStructure)..(if not Class._tostringUnsupported then "" else " | "..tostring(DataStructure)).." ]"..(if not InComment then "" else "=").."]"
end

local function ValidateSharedTableIndex(Index : string)
	local IsKeyword = if type(Index) == "number" then Index else Keywords[Index]

	if not IsKeyword then
		if Index ~= "" then
			local IndexBuffer = fromstring(Index)
			local FirstByte = readu8(IndexBuffer, 0)

			if FirstByte >= 97 and FirstByte <= 122 or FirstByte >= 65 and FirstByte <= 90 or FirstByte == 95 then
				for i = 1, #Index-1 do
					local Byte = readu8(IndexBuffer, i)

					if not ((Byte >= 97 and Byte <= 122) or (Byte >= 65 and Byte <= 90) or Byte == 95 or (Byte >= 48 and Byte <= 57)) then
						return "["..Methods.string(Index).."] = "
					end
				end

				return Index.." = "
			end

			return "["..Methods.string(Index).."] = "
		end

		return "[\"\"] = "
	end

	return "["..IsKeyword.."] = "
end

local function ValidateIndex(Index : any)
	local IndexType = type(Index)
	local IsNumber = IndexType == "number"

	if IsNumber or IndexType == "string" then
		local IsKeyword = if IsNumber then Index else Keywords[Index]

		if not IsKeyword then
			if Index ~= "" then
				local IndexBuffer = fromstring(Index)
				local FirstByte = readu8(IndexBuffer, 0)

				if FirstByte >= 97 and FirstByte <= 122 or FirstByte >= 65 and FirstByte <= 90 or FirstByte == 95 then
					for i = 1, #Index-1 do
						local Byte = readu8(IndexBuffer, i)

						if not ((Byte >= 97 and Byte <= 122) or (Byte >= 65 and Byte <= 90) or Byte == 95 or (Byte >= 48 and Byte <= 57)) then
							return "["..Methods.string(Index).."] = "
						end
					end

					return Index.." = "
				end

				return "["..Methods.string(Index).."] = "
			end

			return "[\"\"] = "
		end

		return "["..IsKeyword.."] = "
	end

	return "["..(if IndexType ~= "table" then Serialize(Index, false, "") else "\"<Table> (table: "..(if getmetatable(Index) == nil then tostring(Index):sub(8) else "@metatable")..")\"").."] = "
end

function DefaultMethods.Axes(Axes : Axes)
	return "Axes.new("..concat({
		if Axes.X then "Enum.Axis.X" else nil,
		if Axes.Y then "Enum.Axis.Y" else nil,
		if Axes.Z then "Enum.Axis.Z" else nil
	},", ")..")"
end

function DefaultMethods.BrickColor(Color : BrickColor)
	return "BrickColor.new("..Color.Number..")"
end

function DefaultMethods.CFrame(CFrame : CFrame)
	local Generation = DefaultCFrames[CFrame]

	if not Generation then
		local x, y, z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = CFrame:GetComponents()
		local SerializeNumber = Methods.number

		return "CFrame.new("..SerializeNumber(x)..", "..SerializeNumber(y)..", "..SerializeNumber(z)..", "..SerializeNumber(R00)..", "..SerializeNumber(R01)..", "..SerializeNumber(R02)..", "..SerializeNumber(R10)..", "..SerializeNumber(R11)..", "..SerializeNumber(R12)..", "..SerializeNumber(R20)..", "..SerializeNumber(R21)..", "..SerializeNumber(R22)..")"
	end

	return Generation
end

do
	local DefaultCatalogSearchParams = CatalogSearchParams.new()
	function DefaultMethods.CatalogSearchParams(Params : CatalogSearchParams, format : boolean?, indents : string)
		if DefaultCatalogSearchParams ~= Params then
			local formatspace = if format then "\n"..indents else " "
			local SerializeString = Methods.string
			local SearchKeyword = Params.SearchKeyword
			local MinPrice = Params.MinPrice
			local MaxPrice = Params.MaxPrice
			local SortType = Params.SortType
			local SortAggregation = Params.SortAggregation
			local CategoryFilter = Params.CategoryFilter
			local SalesTypeFilter = Params.SalesTypeFilter
			local BundleTypes = Params.BundleTypes
			local AssetTypes = Params.AssetTypes
			local CreatorName = Params.CreatorName
			local CreatorType = Params.CreatorType
			local CreatorId = Params.CreatorId
			local Limit = Params.Limit

			return "(function(Param : CatalogSearchParams)"..formatspace..(if SearchKeyword ~= "" then "\tParam.SearchKeyword = "..SerializeString(SearchKeyword)..formatspace else "")..(if MinPrice ~= 0 then "\tParam.MinPrice = "..MinPrice..formatspace else "")..(if MaxPrice ~= 2147483647 then "\tParam.MaxPrice = "..MaxPrice..formatspace else "")..(if SortType ~= Enum.CatalogSortType.Relevance then "\tParam.SortType = Enum.CatalogSortType."..SortType.Name..formatspace else "")..(if SortAggregation ~= Enum.CatalogSortAggregation.AllTime then "\tParam.SortAggregation = Enum.CatalogSortAggregation."..SortAggregation.Name..formatspace else "")..(if CategoryFilter ~= Enum.CatalogCategoryFilter.None then "\tParam.CategoryFilter = Enum.CatalogCategoryFilter."..CategoryFilter.Name..formatspace else "")..(if SalesTypeFilter ~= Enum.SalesTypeFilter.All then "\tParam.SalesTypeFilter = Enum.SalesTypeFilter."..SalesTypeFilter.Name..formatspace else "")..(if #BundleTypes > 0 then "\tParam.BundleTypes = "..Methods.table(BundleTypes, false, "")..formatspace else "")..(if #AssetTypes > 0 then "\tParam.AssetTypes = "..Methods.table(AssetTypes, false, "")..formatspace else "")..(if Params.IncludeOffSale then "\tParams.IncludeOffSale = true"..formatspace else "")..(if CreatorName ~= "" then "\tParams.CreatorName = "..SerializeString(CreatorName)..formatspace else "")..(if CreatorType ~= Enum.CreatorTypeFilter.All then "\tParam.CreatorType = Enum.CreatorTypeFilter."..CreatorType.Name..formatspace else "")..(if CreatorId ~= 0 then "\tParams.CreatorId = "..CreatorId..formatspace else "")..(if Limit ~= 30 then "\tParams.Limit = "..Limit..formatspace else "").."\treturn Params"..formatspace.."end)(CatalogSearchParams.new())"
		end

		return "CatalogSearchParams.new()"
	end
end

function DefaultMethods.Color3(Color : Color3)
	local SerializeNumber = Methods.number

	return "Color3.new("..SerializeNumber(Color.R)..", "..SerializeNumber(Color.G)..", "..SerializeNumber(Color.B)..")"
end

function DefaultMethods.ColorSequence(Sequence : ColorSequence)
	local SerializeColorSequenceKeypoint = Methods.ColorSequenceKeypoint
	local Keypoints = Sequence.Keypoints
	local Size = #Keypoints
	local Serialized = ""

	for i = 1, Size-1 do
		Serialized ..= SerializeColorSequenceKeypoint(Keypoints[i])..", "
	end

	return "ColorSequence.new({"..Serialized..SerializeColorSequenceKeypoint(Keypoints[Size]).."})"
end

function DefaultMethods.ColorSequenceKeypoint(KeyPoint : ColorSequenceKeypoint)
	return "ColorSequenceKeypoint.new("..Methods.number(KeyPoint.Time)..", "..Methods.Color3(KeyPoint.Value)..")"
end

function DefaultMethods.Content(content : Content)
	local Uri = content.Uri

	return if Uri then "Content.fromUri("..Uri..")" else "Content.none"
end

function DefaultMethods.DateTime(Date : DateTime)
	return "DateTime.fromUnixTimestampMillis("..Date.UnixTimestampMillis..")"
end

function DefaultMethods.DockWidgetPluginGuiInfo(Dock : DockWidgetPluginGuiInfo)
	local ArgumentFunction = tostring(Dock):gmatch(":([%w%-]+)")

	return "DockWidgetPluginGuiInfo.new(Enum.InitialDockState."..ArgumentFunction()..", "..(if ArgumentFunction() == "1" then "true" else "false")..", "..(if ArgumentFunction() == "1" then "true" else "false")..", "..ArgumentFunction()..", "..ArgumentFunction()..", "..ArgumentFunction()..", "..ArgumentFunction()..")"
end

function DefaultMethods.Enum(Enum : Enum)
	return "Enums."..tostring(Enum)
end

do
	local Enums = {}

	for i,v in Enum:GetEnums() do
		Enums[v] = "Enum."..tostring(v)
	end

	function DefaultMethods.EnumItem(Item : EnumItem)
		return Enums[Item.EnumType].."."..Item.Name
	end
end

function DefaultMethods.Enums()
	return "Enums"
end

function DefaultMethods.Faces(Faces : Faces)
	return "Faces.new("..concat({
		if Faces.Top then "Enum.NormalId.Top" else nil,
		if Faces.Bottom then "Enum.NormalId.Bottom" else nil,
		if Faces.Left then "Enum.NormalId.Left" else nil,
		if Faces.Right then "Enum.NormalId.Right" else nil,
		if Faces.Back then "Enum.NormalId.Back" else nil,
		if Faces.Front then "Enum.NormalId.Front" else nil,
	}, ", ")..")"
end

function DefaultMethods.FloatCurveKey(CurveKey : FloatCurveKey)
	local SerializeNumber = Methods.number

	return "FloatCurveKey.new("..SerializeNumber(CurveKey.Time)..", "..SerializeNumber(CurveKey.Value)..", Enum.KeyInterpolationMode."..CurveKey.Interpolation.Name..")"
end

function DefaultMethods.Font(Font : Font)
	return "Font.new("..Methods.string(Font.Family)..", Enum.FontWeight."..Font.Weight.Name..", Enum.FontStyle."..Font.Style.Name..")"
end

do
	local Players = game:GetService("Players")
	local FindService = game.FindService

	local Services = {
		Workspace = "workspace",
		Lighting = "game.lighting",
		GlobalSettings = "settings()",
		Stats = "stats()",
		UserSettings = "UserSettings()",
		PluginManagerInterface = "PluginManager()",
		DebuggerManager = "DebuggerManager()"
	}

	if game:GetService("RunService"):IsClient() then
		local LocalPlayer = Players.LocalPlayer

		if not LocalPlayer then
			Players:GetPropertyChangedSignal("LocalPlayer"):Once(function()
				LocalPlayer = Players.LocalPlayer
			end)
		end

		-- Not garenteed to return the correct generation
		function DefaultMethods.Instance(obj : Instance) -- Client
			local ObjectParent = obj.Parent
			local ObjectClassName = obj.ClassName

			if ObjectParent then
				local ObjectName = Methods.string(obj.Name)

				if ObjectClassName ~= "Model" and ObjectClassName ~= "Player" then
					local IsService, Output = pcall(FindService, game, ObjectClassName) -- Generation can and will break when presented with noncreatable Instances such as Path (which is created by PathService:CreateAsync())

					return if not (IsService and Output) then Methods.Instance(ObjectParent)..":WaitForChild("..ObjectName..")" else Services[ObjectClassName] or "game:GetService(\""..ObjectClassName.."\")"
				elseif ObjectClassName == "Model" then
					local Player = Players:GetPlayerFromCharacter(obj)

					return if not Player then Methods.Instance(ObjectParent)..":WaitForChild("..ObjectName..")" else "game:GetService(\"Players\")".. (if Player == LocalPlayer then ".LocalPlayer.Character" else ":WaitForChild("..ObjectName..").Character")
				end

				return "game:GetService(\"Players\")".. (if obj == LocalPlayer then ".LocalPlayer" else ":WaitForChild("..ObjectName..")") 
			end

			return if ObjectClassName == "DataModel" then "game" else "Instance.new(\""..ObjectClassName.."\", nil)"
		end
	else
		function DefaultMethods.Instance(obj : Instance) -- Server
			local ObjectParent = obj.Parent
			local ObjectClassName = obj.ClassName

			if ObjectParent then
				local ObjectName = Methods.string(obj.Name)

				if ObjectClassName ~= "Model" and ObjectClassName ~= "Player" then
					local IsService, Output = pcall(FindService, game, ObjectClassName) -- Generation can and will break when presented with noncreatable Instances such as Path (which is created by PathService:CreateAsync())

					return if not (IsService and Output) then Methods.Instance(ObjectParent)..":WaitForChild("..ObjectName..")" else Services[ObjectClassName] or "game:GetService(\""..ObjectClassName.."\")"
				elseif ObjectClassName == "Model" then
					local Player = Players:GetPlayerFromCharacter(obj)

					return if not Player then Methods.Instance(ObjectParent)..":WaitForChild("..ObjectName..")" else "game:GetService(\"Players\"):WaitForChild("..ObjectName..").Character"
				end

				return "game:GetService(\"Players\"):WaitForChild("..ObjectName..")"
			end

			return if ObjectClassName == "DataModel" then "game" else "Instance.new(\""..ObjectClassName.."\", nil)"
		end
	end

	Class.Services = Services
end

function DefaultMethods.NumberRange(Range : NumberRange)
	local SerializeNumber = Methods.number

	return "NumberRange.new("..SerializeNumber(Range.Min)..", "..SerializeNumber(Range.Max)..")"
end

function DefaultMethods.NumberSequence(Sequence : NumberSequence)
	local SerializeNumberSequenceKeypoint = Methods.NumberSequenceKeypoint
	local Keypoints = Sequence.Keypoints
	local Size = #Keypoints
	local Serialized = ""

	for i = 1, Size-1 do
		Serialized ..= SerializeNumberSequenceKeypoint(Keypoints[i])..", "
	end

	return "NumberSequence.new({"..Serialized..SerializeNumberSequenceKeypoint(Keypoints[Size]).."})"
end

do
	local DefaultOverlapParams = OverlapParams.new()
	function DefaultMethods.OverlapParams(Params : OverlapParams, format : boolean?, indents : string)
		if DefaultOverlapParams ~= Params then
			local formatspace = format and "\n"..indents or " "
			local FilterDescendantsInstances = Params.FilterDescendantsInstances
			local FilterType = Params.FilterType
			local CollisionGroup = Params.CollisionGroup

			return "(function(Param : OverlapParams)"..formatspace..(if #FilterDescendantsInstances > 0 then "\tParam.FilterDescendantsInstances = "..Methods.table(FilterDescendantsInstances, false, "")..formatspace else "")..(if FilterType ~= Enum.RaycastFilterType.Exclude then "\tParam.FilterType = Enum.RaycastFilterType."..FilterType.Name..formatspace else "")..(if CollisionGroup ~= "Default" then "\tParam.CollisionGroup = "..Methods.string(CollisionGroup)..formatspace else "")..(if Params.RespectCanCollide then "\tParam.RespectCanCollide = true"..formatspace else "")..(if Params.BruteForceAllSlow then "\tParam.BruteForceAllSlow = true"..formatspace else "").."\treturn Params"..formatspace.."end)(OverlapParams.new())"
		end

		return "OverlapParams.new()"
	end
end

function DefaultMethods.NumberSequenceKeypoint(Keypoint : NumberSequenceKeypoint)
	local SerializeNumber = Methods.number

	return "NumberSequenceKeypoint.new("..SerializeNumber(Keypoint.Time)..", "..SerializeNumber(Keypoint.Value)..", "..SerializeNumber(Keypoint.Envelope)..")"
end

function DefaultMethods.PathWaypoint(Waypoint : PathWaypoint)
	return "PathWaypoint.new("..Methods.Vector3(Waypoint.Position)..", Enum.PathWaypointAction."..Waypoint.Action.Name..", "..Methods.string(Waypoint.Label)..")"
end

do
	local function nanToString(num : number)
		return if num == num then num else "0/0"
	end

	function DefaultMethods.PhysicalProperties(Properties : PhysicalProperties)
		return "PhysicalProperties.new("..(nanToString(Properties.Density))..", "..nanToString(Properties.Friction)..", "..nanToString(Properties.Elasticity)..", "..nanToString(Properties.FrictionWeight)..", "..nanToString(Properties.ElasticityWeight)..")"
	end
end

function DefaultMethods.RBXScriptConnection(Connection : RBXScriptConnection, _, _, _, InComment : boolean?)
	local CommentSeperator = if not InComment then "" else "="

	return "(nil --["..CommentSeperator.."[ RBXScriptConnection | IsConnected: "..(if Connection.Connected then "true" else "false").." ]"..CommentSeperator.."])" -- Can't support this
end

do
	local Signals = { -- You theoretically could serialize the api to retrieve most of the Signals but I don't believe that its worth it
		GraphicsQualityChangeRequest = "game.GraphicsQualityChangeRequest",
		AllowedGearTypeChanged = "game.AllowedGearTypeChanged",
		ScreenshotSavedToAlbum = "game.ScreenshotSavedToAlbum",
		UniverseMetadataLoaded = "game.UniverseMetadataLoaded",
		ScreenshotReady = "game.ScreenshotReady",
		ServiceRemoving = "game.ServiceRemoving",
		ServiceAdded = "game.ServiceAdded",
		ItemChanged = "game.ItemChanged",
		CloseLate = "game.CloseLate",
		Loaded = "game.Loaded",
		Close = "game.Close",

		RobloxGuiFocusedChanged = "game:GetService(\"RunService\").RobloxGuiFocusedChanged",
		PostSimulation = "game:GetService(\"RunService\").PostSimulation",
		RenderStepped = "game:GetService(\"RunService\").RenderStepped",
		PreSimulation = "game:GetService(\"RunService\").PreSimulation",
		PreAnimation = "game:GetService(\"RunService\").PreAnimation",
		PreRender = "game:GetService(\"RunService\").PreRender",
		Heartbeat = "game:GetService(\"RunService\").Heartbeat",
		Stepped = "game:GetService(\"RunService\").Stepped"
	}

	function DefaultMethods.RBXScriptSignal(Signal : RBXScriptSignal, _, _, _, InComment : boolean?)
		local CommentSeperator = if not InComment then "" else "="
		local SignalName = tostring(Signal):match("Signal ([A-z]+)")

		return Signals[SignalName] or "(nil --["..CommentSeperator.."[ RBXScriptSignal | "..SignalName.." is not supported ]"..CommentSeperator.."])"
	end

	Class.Signals = Signals
end

function DefaultMethods.Random(_, _, _, _, InComment : boolean?) -- Random cant be supported because I cant get the seed
	local CommentSeperator = if not InComment then "" else "="

	return "Random.new(--["..CommentSeperator.."[ <Seed> ]"..CommentSeperator.."])"
end

function DefaultMethods.Ray(Ray : Ray)
	local SerializeVector3 = Methods.Vector3

	return "Ray.new("..SerializeVector3(Ray.Origin)..", "..SerializeVector3(Ray.Direction)..")"
end

do
	local DefaultRaycastParams = RaycastParams.new()
	function DefaultMethods.RaycastParams(Params : RaycastParams, format : boolean?, indents : string)
		if DefaultRaycastParams ~= Params then
			local formatspace = format and "\n"..indents or " "
			local FilterDescendantsInstances = Params.FilterDescendantsInstances
			local FilterType = Params.FilterType
			local CollisionGroup = Params.CollisionGroup

			return "(function(Param : RaycastParams)"..formatspace..(if #FilterDescendantsInstances > 0 then "\tParam.FilterDescendantsInstances = "..Methods.table(FilterDescendantsInstances, false, "")..formatspace else "")..(if FilterType ~= Enum.RaycastFilterType.Exclude then "\tParam.FilterType = Enum.RaycastFilterType."..FilterType.Name..formatspace else "")..(if Params.IgnoreWater then "\tParam.IgnoreWater = true"..formatspace else "")..(if CollisionGroup ~= "Default" then "\tParam.CollisionGroup = "..Methods.string(CollisionGroup)..formatspace else "")..(if Params.RespectCanCollide then "\tParam.RespectCanCollide = true"..formatspace else "")..(if Params.BruteForceAllSlow then "\tParam.BruteForceAllSlow = true"..formatspace else "").."\treturn Params"..formatspace.."end)(RaycastParams.new())"
		end

		return "RaycastParams.new()"
	end
end

function DefaultMethods.Rect(Rect : Rect)
	local SerializeVector2 = Methods.Vector2

	return "Rect.new("..SerializeVector2(Rect.Min)..", "..SerializeVector2(Rect.Max)..")"
end

function DefaultMethods.Region3(Region : Region3)
	local SerializeVector3 = Methods.Vector3
	local Center = Region.CFrame.Position
	local Size = Region.Size/2

	return "Region3.new("..SerializeVector3(Center - Size)..", "..SerializeVector3(Center + Size)..")"
end

function DefaultMethods.Region3int16(Region : Region3int16)
	local SerializeVector3int16 = Methods.Vector3int16

	return "Region3int16.new("..SerializeVector3int16(Region.Min)..", "..SerializeVector3int16(Region.Max)..")"
end

function DefaultMethods.RotationCurveKey(Curve : RotationCurveKey)
	return "RotationCurveKey.new("..Methods.number(Curve.Time)..", "..Methods.CFrame(Curve.Value)..", Enum.KeyInterpolationMode."..Curve.Interpolation.Name..")"
end

function DefaultMethods.SharedTable(Shared : SharedTable, format : boolean?, indents : string, _, InComment : boolean?)
	local isreadonly = IsSharedFrozen(Shared)

	if SharedSize(Shared) ~= 0 then
		local stackindent = indents..(if format then "\t" else "")
		local CurrentIndex = 1
		local Serialized = {}

		for i,v in Shared do
			Serialized[CurrentIndex] = (if CurrentIndex ~= i then ValidateSharedTableIndex(i) else "")..Serialize(v, format, stackindent, nil, InComment)
			CurrentIndex += 1	
		end

		local formatspace = if format then "\n" else ""
		local Contents = formatspace..stackindent..concat(Serialized, (if format then ",\n" else ", ")..stackindent)..formatspace..indents

		return if not isreadonly then "SharedTable.new({"..Contents.."})" else "SharedTable.cloneAndFreeze(SharedTable.new({"..Contents.."}))"
	end

	return if not isreadonly then "SharedTable.new()" else "SharedTable.cloneAndFreeze(SharedTable.new())"
end

function DefaultMethods.TweenInfo(Info : TweenInfo)
	return "TweenInfo.new("..Methods.number(Info.Time)..", Enum.EasingStyle."..Info.EasingStyle.Name..", Enum.EasingDirection."..Info.EasingDirection.Name..", "..Info.RepeatCount..", "..(if Info.Reverses then "true" else "false")..", "..Methods.number(Info.DelayTime)..")"
end

function DefaultMethods.UDim(UDim : UDim)
	return "UDim.new("..Methods.number(UDim.Scale)..", "..UDim.Offset..")"
end

function DefaultMethods.UDim2(UDim2 : UDim2)
	local SerializeNumber = Methods.number
	local Width = UDim2.X
	local Height = UDim2.Y

	return "UDim2.new("..SerializeNumber(Width.Scale)..", "..Width.Offset..", "..SerializeNumber(Height.Scale)..", "..Height.Offset..")"
end

function DefaultMethods.Vector2(Vector : Vector2)
	local SerializeNumber = Methods.number

	return "Vector2.new("..SerializeNumber(Vector.X)..", "..SerializeNumber(Vector.Y)..")"
end

function DefaultMethods.Vector2int16(Vector : Vector2int16)
	return "Vector2int16.new("..Vector.X..", "..Vector.Y..")"
end

function DefaultMethods.Vector3(Vector : Vector3)
	local SerializeNumber = Methods.number

	return DefaultVectors[Vector] or "vector.create("..SerializeNumber(Vector.X)..", "..SerializeNumber(Vector.Y)..", "..SerializeNumber(Vector.Z)..")" -- vector library is more efficent/accurate
end

function DefaultMethods.Vector3int16(Vector : Vector3int16)
	return "Vector3int16.new("..Vector.X..", "..Vector.Y..", "..Vector.Z..")"
end

function DefaultMethods.boolean(bool : boolean)
	return if bool then "true" else "false"
end

function DefaultMethods.buffer(buff : buffer)
	return "buffer.fromstring("..Methods.string(bufftostring(buff))..")"
end

do
	local GlobalFunctions = {} do
		local getrenv = getrenv or (function() -- support for studio executors
			local env = { -- I could be missing a couple libraries
				bit32 = bit32,
				buffer = buffer,
				coroutine = coroutine,
				debug = debug,
				math = math,
				os = os,
				string = string,
				table = table,
				utf8 = utf8,
				Content = Content,
				Axes = Axes,
				AdReward = AdReward, --Empty
				BrickColor = BrickColor,
				CatalogSearchParams = CatalogSearchParams,
				CFrame = CFrame,
				Color3 = Color3,
				ColorSequence = ColorSequence,
				ColorSequenceKeypoint = ColorSequenceKeypoint,
				DateTime = DateTime,
				DockWidgetPluginGuiInfo = DockWidgetPluginGuiInfo,
				Faces = Faces,
				FloatCurveKey = FloatCurveKey,
				Font = Font,
				Instance = Instance,
				NumberRange = NumberRange,
				NumberSequence = NumberSequence,
				NumberSequenceKeypoint = NumberSequenceKeypoint,
				OverlapParams = OverlapParams,
				PathWaypoint = PathWaypoint,
				PhysicalProperties = PhysicalProperties,
				Random = Random,
				Ray = Ray,
				RaycastParams = RaycastParams,
				Rect = Rect,
				Region3 = Region3,
				Region3int16 = Region3int16,
				RotationCurveKey = RotationCurveKey,
				SharedTable = SharedTable,
				task = task,
				TweenInfo = TweenInfo,
				UDim = UDim,
				UDim2 = UDim2,
				Vector2 = Vector2,
				Vector2int16 = Vector2int16,
				Vector3 = Vector3,
				vector = vector,
				Vector3int16 = Vector3int16,
				CellId = CellId, -- Undocumented
				PluginDrag = PluginDrag,
				SecurityCapabilities = SecurityCapabilities,

				assert = assert,
				error = error,
				getfenv = getfenv,
				getmetatable = getmetatable,
				ipairs = ipairs,
				loadstring = loadstring,
				newproxy = newproxy,
				next = next,
				pairs = pairs,
				pcall = pcall,
				print = print,
				rawequal = rawequal,
				rawget = rawget,
				rawlen = rawlen,
				rawset = rawset,
				select = select,
				setfenv = setfenv,
				setmetatable = setmetatable,
				tonumber = tonumber,
				tostring = tostring,
				unpack = unpack,
				xpcall = xpcall,
				collectgarbage = collectgarbage,
				delay = delay,
				gcinfo = gcinfo,
				PluginManager = PluginManager,
				DebuggerManager = DebuggerManager,
				require = require,
				settings = settings,
				spawn = spawn,
				tick = tick,
				time = time,
				UserSettings = UserSettings,
				wait = wait,
				warn = warn,
				Delay = Delay,
				ElapsedTime = ElapsedTime,
				elapsedTime = elapsedTime,
				printidentity = printidentity,
				Spawn = Spawn,
				Stats = Stats,
				stats = stats,
				Version = Version,
				version = version,
				Wait = Wait
			}

			return function()
				return env
			end
		end)()

		local Visited = setmetatable({}, weakkeys) -- support for people who actually modify the roblox env

		for i,v in getrenv() do
			local ElementType = type(i) == "string" and type(v) -- I'm not supporting numbers

			if ElementType then
				if ElementType == "table" then
					local function LoadLibrary(Path : string, tbl : {[string] : any})
						if not Visited[tbl] then
							Visited[tbl] = true

							for i,v in next, tbl do
								local Type = type(i) == "string" and not Keywords[i] and i:match("[A-z_][A-z_0-9]") and type(v)
								local NewPath = Type and (Type == "function" or Type == "table") and Path.."."..i

								if NewPath then
									if Type == "function" then
										GlobalFunctions[v] = NewPath
									else
										LoadLibrary(NewPath, v)
									end
								end
							end

							Visited[tbl] = nil
						end
					end

					LoadLibrary(i, v)
					table.clear(Visited)
				elseif ElementType == "function" then
					GlobalFunctions[v] = i
				end
			end
		end

		Class.GlobalFunctions = GlobalFunctions
	end

	DefaultMethods["function"] = function(Function : (...any?) -> ...any?, format : boolean?, indents : string, _, InComment : boolean?)
		local IsGlobal = GlobalFunctions[Function]

		if not IsGlobal then
			if format then
				local SerializeString = Methods.string

				local CommentSeperator = if not InComment then "" else "="
				local tempindents = indents.."\t\t\t"
				local newlineindent = ",\n"..tempindents
				local source, line, name, numparams, vargs = info(Function, "slna")
				local lclosure = line ~= -1

				return (if lclosure then "" else "coroutine.wrap(").."function()\n\t"..indents.."--["..CommentSeperator.."[\n\t\t"..indents.."info = {\n"..tempindents.."source = "..SerializeString(source)..newlineindent.."line = "..line..newlineindent.."what = "..(if lclosure then "\"Lua\"" else "\"C\"")..newlineindent.."name = "..SerializeString(name)..newlineindent.."numparams = "..numparams..newlineindent.."vargs = "..(if vargs then "true" else "false")..newlineindent.."function = "..tostring(Function).."\n\t\t"..indents.."}\n\t"..indents.."]"..CommentSeperator.."]\n"..indents.."end"..(if lclosure then "" else ")")
			end

			return if islclosure(Function) then "function() end" else "coroutine.wrap(function() end)"
		end

		return IsGlobal
	end
end

function DefaultMethods.table(tbl : {[any] : any}, format : boolean?, indents : string, CyclicList : {[{[any] : any?}] : boolean | nil}?, InComment : boolean?)
	if not CyclicList then
		CyclicList = setmetatable({}, weakkeys)
	end

	if not CyclicList[tbl] then
		local isreadonly = isfrozen(tbl)
		local Index, Value = next(tbl)

		if Index ~= nil then
			local Indents = indents..(if format then "\t" else "")
			local Ending = (if format then ",\n" else ", ")
			local formatspace = if format then "\n" else ""
			local Generation = "{"..formatspace
			local CurrentIndex = 1

			CyclicList[tbl] = true
			repeat
				Generation ..= Indents..(if CurrentIndex ~= Index then ValidateIndex(Index) else "")..Serialize(Value, format, Indents, CyclicList, InComment)
				Index, Value = next(tbl, Index)
				Generation ..= if Index ~= nil then Ending else formatspace..indents.."}"
				CurrentIndex += 1
			until Index == nil
			CyclicList[tbl] = nil

			return if not isreadonly then Generation else "table.freeze("..Generation..")"
		end

		return if not isreadonly then "{}" else "table.freeze({})"
	else
		return "*** cycle table reference detected ***" -- I am NOT supporting cyclic tables as its a huge pain
	end
end

DefaultMethods["nil"] = function()
	return "nil"
end

function DefaultMethods.number(num : number)
	return if num < 1/0 and num > -1/0 then tostring(num) elseif num == 1/0 then (if Class._Serializeinf then "math.huge" else "1/0") elseif num == num then (if Class._Serializeinf then "-math.huge" else "-1/0") else "0/0"
end

do
	local ByteList = {
		["\a"] = "\\a",
		["\b"] = "\\b",
		["\t"] = "\\t",
		["\n"] = "\\n",
		["\v"] = "\\v",
		["\f"] = "\\f",
		["\r"] = "\\r",
		["\""] = "\\\"",
		["\\"] = "\\\\"
	}

	for i = 0, 255 do
		local Character = (i < 32 or i > 126) and string.char(i)

		if Character and not ByteList[Character] then
			ByteList[Character] = ("\\%03d"):format(i)
		end
	end

	function DefaultMethods.string(RawString : string)
		return "\""..RawString:gsub("[\0-\31\34\92\127-\255]", ByteList).."\""
	end
end

function DefaultMethods.thread(thread : thread)
	return "coroutine.create(function() end)"
end

function DefaultMethods.userdata(userdata : any)
	return getmetatable(userdata) ~= nil and "newproxy(true)" or "newproxy(false)"
end

do
	local SecurityCapabilityEnums = Enum.SecurityCapability:GetEnumItems()
	function DefaultMethods.SecurityCapabilities(Capabilities : SecurityCapabilities, format : boolean?, _, _, InComment : boolean?)
		local ContainedCapabilities = {}
		local CurrentIndex = 1

		for i,v in SecurityCapabilityEnums do
			if Capabilities:Contains(v) then
				ContainedCapabilities[CurrentIndex] = "Enum.SecurityCapability."..v.Name
				CurrentIndex += 1
			end
		end

		return "SecurityCapabilities.new("..concat(ContainedCapabilities, ", ")..")"
	end
end

function DefaultMethods.PluginDrag(Drag : PluginDrag)
	local SerializeString = Methods.string

	return "PluginDrag.new("..SerializeString(Drag.Sender)..", "..SerializeString(Drag.MimeType)..", "..SerializeString(Drag.Data)..", "..SerializeString(Drag.MouseIcon)..", "..SerializeString(Drag.DragIcon)..", "..Methods.Vector2(Drag.HotSpot)..")"
end

function DefaultMethods.CellId(_, _, _, _, InComment : boolean?)
	local Comment = if InComment then "=" else ""

	return "CellId.new(--["..Comment.."[ Undocumented ]"..Comment.."])" -- Undocumented so I have no idea what the properties are
end

local function Serializevargs(... : any)
	local tbl = pack(...) -- Thank you https://github.com/sown0000 for pointing out that nils arent printed
	local GenerationSize = 0

	for i = 1, #tbl do
		local Generation = Serialize(tbl[i], true, "")
		tbl[i] = Generation
		GenerationSize += #Generation

		if GenerationSize > 100000 then -- output functions will trim the generation
			break
		end
	end

	return unpack(tbl, 1, tbl.n)
end

-- Safe parallel
function Class.Convert<Type>(DataStructure : Type, format : boolean?)
	return Serialize(DataStructure, format, "")
end

-- Safe parallel
function Class.ConvertKnown<Type>(DataType : string, DataStructure : Type, format : boolean?)
	return Methods[DataType](DataStructure, format, "")
end

-- Safe parallel
function Class.print(... : any?)
	print(Serializevargs(...))
end

-- Safe Parallel
function Class.warn(... : any?)
	warn(Serializevargs(...))
end

if type(setclipboard) == "function" then
	local setclipboard = setclipboard
	-- Safe Parallel
	function Class.setclipboard<Type>(DataStructure : Type, format : boolean?)
		setclipboard(Serialize(DataStructure, format, ""))
	end
end

return Class,Class.Methods
