local MyGameMode = {
	OpForCount = 10,
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
	local triggers = gameplaystatics.GetAllActorsOfClassWithTag('GroundBranch.GBGameTrigger', "MyTrigger")
	actor.SetActive(triggers[1], true)
end

function MyGameMode:OnGameTriggerBeginOverlap(GameTrigger, Character)
	print(actor.__tostring(Character))
	print(actor.__tostring(GameTrigger))

	local triggers = gameplaystatics.GetAllActorsOfClassWithTag('GroundBranch.GBGameTrigger', "MyTrigger")
	if GameTrigger == triggers[1] then
		local AllSpawns = gameplaystatics.GetAllActorsOfClass('GroundBranch.GBAISpawnPoint')
		ai.CreateOverDuration(4.0, self.OpForCount, AllSpawns, self.OpForTeamTag)
	end
end

function MyGameMode:PlayerGameModeRequest(PlayerState, Request)
	if PlayerState ~= nil then
		if Request == "join"  then
			gamemode.EnterPlayArea(PlayerState)
		end
	end
end

return MyGameMode
