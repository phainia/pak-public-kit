local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_MagicStar2_C = Base:Extend("UMG_MagicStar2_C")

function UMG_MagicStar2_C:OnConstruct()
end

function UMG_MagicStar2_C:OnDestruct()
end

function UMG_MagicStar2_C:ItemUpdate(_data)
  self.starNormal:SetVisibility(UE4.ESlateVisibility.Visible)
  self.starHide:SetVisibility(UE4.ESlateVisibility.Visible)
  self.star:SetVisibility(UE4.ESlateVisibility.Visible)
  self.data = _data
  self:StopAllAnimations()
  self:PlayAnimation(self.In)
end

function UMG_MagicStar2_C:ShowAfterSeconds(seconds)
  self:StopAllAnimations()
  self:PlayAnimation(self.In)
  self.waitForShow = true
  self.countDown = seconds
end

function UMG_MagicStar2_C:Update(DeltaTime)
  if self.waitForShow then
    self.countDown = self.countDown - DeltaTime
    if self.countDown < 0 then
      self:Show()
    end
  end
end

function UMG_MagicStar2_C:Show()
  self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self.waitForShow = false
  if not self.data then
    Log.Warning("\232\191\153\233\135\140\232\130\175\229\174\154\230\156\137\233\151\174\233\162\152\239\188\140\229\166\130\230\158\156\232\131\189\229\164\141\231\142\176\231\154\132\232\175\157\239\188\140\232\175\183\230\138\138\231\142\176\229\156\186\228\186\164\231\187\153marvynwang\239\188\140\231\155\174\229\137\141\229\133\136\229\136\164\231\169\186\231\161\174\228\191\157\230\178\161\230\156\137exception\233\152\187\229\161\158\233\128\187\232\190\145")
    return
  end
  if self.data.isEmpty then
  elseif self.data.isNormal then
    self:StopAllAnimations()
    self:PlayAnimation(self.In_blue)
  elseif self.data.isStar then
    self:StopAllAnimations()
    self:PlayAnimation(self.In_gold)
  end
end

function UMG_MagicStar2_C:OnItemUpdate(_data, datalist, index)
end

function UMG_MagicStar2_C:OnItemSelected(_bSelected)
end

function UMG_MagicStar2_C:OnDeactive()
end

return UMG_MagicStar2_C
