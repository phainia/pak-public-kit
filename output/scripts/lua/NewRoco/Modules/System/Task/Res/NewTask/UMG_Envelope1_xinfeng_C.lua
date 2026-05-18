local UMG_Envelope1_xinfeng_C = _G.NRCViewBase:Extend("UMG_Envelope1_xinfeng_C")

function UMG_Envelope1_xinfeng_C:OnConstruct()
  self:PlayAnimation(self.Loop, 0, 9999)
end

function UMG_Envelope1_xinfeng_C:OnDestruct()
end

function UMG_Envelope1_xinfeng_C:OnActive()
end

function UMG_Envelope1_xinfeng_C:OnDeactive()
end

function UMG_Envelope1_xinfeng_C:SetEnvelopeInfo(TaskId)
  local SubTaskConf = _G.DataConfigManager:GetSubTaskConf(TaskId)
  if SubTaskConf then
    local TaskTokenConf = _G.DataConfigManager:GetTaskTokenConf(SubTaskConf.token_reward_id)
    if TaskTokenConf then
      self.NRCImage_5:SetPath(TaskTokenConf.token__source)
    end
  end
end

function UMG_Envelope1_xinfeng_C:OnAddEventListener()
end

return UMG_Envelope1_xinfeng_C
