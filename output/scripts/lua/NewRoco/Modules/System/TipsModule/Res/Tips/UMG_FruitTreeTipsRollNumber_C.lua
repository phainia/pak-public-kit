local UMG_RollNumber_C = require("NewRoco.Modules.System.PVPQualifier.Res.UMG_RollNumber_C")
local UMG_FruitTreeTipsRollNumber_C = UMG_RollNumber_C:Extend("UMG_FruitTreeTipsRollNumber_C")
local DigitTotal = 3
local MaxLimit = 999

function UMG_FruitTreeTipsRollNumber_C:OnConstruct()
  self.DigitListWidget = {
    self.Digit1,
    self.Digit2,
    self.Digit3
  }
  local Speed = 1
  local Len = #self.DigitListWidget
  for i = 1, Len do
    self.DigitListWidget[Len - i + 1]:InitSpeed(Speed)
    Speed = Speed * 1.5
  end
end

function UMG_FruitTreeTipsRollNumber_C:OnActive()
end

function UMG_FruitTreeTipsRollNumber_C:OnDeactive()
end

function UMG_FruitTreeTipsRollNumber_C:OnAddEventListener()
end

function UMG_FruitTreeTipsRollNumber_C:PlayRollNumberAnim(Form, To, Time)
  local DigitsNum = self:GetNumberDigits(To)
  for i = 1, #self.DigitListWidget do
    self.DigitListWidget[i]:SetVisibility(i > DigitsNum and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  UMG_RollNumber_C.PlayRollNumberAnim(self, Form, To, Time)
end

function UMG_FruitTreeTipsRollNumber_C:GetNumberDigits(Num)
  if 0 == Num then
    return 1
  end
  return #tostring(math.abs(Num))
end

function UMG_FruitTreeTipsRollNumber_C:GetDigitList(Value)
  local DigitList = {}
  while Value > 0 do
    table.insert(DigitList, Value % 10)
    Value = math.floor(Value / 10)
  end
  if #DigitList > DigitTotal then
    Log.Error("\230\149\176\229\173\151\232\191\135\229\164\167\239\188\140\232\182\133\229\135\186", DigitTotal, "\228\189\141\230\149\176\239\188\140 Value=", Value)
  end
  for i = #DigitList + 1, DigitTotal do
    DigitList[i] = 0
  end
  return DigitList
end

return UMG_FruitTreeTipsRollNumber_C
