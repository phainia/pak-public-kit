local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local UMG_PVP_ModelList_C = Base:Extend("UMG_PVP_ModelList_C")

function UMG_PVP_ModelList_C:OnConstruct()
end

function UMG_PVP_ModelList_C:OnDestruct()
end

function UMG_PVP_ModelList_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  self.Ordinary:SetPath(_data.picPath1)
  self.Selected:SetPath(_data.picPath2)
  self.Title_Model_1:SetText(_data.titleName)
  self.Title_Model:SetText(_data.titleName)
end

function UMG_PVP_ModelList_C:OnItemSelected(_bSelected)
  if _bSelected then
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1271, "UMG_PVP_ModelList_C:OnItemSelected")
    self.Switcher:SetActiveWidgetIndex(1)
    _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.ChangePVPBattleType, self.uiData.pvpType)
  else
    self.Switcher:SetActiveWidgetIndex(0)
  end
end

function UMG_PVP_ModelList_C:OnDeactive()
end

return UMG_PVP_ModelList_C
