local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local Base = NPCActionBase
local NPCActionStarChainAward = Base:Extend("NPCActionStarChainAward")

function NPCActionStarChainAward:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionStarChainAward:Execute()
  Base.Execute(self)
end

function NPCActionStarChainAward:OnSubmit(rsp)
  Base.OnSubmit(self, rsp)
  local ErrorCode = rsp.ret_info.ret_code
  if ErrorCode == ProtoEnum.MOBA_RET.ErrorCode.ERR_COMMON_SYS_FUNC_BANNED or ErrorCode == ProtoEnum.MOBA_RET.ZoneErr.ERR_ZONE_COMMON_BANNED then
    self.needSendReq = false
    self:Finish()
  else
    NRCModeManager:GetCurMode():DisablePanelByLayer(Enum.UILayerType.UI_LAYER_MAIN)
    local InstanceID = tonumber(self.Config.action_param1)
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1067, "NPCActionStarChainAward:Execute")
    NRCModuleManager:DoCmd(StarChainModuleCmd.OpenStarChainAwardPanel, self, InstanceID)
    self.bOpen = true
    self:SetViewObjOption()
  end
end

function NPCActionStarChainAward:Finish(success, data, param)
  self.bOpen = false
  Base.Finish(self, success, data, param)
end

function NPCActionStarChainAward:Destroy()
  local Module = _G.NRCModuleManager:GetModule("StarChain")
  if Module then
    Module:DeadCloseStarChainPanel()
  end
  self.bOpen = false
end

return NPCActionStarChainAward
