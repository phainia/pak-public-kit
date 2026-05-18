require("UnLuaEx")
local UMG_MapTips_C = NRCPanelBase:Extend("UMG_MapTips_C")

function UMG_MapTips_C:Construct()
end

function UMG_MapTips_C:OnAnimationFinished(Animation)
  if Animation == self.Anim then
    self:DoClose()
  end
end

function UMG_MapTips_C:OnActive()
  self:SetContent()
end

function UMG_MapTips_C:SetContent(name, area)
  self:PlayAnimation(self.Anim, 0)
end

function UMG_MapTips_C:Destruct()
end

return UMG_MapTips_C
