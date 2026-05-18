local UIUtils = require("NewRoco.Modules.System.TipsModule.Utils.UIUtils")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Magic_List_C = Base:Extend("UMG_Magic_List_C")

function UMG_Magic_List_C:OnDestruct()
end

function UMG_Magic_List_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  self:SetIcon(self.uiData.petState)
end

function UMG_Magic_List_C:OnItemSelected(_bSelected)
  local state = 1 ~= self.uiData.petState and true or false
  local param = {
    petbaseId = self.uiData.petBaseConfId,
    needBlur = false,
    notAcquired = state,
    isSketch = true
  }
  _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenMagicDetailTips, param)
end

function UMG_Magic_List_C:OnDeactive()
end

function UMG_Magic_List_C:SetIcon(petState)
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(self.uiData.petBaseConfId)
  local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
  self.ItemIcon:SetPath(modelConf.icon)
  UIUtils.GetPetQuality(self.BGColor, petBaseConf.quality)
  if 1 == petState then
    self.ItemIcon:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#FFFFFFFF"))
  else
    self.ItemIcon:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#000000CC"))
  end
end

return UMG_Magic_List_C
