local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local MagicManualUtils = require("NewRoco/Modules/System/MagicManual/MagicManualUtils")
local UMG_Friend_Wold_Item_C = Base:Extend("UMG_Friend_Wold_Item_C")

function UMG_Friend_Wold_Item_C:OnConstruct()
end

function UMG_Friend_Wold_Item_C:OnDestruct()
end

function UMG_Friend_Wold_Item_C:OnItemUpdate(_data, datalist, index)
  if _G.GlobalConfig.DebugOpenUI then
    local icon = "PaperSprite'/Game/NewRoco/Modules/System/Common/Icon/XueMai/Frames/img_putong_png.img_putong_png'"
    self.Species:SetPath(icon)
    local icon_flower = "PaperSprite'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Frames/img_flowerseed_Normal_png.img_flowerseed_Normal_png'"
    self.huazhong:SetPath(icon_flower)
    local model = "Texture2D'/Game/NewRoco/Modules/System/BigMap/Raw/Atlas/WorldMapNpc/Frames/10037.10037'"
    self.HeadPortrait:SetPath(NRCUtils:FormatConfIconPath(model, _G.UIIconPath.HeadIconPath))
    return
  end
  self.FlowerData = _data
  self:SetInfo()
  local BookState = _G.NRCModuleManager:DoCmd(HandbookModuleCmd.GetPetHandBookState, self.FlowerData.battle_petbase_id)
  if BookState == _G.ProtoEnum.PetHandbookStatus.PHS_COLLECTED then
    self.NotCollectedText:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.NotCollectedText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.NotCollectedText:SetText(LuaText.pet_not_collected)
  end
  self:SetResonanceList()
end

function UMG_Friend_Wold_Item_C:SetInfo()
  if self.FlowerData.battle_petbase_id then
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(self.FlowerData.battle_petbase_id)
    if petBaseConf then
      local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
      self.HeadPortrait:SetPath(NRCUtils:FormatConfIconPath(modelConf.icon, _G.UIIconPath.HeadIconPath))
      local image_Icons = {
        self.Species,
        self.Species_1
      }
      if 1 == #petBaseConf.unit_type then
        image_Icons[2]:SetVisibility(UE4.ESlateVisibility.Collapsed)
      else
        image_Icons[2]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
      local index = 1
      for i = #petBaseConf.unit_type, 1, -1 do
        local petType = petBaseConf.unit_type[i]
        local typeDic = _G.DataConfigManager:GetTypeDictionary(petType)
        image_Icons[index]:SetPath(typeDic.type_icon)
        index = index + 1
      end
    end
  end
  local bloodConf = _G.DataConfigManager:GetPetBloodConf(self.FlowerData.blood)
  self.huazhong:SetPath(bloodConf.icon_flower)
  self.Image_Blood:SetPath(bloodConf.icon)
  local level, IsReCom = MagicManualUtils.GetFlowerLevel(self.FlowerData.star, self.FlowerData.spec_flower_seed_id)
  if IsReCom then
    self.RemarkName_1:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#C3C1B4FF"))
  else
    self.RemarkName_1:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#C7494AFF"))
  end
  self.RemarkName_1:SetText(string.format(LuaText.umg_petskilltemple2_1, level))
  self:UpdateShinyFlowerInfo()
end

function UMG_Friend_Wold_Item_C:UpdateShinyFlowerInfo()
  self.Switcher_Bg:SetActiveWidgetIndex(2)
  self.Switcher_xingxing:SetActiveWidgetIndex(2)
  self.predestined:SetVisibility(UE4.ESlateVisibility.Collapsed)
  local TypeWrap = NRCModuleManager:GetModule("MagicManualModule"):GetFlowerType(self.FlowerData)
  if TypeWrap.IsLimitedFlower then
    self.Switcher_Bg:SetActiveWidgetIndex(1)
    self.Switcher_xingxing:SetActiveWidgetIndex(1)
  elseif TypeWrap.IsShinyFlower then
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(self.FlowerData.battle_petbase_id)
    if petBaseConf then
      local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
      self.HeadPortrait:SetPath(NRCUtils:FormatConfIconPath(modelConf.shiny_icon, _G.UIIconPath.HeadIconPath))
    end
    self.Switcher_Bg:SetActiveWidgetIndex(0)
    self.Switcher_xingxing:SetActiveWidgetIndex(0)
  elseif TypeWrap.Is7StarHardFlower then
    self.predestined:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Switcher_Bg:SetActiveWidgetIndex(3)
  end
end

function UMG_Friend_Wold_Item_C:SetResonanceList()
end

function UMG_Friend_Wold_Item_C:OnItemSelected(_bSelected)
end

function UMG_Friend_Wold_Item_C:OnDeactive()
end

return UMG_Friend_Wold_Item_C
