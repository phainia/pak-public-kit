local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local UMG_BattleEnterWindow_C = _G.NRCPanelBase:Extend("UMG_BattleEnterWindow_C")

function UMG_BattleEnterWindow_C:OnConstruct()
end

function UMG_BattleEnterWindow_C:OnDestruct()
end

function UMG_BattleEnterWindow_C:OnActive()
  self:SetVisibility(UE4.ESlateVisibility.Hidden)
  if self.Display then
    self.Display:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_BattleEnterWindow_C:ShowAnimation(SkillObj)
  self:SetVisibility(UE4.ESlateVisibility.Visible)
  if self.Display then
    self.Display:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  if not _G.BattleManager then
    Log.Error("UMG_Effect_EnterBattlePet_C BattleManager is Nil")
    return
  end
  local pawnManager = _G.BattleManager.battlePawnManager
  if not pawnManager then
    Log.Error("UMG_Effect_EnterBattlePet_C pawnManager is Nil")
    return
  end
  local LuaPet = pawnManager:GetTeamPet(BattleEnum.Team.ENUM_ENEMY, 1)
  if LuaPet then
    if self.Txt_PetName_1 then
      self.Txt_PetName_1:SetText(LuaPet.card.name)
    end
    if self.Txt_PetName_2 then
      self.Txt_PetName_2:SetText(LuaPet.card.name)
    end
    if self.Txt_Xuhao_1 then
      self.Txt_Xuhao_1:SetText(LuaPet.card.petBaseConf.id)
    end
    if self.Txt_Xuhao_2 then
      self.Txt_Xuhao_2:SetText(LuaPet.card.petBaseConf.id)
    end
    if LuaPet.card.petBaseConf.unit_type[1] then
      self.Icon_type1:SetVisibility(UE4.ESlateVisibility.Visible)
      local iconPath = _G.DataConfigManager:GetTypeDictionary(LuaPet.card.petBaseConf.unit_type[1]).type_icon
      local rsl = self.Icon_type1:SetPath(iconPath)
    else
      self.Icon_type1:SetVisibility(UE4.ESlateVisibility.Hidden)
    end
    if LuaPet.card.petBaseConf.unit_type[2] then
      self.Icon_type2:SetVisibility(UE4.ESlateVisibility.Visible)
      local iconPath = _G.DataConfigManager:GetTypeDictionary(LuaPet.card.petBaseConf.unit_type[2]).type_icon
      local rsl = self.Icon_type2:SetPath(iconPath)
    else
      self.Icon_type2:SetVisibility(UE4.ESlateVisibility.Hidden)
    end
  else
    Log.Debug("No pet...........")
  end
  if self.Root_shouchu then
    if _G.BattleManager.battleRuntimeData.battleStartParam.encountered then
      self.Root_shouchu:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      self.Root_shouchu:SetVisibility(UE4.ESlateVisibility.Hidden)
    end
  end
  self:PlayAnimation(self.Yuchong_In)
end

function UMG_BattleEnterWindow_C:PlayCloseAnimation()
  self:PlayAnimation(self[BattleConst.InPlace.SlideOut])
end

function UMG_BattleEnterWindow_C:OnAnimationFinished(Animation)
  if Animation == self[BattleConst.InPlace.SlideOut] then
    self:DoClose()
  end
end

function UMG_BattleEnterWindow_C:OnDeactive()
end

return UMG_BattleEnterWindow_C
