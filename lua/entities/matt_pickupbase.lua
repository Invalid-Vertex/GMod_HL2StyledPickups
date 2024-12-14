AddCSLuaFile()
ENT.Type = "anim"
DEFINE_BASECLASS("base_anim")
ENT.Author = "InvalidVertex [STEAM_0:1:50043461]"
ENT.Contact = "https://steamcommunity.com/id/invalidvertex/"
ENT.Category = "InvalidVertex's Ents"
ENT.PrintName = "InvalidVertex's Pickup Base"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.DisableDuplicator = true

--Pickup specific
ENT.PickupType = "other" --"health", "ammo" or "other"
ENT.PickupSound = "items/suitchargeno1.wav" --Allow for custom pickup sounds
ENT.HealthAmount = 0 --The percentage of the players health to heal (0.0 - 1.0)
ENT.ArmorAmount = 0 --The amount of armor to give
ENT.AmmoAmount = 0 --How many clips to give
ENT.Model = "models/props_junk/PopCan01a.mdl"
ENT.ModelScale = 1.25 --How big the model should be, default is generally fine
ENT.RegenTime = 15 --How long it takes for the pickup to regenerate, 15 seconds is the time Team Fortress 2 uses
ENT.LocalPos = Vector(0,0,16) --This default is generally fine unless the model is a bit fucky
ENT.LocalAng = Angle(0,0,22.5) --This default is generally fine unless the model is a bit fucky
ENT.GlowLocalPos = Vector(0,0,0) --This default is generally fine unless the model is a bit fucky


if (SERVER) then
	function ENT:Initialize()
		self:SetModel(self.Model)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		self:SetModelScale(self.ModelScale,0)
		self:SetLocalAngles(self.LocalAng)
		self:SetPos(self:GetPos()+self.LocalPos)
		self:SetTrigger(true)
		self:Activate()
		self:AddEFlags(bit.bor(EFL_NO_PHYSCANNON_INTERACTION,EFL_NO_DISSOLVE,EFL_NO_DAMAGE_FORCES))
		HL2HealthAmmo_EasterEggHat(self)
		util.PrecacheSound(self.PickupSound)
	end

	function ENT:Think()
		self:SetLocalAngles(self:GetLocalAngles()+Angle(0,2,0)) --SPEEEEEN
		self:SetLocalPos(self:GetLocalPos()+Vector(0,0,math.sin(CurTime()*4)/6))
		for _,ent in pairs(self:GetChildren()) do
			ent:SetNoDraw(self:GetNoDraw())	--So the easter egg models hide when the main model does
		end
		self:NextThink(CurTime())
		return true
	end

	function ENT:StartTouch(client)
		if client:IsPlayer() then
			--Handle pickup types here
			if self.PickupType == "health" then
				if client:Health() < client:GetMaxHealth() then
					PickupTaken(self, self.PickupType)
					client:SetHealth(math.Clamp(client:Health()+client:GetMaxHealth()*self.HealthAmount,0,client:GetMaxHealth()))
					client:SetArmor(math.Clamp(client:Armor()+self.ArmorAmount,0,100))
				end
			elseif self.PickupType == "ammo" then
				if GetConVar("hl2_healthammo_activeweapononly"):GetInt() == 1 then
					if client:GetActiveWeapon():Clip1() > 0 then
						PickupTaken(self, self.PickupType)
						ResupplyAmmo(client, client:GetActiveWeapon(), self)
					end
				elseif GetConVar("hl2_healthammo_activeweapononly"):GetInt() == 0 then
					PickupTaken(self, self.PickupType)
					for _,weapon in pairs(client:GetWeapons()) do
						ResupplyAmmo(client, weapon, self)
					end
				end
			elseif self.PickupType == "other" then
				PickupTaken(self, self.PickupType)
				--Possibly handle other pickup types?
			end
		end
	end

	function ResupplyAmmo(client, weapon, pickup)
		local ammotype_primary = weapon:GetPrimaryAmmoType()
		local ammotype_secondary = weapon:GetSecondaryAmmoType()

		--Handle primary ammo resupply
		if ammotype_primary != -1 then
			if weapon:GetMaxClip1() <= 1 && client:GetAmmoCount(ammotype_primary) < game.GetAmmoMax(ammotype_primary) then
				client:GiveAmmo(pickup.AmmoAmount,ammotype_primary,true)
			elseif weapon:GetMaxClip1() > 1 && client:GetAmmoCount(ammotype_primary) < game.GetAmmoMax(ammotype_primary) then
				client:GiveAmmo(weapon:GetMaxClip1()*pickup.AmmoAmount,ammotype_primary,true)
			end
		end

		--Handle secondary ammo resupply
		if ammotype_secondary != -1 then
			if client:GetAmmoCount(ammotype_secondary) < game.GetAmmoMax(ammotype_secondary) then
				client:GiveAmmo(weapon:GetMaxClip2()*pickup.AmmoAmount,ammotype_secondary,true)
			end
		end	
	end

	function PickupTaken(pickup, type)
		if pickup:IsValid() then
			sound.Play(pickup.PickupSound, pickup:GetPos(),75,100,1)
			pickup:SetTrigger(false)
			pickup:SetNoDraw(true)
			timer.Simple(pickup.RegenTime,function() Regenerate(pickup) end)
			HL2HealthAmmo_EasterEgg(pickup)
		end
	end
	
	function Regenerate(pickup)
		if pickup:IsValid() then
			pickup:SetTrigger(true)
			pickup:SetNoDraw(false)
			sound.Play("items/suitchargeok1.wav",pickup:GetPos(),75,100,1)
		end
	end
end

if (CLIENT) then
	function ENT:Draw()
		self:DrawModel()
	end
	
	function ENT:Think()
		if GetConVar("developer"):GetString() == "-1" then
			local dbg_lifetime = 0
			debugoverlay.EntityTextAtPosition(self:GetPos(), -2, "Dormant: "..tostring(self:IsDormant()), dbg_lifetime, false)
			debugoverlay.EntityTextAtPosition(self:GetPos(), -1, "Pickup Type: "..self.PickupType, dbg_lifetime, false)
			debugoverlay.EntityTextAtPosition(self:GetPos(), 0, "HealthAmount: "..self.HealthAmount.."\t(Health we'll recieve: "..LocalPlayer():GetMaxHealth()*self.HealthAmount..")", dbg_lifetime, false)
			debugoverlay.EntityTextAtPosition(self:GetPos(), 1, "ArmorAmount: "..self.ArmorAmount, dbg_lifetime, false)
			debugoverlay.EntityTextAtPosition(self:GetPos(), 2, "AmmoAmount (How many clips to give): "..self.AmmoAmount, dbg_lifetime, false)
			debugoverlay.Box(self:GetPos(), self:OBBMins(), self:OBBMaxs(), dbg_lifetime, Color(192,192,192))
		end
		if self:IsDormant() == false then
			--Only display the glow for health pickups
			if self.PickupType == "health" then
				local item_glow = DynamicLight(self:EntIndex(), false)
				if item_glow && !self:GetNoDraw() then
					item_glow.Pos = self:GetPos()+self.GlowLocalPos
					item_glow.R = 75
					item_glow.G = 225
					item_glow.B = 75
					item_glow.Brightness = 4
					item_glow.Decay = 2048
					item_glow.Size = 64
					item_glow.Style = 5
					item_glow.DieTime = CurTime()+1
				end
			end
		end
	end
end
