--!strict

--[[
	Event Service
	A Luau module made to replicate Roblox's native script event and connection system.
]]--

---------------------------------------------------------------------------------------

local types = require(script:WaitForChild("Types"))

---------------------------------------------------------------------------------------


local DEFAULT_KEY : any = "global"
local DEFAULT_DIR : any = "EventService"

local DEFAULT_TIMEOUT : number = 5
local DEFAULT_DT : number = 0.5

---------------------------------------------------------------------------------------

local events : {
	[any] : {
		[any] : {
			[string] : types.Event
		}
	}
} = {}

---------------------------------------------------------------------------------------

local Event = {
	Fire = function(self : types.Event, ...)
		local args = {...}
		task.spawn(function()
			for i, v in pairs(self.Connections) do
				if v then
					if v.FireLimit and v.FireCount >= v.FireLimit then
						v:Disconnect()
					end
					if v.Callback then
						if v.Parallel then
							task.desynchronize(); v.Callback(table.unpack(args))
						else
							v.Callback(table.unpack(args))
						end
						rawset(self, "FireCount", self.FireCount+1)
						v.FireCount+=1
					else
						rawset(self.Connections, i, nil)
					end
				end
			end
		end)
	end,
	Connect = function(self : types.Event, callback : (any) -> (), name : string?, fire_limit : number?) : types.Connection?
		name = name or tostring(os.clock())
		if name then 
			local connection : types.Connection = {
				Callback = callback,
				Disconnect = function(self : types.Connection)
					self.Callback = nil
				end,
				Name = name,
				Parallel = false,
				FireLimit = fire_limit,
				FireCount = 0
			}

			self.Connections[name] = connection
			return self.Connections[name]
		end
		return nil
	end,
	Destroy = function(self)
		self = nil
	end,
	Wait = function(self : types.Event, timeout : number?, dt : number?) : (any, number)
		local dt, timeout = dt or DEFAULT_DT, timeout or DEFAULT_TIMEOUT  
		local result, done, start_time = nil, false, os.clock()
		
		local connection : types.Connection = self:Connect(function(...)
			result = ...
			done = true
		end, "__wait"..start_time, 1)
		
		while not done do
			if os.clock() - start_time >= timeout then
				break
			end
			task.wait(dt)
		end
		
		local end_time = os.clock()
		local yield_time = end_time - start_time
		
		return result, yield_time
	end,
	Connections = {},
	FireCount = 0
}

Event.__index = Event

Event.__newindex = function(t, k, v)
	error("Cannot add properties to an Event.")
end

---------------------------------------------------------------------------------------

local module = {
	new = function(name : string, key : any?, dir : any?, fire_limit : number?) : types.Event
		key = key or DEFAULT_KEY; dir = dir or DEFAULT_DIR
		
		local self = {Name = name, FireLimit = fire_limit}
		
		setmetatable(self, Event)
		
		if not events[key] then events[key] = {} end
		if not events[key][dir] then events[key][dir] = {} end
		
		events[key][dir][name] = self :: any
		
		return self :: any
	end,
	GetEvent = function(name : string, key : any?, dir : any?) : types.Event?
		if events[key] then
			if events[key][dir] then
				return events[key][dir][name]
			end
		end
		return nil
	end
}

---------------------------------------------------------------------------------------

function main()
	events[DEFAULT_KEY] = {}
	events[DEFAULT_KEY][DEFAULT_DIR] = {} 
end

main()

---------------------------------------------------------------------------------------

return module
