local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UIUtils = require("NewRoco.Modules.System.TipsModule.Utils.UIUtils")
local BattleUIModuleCmd = reload("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local UMG_PVP_PetList_C = Base:Extend("UMG_PVP_PetList_C")

function UMG_PVP_PetList_C:OnConstruct()
end

function UMG_PVP_PetList_C:OnDestruct()
end

function UMG_PVP_PetList_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  self.touchStartTime = 0
  self:SetupUI()
end

function UMG_PVP_PetList_C:SetupUI()
  if self.uiData.IsFirstOpenPanel == true then
    self:PlayAnimation(self.Open)
  end
  local uiData = self.uiData.petGid
  if 0 ~= uiData then
    local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(uiData)
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petData.base_conf_id)
    local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
    self.NumText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.ItemIcon:SetVisibility(UE4.ESlateVisibility.Visible)
    self.TextBG:SetVisibility(UE4.ESlateVisibility.Visible)
    self.BGColor:SetVisibility(UE4.ESlateVisibility.Visible)
    self.ItemIcon:SetPath(NRCUtils:FormatConfIconPath(modelConf.ui_icon, _G.UIIconPath.UIHeadIconPath))
    self.NumText:SetText(tostring(petData.level))
    UIUtils.GetPetQuality(self.BGColor, petBaseConf.quality)
  else
    self.NumText:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.ItemIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.TextBG:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.BGColor:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_PVP_PetList_C:OnItemSelected(_bSelected)
  if _bSelected then
    self.Selected:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if 0 ~= self.uiData.petGid then
      UE4.UNRCAudioManager.Get():PlaySound2DAuto(1003, "UMG_PVP_PetList_C:OnItemSelected")
      local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.uiData.petGid)
      _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.SetPVPPetTip, true, self.uiData.petGid)
    else
      UE4.UNRCAudioManager.Get():PlaySound2DAuto(1281, "UMG_PVP_PetList_C:OnItemSelected1")
      _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenPvPPetTeamPanel)
      _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.SetPVPPetTip, false)
      self.Selected:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  else
    self.Selected:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  _G.UpdateManager:UnRegister(self)
end

function UMG_PVP_PetList_C:OnTouchStarted(MyGeometry, InTouchEvent)
  if self.uiData then
    _G.UpdateManager:Register(self)
  end
  Base.OnTouchStarted(self, MyGeometry, InTouchEvent)
  return UE.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_PVP_PetList_C:OnTick(InDeltaTime)
  self.touchStartTime = self.touchStartTime + InDeltaTime
  if self.touchStartTime > 0.8 then
    if self.uiData and 0 ~= self.uiData.petGid then
      local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.uiData.petGid)
      _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SetOpenPanelPetData, petData, 2, true)
      UE4.UNRCAudioManager.Get():PlaySound2DAuto(1014, "UMG_LobbyMain_C:OnBtnPetHeadClick")
      NRCModuleManager:DoCmd(PetUIModuleCmd.OpenPanelPetMain, {
        subPanelIndex = 4,
        callback = self.OnUMGLoadFinished
      })
    else
      _G.UpdateManager:UnRegister(self)
    end
    self.touchStartTime = 0
    _G.UpdateManager:UnRegister(self)
  end
end

function UMG_PVP_PetList_C:OnDeactive()
end

return UMG_PVP_PetList_C
