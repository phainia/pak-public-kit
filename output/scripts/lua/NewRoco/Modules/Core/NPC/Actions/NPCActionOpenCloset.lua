local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local Base = NPCActionBase
local NPCActionOpenCloset = Base:Extend("NPCActionOpenShop")

function NPCActionOpenCloset:ExecuteWithModel()
end

function NPCActionOpenCloset:OnSubmit(rsp)
  Base.OnSubmit(self, rsp)
  if rsp and rsp.ret_info and 0 ~= rsp.ret_info.ret_code then
    self:Finish(false)
    return
  end
  self.bIsPlayerLinked = false
  local View = self:GetOwnerNPCView()
  if not View then
    return true
  end
  NRCModeManager:GetCurMode():DisablePanelByLayer(Enum.UILayerType.UI_LAYER_MAIN)
  NRCProfilerLog:NRCClickBtn(true, "AppearanceCloset")
  self:OpenClosetPanel()
  self:SwitchLightEnv(true)
end

function NPCActionOpenCloset:Finish(success, data, param)
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if localPlayer and self.bIsPlayerLinked then
    localPlayer:SendEvent(PlayerModuleEvent.ON_SET_LINK_STATE, true, PlayerModuleEvent.LinkReasonFlags.DIALOGUE)
  end
  NRCModeManager:GetCurMode():RevertPanelEnableStateByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
  self:SwitchLightEnv(false)
  Base.Finish(self, success, data, param)
end

function NPCActionOpenCloset:OpenClosetPanel()
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if localPlayer then
    local statusComp = localPlayer.statusComponent
    if statusComp then
      local hasStatus = statusComp:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_HAND_IN_HAND)
      if hasStatus then
        self.bIsPlayerLinked = true
        localPlayer:SendEvent(PlayerModuleEvent.ON_SET_LINK_STATE, false, PlayerModuleEvent.LinkReasonFlags.DIALOGUE)
      else
        self.bIsPlayerLinked = false
      end
    end
  end
  _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.OpenAppearanceClosetPanel, self)
end

function NPCActionOpenCloset:SwitchLightEnv(bEnabled)
  local viewObj = self:GetOwnerNPCView()
  if not viewObj then
    Log.Debug("NPCActionOpenCloset:SwitchLightEnv viewObj is nil")
    return
  end
  local lightEnvChildActorComp = viewObj.LightEnvActor
  if not lightEnvChildActorComp or not UE4.UObject.IsValid(lightEnvChildActorComp) then
    Log.Debug("NPCActionOpenCloset:SwitchLightEnv lightEnvChildActorComp is nil")
    return
  end
  local lightEnvActor = lightEnvChildActorComp:GetChildActor()
  if not lightEnvActor or not UE4.UObject.IsValid(lightEnvActor) then
    Log.Debug("NPCActionOpenCloset:SwitchLightEnv lightEnvActor is nil")
    return
  end
  if bEnabled then
    if lightEnvActor.Start then
      Log.Debug("NPCActionOpenCloset:SwitchLightEnv Start")
      lightEnvActor:Start()
    end
  elseif lightEnvActor.End then
    Log.Debug("NPCActionOpenCloset:SwitchLightEnv End")
    lightEnvActor:End()
  end
end

return NPCActionOpenCloset
