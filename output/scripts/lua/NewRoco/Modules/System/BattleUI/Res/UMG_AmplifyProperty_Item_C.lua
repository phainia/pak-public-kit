local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_AmplifyProperty_Item_C = Base:Extend("UMG_AmplifyProperty_Item_C")

function UMG_AmplifyProperty_Item_C:OnConstruct()
end

function UMG_AmplifyProperty_Item_C:OnDestruct()
end

function UMG_AmplifyProperty_Item_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self:SetInfo()
end

function UMG_AmplifyProperty_Item_C:SetInfo()
  local data = self.data
  self.AmplifyNum_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.AmplifyNum_1:SetText("")
  if data.stack and data.stack > 1 then
    self.AmplifyNum_1:SetText(data.stack)
  end
  local LocalizationConf = _G.DataConfigManager:GetLocalizationConf(tostring(data.tip_id))
  if LocalizationConf then
    self.AmplifyDesc_1:SetText(LocalizationConf.msg)
    local skillDamType = BattleUtils.SkillEnhanceInfoToSkillDamageType(data)
    local typeDic = skillDamType and _G.DataConfigManager:GetTypeDictionary(skillDamType)
    local icon_path = typeDic and typeDic.synchron_petbag_icon
    if icon_path then
      self.AmplifyIcon_1:SetPath(icon_path)
    else
      self.AmplifyIcon_1:SetPath("PaperSprite'/Game/NewRoco/Modules/System/BattleUI/Raw/Atlas/Combat/Frames/img_jinengzengqiang_png.img_jinengzengqiang_png'")
    end
  end
end

function UMG_AmplifyProperty_Item_C:OnItemSelected(_bSelected)
end

function UMG_AmplifyProperty_Item_C:OnDeactive()
end

return UMG_AmplifyProperty_Item_C
