require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local Delegate = require("Utils.Delegate")
local NPCModuleEnum = require("NewRoco.Modules.Core.NPC.NPCModuleEnum")
local WeatherType = Enum.WeatherType
local SkillDamType = Enum.SkillDamType
local MoaiSkillDir = "/Game/ArtRes/Effects/G6Skill/QiYuQi"
local InteractSkillDir = "/Game/ArtRes/Effects/G6Skill/Xibiejiaohu"
local BP_NPCRainMoai_C = Base:Extend("BP_NPCRainMoai_C")

function BP_NPCRainMoai_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
  self:ResetInteractParam()
  self.interactFinishDelegate = Delegate()
  self.weather = WeatherType.WT_NONE
  self.oldWeather = WeatherType.WT_NONE
  self.cupEffect = nil
end

function BP_NPCRainMoai_C:OnVisible()
  Base.OnVisible(self)
  if not self.sceneCharacter then
    return
  end
  self:RefreshByServerData(true)
end

function BP_NPCRainMoai_C:OnInVisible()
  self:UpdateCupEffect()
  self.RocoSkill:StopCurrentSkill()
  Base.OnInVisible(self)
end

function BP_NPCRainMoai_C:PlaySkillImmediately()
  local skillName = NPCModuleEnum.RainMoaiSkillMap[self.weather]
  if string.IsNilOrEmpty(skillName) then
    return
  end
  local skillPath = string.format("%s/%s", MoaiSkillDir, skillName)
  self:PlaySkill(skillPath, self, self, nil, self.OnMainSkillEnd)
end

function BP_NPCRainMoai_C:OnWeatherChange()
  local weather = self:GetWeather()
  Log.Warning("BP_NPCRainMoai_C:OnWeatherChange", table.getKeyName(WeatherType, self.weather))
  if self.weather == weather then
    return
  end
  self.RocoSkill:StopCurrentSkill()
  self.oldWeather = self.weather
  self.weather = weather
  if self.interactPet then
    if self.interactPet.viewObj then
      self:PlaySkillByInteract()
    else
      self:OnInteractSkillEnd()
      self:PlaySkillByNature()
    end
  else
    self:PlaySkillByNature()
  end
end

function BP_NPCRainMoai_C:PlaySkillByNature()
  local skillName = NPCModuleEnum.RainMoaiSkillMap[self.weather]
  if skillName then
    self:UpdateCupEffect()
    self:PlaySkillImmediately()
    return
  end
  local oldSkillName = NPCModuleEnum.RainMoaiSkillMap[self.oldWeather]
  if oldSkillName and not skillName then
    local function registerEvent(skill)
      skill:RegisterEventCallback("OnCupEffectCreate", self, self.OnCupEffectCreate)
    end
    
    local skillPath = string.format("%s/%s_End", MoaiSkillDir, oldSkillName)
    self:PlaySkill(skillPath, self, self, registerEvent)
  end
end

function BP_NPCRainMoai_C:OnCupEffectCreate(Name, Skill)
  self:UpdateCupEffect()
end

function BP_NPCRainMoai_C:PlaySkillByInteract()
  if self.weather == WeatherType.WT_LIGHTRAIN or self.weather == WeatherType.WT_HEAVYRAIN or self.weather == WeatherType.WT_FOGGY then
    local skillName = NPCModuleEnum.RainMoaiSkillMap[self.weather]
    local skillPath = string.format("%s/%s_Start", MoaiSkillDir, skillName)
    
    local function registerEvent(skill)
      skill:RegisterEventCallback("PetSkillEnd", self, self.OnPetSkillEnd)
    end
    
    self.interactPet.viewObj:PlaySkill(skillPath, self.interactPet.viewObj, self, registerEvent)
  else
    self.interactPet.viewObj:PlayCommonPetInteractionSkill(self.interactType, self, self.OnPetSkillEnd)
  end
end

