local DebugModuleEvent = reload("NewRoco.Modules.System.Debug.DebugModuleEvent")
local UMG_DebugGmTips_C = _G.NRCPanelBase:Extend("UMG_DebugGmTips_C")

function UMG_DebugGmTips_C:OnConstruct()
  self.CommGmCmd = nil
  self:OnAddEventListener()
end

function UMG_DebugGmTips_C:OnDestruct()
end

function UMG_DebugGmTips_C:OnActive(CommGm)
  self.CommGmCmd = CommGm
  if CommGm.params and #CommGm.params > 0 then
    self.List:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.List:InitGridView(CommGm.params)
  else
    self.List:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.Title:SetText(CommGm.cmd_desc)
end

function UMG_DebugGmTips_C:OnDeactive()
end

function UMG_DebugGmTips_C:OnAddEventListener()
  self:AddButtonListener(self.CloseBtn.btnClose, self.DoClose)
  self:AddButtonListener(self.Cancel.btnLevelUp, self.DoClose)
  self:AddButtonListener(self.Confirm.btnLevelUp, self.OnConfirm)
  self:RegisterEvent(self, DebugModuleEvent.RefreshResult, self.OnRefreshResult)
end

function UMG_DebugGmTips_C:OnConfirm()
  local Req = _G.ProtoMessage:newZoneGmExecCommGmCmdReq()
  Req.cmd.cmd_id = self.CommGmCmd.cmd_id
  Req.cmd.cmd_name = self.CommGmCmd.cmd_name
  Req.cmd.cmd_desc = self.CommGmCmd.cmd_desc
  Req.cmd.params = {}
  local IsSucceed = true
  local AutoParam, IsSatisfy = nil, true
  if self.CommGmCmd and self.CommGmCmd.params then
    for i, param in ipairs(self.CommGmCmd.params) do
      local Item = self.List:GetItemByIndex(i - 1)
      if Item then
        AutoParam, IsSatisfy = Item:GetAutoParam()
        if IsSatisfy then
          table.insert(Req.cmd.params, AutoParam)
        else
          IsSucceed = false
        end
      end
    end
  end
  if IsSucceed then
    _G.NRCModuleManager:DoCmd(DebugModuleCmd.GMExecCommGmCmd, Req.cmd)
  end
end

function UMG_DebugGmTips_C:OnRefreshResult(_, Rsp)
  local IsSucceed = 0 == Rsp.ret_info.ret_code and "\230\136\144\229\138\159" or "\229\164\177\232\180\165"
  local result = Rsp.ret_info.ret_msg
  local Text
  if IsSucceed then
    Text = string.format("<span color=\"#FF0000FF\">%s,</><span color=\"#000000FF\">%s,</>%s", IsSucceed, Rsp.ret_info.ret_code, result)
  else
    Text = string.format("<span color=\"#FF0000FF\">%s,</><span color=\"#000000FF\">%s,</>%s", IsSucceed, Rsp.ret_info.ret_code, result)
  end
  self.TextResult:SetText(Text)
end

return UMG_DebugGmTips_C
