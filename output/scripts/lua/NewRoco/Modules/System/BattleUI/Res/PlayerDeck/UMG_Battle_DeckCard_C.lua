local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local UMG_Battle_DeckCard_C = NRCUmgClass:Extend("")

function UMG_Battle_DeckCard_C:Construct()
  self.heardExist = true
  self.curState = BattleConst.DeckCardState.None
end

function UMG_Battle_DeckCard_C:HideAll(isLeaderFight)
  self.Image:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Image_Back:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.ImageMask:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.ImageWild:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.ImageWild_Back:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.ImageLeaderFight:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if isLeaderFight then
    self.ImageLeaderFightMask:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.ImageLeaderFightMask:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.Pet:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_Battle_DeckCard_C:SetEmpty(isWild, isLeaderFight)
  isWild = isWild or false
  self.card = nil
  self.curState = BattleConst.DeckCardState.None
  self:HideAll(isLeaderFight)
  if isWild then
  else
    self.Image_Back:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end

function UMG_Battle_DeckCard_C:IsVisualEmpty()
  local v1 = self.Image:GetVisibility()
  local v2 = self.Image_Back:GetVisibility()
  local v3 = self.ImageMask:GetVisibility()
  local v4 = self.ImageWild:GetVisibility()
  local v5 = self.ImageWild_Back:GetVisibility()
  local v6 = self.ImageLeaderFight:GetVisibility()
  local v7 = self.ImageLeaderFightMask:GetVisibility()
  local v8 = self.Pet:GetVisibility()
  local check = {
    v1,
    v2,
    v3,
    v4,
    v5,
    v6,
    v7,
    v8
  }
  for i = 1, #check do
    if check[i] ~= UE4.ESlateVisibility.Collapsed and check[i] ~= UE4.ESlateVisibility.Hidden then
      return false
    end
  end
  return true
end

function UMG_Battle_DeckCard_C:SetState(nextState)
  local flag = nextState.isAlive
  local isWild = nextState.isWild
  local isLeaderFight = nextState.isLeaderFight
  local isEmpty = nextState.isEmpty
  local isSeriesFight = nextState.isSeriesFight
  local isRandomPet = nextState.isRandomPet
  if isEmpty then
    self:SetEmpty(isSeriesFight, isLeaderFight)
    return
  end
  self.card = nil
  isWild = isWild or false
  self:HideAll(isLeaderFight)
  if flag then
    self.curState = BattleConst.DeckCardState.Living
  else
    self.curState = BattleConst.DeckCardState.Dead
  end
  if isLeaderFight then
    if flag then
      self.heardExist = true
      self.ImageLeaderFight:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.ImageLeaderFight:SetRenderOpacity(1)
    elseif self.heardExist then
      self.heardExist = false
      self:PlayAnimation(self.hello)
    end
    return
  end
  local ImageVisibility = UE4.ESlateVisibility.Collapsed
  local ImagePath = ""
  local ImageMaskVisibility = UE4.ESlateVisibility.Collapsed
  local ImageMaskPath = ""
  if isWild then
    if flag then
      self.ImageWild:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.ImageWild_Back:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  elseif isRandomPet then
    if flag then
      ImageVisibility = UE4.ESlateVisibility.SelfHitTestInvisible
      ImagePath = BattleConst.RandomPetDeckCardIcon
    else
      ImageMaskVisibility = UE4.ESlateVisibility.SelfHitTestInvisible
      ImageMaskPath = BattleConst.RandomDeadPetDeckCardIcon
    end
  elseif flag then
    ImageVisibility = UE4.ESlateVisibility.SelfHitTestInvisible
    ImagePath = BattleConst.NormalPetDeckCardIcon
  else
    ImageMaskVisibility = UE4.ESlateVisibility.SelfHitTestInvisible
    ImageMaskPath = BattleConst.NormalDeadPetDeckCardIcon
  end
  self.Image:SetVisibility(ImageVisibility)
  self.Image:SetPath(ImagePath)
  self.ImageMask:SetVisibility(ImageMaskVisibility)
  self.ImageMask:SetPath(ImageMaskPath)
end

function UMG_Battle_DeckCard_C:SetB1FinalBattleP1Empty()
  self.card = nil
  self.curState = _G.BattleConst.DeckCardState.None
  self:HideAll(nil)
end

function UMG_Battle_DeckCard_C:SetB1FinalBattleP1State(flag)
  self.card = nil
  self:HideAll(nil)
  if flag then
    self.curState = _G.BattleConst.DeckCardState.Living
  else
    self.curState = _G.BattleConst.DeckCardState.Dead
  end
  if flag then
    self.heardExist = true
    self.Fx_bg_Nightmare:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  elseif self.heardExist then
    self.heardExist = false
    self:PlayAnimation(self.Nightmare_out)
  else
    self.Fx_bg_Nightmare:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Battle_DeckCard_C:Set1VNState(card, isLeaderFight)
  self.curState = BattleConst.DeckCardState.Living
  self.card = card
  self:HideAll(isLeaderFight)
  self.Pet:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.Pet:SetPath(NRCUtils:FormatConfIconPath(card.icon, _G.UIIconPath.HeadIconPath))
end

function UMG_Battle_DeckCard_C:PlayAnimationById(animId)
  if animId == BattleConst.EffectAnimation.ChangeToCute then
    self:PlayAnimation(self.Menghua)
  elseif animId == BattleConst.EffectAnimation.Resurrection then
    self:PlayAnimation(self.Resurrection)
  end
end

return UMG_Battle_DeckCard_C
