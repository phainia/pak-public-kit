local TipsModuleEvent = reload("NewRoco.Modules.System.TipsModule.TipsModuleEvent")
local PetUtils = require("NewRoco.Utils.PetUtils")
local UMG_PetEvoTip_C = _G.NRCPanelBase:Extend("UMG_PetEvoTip_C")

function UMG_PetEvoTip_C:OnConstruct()
  self.showEvoTips = true
end

function UMG_PetEvoTip_C:OnDestruct()
end

function UMG_PetEvoTip_C:OnActive()
end

function UMG_PetEvoTip_C:OnDeactive()
end

function UMG_PetEvoTip_C:SetIcon(_ballId)
  local BallId = _ballId
  if 0 == BallId then
    BallId = 100002
  end
  local CurIconConf = _G.DataConfigManager:GetBallConf(BallId)
  if CurIconConf then
    local CurIconPath = CurIconConf.ball_tips_icon
    self.CurIcon:SetPath(CurIconPath)
  end
end

function UMG_PetEvoTip_C:SetDisableEvoTips(disable)
  if disable then
    self:ShowEvoTip(0)
  end
  self.disableEvoTips = disable
end

function UMG_PetEvoTip_C:TipShowOrHide(on)
  if on then
    self.showEvoTips = true
    self:MainuiShowEvoTip()
  else
    self.showEvoTips = false
  end
end

function UMG_PetEvoTip_C:MainuiShowEvoTip()
  if self.showEvoTips == true then
    local data = self:GetEvo()
    if not data then
      self:ShowEvoTip(0)
    elseif true == data then
      self:ShowEvoTip(10)
    end
  end
end

function UMG_PetEvoTip_C:GetEvo()
  local battlePetList = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetInfo()
  if battlePetList then
    for i, petData in pairs(battlePetList) do
      local data = PetUtils.GetLevelUpData(petData)
      if data and data.evoType == true then
        return true
      end
    end
  end
  return nil
end

function UMG_PetEvoTip_C:ShowEvoTip(evoNum)
  if self.disableEvoTips then
    return
  end
  self:StopAllAnimations()
  if 0 == evoNum then
    self.Image_evo:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.ParticleSystemWidget2_53:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.ParticleSystemWidget2:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif 10 == evoNum then
    self.Image_evo:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.ParticleSystemWidget2_53:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.ParticleSystemWidget2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:PlayAnimation(self.top, 0, 9999)
  elseif 1 == evoNum then
    self:PlayAnimation(self.Low, 0, 9999)
  elseif 2 == evoNum then
    self:PlayAnimation(self.Middle, 0, 9999)
  elseif 3 == evoNum then
    self:PlayAnimation(self.High, 0, 9999)
  end
end

return UMG_PetEvoTip_C
