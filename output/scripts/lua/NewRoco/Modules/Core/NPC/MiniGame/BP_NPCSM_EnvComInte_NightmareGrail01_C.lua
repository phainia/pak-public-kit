local ViewNPCBase = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local Base = ViewNPCBase
local BP_NPCSM_EnvComInte_NightmareGrail01_C = Base:Extend("BP_NPCSM_EnvComInte_NightmareGrail01_C")
local OpenNightmareEndPath = "/Game/ArtRes/Effects/G6Skill/SceneEffect/G6_Scene_NightMare_End.G6_Scene_NightMare_End_C"

function BP_NPCSM_EnvComInte_NightmareGrail01_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
  self.bDoAction = false
  self.bRecover = false
  self.Skill = nil
  self.bPreloadSkill = false
  self.bShengBeiLoopActivated = false
  _G.NRCEventCenter:RegisterEvent("BP_NPCSM_EnvComInte_NightmareGrail01_C", self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReconnect)
end

function BP_NPCSM_EnvComInte_NightmareGrail01_C:OnFirstVisible()
  Base.OnFirstVisible(self)
  if not _G.MiniGameModuleCmd then
    Log.Error("BP_NPCSM_EnvComInte_NightmareGrail01_C:OnFirstVisible  MiniGameModuleCmd is not ready")
    return
  end
  local NeedPlayNightmareAction = _G.NRCModuleManager:DoCmd(_G.MiniGameModuleCmd.NeedPlayNightmareAction)
  if NeedPlayNightmareAction then
    UpdateManager:Register(self)
  elseif _G.NRCModuleManager:DoCmd(_G.MiniGameModuleCmd.IsInNightmare) then
    self:OnOpenLoopFX()
  else
    UpdateManager:Register(self)
    self.bRecover = true
  end
end

function BP_NPCSM_EnvComInte_NightmareGrail01_C:OnReconnect()
  if _G.NRCModuleManager:DoCmd(_G.MiniGameModuleCmd.IsInNightmare) and not self.bShengBeiLoopActivated then
    self:OnOpenLoopFX()
  end
end

function BP_NPCSM_EnvComInte_NightmareGrail01_C:OnTick(InDeltaTime)
  if not self.bPreloadSkill then
    self:PreloadSkill()
    self.bPreloadSkill = true
  end
  local NeedShowAnim = _G.NRCModuleManager:DoCmd(_G.MiniGameModuleCmd.IsInNightmare)
  local NeedPlayOpenNightmare = _G.NRCModuleManager:DoCmd(_G.MiniGameModuleCmd.IsOpenNightmareFinish)
  if NeedPlayOpenNightmare then
    self:StartPerformance()
    UpdateManager:UnRegister(self)
    _G.NRCModuleManager:DoCmd(_G.MiniGameModuleCmd.SetOpenNightmareFinish, false)
  elseif NeedShowAnim and self.bRecover then
    self:OnOpenLoopFX()
    UpdateManager:UnRegister(self)
  end
end

function BP_NPCSM_EnvComInte_NightmareGrail01_C:PreloadSkill()
  _G.NRCResourceManager:LoadResAsync(self, OpenNightmareEndPath, PriorityEnum.Active_World_NPC_Nightmare, 0, self.OnPreloadFinish, self.OnPreloadFailed)
  self.bPreloadSkill = true
end

function BP_NPCSM_EnvComInte_NightmareGrail01_C:OnPreloadFinish(resRequest, skillObj)
  if not self.RocoSkill then
    return
  end
  if skillObj then
    self.Skill = self.RocoSkill:FindOrAddSkillObj(skillObj)
    self.Skill:SetCaster(self)
    self.Skill:SetTargets({self})
    self.Skill:RegisterEventCallback("PreEnd", self, self.OnPerformanceFinish)
    self.Skill:RegisterEventCallback("OpenLoopFX", self, self.OnOpenLoopFX)
    if self.bDoAction then
      self:StartPerformance()
    end
  end
end

function BP_NPCSM_EnvComInte_NightmareGrail01_C:OnPreloadFailed()
end

function BP_NPCSM_EnvComInte_NightmareGrail01_C:StartPerformance()
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not player then
    return
  end
  self.bDoAction = true
  if not self.RocoSkill then
    return
  end
  local Result = self.RocoSkill:LoadAndPlaySkill(self.Skill)
  if not Result then
    return
  end
end

function BP_NPCSM_EnvComInte_NightmareGrail01_C:OnPerformanceFinish()
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  self.Skill:UnregisterEventCallback("PreEnd", self, self.OnPerformanceFinish)
  self.Skill:UnregisterEventCallback("OpenLoopFX", self, self.OnOpenLoopFX)
  self.RocoSkill:RemoveSkillObj(self.Skill)
  if self.bDoAction then
    if player and player.inputComponent then
      player.inputComponent:SetInputEnable(self, true, "ActionNightmare")
    end
    _G.NRCModeManager:GetCurMode():RevertPanelEnableStateByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
  end
  _G.NRCModuleManager:DoCmd(_G.MiniGameModuleCmd.SetPlayNightmareAction, false)
  self.bDoAction = false
  self.bPreloadSkill = false
end

function BP_NPCSM_EnvComInte_NightmareGrail01_C:OnOpenLoopFX()
  self.bShengBeiLoopActivated = true
  self:OpenLoopFX()
end

function BP_NPCSM_EnvComInte_NightmareGrail01_C:Recycle()
  self:OnCloseFX()
  Base.Recycle(self)
end

function BP_NPCSM_EnvComInte_NightmareGrail01_C:ReceiveDestroyed()
  if self.bDoAction then
    local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
    if player and player.inputComponent then
      player.inputComponent:SetInputEnable(self, true, "ActionNightmare")
    end
    self.Skill:UnregisterEventCallback("PreEnd", self, self.OnPerformanceFinish)
    self.Skill:UnregisterEventCallback("OpenLoopFX", self, self.OnOpenLoopFX)
    self.RocoSkill:RemoveSkillObj(self.Skill)
    _G.NRCModeManager:GetCurMode():RevertPanelEnableStateByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
    _G.NRCModuleManager:DoCmd(_G.MiniGameModuleCmd.SetPlayNightmareAction, false)
  else
  end
  UpdateManager:UnRegister(self)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReconnect)
end

function BP_NPCSM_EnvComInte_NightmareGrail01_C:OnCloseFX()
  self:CloseFx()
  self.bShengBeiLoopActivated = false
end

return BP_NPCSM_EnvComInte_NightmareGrail01_C
