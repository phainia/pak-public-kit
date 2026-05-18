local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_SystemSettingMapOptionItem_C = Base:Extend("UMG_SystemSettingMapOptionItem_C")

function UMG_SystemSettingMapOptionItem_C:OnConstruct()
end

function UMG_SystemSettingMapOptionItem_C:OnDestruct()
end

function UMG_SystemSettingMapOptionItem_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  self.bIsFirstSelect = true
  self:InitInfo()
end

function UMG_SystemSettingMapOptionItem_C:InitInfo()
  if self.uiData.mapMode then
    local mapMode = self.uiData.mapMode
    if mapMode == ProtoEnum.NavigationModeType.NMT_MINIMAP then
      self.Icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/SystemSetting/Raw/Frames/img_Option_png.img_Option_png'")
    elseif mapMode == ProtoEnum.NavigationModeType.NMT_COMPASS then
      self.Icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/SystemSetting/Raw/Frames/img_Option2_png.img_Option2_png'")
    end
  end
  self.SelectBg:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_SystemSettingMapOptionItem_C:OnItemSelected(_bSelected)
  if _bSelected then
    self.SelectBg:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:PlayAnimation(self.Select_In)
    _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_MapModeSelection_C:OkBtnClick")
    if self.uiData.mapMode then
      if self.bIsFirstSelect then
        self.bIsFirstSelect = false
      else
        _G.DataModelMgr.PlayerDataModel:SetNavigationMode(self.uiData.mapMode)
      end
    else
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.navigation_mode_no_select_tips)
    end
  else
    self:PlayAnimationReverse(self.Select_In)
  end
end

function UMG_SystemSettingMapOptionItem_C:OnDeactive()
end

function UMG_SystemSettingMapOptionItem_C:OnAnimationFinished(anim)
end

return UMG_SystemSettingMapOptionItem_C
