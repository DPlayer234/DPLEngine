-- local x; x, _ = xpcall(require, function(msg) print(debug.traceback(msg)) end, "test_tree")
-- for i=1, 3 do _:continue() end
return heartbeat.BehaviorTree {
	type = "Selector",
	children = {
		{
			type = "Task",
			param = function(self)
				for i=1, 2 do
					self:yield(false)
				end

				local s = love.math.random() < 0.5
				print("Task 1", s)
				return s
			end
		},
		{
			type = "Sequence",
			children = {
				{
					type = "Task",
					param = function(self)
						local s = love.math.random() < 0.5
						print("Task 2.1", s)
						return s
					end
				},
				{
					type = "Parallel",
					children = {
						{
							type = "Task",
							param = function()
								print("YAY")
							end
						},
						{
							type = "Task",
							param = function()
								print("NAY")
							end
						}
					}
				}
			}
		}
	}
}
