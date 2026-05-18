local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local NpcOptionEvent = require("NewRoco.Modules.Core.NPC.Executors.NpcOptionEvent")
local ViewNPCBase = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local SleepingOwlModuleEvent = require("NewRoco.Modules.System.SleepingOwl.SleepingOwlModuleEvent")
local Base = ViewNPCBase
local BP_NPCOwlSanctuaryBase_C = Base:Extend("BP_NPCOwlSanctuaryBase_C")
local OwlDetectedRadiusSquared = 2250000

function BP_NPCOwlSanctuaryBase_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
  self.Option = nil
  self.CurrentState = nil
  self.CurrentFruitCount = -1
  self.bPanelOpened = false
  self.bSkillPlaying = false
  self.bNeedDetected = nil
  self.IsReconnect = false
  local GetHasActorBegunPlay = UE.NPCUtils.GetHasActorBegunPlay
  if GetHasActorBegunPlay and GetHasActorBegunPlay(self) then
    self:ReceiveBeginPlay()
  else
    self:ClearTimer()
    self.BeginPlayCheckTimer = _G.TimerManager:CreateTimer(self, "BeginPlayCheckTimer", 60, self.OnTimerUpdate, self.OnTimerComplete, 10)
  end
  Log.Debug("BP_NPCOwlSanctuaryBase_C:Initialize", UE.UObject.GetFullName(self), tostring(self))
end

function BP_NPCOwlSanctuaryBase_C:ReceiveBeginPlay()
  Log.Debug("BP_NPCOwlSanctuaryBase_C:ReceiveBeginPlay", self.sceneCharacter and self.sceneCharacter:DebugNPCNameAndID() or "no scene character", UE.UObject.GetFullName(self), self)
  Base.ReceiveBeginPlay(self)
  self:ClearTimer()
end

function BP_NPCOwlSanctuaryBase_C:ReceiveEndPlay()
  Log.Debug("BP_NPCOwlSanctuaryBase_C:ReceiveEndPlay", self.sceneCharacter and self.sceneCharacter:DebugNPCNameAndID() or "no scene character", UE.UObject.GetFullName(self), self)
  Base.ReceiveEndPlay(self)
  self:ClearTimer()
end

function BP_NPCOwlSanctuaryBase_C:OnTimerComplete()
  if not UE.UObject.IsValid(self) then
    return
  end
  Log.Error("BP_NPCOwlSanctuaryBase_C:OnTimerComplete i didnt receive any begin play!!!!", UE.UObject.GetFullName(self), tostring(self))
  self:ClearTimer()
  self:ReceiveBeginPlay()
  if not RocoEnv.IS_EDITOR then
    local ErrorMessage = string.format("BP_NPCOwlSanctuaryBase_C\229\156\168Initialize\228\185\139\229\144\142\231\154\13260\231\167\146\229\134\133\230\178\161\230\156\137\230\148\182\229\136\176ReceiveBeginPlay:%s %s", UE.UObject.GetFullName(self), tostring(self))
    _G.NRCSDKManager:CrashSightReportExceptionWithReason("Actor\231\148\159\229\145\189\229\145\168\230\156\159\229\188\130\229\184\184", ErrorMessage, "")
  end
end

function BP_NPCOwlSanctuaryBase_C:OnTimerUpdate()
  if not self.BeginPlayCheckTimer then
    Log.Error("BP_NPCOwlSanctuaryBase_C:OnTimerUpdate where does this come from????", UE.UObject.GetFullName(self), tostring(self))
    return
  end
  Log.Debug("BP_NPCOwlSanctuaryBase_C:OnTimerUpdate wait for begin play", self.BeginPlayCheckTimer.elapsedTime, UE.UObject.GetFullName(self), tostring(self))
end

function BP_NPCOwlSanctuaryBase_C:ClearTimer()
  if not self.BeginPlayCheckTimer then
    return
  end
  _G.TimerManager:RemoveTimer(self.BeginPlayCheckTimer)
  self.BeginPlayCheckTimer = nil
  Log.Debug("BP_NPCOwlSanctuaryBase_C:ClearTimer", UE.UObject.GetFullName(self), tostring(self))
end

function BP_NPCOwlSanctuaryBase_C:SetSceneCharacter(sceneCharacter)
  if sceneCharacter then
    Base.SetSceneCharacter(self, sceneCharacter)
    self:Setup()
  else
    self:Teardown()
    self.CurrentFruitCount = -1
    Base.SetSceneCharacter(self, sceneCharacter)
  end
end

function BP_NPCOwlSanctuaryBase_C:GetMaxFruitSlotsCount()
  if not self.sceneCharacter then
    return 0
  end
  local ServerData = self.sceneCharacter.serverData
  local BaseInfo = ServerData and ServerData.npc_base
  local ContentID = BaseInfo and BaseInfo.npc_content_cfg_id or 0
  local Conf = _G.DataConfigManager:GetOwlSanctuaryConf(ContentID, true)
  if not Conf then
    return 0
  end
  return Conf.slot_num or 0
