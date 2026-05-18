local UMG_Task_UIiconAn_C = _G.NRCPanelBase:Extend("UMG_Task_UIiconAn_C")

function UMG_Task_UIiconAn_C:OnConstruct()
end

function UMG_Task_UIiconAn_C:OnDestruct()
end

function UMG_Task_UIiconAn_C:OnActive()
end

function UMG_Task_UIiconAn_C:OnDeactive()
end

function UMG_Task_UIiconAn_C:UIiconAnInit(index)
  local animas = {
    self.Icon_M3,
    self.Icon_M2,
    self.Icon_M1
  }
  for i = 1, #animas do
    local item = animas[i]
    if i == index then
      self.UIiconAn = item
      item:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      item:SetVisibility(UE4.ESlateVisibility.Hidden)
    end
  end
end

function UMG_Task_UIiconAn_C:PlayChange1()
  self:PlayAnimation(self.change1)
end

function UMG_Task_UIiconAn_C:PlayNormal()
  self:PlayAnimation(self.normal)
end

function UMG_Task_UIiconAn_C:PlayChange2()
  self:PlayAnimation(self.change2)
end

return UMG_Task_UIiconAn_C
