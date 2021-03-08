local MyGameMode = {
	OpForCount = 15,
	OpForTeamId = 100,
	OpForTeamTag = "OpFor",
}

MyGameMode.__index = MyGameMode

function MyGameMode:new()
	local self = {}
	setmetatable(self, MyGameMode)
	return self
end

function MyGameMode:PostRun()
	local AllSpawns = gameplaystatics.GetAllActorsOfClass('GroundBranch.GBAISpawnPoint')

	ai.CreateAIOverDuration(4.0, self.OpForCount, AllSpawns, self.OpForTeamTag)
end

function MyGameMode:PlayerGameModeRequest(PlayerState, Request)
	if PlayerState ~= nil then
		if Command == "join"  then
			EnterPlayArea(PlayerState)
		end
	end
end

return MyGameMode
