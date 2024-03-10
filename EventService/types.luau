--!strict

export type Connection = {
	Callback : ((any) -> ()) | nil,
	Disconnect : (any) -> (),

	Parallel : boolean,
	Key : any,

	FireLimit : number?,
	FireCount : number
}

export type ConnectFunction = (self : Event, callback : (any) -> (), name : string?, fire_limit : number?) -> Connection

export type Event = {
	Fire : (self : Event, (any)) -> (),

	Connect : (self : Event, callback : (any) -> (), name : string?, fire_limit : number?) -> Connection,
	ConnectParallel : (self : Event, callback : (any) -> (), name : string?, fire_limit : number?) -> Connection,

	Connections : {[string] : Connection | nil},

	Destroy : (self : Event) -> (),
	Wait : (self : Event) -> (),

	FireCount : number,
	Name : string
}

return nil
