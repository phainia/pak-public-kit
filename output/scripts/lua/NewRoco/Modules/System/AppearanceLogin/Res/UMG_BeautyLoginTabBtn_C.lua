local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_BeautyLoginTabBtn_C = Base:Extend("UMG_BeautyLoginTabBtn_C")

function UMG_BeautyLoginTabBtn_C:OnConstruct()
end

function UMG_BeautyLoginTabBtn_C:OnDestruct()
end

function UMG_BeautyLoginTabBtn_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  self.Suit_Ordinary:SetPath(_data.Icon)
  local pathArray = string.split(_data.Icon, "/")
  local nameArray = string.split(pathArray[#pathArray], "_png")
  local bgName1 = nameArray[1] .. 1
  local bgName2 = nameArray[2] .. 1
  local bgPath = ""
  for i = 1, #pathArray - 1 do
    bgPath = bgPath .. pathArray[i] .. "/"
  end
  local bgPathTable = {
    bgPath,
    bgName1,
    "_png",
    bgName2,
    "_png'"
  }
  bgPath = table.concat(bgPathTable)
  self.Suit_Selected:SetPath(bgPath)
end

function UMG_BeautyLoginTabBtn_C:OnItemSelected(_bSelected)
  self:StopAllAnimations()
  if _bSelected then
    self:PlayAnimation(self.Btn_Suit_A)
    _G.NRCModuleManager:DoCmd(AppearanceLoginModuleCmd.SetBeautyTabEnum, self.uiData.Type)
  else
    self:PlayAnimation(self.Btn_Suit_A_Out)
  end
end

function UMG_BeautyLoginTabBtn_C:OnDeactive()
end

return UMG_BeautyLoginTabBtn_C