function BP_NPCRainMoai_C:OnPetSkillEnd(Name, Skill)
  if not (UE.UObject.IsValid(self) and self.RocoSkill) or not UE.UObject.IsValid(self.RocoSkill) then
    Log.Error("\231\178\190\231\129\181\232\161\168\230\188\148\231\187\147\230\157\159\229\155\158\230\157\165\231\165\136\233\155\168\229\153\168\229\157\143\228\186\134\239\188\140\228\184\173\230\150\173\229\144\142\229\141\138\231\168\139\232\161\168\230\188\148\239\188\129")
    self:OnInteractSkillEnd()
    return
  end
  self:UpdateCupEffect()
  self.RocoSkill:StopCurrentSkill()
  local skillName = NPCModuleEnum.RainMoaiSkillMap[self.weather]
  local skillPath = string.format("%s/%s", MoaiSkillDir, skillName)
  self:PlaySkill(skillPath, self, self, nil, self.OnMainSkillEnd, true)
  local skillPath01 = string.format("%s/%s01", InteractSkillDir, NPCModuleEnum.UnLockSkillPathMap[self.interactType])
  self:PlaySkill(skillPath01, self, nil, nil, self.OnInteractSkillEnd, true)
end

function BP_NPCRainMoai_C:OnInteractSkillEnd(Name, Skill)
  self.interactFinishDelegate:Invoke(self)
  self:ResetInteractParam()
end

function BP_NPCRainMoai_C:OnMainSkillEnd(Name, Skill)
  self:UpdateCupEffect(Skill)
end

function BP_NPCRainMoai_C:ResetInteractParam()
  self.interactPet = nil
  self.interactType = SkillDamType.SDT_NONE
end

function BP_NPCRainMoai_C:UpdateCupEffect(skill)
  if self.cupEffect then
    self.cupEffect:K2_DestroyActor()
    self.cupEffect = nil
  end
  if skill then
    local blackboard = skill:GetBlackboard()
    self.cupEffect = blackboard:GetValueAsObject("Actor001")
    blackboard:RemoveObjectValue("Actor001")
    if self.cupEffect then
      self.cupEffect:SetActorHiddenInGame(self.bHidden)
    end
  end
end

function BP_NPCRainMoai_C:IsCanInteract(interactType)
  if NPCModuleEnum.WeatherToSkillDamType[self.weather] then
    return NPCModuleEnum.WeatherToSkillDamType[self.weather] ~= interactType
  end
  return true
end

function BP_NPCRainMoai_C:SetVisibleInternal(flag)
  Base.SetVisibleInternal(self, flag)
  if self.cupEffect then
    self.cupEffect:SetActorHiddenInGame(not flag)
  end
end

function BP_NPCRainMoai_C:OnEnterBattle(center, radius, disSqr)
  Base.OnEnterBattle(self, center, radius, disSqr)
  if self.interactPet then
    _G.NRCModuleManager:DoCmd(_G.SceneModuleCmd.ConsumeCachedActorTag, self.sceneCharacter:GetServerId())
  end
end

function BP_NPCRainMoai_C:OnLeaveBattle()
  Base.OnLeaveBattle(self)
  if self.interactPet then
    _G.NRCModuleManager:DoCmd(_G.SceneModuleCmd.ConsumeCachedActorTag, self.sceneCharacter:GetServerId())
    self:OnInteractSkillEnd()
    self:PlaySkillImmediately()
  end
end

function BP_NPCRainMoai_C:GetWeather()
  local Character = self.sceneCharacter
  local ServerData = Character and Character.serverData
  local WeatherInfo = ServerData and ServerData.weather_info
  local WT = WeatherInfo and (WeatherInfo.weather_type or WeatherType.WT_NONE) or WeatherType.WT_NONE
  return WT
end

function BP_NPCRainMoai_C:RefreshByServerData(bForcePlaySkill)
  local realOldWeather = self.weather
  self.weather = self:GetWeather()
  if bForcePlaySkill then
    self:PlaySkillImmediately()
    return
  end
  if nil ~= realOldWeather and realOldWeather ~= self.weather then
    self:PlaySkillImmediately()
  end
end

function BP_NPCRainMoai_C:UpdateData(ServerData, bIsReconnect)
  Base.UpdateData(self, ServerData, bIsReconnect)
  self:RefreshByServerData(false)
end

return BP_NPCRainMoai_C
