local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local UMG_ShouLingView_C = _G.NRCPanelBase:Extend("UMG_ShouLingView_C")

function UMG_ShouLingView_C:OnConstruct()
  Log.Debug("UMG_ShouLingView_C:OnConstruct")
  self.PetInfo = BattleUtils.GetBattleInitInfo().enemy_team[1].pets[1]
  local CommonPetInfo = self.PetInfo.battle_common_pet_info
  self.enemyId = CommonPetInfo.base_conf_id
  local PetBaseConf = _G.DataConfigManager:GetPetbaseConf(self.enemyId)
  if PetBaseConf then
    self.enemyName = PetBaseConf.name
  else
    self.enemyName = "\231\173\150\229\136\146\230\178\161\230\156\137\233\133\141\229\149\138"
  end
  self.bossName:SetText(self.enemyName)
  self.bossId:SetText(self.enemyId)
  self:SetType()
end

function UMG_ShouLingView_C:OnDestruct()
end

function UMG_ShouLingView_C:OnActive()
  Log.Debug("UMG_ShouLingView_C:OnActive")
end

function UMG_ShouLingView_C:OnDeactive()
end

function UMG_ShouLingView_C:SetType()
  local Attrs = self.PetInfo.battle_inside_pet_info.battle_attr
  local attr1 = Attrs[_G.Enum.AttributeType.AT_DAMTYPE1 + 1]
  local attr2 = Attrs[_G.Enum.AttributeType.AT_DAMTYPE2 + 1]
  local attr3 = Attrs[_G.Enum.AttributeType.AT_DAMTYPE3 + 1]
  local petTypes = {
    attr1,
    attr2,
    attr3
  }
  if petTypes then
    for i = 1, 4 do
      local petType = petTypes[i]
      if petType and petType > 0 then
        local conf = _G.DataConfigManager:GetTypeDictionary(petType)
        if i <= #petTypes and petType > 1 and conf then
          self["Attr" .. i]:SetVisibility(UE4.ESlateVisibility.Visible)
          local iconPath = conf.type_icon
          self["Attr" .. i]:SetPath(iconPath)
        else
          self["Attr" .. i]:SetVisibility(UE4.ESlateVisibility.Hidden)
        end
      end
    end
  end
end

return UMG_ShouLingView_C
