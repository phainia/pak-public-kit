local UMG_TopMark_C = _G.NRCPanelBase:Extend("UMG_TopMark_C")

function UMG_TopMark_C:OnActive()
end

function UMG_TopMark_C:UpdateUid(uid)
  for i = 1, 5 do
    self["Text" .. i]:SetText(string.format(LuaText.TopMarkText, uid or 0))
  end
end

function UMG_TopMark_C:OnDeactive()
end

function UMG_TopMark_C:OnAddEventListener()
end

return UMG_TopMark_C
