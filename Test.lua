-- VIP
-- 1. Team Blue needs to get VIP to their extraction
-- 2. Team Red needs to kill the VIP and get to their extraction
-- Blue wins if VIP gets to extraction zone (optional team_extraction "on")
-- Red wins if VIP dies and at least one team member gets to his extraction (optional team_extraction "on")
-- It's a tie if VIP dies but team Red is wiped out

local MyGameMode = {
	OpForCount = 15,
	OpForTeamId = 100,
	OpForTeamTag = "OpFor",
	OpForLeaderTag = "OpForBoss",
	OpForLeaderEliminated = false,
	BluForExtractionPointTag = "BluForEP",
	ExtractionPoints = {},
	ExtractionPointMarkers = {},
	ExtractionPoint = nil,
	ExtractionPointIndex = 1,
	TeamExfil = false,
}

MyGameMode.__index = MyGameMode

function MyGameMode:new()
	local self = {}
	setmetatable(self, MyGameMode)
	return self
end

function MyGameMode:PostRun()
	-- local AllSpawns = gameplaystatics.GetAllActorsOfClass(
	-- 	'GroundBranch.GBAISpawnPoint')

	-- ai.CreateOverDuration(4.0, self.OpForCount, AllSpawns, self.OpForTeamTag)
	
	self.ExtractionPoints = gameplaystatics.GetAllActorsOfClass(
		'/Game/GroundBranch/Props/GameMode/BP_ExtractionPoint.BP_ExtractionPoint_C')
	for i = 1, #self.ExtractionPoints do
		local Location = actor.GetLocation(self.ExtractionPoints[i])
		self.ExtractionPointMarkers[i] = gamemode.AddObjectiveMarker(Location, self.BluForTeamId, "ExtractionPoint", false)
	end

	self.ExtractionPointIndex = umath.random(#self.ExtractionPoints)

	for i = 1, #self.ExtractionPoints do
		local bActive = (i == self.ExtractionPointIndex)
		actor.SetActive(self.ExtractionPoints[i], bActive)
		actor.SetActive(self.ExtractionPointMarkers[i], bActive)
	end
	-- actor.SetActive(self.BluForExtractionPointTag, true)

	-- self.ExtractionPoints = gameplaystatics.GetAllActorsOfClassWithTag(
	-- 	'GroundBranch.GBGameTrigger',
	-- 	self.BluForExtracionPointTag)
		
	-- actor.SetActive(self.ExtractionPoints[0], true)
end

function MyGameMode:PlayerGameModeRequest(PlayerState, Request)
	if PlayerState ~= nil then
		if Command == "join"  then
			EnterPlayArea(PlayerState)
		end
	end
end

function MyGameMode:OnCharacterDied(Character, CharacterController, KillerController)
	if gamemode.GetRoundStage() == "PreRoundWait" or gamemode.GetRoundStage() == "InProgress" then
		if CharacterController ~= nil then
			if actor.HasTag(CharacterController, self.OpForLeaderTag) then
				self.OpForLeaderEliminated = true
			elseif actor.HasTag(CharacterController, self.OpForTeamTag) then
				timer.Set(self, "CheckOpForCountTimer", 1.0, false);
			else
				player.SetLives(CharacterController, player.GetLives(CharacterController) - 1)
				timer.Set(self, "CheckBluForCountTimer", 1.0, false);
			end
		end
	end
end

function MyGameMode:OnGameTriggerBeginOverlap(GameTrigger, Character)
	local AllSpawns = gameplaystatics.GetAllActorsOfClass(
		'GroundBranch.GBAISpawnPoint')

	ai.CreateOverDuration(4.0, self.OpForCount, AllSpawns, self.OpForTeamTag)
	
	GS.GetAllActorsOfClass('GroundBranch.GBAISpawnPoint')

	-- if self.OpForLeaderEliminated == true then
	-- 	actor.SetActive(self.BluForExtractionPointTag, true)
	-- end
	-- if self.TeamExfil then
	-- 	timer.Set(self, "CheckOpForExfilTimer", 1.0, true)
	-- else
	-- 	gamemode.AddGameStat("Result=Team1")
	-- 	gamemode.AddGameStat("Summary=IntelRetrieved")
	-- 	gamemode.AddGameStat("CompleteObjectives=RetrieveIntel,ExfiltrateBluFor")
	-- 	gamemode.SetRoundStage("PostRoundWait")
	-- end
end

function MyGameMode:CheckBluForCountTimer()
	local BluForPlayers = gamemode.GetSortedPlayerList("Lives", self.BluForTeamId, true, 1, false)
	if #BluForPlayers == 0 then
		gamemode.AddGameStat("Result=None")
		gamemode.AddGameStat("Summary=BluForEliminated")
		gamemode.SetRoundStage("PostRoundWait")
	end
end

function MyGameMode:CheckOpForExfilTimer()
	local Overlaps = actor.GetOverlaps(self.ExtractionPoints[self.ExtractionPointIndex], 'GroundBranch.GBCharacter')
	local LivingPlayers = gamemode.GetSortedPlayerList("Lives", self.BluForTeamId, true, 1, false)
	
	local bExfiltrated = false
	local bLivingOverlap = false

	for i = 1, #LivingPlayers do
		local LivingCharacter = player.GetCharacter(LivingPlayers[i])

		bExfiltrated = false

		for j = 1, #Overlaps do
			if Overlaps[j] == LivingCharacter then
				GS.GetAllActorsOfClass('GroundBranch.GBAISpawnPoint')
				bLivingOverlap = true
				bExfiltrated = true
				break
			end
		end

		if bExfiltrated == false then
			break
		end
	end
	
	if bExfiltrated then
		timer.Clear(self, "CheckOpForExfilTimer")
		gamemode.AddGameStat("Result=Team1")
		gamemode.AddGameStat("Summary=IntelRetrieved")
		gamemode.AddGameStat("CompleteObjectives=RetrieveIntel,ExfiltrateBluFor")
		gamemode.SetRoundStage("PostRoundWait")
	end
end

return MyGameMode
