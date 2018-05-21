-- local x; x, _ = xpcall(require, function(msg) print(debug.traceback(msg)) end, "test_m")
local StateMachine = heartbeat.StateMachine
local State        = StateMachine.State
local Transition   = StateMachine.Transition

_a = false
_b = false
_c = false

local MyState = heartbeat.class("MyState", State)

function MyState:new(name)
	self:State(name)

	self
	:addTransition(Transition("a")
		:setCondition(function(self)
			return _a
		end)
	)
	:addTransition(Transition("b")
		:setCondition(function(self)
			return _b
		end)
	)
	:addTransition(Transition("c")
		:setCondition(function(self)
			return _c
		end)
	)
end

function MyState:update() print("Update>", self:getName()) end

function MyState:enter()
	print("Enter>", self:getName())

	_a = false
	_b = false
	_c = false
end

function MyState:exit() print("Exit>", self:getName()) end

return StateMachine()
	:addState(
		State("a")
		:setUpdate(function(self)
			print(self:getName())
		end)
		:setEntry(function(self)
			print("Enter", self:getName())
			_a = false
		end)
		:addTransition(Transition("b")
			:setCondition(function(self)
				return _b
			end)
		)
		:addTransition(Transition("c")
			:setCondition(function(self)
				return _c
			end)
		)
	)
	:addState(MyState("b"))
	:addState(MyState("c"))
	:setNextState("a")
