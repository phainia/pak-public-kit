local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local UMG_Battle_Top_Panel_C = NRCUmgClass:Extend("")

function UMG_Battle_Top_Panel_C:Construct()
  self.battleManager = _G.BattleManager
  self:AddListener()
end

function UMG_Battle_Top_Panel_C:Destruct()
  NRCUmgClass.Destruct(self)
end

function UMG_Battle_Top_Panel_C:SetRound(round)
  round = round or 1
  if not type(round) == "number" then
    Log.Error("round need number")
    return
  end
  local one = 0
  local ten = 0
  if round > 99 then
    ten = math.fmod(round, 100)
    ten = math.modf(ten / 10)
    one = math.fmod(ten, 10)
  elseif round > 9 then
    ten = math.modf(round / 10)
    one = math.fmod(round, 10)
  else
    ten = 0
    one = round
  end
  if 0 == ten then
    self.Num1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.Num1:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  self.Num1:ChangeImage(ten)
  self.Num2:ChangeImage(one)
end

function UMG_Battle_Top_Panel_C:AddListener()
end

function UMG_Battle_Top_Panel_C:OnAnimationFinished(Animation)
  if Animation == self.disappear then
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Battle_Top_Panel_C:RemoveListener()
end

function UMG_Battle_Top_Panel_C:Show()
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_Battle_Top_Panel_C:Hide(withAnim)
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

return UMG_Battle_Top_Panel_C
