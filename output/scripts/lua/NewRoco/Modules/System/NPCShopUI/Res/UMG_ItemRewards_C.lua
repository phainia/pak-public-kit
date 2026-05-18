local UMG_ItemRewards_C = _G.NRCPanelBase:Extend("UMG_ItemRewards_C")
local NPCShopUIModuleEvent = reload("NewRoco.Modules.System.NPCShopUI.NPCShopUIModuleEvent")

function UMG_ItemRewards_C:OnConstruct()
  self.uiData = {}
  self.canClose = false
end

function UMG_ItemRewards_C:OnDestruct()
end

function UMG_ItemRewards_C:OnActive(_param, text, IsLevelReward, ...)
  _G.NRCPanelBase.OnActive(self, _param, ...)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1066, "UMG_ItemRewards_C:OnActive")
  local SizeBoxPos = self.SizeBox.Slot:GetPosition()
  self.uiData = _param
  if IsLevelReward then
    self.Switcher:SetActiveWidgetIndex(1)
    self.IsLevelReward = true
    SizeBoxPos.y = 8
    if IsLevelReward < 10 then
      IsLevelReward = "0" .. IsLevelReward
    end
    self.NRCTitle_2:SetText(IsLevelReward)
    self.NRCTitle_3:SetText(IsLevelReward)
    self.SizeBox.Slot:SetPosition(SizeBoxPos)
  else
    self.Switcher:SetActiveWidgetIndex(0)
    self.IsLevelReward = false
    SizeBoxPos.y = -22.456974
    self.SizeBox.Slot:SetPosition(SizeBoxPos)
  end
  self:OnAddEventListener()
  _G.NRCProfilerLog:NRCPanelOpenAnimation(true, self.panelName)
  if self.IsLevelReward then
    self:PlayAnimation(self.In_2)
  else
    self:PlayAnimation(self.In)
  end
  self:SetDatas(_param)
  self.textInfo:SetText(text)
end

function UMG_ItemRewards_C:OnDeactive()
end

function UMG_ItemRewards_C:SetDatas(RewardsList)
  if RewardsList and #RewardsList > 0 then
    self.ItemList:InitList(RewardsList)
    if self.IsLevelReward then
      self:DelaySeconds(1.466, function()
        for i = 1, #RewardsList do
          if self.ItemList then
            local item = self.ItemList:GetItemByIndex(i - 1)
            if item then
              item:PlayAnimation(item.Open_1)
            end
          end
        end
      end)
    else
      self:DelaySeconds(0.55, function()
        for i = 1, #RewardsList do
          if self.ItemList then
            local item = self.ItemList:GetItemByIndex(i - 1)
            if item then
              item:PlayAnimation(item.Open_1)
            end
          end
        end
      end)
    end
  else
    self.ItemList:Clear()
  end
end

function UMG_ItemRewards_C:OnAddEventListener()
  self:AddButtonListener(self.btnClose, self.OnBtnCloseClick)
end

function UMG_ItemRewards_C:OnBtnCloseClick()
  if self.canClose == true then
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1008, "UMG_ItemRewards_C:OnBtnCloseClick")
    if self.IsLevelReward then
      self:PlayAnimation(self.Out_2)
    else
      self:PlayAnimation(self.Out)
    end
    self.canClose = false
  end
end

function UMG_ItemRewards_C:OnAnimationFinished(Animation)
  if self.Out == Animation or self.Out_2 == Animation then
    self.canClose = true
    _G.NRCModuleManager:GetModule("NPCShopUIModule"):DispatchEvent(NPCShopUIModuleEvent.NPCSHOP_ITEM_REWARS_CLOSE)
    self:DoClose()
  elseif Animation == self.In or Animation == self.In_2 then
    self:UnlockIsSelectBtn()
    self.canClose = true
    _G.NRCProfilerLog:NRCPanelOpenAnimation(false, self.panelName)
  end
end

function UMG_ItemRewards_C:UnlockIsSelectBtn()
  _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.UnlockIsSelectBtn, "BattlePassModule", "BattlePassAwardMain", _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetPanelSelectBtnReason, "BattlePassAwardMain").GET)
  _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.UnlockIsSelectBtn, "BattlePassModule", "BattlePassAwardMain", _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetPanelSelectBtnReason, "BattlePassAwardMain").TIPS)
end

return UMG_ItemRewards_C
