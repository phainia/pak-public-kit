local UMG_PastActivity_Hearsay_C = _G.NRCPanelBase:Extend("UMG_PastActivity_Hearsay_C")

function UMG_PastActivity_Hearsay_C:OnConstruct()
  self:AddButtonListener(self.Button, self.ClosePanel)
end

function UMG_PastActivity_Hearsay_C:OnDestruct()
end

function UMG_PastActivity_Hearsay_C:ClosePanel()
  _G.NRCAudioManager:PlaySound2DAuto(41400008, "UMG_PastActivity_Hearsay_C:ClosePanel")
  self:OnClose()
end

function UMG_PastActivity_Hearsay_C:OnActive(_tips)
  if _tips then
    local textCtrl = {
      self.Text_1,
      self.Text,
      self.Text_2
    }
    local tipsCnt = #_tips
    for _index, _ctrl in ipairs(textCtrl) do
      if _index <= tipsCnt then
        _ctrl:SetText(_tips[_index])
      else
        _ctrl:SetText("")
      end
    end
  end
end

return UMG_PastActivity_Hearsay_C
