require("UnLuaEx")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_SpriteHeadTemple_C = Base:Extend("UMG_SpriteHeadTemple_C")

function UMG_SpriteHeadTemple_C:Destruct()
  Base.Destruct(self)
end

function UMG_SpriteHeadTemple_C:OnItemUpdate(_data, datalist, index)
  local npcModuleCfg
  local petBaseCfg = _G.DataConfigManager:GetPetbaseConf(_data.npcId)
  if petBaseCfg then
    npcModuleCfg = _G.DataConfigManager:GetModelConf(petBaseCfg.model_conf)
  end
  if npcModuleCfg and npcModuleCfg.ui_icon then
    self.headIcon:SetPath(npcModuleCfg.ui_icon)
  end
  self.headIconRetainer:SetEffectMaterial(_data.headMaterial)
  if _data.npcStatus == _G.ProtoEnum.WorldMapPetStatus.ENUM.NotMet then
    self.imgQuestion:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.imgQuestion:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

return UMG_SpriteHeadTemple_C
