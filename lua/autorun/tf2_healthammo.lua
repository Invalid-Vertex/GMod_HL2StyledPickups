AddCSLuaFile()
game.AddParticles("particles/easteregg_snow.pcf")
PrecacheParticleSystem("snowburst")
local storagedir = "hl2pickups_custom"

if (SERVER) then
	local config_example = "healthkit,small,760,-1060,-140\nammopack,small,760,-1110,-145\nhealthkit,full,535,4255,-10\nammopack,full,535,4355,-22\nhealthkit,medium,-4900,5275,-90\nammopack,medium,-4900,5325,-90\n"
	CreateConVar("hl2_healthammo_secret","1",FCVAR_ARCHIVE,"Enable \"Holiday Cheer\" during December")
	CreateConVar("hl2_healthammo_activeweapononly","0",FCVAR_ARCHIVE,"Enable ammo resupply for current weapon only, good for Deathmatch-style gamemodes")

	local function NoPhysgunPickup(client,entity)
		if baseclass.Get(entity:GetClass())["Base"] == "matt_pickupbase" then
			return false
		end
	end
	hook.Add("PhysgunPickup","DisablePhysgunPickup",NoPhysgunPickup)

	local function HL2HealthAmmo_Spawn()
		if not file.Exists(storagedir,"DATA") then
			file.CreateDir(storagedir)
		end
		config_file = file.Read(storagedir.."/"..game.GetMap()..".dat","DATA")
		if not config_file then MsgN("[HL2HealthAmmo] ERROR! Map specific config file not found!\n") return end
		config_file = string.Split(config_file,"\n")
		for _,line in ipairs(config_file) do
			local key = string.Split(line, ",")
			if (#key <= 1) or string.StartWith(line, "//") then continue end
			if (#key < 5) then MsgN("[HL2HealthAmmo] ERROR! Malformed entry: "..line.."\n") continue end
			if (#key == 5) then
				--New parser key: 1 = Type, 2 = Size, 3 = X, 4 = Y, 5 = Z
				local pickup = ents.Create(string.format("item_"..key[1].."_"..key[2]))
				pickup:SetPos(Vector(key[3],key[4],key[5]))
				pickup:Spawn()
			end
		end
	end
	hook.Add("PostCleanupMap","PostCleanupMap",function() HL2HealthAmmo_Spawn() end)
	
	local function HL2HealthAmmo_Init()
		if !file.Exists(storagedir.."/".."gm_construct"..".dat", "DATA") then
			file.Write(storagedir.."/".."gm_construct"..".dat", "//Format is: Type,Size,X,Y,Z\n//Valid types are 'healthkit' and 'ammopack', valid sizes are 'small, medium', and 'full'\n//Example below:\n"..config_example)
		end
		timer.Simple(1,function() HL2HealthAmmo_Spawn() end)
	end
	hook.Add("Initialize","HL2HealthAmmo_Init",HL2HealthAmmo_Init)





	--Super secret holiday easter egg
	function HL2HealthAmmo_EasterEgg(entity)
		if GetConVar("hl2_healthammo_secret"):GetInt() > 0 and os.date("%m") == "12" then
			ParticleEffect("snowburst",entity:GetPos(),Angle(0,0,0))
			sound.Play(string.format("jingles/jingle_0"..math.random(1,4)..".mp3"),entity:GetPos(),75,math.random(90,110),0.75)
		end
	end

	function HL2HealthAmmo_EasterEggHat(entity)
		if GetConVar("hl2_healthammo_secret"):GetInt() > 0 and os.date("%m") == "12" then
			local eastereggprop = ents.Create("prop_dynamic")
			if	string.find(entity:GetClass(),"healthkit") then	
				eastereggprop:SetModel("models/easteregg/santahat.mdl")
				eastereggprop:SetParent(entity)
				eastereggprop:DrawShadow(false)
				eastereggprop:SetSolid(SOLID_NONE)
				eastereggprop:Spawn()
				if string.find(entity:GetClass(),"small") then
					eastereggprop:SetPos(Vector(-1.5,0,10))
					eastereggprop:SetAngles(entity:GetAngles())
					eastereggprop:SetModelScale(0.80)
				elseif string.find(entity:GetClass(),"medium") then
					eastereggprop:SetPos(Vector(2.5,0,1.35))
					eastereggprop:SetAngles(entity:GetAngles()-Angle(90,0,0))
					eastereggprop:SetModelScale(1.25)
				elseif string.find(entity:GetClass(),"full") then
					eastereggprop:SetPos(Vector(-2,-5,12))
					eastereggprop:SetModelScale(1.35)
					eastereggprop:SetAngles(entity:GetAngles()-Angle(0,-35,-25))
				end
			elseif	string.find(entity:GetClass(),"ammopack") then
				eastereggprop:Remove()
				--Unused for now
				--Note to self:
				--Maybe use santa beard or reindeer horns for ammopacks?
			end
		end
	end
end