end

function BP_NPCOwlSanctuaryBase_C:GetCurrentFruitCount()
  if not self.sceneCharacter then
    return 0
  end
  local count = 0
  local ServerData = self.sceneCharacter.serverData
  local BaseInfo = ServerData and ServerData.npc_base
  local ContentID = BaseInfo and BaseInfo.npc_content_cfg_id or 0
  local FruitInfo = _G.DataModelMgr.PlayerDataModel:GetAllPlayerOwlSanctuaryNpcInfo()
  local PlayerUin = _G.DataModelMgr.PlayerDataModel:GetPlayerUin()
  for _, i in pairs(FruitInfo) do
    if i.uin == PlayerUin then
      for _, j in pairs(i.owl_sanctuarys) do
        if j.npc_content_id == ContentID then
          for _, k in pairs(j.fruit_brief_infos) do
            if 0 ~= k.fruit_id then
              count = count + 1
            end
          end
        end
      end
    end
  end
  return count
end

function BP_NPCOwlSanctuaryBase_C:GetUpGrade()
  if not self.sceneCharacter then
    return false
  end
  local MyOwlSanctuaryNpcInfo = _G.DataModelMgr.PlayerDataModel:GetOwlSanctuaryNpcInfo()
  if not MyOwlSanctuaryNpcInfo or not MyOwlSanctuaryNpcInfo.owl_sanctuarys then
    return false
  end
  for _, i in pairs(MyOwlSanctuaryNpcInfo.owl_sanctuarys) do
    if i.npc_content_id == self.sceneCharacter.serverData.npc_base.npc_content_cfg_id then
      if i.is_upgrade then
        return true
      else
        return false
      end
    end
  end
  return false
end

function BP_NPCOwlSanctuaryBase_C:SetUpGrade(isUpGrade)
  if isUpGrade then
    if self.Nourish_Big_CT then
      self:Nourish_Big_CT()
    end
  elseif self.NoNourish then
    self:NoNourish()
  end
end

function BP_NPCOwlSanctuaryBase_C:OnLevelChanged()
  if self.bSkillPlaying then
    return false
  end
  self:SetUpGrade(self:GetUpGrade())
end

function BP_NPCOwlSanctuaryBase_C:SetSkillPlaying(bPlaying)
  self.bSkillPlaying = bPlaying or false
end

function BP_NPCOwlSanctuaryBase_C:OnEnterDialogue()
  self:SetSkillPlaying(true)
end

function BP_NPCOwlSanctuaryBase_C:OnLeaveDialogue()
  self:SetSkillPlaying(false)
end

function BP_NPCOwlSanctuaryBase_C:OnStatusChanged()
  Log.Trace("BP_NPCOwlSanctuaryBase_C:OnStatusChanged", self, self.resourceLoaded)
  if not self or not UE4.UObject.IsValid(self) then
    return
  end
  if self.bPanelOpened then
    return
  end
  if not self.resourceLoaded then
    return
  end
  local Count = self:GetCurrentFruitCount()
  if self.CurrentFruitCount == Count then
    return
  end
  self.CurrentFruitCount = Count
  self:NoFruit()
  if 0 == Count then
  elseif 1 == Count then
    self:PushFruit()
  else
    self:PushFruits()
  end
end

function BP_NPCOwlSanctuaryBase_C:OnFirstVisible()
  Base.OnFirstVisible(self)
  self:OnStatusChanged()
  self:OnLevelChanged()
end

function BP_NPCOwlSanctuaryBase_C:Setup()
  self:SetSkillPlaying(false)
  if not self.sceneCharacter then
    return
  end
  self.sceneCharacter:AddEventListener(self, NPCModuleEvent.NPC_LEVEL_UP, self.OnLevelChanged)
  self.sceneCharacter:AddEventListener(self, NPCModuleEvent.OnLogicStatusUpdated, self.OnStatusChanged)
  self.sceneCharacter:AddEventListener(self, NPCModuleEvent.OnEnterDialogue, self.OnEnterDialogue)
  self.sceneCharacter:AddEventListener(self, NPCModuleEvent.OnLeaveDialogue, self.OnLeaveDialogue)
  _G.NRCEventCenter:RegisterEvent("BP_NPCOwlSanctuaryBase_C", self, SleepingOwlModuleEvent.PanelDestroy, self.OnPanelClosed)
  _G.NRCEventCenter:RegisterEvent("BP_NPCOwlSanctuaryBase_C", self, _G.NRCGlobalEvent.RECONNECT_UPDATEOWL, self.ReconnectUpdate)
  self:CheckSanctuaryDetectedState()
  if not self.resourceLoaded then
    return
  end
  self:OnStatusChanged()
  self:OnLevelChanged()
end

