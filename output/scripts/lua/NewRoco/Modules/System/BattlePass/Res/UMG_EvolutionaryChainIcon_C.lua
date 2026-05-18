local BattlePassModuleEvent = require("NewRoco.Modules.System.BattlePass.BattlePassModuleEvent")
local UMG_EvolutionaryChainIcon_C = _G.NRCPanelBase:Extend("UMG_EvolutionaryChainIcon_C")

function UMG_EvolutionaryChainIcon_C:OnConstruct()
  self:OnAddEventListener()
end

function UMG_EvolutionaryChainIcon_C:OnDeactive()
end

function UMG_EvolutionaryChainIcon_C:SetData(data, isShining)
  self.data = data
  local petbaseConf = self.data:GetPetbascConf()
  local iconPath = self.data:GetPetIconPath(isShining)
  local handbookState = self.data:GetHandbookState()
  self.ColorfulHeadIcon:SetPetIconPathAndMaterial(iconPath, _G.Enum.MutationDiffType.MDT_SHINING)
  if petbaseConf and petbaseConf.name then
    self.NRCText_61:SetText(petbaseConf.name)
  end
  if handbookState ~= _G.ProtoEnum.PetHandbookStatus.PHS_COLLECTED then
    self.NRCText:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.NRCText_61:SetText("???")
  else
    self.NRCText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if handbookState == _G.ProtoEnum.PetHandbookStatus.PHS_COLLECTED and petbaseConf and petbaseConf.form and petbaseConf.form ~= "" then
    self.NRCText:SetText(petbaseConf.form)
    self.NRCText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.NRCText:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.NRCSwitcher_0:SetActiveWidgetIndex(handbookState == _G.ProtoEnum.PetHandbookStatus.PHS_COLLECTED and 0 or 1)
  self:PlayAnimation(self.In)
end

function UMG_EvolutionaryChainIcon_C:PlayOutAnimation()
  self:PlayAnimation(self.Out)
end

function UMG_EvolutionaryChainIcon_C:OnAddEventListener()
  self:AddButtonListener(self.Button_42, self.OnButton)
end

function UMG_EvolutionaryChainIcon_C:OnButton()
  if self.data:GetHandbookState() ~= _G.ProtoEnum.PetHandbookStatus.PHS_COLLECTED then
    _G.NRCAudioManager:PlaySound2DAuto(41401015, "UMG_EvolutionaryChainIcon_C:OnButton")
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.chain_undiscover_tips)
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(40002003, "UMG_EvolutionaryChainIcon_C:OnButton")
  _G.NRCEventCenter:DispatchEvent(BattlePassModuleEvent.UpdateSelectPetData, self.data.petbaseId)
end

function UMG_EvolutionaryChainIcon_C:PlaySelectAnimation()
  self:PlayAnimation(self.Select)
end

function UMG_EvolutionaryChainIcon_C:PlayNomarlAnimation()
  self:StopAllAnimations()
  self:PlayAnimation(self.Nomarl)
end

return UMG_EvolutionaryChainIcon_C
