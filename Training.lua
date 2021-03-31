local training = {
}

function training:PostRun()
	gamemode.AddGameRule("AllowDeadChat")
	gamemode.AddGameRule("AllowUnrestrictedVoice")
	gamemode.AddGameRule("SpectateFreeCam")
	gamemode.AddGameRule("SpectateEnemies")
end

return training
