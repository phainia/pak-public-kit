local ViewNPCBase = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local Base = ViewNPCBase
local BP_ShenShou_Transmit_Com_HD_C = Base:Extend("BP_ShenShou_Transmit_Com_HD_C")
BP_ShenShou_Transmit_Com_HD_C.SkillPath = "/Game/ArtRes/Effects/G6Skill/ShenShou/G6_ShenShou_Transmit_HD_Start.G6_ShenShou_Transmit_HD_Start"

function BP_ShenShou_Transmit_Com_HD_C:Ctor()
  Base.Ctor(self)
end

function BP_ShenShou_Transmit_Com_HD_C:ReceiveBeginPlay()
  Base.ReceiveBeginPlay(self)
  self.Request = _G.NRCResourceManager:LoadResAsync(self, self.SkillPath, PriorityEnum.Active_World_Combat_Boss, 5)
  _G.NRCEventCenter:RegisterEvent("BP_ShenShou_Transmit_Com_HD_C", self, NPCModuleEvent.OnLegendaryGrassBeginPlay, self.CheckShow)
  if not self.bStart then
    self:SetActorHiddenInGame(true)
  end
end

function BP_ShenShou_Transmit_Com_HD_C:ReceiveEndPlay(Reason)
  self:ClearDelay()
  if self.Request then
    _G.NRCResourceManager:UnLoadRes(self.Request)
    self.Request = nil
  end
  _G.NRCEventCenter:UnRegisterEvent(self, NPCModuleEvent.OnLegendaryGrassBeginPlay, self.CheckShow)
  Base.ReceiveEndPlay(self, Reason)
end

function BP_ShenShou_Transmit_Com_HD_C:Recycle()
  self:ClearDelay()
  if self.Request then
    _G.NRCResourceManager:UnLoadRes(self.Request)
    self.Request = nil
  end
  _G.NRCEventCenter:UnRegisterEvent(self, NPCModuleEvent.OnLegendaryGrassBeginPlay, self.CheckShow)
  Base.Recycle(self)
end

function BP_ShenShou_Transmit_Com_HD_C:Init()
  Base.Init(self)
  if not self.bStart then
    self:SetActorHiddenInGame(true)
  end
end

function BP_ShenShou_Transmit_Com_HD_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
  self:ClearDelay()
  self.DelayID = _G.DelayManager:DelayFrames(2, function()
    self:CheckShow()
  end)
end

function BP_ShenShou_Transmit_Com_HD_C:CheckIsFirstAppearance()
  if self.sceneCharacter and self.sceneCharacter:IsFirstAppearance() then
    return true
  end
  return false
end

function BP_ShenShou_Transmit_Com_HD_C:CheckDistance()
  local player = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local maxDis = 1200
  if player and player.viewObj then
    local playerLoc = player.viewObj:Abs_K2_GetActorLocation()
    local shenShouLoc = self:Abs_K2_GetActorLocation()
    if playerLoc and shenShouLoc then
      local dist = UE4.FVector.Dist(playerLoc, shenShouLoc)
      if maxDis >= dist then
        return true
      end
    end
  end
  return false
end

function BP_ShenShou_Transmit_Com_HD_C:CheckShow()
  if self.grassCheckPass then
    return
  end
  if self.TagName and self.TagName ~= "None" then
    local grassActor = self:CheckGrass()
    if not grassActor then
      return
    else
      grassActor:DissolveGlass()
    end
  end
  self.grassCheckPass = true
  if self.sceneCharacter then
    local isOwner = _G.DataModelMgr.PlayerDataModel:IsCurrentWorldOwner()
    if not self:CheckIsFirstAppearance() or not isOwner then
      self:SetActorHiddenInGame(false)
      self:Idle()
    elseif self:CheckDistance() then
      local player = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
      if player then
        local skillComponent = player.viewObj.RocoSkill
        if skillComponent then
          local skillProxy = RocoSkillProxy.Create(self.SkillPath, skillComponent)
          skillProxy:SetCaster(player.viewObj)
          skillProxy:SetTargets({self})
          skillProxy:RegisterEventCallback("End", self, self.OnShowEnd)
          skillProxy:RegisterEventCallback("Start", self, self.OnShowStart)
          skillProxy:RegisterEventCallback("Interrupt", self, self.OnShowInterrupt)
          skillProxy:PlaySkill()
        end
      end
    else
      self:OnStart()
    end
  end
end

function BP_ShenShou_Transmit_Com_HD_C:CheckGrass()
  local currentWorld = UE4Helper.GetCurrentWorld()
  if currentWorld then
    local grassActors = UE4.UGameplayStatics.GetAllActorsOfClass(currentWorld, self.GrassClass):ToTable()
    for _, actor in pairs(grassActors or {}) do
      if actor and actor.TagName == self.TagName then
        return actor
      end
    end
  end
  return nil
end

function BP_ShenShou_Transmit_Com_HD_C:ClearDelay()
  if self.DelayID then
    _G.DelayManager:CancelDelayById(self.DelayID)
  end
  self.DelayID = nil
end

function BP_ShenShou_Transmit_Com_HD_C:OnShowStart()
  _G.NRCModeManager:GetCurMode():DisablePanelByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
end

function BP_ShenShou_Transmit_Com_HD_C:OnShowEnd()
  _G.NRCModeManager:GetCurMode():RevertPanelEnableStateByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
end

function BP_ShenShou_Transmit_Com_HD_C:OnShowInterrupt()
  _G.NRCModeManager:GetCurMode():RevertPanelEnableStateByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
end

function BP_ShenShou_Transmit_Com_HD_C:CheckIsActivated()
  local isActivated = false
  local LogicComp = self.sceneCharacter.LogicStatusComponent
  if LogicComp then
    isActivated, _, _ = LogicComp:GetStatus(Enum.SpaceActorLogicStatus.SALS_INTERACTING)
  end
  return isActivated
end

function BP_ShenShou_Transmit_Com_HD_C:CheckActivatedEffect()
  if self:CheckIsActivated() then
    self:Start()
  end
end

return BP_ShenShou_Transmit_Com_HD_C
