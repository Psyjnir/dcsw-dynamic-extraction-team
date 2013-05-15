local assetUnit  	= Unit.getByName('Downed Pilot')
local assetGroup	= Group.getByName('Downed Pilot')
local rescueUnit	= false
local rescueGroup	= false
local verifyGroup	= false

trigger.action.setUserFlag('15', false)
trigger.action.setUserFlag('5000', false)
trigger.action.setUserFlag('5001', false)
trigger.action.setUserFlag('5002', false)
trigger.action.setUserFlag('5003', false)

mist.flagFunc.units_in_zones {
	units 		= {'Pontiac 1-1', 'Pontiac 1-2', 'Chevy 1-1', 'Chevy 2-1', 'Chevy 3-1', 'Chevy 4-1'},
	zones 		= {'RescueBegins'},
	flag		= 5000,
	stopflag	= 15
}

mist.flagFunc.units_in_moving_zones {
	units		= {'Delta', 'Echo'},
	zone_units	= {'Downed Pilot'},
	radius		= 10,
	flag		= 5001,
	stopflag	= 15
}

mist.flagFunc.units_in_moving_zones {
	units		= {'Downed Pilot', 'Delta', 'Echo'},
	zone_units	= {'Pontiac 1-1', 'Pontiac 1-2', 'Chevy 1-1', 'Chevy 2-1', 'Chevy 3-1', 'Chevy 4-1'},
	zone_type	= 'sphere',
	radius		= 20,
	flag		= 5002,
	req_num		= 2,
	stopflag	= 15
}

function generateVerifyGroupData(assetUnit, rescueUnit)
	local assetUnitPosition		= assetUnit:getPosition().p
	local rescueUnitPosition	= rescueUnit:getPosition().p
	
	local rescueUnitHeading		= mist.getHeading(rescueUnit)
	local verifySpawnDistance	= 20
	
	local verifyGroupX			= rescueUnitPosition.x + verifySpawnDistance * math.cos(rescueUnitHeading + math.pi / 2)
	local verifyGroupY			= rescueUnitPosition.z + verifySpawnDistance * math.sin(rescueUnitHeading + math.pi / 2)
	local verifyGroupLeftX		= rescueUnitPosition.x + verifySpawnDistance * math.cos(rescueUnitHeading + (math.pi * 3) / 2)
	local verifyGroupLeftY		= rescueUnitPosition.z + verifySpawnDistance * math.sin(rescueUnitHeading + (math.pi * 3) / 2)
	local leftDistance			= math.sqrt((verifyGroupLeftX - assetUnitPosition.x) ^ 2 + (verifyGroupLeftY - assetUnitPosition.z) ^ 2)
	local rightDistance			= math.sqrt((verifyGroupX - assetUnitPosition.x) ^ 2 + (verifyGroupY - assetUnitPosition.z) ^ 2)
	
	if rightDistance >= leftDistance then
		verifyGroupX = verifyGroupLeftX
		verifyGroupY = verifyGroupLeftY
	end
	
	local verifyGroupData = {
		["name"] = "VerificationGroup",
		["taskSelected"] = true,
		["hidden"] = false,
		["groupId"] = math.random(1111111,9999999),
		["visible"] = false,
		["units"] = 
		{
			[1] = 
			{
				["y"] = verifyGroupY,
				["type"] = "Soldier M4",
				["name"] = "Delta",
				["unitId"] = math.random(1111111,9999999),
				["heading"] = rescueUnitHeading,
				["playerCanDrive"] = true,
				["skill"] = "Average",
				["x"] = verifyGroupX,
			}, -- end of [1]
			[2] = 
			{
				["y"] = verifyGroupY - 1,
				["type"] = "Soldier M4",
				["name"] = "Echo",
				["unitId"] = math.random(1111111,9999999),
				["heading"] = rescueUnitHeading,
				["playerCanDrive"] = true,
				["skill"] = "Average",
				["x"] = verifyGroupX - 1,
			}, -- end of [2]
		},
		["y"] = verifyGroupY,
		["x"] = verifyGroupX,
		["start_time"] = 0,
		["task"] = "Ground Nothing",
	}
	
	return verifyGroupData
end

