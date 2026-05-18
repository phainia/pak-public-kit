local UMG_Battle_WaitLoading_C = _G.NRCPanelBase:Extend("UMG_Battle_WaitLoading_C")

function UMG_Battle_WaitLoading_C:OnActive()
  self:OnInit()
  _G.UpdateManager:Register(self)
end

function UMG_Battle_WaitLoading_C:OnInit()
  self.burnTime = 0
  self.displayText = _G.DataConfigManager:GetBattleGlobalConfig("pvp_rank_character15").str
  self:SetRenderOpacity(1)
  self:SetContent()
  self:PlayAnimation(self.TweenIn)
end

function UMG_Battle_WaitLoading_C:OnDeactive()
  _G.UpdateManager:UnRegister(self)
end

function UMG_Battle_WaitLoading_C:SetContent()
  local waitTime = 0
  local waitTimeSeconds = 0
  if BattleManager.battleRuntimeData and BattleManager.battleRuntimeData.roundTime then
    waitTime = math.max(0, BattleManager.battleRuntimeData.roundTime - _G.ZoneServer:GetServerTime())
    waitTimeSeconds = math.ceil(waitTime / 1000)
  end
  if self.displayText then
    self.Text_Tips:SetText(string.format(self.displayText, waitTimeSeconds))
  else
    self.Text_Tips:SetText(string.format("%s", waitTimeSeconds))
    Log.Error("UMG_Battle_WaitLoading_C:SetContent display Text is nil")
  end
  if waitTime <= 0 then
    self:Hide()
  end
end

function UMG_Battle_WaitLoading_C:OnTick(InDeltaTime)
  if self.burnTime >= 0 then
    self.burnTime = self.burnTime + InDeltaTime
    if self.burnTime >= 1 then
      self:SetContent()
      self.burnTime = 0
    end
  end
end

function UMG_Battle_WaitLoading_C:Hide()
  self.burnTime = -1
  _G.UpdateManager:UnRegister(self)
  self:PlayAnimation(self.TweenOut)
end

function UMG_Battle_WaitLoading_C:OnAnimationFinished(Animation)
  if Animation == self.TweenOut then
    self:SetRenderOpacity(0)
    self:DoClose()
  end
end

return UMG_Battle_WaitLoading_C
