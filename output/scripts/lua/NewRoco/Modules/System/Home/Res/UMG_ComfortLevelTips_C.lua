local UMG_ComfortLevelTips_C = _G.NRCPanelBase:Extend("UMG_ComfortLevelTips_C")

function UMG_ComfortLevelTips_C:OnActive()
  self:OnAddEventListener()
  self:Init()
end

function UMG_ComfortLevelTips_C:OnDeactive()
end

function UMG_ComfortLevelTips_C:OnAddEventListener()
  self:AddButtonListener(self.btnCloseTips, self.ReqClose)
end

function UMG_ComfortLevelTips_C:Init()
  local BriefInfo = HomeIndoorSandbox.Server:GetDisplayHomeBriefInfo()
  if BriefInfo then
    local ComfortLevel = BriefInfo.home_comfort_level
    self.Text_ComfortLevel:SetText(tostring(ComfortLevel))
  else
    self.Text_ComfortLevel:SetText("0")
  end
  local HOME_COMFORT_CONF = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.HOME_COMFORT_CONF):GetAllDatas()
  local Comforts = {}
  for k, v in pairs(HOME_COMFORT_CONF) do
    table.insert(Comforts, v)
  end
  table.sort(Comforts, function(a, b)
    return a.coordinate < b.coordinate
  end)
  self.NRCGridView_86:InitGridView(Comforts)
end

function UMG_ComfortLevelTips_C:ReqClose()
  if self.bPendingClose then
    return
  end
  self.bPendingClose = true
  self:PlayAnimation(self.Disappear)
end

function UMG_ComfortLevelTips_C:OnAnimationFinished(Anim)
  if Anim == self.Disappear then
    self:OnClose()
  end
end

return UMG_ComfortLevelTips_C
