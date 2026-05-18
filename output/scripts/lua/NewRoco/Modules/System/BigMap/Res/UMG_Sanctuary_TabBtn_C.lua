local UMG_Sanctuary_TabBtn_C = NRCClass()

function UMG_Sanctuary_TabBtn_C:Init(text)
  self.NRCText_60:SetText(text)
end

function UMG_Sanctuary_TabBtn_C:PlayAni()
  self:PlayAnimation(self.Press)
end

function UMG_Sanctuary_TabBtn_C:StopAni()
  self:PlayAnimation(self.Normal)
end

return UMG_Sanctuary_TabBtn_C
