require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
local PetHUDComponent = require("NewRoco.Modules.Core.Scene.Component.HUD.PetHUDComponent")
local FarmModuleEvent = require("NewRoco.Modules.System.Farm.FarmModuleEvent")
local FarmModuleEnum = require("NewRoco.Modules.System.Farm.FarmModuleEnum")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local FarmUtils = require("NewRoco.Modules.System.Farm.FarmUtils")
local FarmConst = require("NewRoco.Modules.System.Farm.FarmConst")
local BP_Farm_Entrance_C = Base:Extend("BP_Farm_Entrance_C")

function BP_Farm_Entrance_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

function BP_Farm_Entrance_C:Init()
  Base.Init(self)
end

function BP_Farm_Entrance_C:OnFrameLoad(distanceRatio)
  local Character = self.sceneCharacter
  if not SceneUtils.debugCloseNPCFacialAndWidget and Character then
    local hud = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetHudFromPool, "UMG_Hud_Pet")
    if not hud then
      local hudClass = _G.NRCBigWorldPreloader:Get("PET_HUD")
      hud = UE4.UWidgetBlueprintLibrary.Create(self, hudClass)
    end
    Log.Debug("BP_Farm_Entrance_C:OnFrameLoad SetWidget")
    if UE.UObject.IsValid(hud) and self.HeadWidget then
      self.HeadWidget:SetWidget(hud)
      hud:SetParentHUD(self.HeadWidget)
    end
    Character:EnsureComponent(PetHUDComponent)
    if Character.PetHUDComponent then
      Character.PetHUDComponent:OnFrameLoaded()
    end
  end
  Base.OnFrameLoad(self, distanceRatio)
  if Character and Character.config then
    self.HeadWidget.FarDisAppearDis = Character.config.npc_nameplate_show_distance or 4000
  end
end

function BP_Farm_Entrance_C:OnLoadResource()
  Base.OnLoadResource(self)
end

function BP_Farm_Entrance_C:OnVisible()
  Base.OnVisible(self)
  self:RefreshUnlockState()
  self:OnFarmLandInfoChanged()
  self.SkillStarted = false
end

function BP_Farm_Entrance_C:SetSceneCharacter(sceneCharacter)
  if sceneCharacter then
    Base.SetSceneCharacter(self, sceneCharacter)
    self:Register()
  else
    self:Unregister()
    Base.SetSceneCharacter(self, sceneCharacter)
  end
end

function BP_Farm_Entrance_C:Register()
  if not self.sceneCharacter then
    return
  end
  _G.NRCEventCenter:RegisterEvent("BP_Farm_Entrance_C", self, FarmModuleEvent.OnFarmLandInfoChanged, self.OnFarmLandInfoChanged)
  if not self.resourceLoaded then
    return
  end
end

function BP_Farm_Entrance_C:Unregister()
  _G.NRCEventCenter:UnRegisterEvent(self, FarmModuleEvent.OnFarmLandInfoChanged, self.OnFarmLandInfoChanged)
  if not self.sceneCharacter then
    return
  end
end

function BP_Farm_Entrance_C:OnLogicStatusChange(ChangeInfo)
  if not ChangeInfo or ChangeInfo.changed_status.status ~= _G.ProtoEnum.SpaceActorLogicStatus.SALS_HOME_PLANT_UNLOCK_ENTRY_NPC then
    return
  end
  if not self.sceneCharacter then
    return
  end
  self:RefreshUnlockState()
end

function BP_Farm_Entrance_C:RefreshUnlockState()
  if SceneUtils.IsLogicStatusHomePlantUnlockEntry(self.sceneCharacter) then
    self:PlayIdleEndEffect()
  else
    self:PlayIdleStartEffect()
  end
end

function BP_Farm_Entrance_C:PlayIdleStartEffect()
  Log.Debug("BP_Farm_Entrance_C try PlayIdleStartEffect!")
  if not self.SkillStarted and self.Deactive then
    self:Deactive()
  end
end

function BP_Farm_Entrance_C:PlayIdleEndEffect()
  Log.Debug("BP_Farm_Entrance_C try PlayIdleEndEffect!")
  if not self.SkillStarted and self.Active then
    self:Active()
  end
end

function BP_Farm_Entrance_C:OnFarmLandInfoChanged()
  if self.sceneCharacter and self.sceneCharacter.PetHUDComponent then
    self.sceneCharacter.PetHUDComponent:OnRefreshFarmNpcStatus(FarmModuleEnum.NPCType.Entrance)
  end
end

function BP_Farm_Entrance_C:StartSkill()
  if self.SkillStarted then
    Log.Error("BP_Farm_Entrance_C:StartSkill skill already started")
    return
  end
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not player then
    Log.Error("BP_Farm_Entrance_C:StartSkill \230\137\190\228\184\141\229\136\176player")
    return
  end
  local targets = {}
  table.insert(targets, self)
  local skillComp = player.viewObj.RocoSkill
  local skill = RocoSkillProxy.Create(FarmConst.SkillPath.UnlockEntrance, skillComp)
  if not skill then
    Log.Error("BP_Farm_Entrance_C:StartSkill \230\137\190\228\184\141\229\136\176Skill")
    return
  end
  skill:SetWithLoadAndPlay(true)
  skill:SetCaster(player.viewObj)
  skill:SetTargets(targets)
  skill:RegisterEventCallback("PreStart", self, self.OnSetupBlackboard)
  skill:RegisterEventCallback("PreEnd", self, self.SkillComplete)
  skill:RegisterEventCallback("End", self, self.SkillComplete)
  skill:RegisterEventCallback("Interrupt", self, self.OnInterrupted)
  skill:PlaySkill(self, self.OnSkillStart)
  self.SkillStarted = true
end

function BP_Farm_Entrance_C:OnSkillStart(Skill, Result)
  if Result == UE.ESkillStartResult.Success then
    local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
    if player then
      player.viewObj:SetActorHiddenInGame(true)
    end
  else
    self:SkillFailed()
  end
end

function BP_Farm_Entrance_C:OnSetupBlackboard(Name, Skill)
  if not Skill or not Skill.Blackboard then
    return
  end
end

function BP_Farm_Entrance_C:SkillFailed()
  Log.Error("BP_Farm_Entrance_C:SkillFailed")
  self.SkillStarted = false
  self:SkillComplete()
end

function BP_Farm_Entrance_C:SkillComplete(Name, Skill)
  self.SkillStarted = false
  self:RefreshUnlockState()
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if player then
    player.viewObj:SetActorHiddenInGame(false)
  end
end

function BP_Farm_Entrance_C:OnInterrupted(Name, Skill)
  Log.Error("BP_Farm_Entrance_C:OnInterrupted")
  self.SkillStarted = false
  self:SkillComplete()
end

return BP_Farm_Entrance_C