function BP_NPCOwlSanctuaryBase_C:Teardown()
  self:SetSkillPlaying(false)
  if not self.sceneCharacter then
    return
  end
  self.sceneCharacter:RemoveEventListener(self, NPCModuleEvent.NPC_LEVEL_UP, self.OnLevelChanged)
  self.sceneCharacter:RemoveEventListener(self, NPCModuleEvent.OnLogicStatusUpdated, self.OnStatusChanged)
  self.sceneCharacter:RemoveEventListener(self, NPCModuleEvent.OnEnterDialogue, self.OnEnterDialogue)
  self.sceneCharacter:RemoveEventListener(self, NPCModuleEvent.OnLeaveDialogue, self.OnLeaveDialogue)
  _G.NRCEventCenter:UnRegisterEvent(self, SleepingOwlModuleEvent.PanelDestroy, self.OnPanelClosed)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.RECONNECT_UPDATEOWL, self.ReconnectUpdate)
end

function BP_NPCOwlSanctuaryBase_C:GetRealForwardVector()
  return self:GetActorRightVector()
end

function BP_NPCOwlSanctuaryBase_C:OnPanelOpened()
  self.bPanelOpened = true
  self:HideFruit()
end

function BP_NPCOwlSanctuaryBase_C:OnPanelClosed()
  self.bPanelOpened = false
  self:ShowFruit()
  self:OnStatusChanged()
end

function BP_NPCOwlSanctuaryBase_C:ReconnectUpdate()
  if not self.sceneCharacter then
    return
  end
  if not self.IsReconnect then
    return
  end
  if not self.resourceLoaded then
    return
  end
  self:OnLevelChanged()
  self:OnPanelClosed()
  self.IsReconnect = false
end

function BP_NPCOwlSanctuaryBase_C:UpdateData(ServerData, bIsReconnect)
  self.IsReconnect = bIsReconnect
end

function BP_NPCOwlSanctuaryBase_C:OnFruitDataUpdate()
  local serverData = self.sceneCharacter.serverData
  local owlContenId = serverData.npc_base.npc_content_cfg_id
  if nil == owlContenId then
    Log.Error("ContenId\230\156\170\230\136\144\229\138\159\232\142\183\229\143\150\229\136\176")
    return
  end
  local req = _G.ProtoMessage:newZoneGetOwlSanctuaryFruitInfoReq()
  req.content_id = owlContenId
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_GET_OWL_SANCTUARY_FRUIT_INFO_REQ, req, self, self.OnGetOwlSanctuaryFruitInfo, false, false)
end

function BP_NPCOwlSanctuaryBase_C:OnGetOwlSanctuaryFruitInfo(rsp)
  if 0 == rsp.ret_info.ret_code then
    self.fruitInfo = rsp.owl_sanctuary_fruit_info
    self:UpdateBigMapData()
  end
end

function BP_NPCOwlSanctuaryBase_C:UpdateBigMapData()
end

function BP_NPCOwlSanctuaryBase_C:CheckSanctuaryDetectedState(DefaultTrueEvenFail)
  if DefaultTrueEvenFail then
    self.bNeedDetected = true
  end
  if self.sceneCharacter == nil then
    return
  end
  local serverData = self.sceneCharacter.serverData
  local owlContentId = serverData.npc_base.npc_content_cfg_id
  if nil == owlContentId then
    Log.Error("ContenId\230\156\170\230\136\144\229\138\159\232\142\183\229\143\150\229\136\176")
    return
  end
  local MyOwlSanctuaryNpcInfo = _G.DataModelMgr.PlayerDataModel:GetOwlSanctuaryNpcInfo()
  if nil == MyOwlSanctuaryNpcInfo or nil == MyOwlSanctuaryNpcInfo[1] or nil == MyOwlSanctuaryNpcInfo.owl_sanctuarys then
    return
  end
  self.bNeedDetected = true
  for idx, sanctuaryInfo in ipairs(MyOwlSanctuaryNpcInfo.owl_sanctuarys) do
    if sanctuaryInfo.npc_content_id == owlContentId then
      self.bNeedDetected = false
      return
    end
  end
end

function BP_NPCOwlSanctuaryBase_C:MarkHadDetected()
  self.bNeedDetected = false
end

function BP_NPCOwlSanctuaryBase_C:OnDistanceOptimize(distance, viewDotValue, bulkyVisible, distanceRatio)
  if not self.bNeedDetected then
    if self.bNeedDetected == nil then
      self:CheckSanctuaryDetectedState(true)
    end
    return
  end
  if distance < OwlDetectedRadiusSquared then
    local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
    if localPlayer then
      self.bNeedDetected = false
      localPlayer:ForceSendMoveReq()
    end
  end
end

function BP_NPCOwlSanctuaryBase_C:OnResourceLoadFinish()
  Base.OnResourceLoadFinish(self)
  local Root = self:K2_GetRootComponent()
  if Root and UE.UObject.IsValid(Root) then
    Root:SetMobility(UE.EComponentMobility.Static)
  end
end

return BP_NPCOwlSanctuaryBase_C
