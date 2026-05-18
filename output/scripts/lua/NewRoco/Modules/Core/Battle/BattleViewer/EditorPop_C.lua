local EditorPop_C = _G.NRCUmgClass:Extend("EditorPop_C")
local PetUtils = require("NewRoco.Utils.PetUtils")

function EditorPop_C:Tick(MyGeometry, InDeltaTime)
  if not self.isStart then
    self.isStart = true
    self:Rebuild()
    self:PlayAnimation(self.Open)
  end
end

function EditorPop_C:Rebuild()
  self.Content:BuildNums()
  self.Content_1:BuildNums()
  local Content = "10"
  for i = 1, 8 do
    if i <= #Content then
      local c = Content:sub(i, i)
      self.Content.Nums[i]:SetText(c)
      self.Content.Nums[i]:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      self.Content_1.Nums[i]:SetText(c)
      self.Content_1.Nums[i]:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    else
      self.Content.Nums[i]:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Content_1.Nums[i]:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function EditorPop_C:SetPosition(target, targetPos)
end

function EditorPop_C:OnAnimationFinished(Animation)
  if Animation == self.Open then
    self:RemoveFromParent()
  end
end

return EditorPop_C
