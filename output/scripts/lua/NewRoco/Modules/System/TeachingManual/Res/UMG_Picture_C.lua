local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Picture_C = Base:Extend("UMG_Picture_C")

function UMG_Picture_C:OnConstruct()
end

function UMG_Picture_C:OnDestruct()
end

function UMG_Picture_C:OnActive()
end

function UMG_Picture_C:OnDeactive()
end

function UMG_Picture_C:OnAddEventListener()
end

function UMG_Picture_C:OnItemUpdate(_data, dataList, index)
  self.uiData = _data
  if self:_IsPCMode() then
    self:SetIconPath(self.uiData.bg_PC)
  else
    self:SetIconPath(self.uiData.bg)
  end
end

function UMG_Picture_C:SetIconPath(_Path)
  local Icon = "Texture2D'/Game/NewRoco/Modules/System/TeachingManual/Raw/Icon/"
  local Path = string.format("%s%s", Icon, _Path)
  self.Image_35:SetPath(Path)
end

function UMG_Picture_C:SetPath(Path)
  self.Image_35:SetPath(Path)
end

function UMG_Picture_C:_IsPCMode()
  if RocoEnv.IS_EDITOR then
    return _G.GlobalConfig.bEditorAsPcInTeachManual or false
  else
    return RocoEnv.PLATFORM == "PLATFORM_WINDOWS"
  end
end

return UMG_Picture_C
