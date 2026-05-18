local UMG_MiniGame_TaskItem_C = _G.NRCPanelBase:Extend("UMG_MiniGame_TaskItem_C")
local MiniGameModuleEvent = reload("NewRoco.Modules.System.MiniGame.MiniGameModuleEvent")

function UMG_MiniGame_TaskItem_C:SetData(Progress, Max, Nomen)
  self:SetVisibility(UE4.ESlateVisibility.Visible)
  if Progress.value >= 0 and Progress.value < 6 then
    for i = 1, self.List:GetItemCount() do
      local item = self.List:GetItemByIndex(i - 1)
      if not item then
        break
      end
      if i > Progress.value then
        item:SetActive(false)
      else
        item:SetActive(true)
      end
    end
    if not self.inited then
      NRCEventCenter:RegisterEvent("UMG_MiniGame_TaskItem_C", self, MiniGameModuleEvent.OnGameFinishedImmediate, self.OnGameFinishedImmediate)
      self.inited = true
    end
  end
end

function UMG_MiniGame_TaskItem_C:OnDestruct()
  NRCEventCenter:UnRegisterEvent(self, MiniGameModuleEvent.OnGameFinishedImmediate, self.OnGameFinishedImmediate)
end

function UMG_MiniGame_TaskItem_C:OnGameFinishedImmediate()
  for i = 1, self.List:GetItemCount() do
    local item = self.List:GetItemByIndex(i - 1)
    if not item then
      break
    end
    item:DelayPlayFullAnim(i * 0.05 + 0.5)
  end
end

return UMG_MiniGame_TaskItem_C
