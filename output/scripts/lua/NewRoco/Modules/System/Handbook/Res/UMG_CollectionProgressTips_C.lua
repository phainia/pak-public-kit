local UMG_CollectionProgressTips_C = _G.NRCPanelBase:Extend("UMG_CollectionProgressTips_C")

function UMG_CollectionProgressTips_C:OnActive(conf, count)
  _G.NRCAudioManager:PlaySound2DAuto(41400002, "UMG_CollectionProgressTips_C:OnActive")
  self:PlayAnimation(self.Appear)
  self.NRCText_76:SetText(LuaText.handbook_collect_progress_5)
  self.ChangeText:SetText(string.format(LuaText.handbook_collect_progress_6, conf.name, count))
end

function UMG_CollectionProgressTips_C:OnConstruct()
  self:OnAddEventListener()
end

function UMG_CollectionProgressTips_C:OnDeactive()
end

function UMG_CollectionProgressTips_C:OnAddEventListener()
  self:AddButtonListener(self.btnCloseTips, self.OnCloseTips)
end

function UMG_CollectionProgressTips_C:OnCloseTips()
  if self:IsAnimationPlaying(self.Disappear) then
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(41400003, "UMG_CollectionProgressTips_C:OnActive")
  self:PlayAnimation(self.Disappear)
end

function UMG_CollectionProgressTips_C:OnAnimationFinished(Animation)
  if Animation == self.Disappear then
    self:DoClose()
  end
end

return UMG_CollectionProgressTips_C
