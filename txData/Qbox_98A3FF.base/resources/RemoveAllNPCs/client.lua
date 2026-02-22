trafficDensity = 0
pedDensity = 0

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0) -- prevent crashing

		-- These natives have to be called every frame.
		SetVehicleDensityMultiplierThisFrame(trafficDensity) -- set traffic density to 0 
		SetPedDensityMultiplierThisFrame(pedDensity) -- set npc/ai peds density to 0
		SetRandomVehicleDensityMultiplierThisFrame(trafficDensity) -- set random vehicles (car scenarios / cars driving off from a parking spot etc.) to 0
		SetParkedVehicleDensityMultiplierThisFrame(trafficDensity) -- set random parked vehicles (parked car scenarios) to 0
		SetScenarioPedDensityMultiplierThisFrame(pedDensity, pedDensity) -- set random npc/ai peds or scenario peds to 0
		SetGarbageTrucks(true) -- Stop garbage trucks from randomly spawning
		SetRandomBoats(true) -- Stop random boats from spawning in the water.
		SetCreateRandomCops(true) -- disable random cops walking/driving around.
		SetCreateRandomCopsNotOnScenarios(true) -- stop random cops (not in a scenario) from spawning.
		SetCreateRandomCopsOnScenarios(true) -- stop random cops (in a scenario) from spawning.
		
		local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))
		ClearAreaOfVehicles(x, y, z, 1000, false, false, false, false, false)
		RemoveVehiclesFromGeneratorsInArea(x - 500.0, y - 500.0, z - 500.0, x + 500.0, y + 500.0, z + 500.0);
	end
end)