function generateWaypoints(assetUnit, rescueUnit, waypointType)
	local waypoints = {}
	local assetPos	= assetUnit:getPosition().p
	local rescuePos	= rescueUnit:getPosition().p
	local verifyPos = Unit.getByName("Delta"):getPosition().p

	local assetPoint = {
		["type"] = "Flyover Point",
		["ETA"] = 0,
		["y"] = assetPos.z - 6,
		["x"] = assetPos.x,
		["ETA_locked"] = true,
		["speed"] = 15,
		["speed_locked"] = true,
	}

	local rescuePoint = {
		["type"] = "Flyover Point",
		["ETA"] = 0,
		["y"] = rescuePos.z,
		["x"] = rescuePos.x,
		["ETA_locked"] = true,
		["speed"] = 15,
		["speed_locked"] = true,
	}
	
	local verifyPoint = {
		["type"] = "Flyover Point",
		["ETA"] = 0,
		["y"] = verifyPos.z,
		["x"] = verifyPos.x,
		["ETA_locked"] = true,
		["speed"] = 15,
		["speed_locked"] = true,
	}
	
	if waypointType == 'ingress' then
		waypoints[#waypoints+1] = mist.ground.buildWP(verifyPoint, 'Off Road', 20)
		waypoints[#waypoints+1] = mist.ground.buildWP(assetPoint, 'Diamond', 20)
	elseif waypointType == 'egress' then
		waypoints[#waypoints+1] = mist.ground.buildWP(assetPoint, 'Off Road', 20)
		waypoints[#waypoints+1] = mist.ground.buildWP(rescuePoint, 'Diamond', 20)
	elseif waypointType == 'stopPush' then
		waypoints[#waypoints+1] = mist.ground.buildWP(verifyPoint, 'Off Road', 20)
		waypoints[#waypoints+1] = mist.ground.buildWP(assetPoint, 'Diamond', 20)
	end
	
	return waypoints
end

function getRescueUnit(rescueUnit)
	if (trigger.misc.getUserFlag('5000') == 1 and not rescueUnit) or (rescueUnit and rescueUnit:inAir()) then
		if Unit.getByName('Pontiac 1-1') and not Unit.getByName('Pontiac 1-1'):inAir() and next(mist.getUnitsInZones({'Pontiac 1-1'}, {'RescueBegins'})) then
			rescueUnit = Unit.getByName('Pontiac 1-1')
		elseif Unit.getByName('Pontiac 1-2') and not Unit.getByName('Pontiac 1-2'):inAir() and next(mist.getUnitsInZones({'Pontiac 1-2'}, {'RescueBegins'})) then
			rescueUnit = Unit.getByName('Pontiac 1-2')
		elseif Unit.getByName('Chevy 1-1') and not Unit.getByName('Chevy 1-1'):inAir() and next(mist.getUnitsInZones({'Chevy 1-1'}, {'RescueBegins'})) then
			rescueUnit = Unit.getByName('Chevy 1-1')
		elseif Unit.getByName('Chevy 2-1') and not Unit.getByName('Chevy 2-1'):inAir() and next(mist.getUnitsInZones({'Chevy 2-1'}, {'RescueBegins'})) then
			rescueUnit = Unit.getByName('Chevy 2-1')
		elseif Unit.getByName('Chevy 3-1') and not Unit.getByName('Chevy 3-1'):inAir() and next(mist.getUnitsInZones({'Chevy 3-1'}, {'RescueBegins'})) then
			rescueUnit = Unit.getByName('Chevy 3-1')
		elseif Unit.getByName('Chevy 4-1') and not Unit.getByName('Chevy 4-1'):inAir() and next(mist.getUnitsInZones({'Chevy 4-1'}, {'RescueBegins'})) then
			rescueUnit = Unit.getByName('Chevy 4-1')
		else
			rescueUnit = false
		end
	end
	
	return rescueUnit
end

function spawnVerifyGroup(assetUnit, rescueUnit)
	local verifyGroupData	= generateVerifyGroupData(assetUnit, rescueUnit)
	local verifyGroup		= coalition.addGroup(country.id.USA, Group.Category.GROUND, verifyGroupData)
	
	return verifyGroup
end

function main(assetUnit, assetGroup, rescueUnit, verifyGroup, verifyStarted, verifyDone, pushingToEgress)
	local egress			= nil
	local ingress			= nil
	local stopPush			= nil
	local verifyTime		= 600	-- time in seconds (ten minutes)

	if next(mist.getUnitsInZones({'Pontiac 1-1', 'Pontiac 1-2', 'Chevy 1-1', 'Chevy 2-1', 'Chevy 3-1', 'Chevy 4-1'}, {'RescueBegins'})) ==  nil then
		trigger.action.setUserFlag('5000', 0)
	end

	if trigger.misc.getUserFlag('5001') == 1 and verifyStarted == false then
		mist.scheduleFunction(trigger.action.setUserFlag, {'5003', true}, timer.getTime() + verifyTime) -- Verify Complete Flag
		trigger.action.outText("This is Delta squad. We have made contact with the asset. Give us close air support for ten minutes while we verify his identity.", 40)
		trigger.action.outSound('DeltaSupportRequest.ogg')
		
		verifyStarted = true
	end
	
	rescueUnit = getRescueUnit(rescueUnit)

	if rescueUnit then
		rescueUnitVelocity = rescueUnit:getVelocity()
		
		if verifyGroup then
			egress	= generateWaypoints(assetUnit, rescueUnit, 'egress')

			if trigger.misc.getUserFlag('5001') == 1 and trigger.misc.getUserFlag('5002') == 1 and trigger.misc.getUserFlag('5003') == 1 then
				trigger.action.outText("This is Delta squad. We're on board with the asset and ready for dust off.", 40)
				trigger.action.outSound('ExtractComplete.ogg')
				trigger.action.setUserFlag('500', false)
				trigger.action.setUserFlag('15', true)
				verifyGroup:destroy()
				assetGroup:destroy()
			elseif trigger.misc.getUserFlag('5001') == 1 and trigger.misc.getUserFlag('5003') == 1 and not pushingToEgress then
				if rescueUnitVelocity.x < 1 and rescueUnitVelocity.y < 1 and rescueUnitVelocity.z < 1 then
					pushingToEgress = true
					mist.goRoute(verifyGroup, egress)
					mist.scheduleFunction(mist.goRoute, {assetGroup, egress}, timer.getTime() + 5)
					if not verifyDone then
						verifyDone = true
						trigger.action.outText("This is Delta squad. We have verified the identity of the asset. We are pushing to extraction.", 40)
						trigger.action.outSound('StartPushToExtraction.ogg')
					else
						trigger.action.outText("This is Delta squad. We are pushing to extraction.", 40)
						trigger.action.outSound('ResumePushToExtraction.ogg')
					end
				end
			end
		else
			if rescueUnitVelocity.x < 1 and rescueUnitVelocity.y < 1 and rescueUnitVelocity.z < 1 then
				verifyGroup	= spawnVerifyGroup(assetUnit, rescueUnit)
			
				ingress		= generateWaypoints(assetUnit, rescueUnit, 'ingress')
				trigger.action.outText("This is Delta squad. We have boots on the ground and we're pushing towards the asset.", 40)
				trigger.action.outSound('StartPushToAsset.ogg')
				
				mist.goRoute(verifyGroup, ingress)
			end
		end
	elseif verifyGroup then
		trigger.action.setUserFlag('5002', false)
		
		if pushingToEgress then
			stopPush	= generateWaypoints(assetUnit, assetUnit, 'stopPush')
		
			trigger.action.outText("This is Delta squad. Um - we're not on board yet. Return to the extraction zone for dust off.", 40)
			trigger.action.outSound('StopPushToExtraction.ogg')
			mist.goRoute(verifyGroup, stopPush)
			mist.goRoute(assetGroup, stopPush)
			pushingToEgress = false
		end
		
		if trigger.misc.getUserFlag('5001') == 1 and trigger.misc.getUserFlag('5003') == 1 and not verifyDone then
			trigger.action.outText("This is Delta squad. We have verified the identity of the asset. Return to the extraction zone for dust off.", 40)
			trigger.action.outSound('AssetVerificationComplete.ogg')
			verifyDone = true
		end
	end
	
	if trigger.misc.getUserFlag('15') == 0 and trigger.misc.getUserFlag('999') == 0 then
		mist.scheduleFunction(main, {assetUnit, assetGroup, rescueUnit, verifyGroup, verifyStarted, verifyDone, pushingToEgress}, timer.getTime() + 1)
	end
end

main(assetUnit, assetGroup, rescueUnit, verifyGroup, false, false, false)
