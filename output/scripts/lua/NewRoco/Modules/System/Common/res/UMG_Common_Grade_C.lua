local UMG_Common_Grade_C = _G.NRCPanelBase:Extend("UMG_Common_Grade_C")

function UMG_Common_Grade_C:Init(cardSkinId)
  local CardSkinConf = _G.DataConfigManager:GetCardSkinConf(cardSkinId)
  if not CardSkinConf then
    Log.Error("UMG_Common_Grade_C:Init CardSkinConf is nil , cardSkinId:" .. tostring(cardSkinId))
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return
  end
  if not CardSkinConf.level_icon or CardSkinConf.level_icon == "" then
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return
  end
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  local gradeIconPath = string.format(UEPath.CARD_UPGRADE_ICON_PATH, CardSkinConf.level_icon)
  self.Grade:SetPath(gradeIconPath)
end

return UMG_Common_Grade_C
