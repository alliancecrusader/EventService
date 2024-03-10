--!strict

--[[
	Event Service
	A Luau module made to replicate Roblox's native script event and connection system.
]]--

---------------------------------------------------------------------------------------

local DEFAULT_KEY : any = "global"
local DEFAULT_DIR : any = "EventService"

local DEFAULT_TIMEOUT : number = 5
local DEFAULT_DT : number = 0.5

---------------------------------------------------------------------------------------

export type __function = () -> ()

export type Connection = {
	Disconnect : () -> (),
	Callback : __function,
	Key : any
}

export type Event = {
	Fire : (any) -> (),
	Connect : (callback : __function, name : string) -> Connection,
	Connections : {[string] : Connection},
	Destroy : (any) -> (),
	Wait : (any) -> ()
}

---------------------------------------------------------------------------------------

local events : {
	[any] : {
		[any] : {
			[string] : Event
		}
	}
} = {}

---------------------------------------------------------------------------------------

local Event = {
	__newindex = function(t, k, v)
		error("Cannot add properties to an event.")
	end,
	Fire = function(self, ...)
		for i, v in pairs(self.Connections)  do
			v["Callback"](...)
		end
	end,
	Connect = function(self, callback : (any) -> (), name : string) : Connection
		local connection : Connection = {
			Callback = callback,
			Disconnect = function()
				self.Connections[name] = nil
			end,
			Name = name
		}
		
		self.Connections[name] = connection
		return self.Connections[name]
	end,
	Destroy = function(self)
		self = nil
	end,
	Wait = function(self, timeout : number?, dt : number?) : (any, number)
		local dt, timeout = dt or DEFAULT_DT, timeout or DEFAULT_TIMEOUT  
		local result, done, start_time = nil, false, os.clock()
		
		local connection : Connection = self:Connect(function(...)
			result = ...
			done = true
		end, "__wait"..start_time)
		
		while not done do
			if os.clock() - start_time >= timeout then
				break
			end
			task.wait(dt)
		end
		
		connection.Disconnect()
		local end_time = os.clock()
		local yield_time = end_time - start_time
		
		return result, yield_time
	end,
	Connections = {}
}

Event.__index = Event

---------------------------------------------------------------------------------------

local module = {
	new = function(name : string, key : any?, dir : any?) : Event
		local self = {Name = name}
		
		setmetatable(self, Event)
		events[key or DEFAULT_KEY][dir or DEFAULT_DIR][name] = self :: any
		
		return self :: any
	end,
	GetEvent = function(name : string, key : any?, dir : any?) : Event?
		return events[key or DEFAULT_KEY][dir or DEFAULT_DIR][name]
	end
}

---------------------------------------------------------------------------------------

return module
