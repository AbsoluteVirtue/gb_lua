-- VIP
-- 1. Team Blue needs to get VIP to their extraction
-- 2. Team Red needs to kill the VIP and get to their extraction
-- Blue wins if VIP gets to extraction zone (optional team_extraction "on")
-- Red wins if VIP dies and at least one team member gets to his extraction (optional team_extraction "on")
-- It's a tie if VIP dies but team Red is wiped out

-- TAS
-- 1. Team Blue has pre-determined insertion points to chose from, so Team Red doesn't know exactly where the enemy will be coming from
-- 2. Team Red has pre-determined defend ponts to chose from, their choice becomes the area Team Blue needs to capture
-- Blue wins if they hold the capture point while having a majority, or eliminating the entire enemy team
-- Red wins if round time expires before capture, or if the entire BLue team is dead (optional)
-- Match is round-based, each round roles are reversed
-- There's an optional VIP-based mode for small player numbers

local MyGameMode = {
	BluForTeamId = 1,
	BluForTeamTag = "BluFor",
	BluForLoadoutName = "NoTeam",
	OpForCount = 10,
	OpForTeamId = 100,
	OpForTeamTag = "OpFor",
	OpForLeaderTag = "OpForBoss",
	OpForLeaderId = 44,
	OpForLeaderEliminated = false,
	BluForExtractionPointTag = "ep_test",
	ExtractionPoints = {},
	ExtractionPointMarkers = {},
	ExtractionPoint = nil,
	ExtractionPointIndex = 1,
	TeamExfil = false,
}

MyGameMode.__index = MyGameMode

function
MyGameMode:new()
	print("-------------------------------------ctor")

	local self = {}
	setmetatable(self, MyGameMode)
	return self
end

function
MyGameMode:PrintTeamCount(TeamId)
	local BluForPlayers = gamemode.GetPlayerList("Lives", TeamId, true, 1, false)
	local Players = gamemode.GetPlayerCount(true)
	print("Init finished, team/players: " .. #BluForPlayers .. "/" .. Players)
end

function
MyGameMode:PostRun()
	print("-------------------------------------PostRun")

	local AllSpawns = gameplaystatics.GetAllActorsOfClass(
		'GroundBranch.GBAISpawnPoint')

	-- ai.CreateOverDuration(4.0, self.OpForCount, AllSpawns, self.OpForTeamTag)

	for i = 1, #AllSpawns do
		print(actor.GetTeamId(AllSpawns[i]))
		if self.OpForLeaderId == actor.GetTeamId(AllSpawns[i]) then
			ai.Create(AllSpawns[i], self.OpForLeaderTag, 5.0)
		else
			ai.Create(AllSpawns[i], self.OpForTeamTag, 5.0)
		end
	end

	-- local bossSpawns = ai.GetControllers(
	-- 	'GroundBranch.GBAISpawnPoint', self.OpForTeamTag, self.OpForTeamId, self.OpForLeaderId)
	-- for i = 1, #bossSpawns do
	-- 	print("-------------------------------------leader check")
	-- 	actor.AddTag(bossSpawns[i], self.OpForLeaderTag)
	-- end

	self.ExtractionPoints = gameplaystatics.GetAllActorsOfClass(
		'/Game/GroundBranch/Props/GameMode/BP_ExtractionPoint.BP_ExtractionPoint_C')
	for i = 1, #self.ExtractionPoints do
		local Location = actor.GetLocation(self.ExtractionPoints[i])
		self.ExtractionPointMarkers[i] = gamemode.AddObjectiveMarker(
			Location, self.BluForTeamId, "ExtractionPoint", false)
	end

	-- self.ExtractionPointIndex = umath.random(#self.ExtractionPoints)

	-- for i = 1, #self.ExtractionPoints do
	-- 	local bActive = (i == self.ExtractionPointIndex)
	-- 	actor.SetActive(self.ExtractionPoints[i], bActive)
	-- 	actor.SetActive(self.ExtractionPointMarkers[i], bActive)
	-- end

	-- local triggers = gameplaystatics.GetAllActorsOfClassWithTag(
	-- 	'GroundBranch.GBGameTrigger', self.BluForExtractionPointTag)
	-- for i = 1, #triggers do
	-- 	actor.SetActive(triggers[i], true)
	-- end

	gamemode.AddPlayerTeam(self.BluForTeamId, self.BluForTeamTag, self.BluForLoadoutName)

	local allPlayers = gameplaystatics.GetAllActorsOfClass('/Game/GBCore/Character/BP_Character.BP_Character_C')
	for i = 1, #allPlayers do
		print(getmetatable(allPlayers[i]))
		actor.SetTeamId(allPlayers[i], self.BluForTeamId)
		print(actor.GetTeamId(allPlayers[i]))
	end

	-- gamemode.AddGameRule("UseReadyRoom")
	-- gamemode.SetRoundStage("WaitingForReady")
end

function
MyGameMode:PlayerGameModeRequest(PlayerState, Request)
	print("-------------------------------------PlayerGameModeRequest")

	if PlayerState ~= nil then
		if Request == "join"  then
			gamemode.EnterPlayArea(PlayerState)
		end
	end
end

function
MyGameMode:OnCharacterDied(Character, CharacterController, KillerController)
	print("-------------------------------------OnCharacterDied")

	local tags = actor.GetTags(CharacterController)
	for i = 1, #tags do
		print(tags[i])
	end

	-- if gamemode.GetRoundStage() == "PreRoundWait" or gamemode.GetRoundStage() == "InProgress" then
		if CharacterController ~= nil then
			if actor.HasTag(CharacterController, self.OpForLeaderTag) then
				print("-------------------------------------OpForBoss check")
				self.OpForLeaderEliminated = true

				for i = 1, #self.ExtractionPoints do
					local bActive = (i == self.ExtractionPointIndex)
					actor.SetActive(self.ExtractionPoints[i], bActive)
					actor.SetActive(self.ExtractionPointMarkers[i], bActive)
				end
			elseif actor.HasTag(CharacterController, "OpFor") then
				print("-------------------------------------OpFor check")
				timer.Set(self, "CheckOpForCountTimer", 1.0, false);
			else
				player.SetLives(CharacterController, player.GetLives(CharacterController) - 1)
				timer.Set(self, "CheckBluForCountTimer", 1.0, false);
			end
		end
	-- end
end

function
MyGameMode:OnGameTriggerBeginOverlap(GameTrigger, Character)
	print("-------------------------------------OnGameTriggerBeginOverlap")

	print(actor.__tostring(GameTrigger))

	-- player.IsAlive(Player)
	
	-- print(os.time())

	if self.OpForLeaderEliminated == true then
		gamemode.AddGameStat("Result=Team1")
		gamemode.AddGameStat("Summary=IntelRetrieved")
		gamemode.AddGameStat("CompleteObjectives=RetrieveIntel,ExfiltrateBluFor")
		gamemode.SetRoundStage("PostRoundWait")
	end
	if self.TeamExfil then
		timer.Set(self, "CheckOpForExfilTimer", 1.0, true)
	else

	end
end

function
MyGameMode:CheckBluForCountTimer()
	print("-------------------------------------CheckBluForCountTimer")

	local BluForPlayers = gamemode.GetSortedPlayerList("Lives", self.BluForTeamId, true, 1, false)
	if #BluForPlayers == 0 then
		gamemode.AddGameStat("Result=None")
		gamemode.AddGameStat("Summary=BluForEliminated")
		gamemode.SetRoundStage("PostRoundWait")
	end
end

function
MyGameMode:CheckOpForExfilTimer()
	print("-------------------------------------CheckOpForExfilTimer")

	local Overlaps = actor.GetOverlaps(self.ExtractionPoints[self.ExtractionPointIndex], 'GroundBranch.GBCharacter')
	local LivingPlayers = gamemode.GetSortedPlayerList("Lives", self.BluForTeamId, true, 1, false)
	
	local bExfiltrated = false
	local bLivingOverlap = false

	for i = 1, #LivingPlayers do
		local LivingCharacter = player.GetCharacter(LivingPlayers[i])

		bExfiltrated = false

		for j = 1, #Overlaps do
			if Overlaps[j] == LivingCharacter then
				print('This is my message: ' .. os.time())
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
