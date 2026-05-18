local UMG_WishPower_C = _G.NRCPanelBase:Extend("UMG_WishPower_C")
local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")

function UMG_WishPower_C:OnActive(shouldOpenTutorial)
  self:OnAddEventListener()
  self:InitUI()
end

function UMG_WishPower_C:OnDeactive()
  self:OnRemoveEventListener()
end

function UMG_WishPower_C:OnAddEventListener()
  _G.BattleEventCenter:Bind(self, BattlePerformEvent.WishPowerChange, BattlePerformEvent.WishPowerShow)
end

function UMG_WishPower_C:OnRemoveEventListener()
  _G.BattleEventCenter:UnBind(self)
end

function UMG_WishPower_C:InitUI()
  self.maxWishPower = math.floor(_G.DataConfigManager:GetBattleGlobalConfig("a1_finalbattle_energy_max").num / 2)
  local wishPowerData = {}
  for i = 1, self.maxWishPower do
    table.insert(wishPowerData, i)
  end
  self.VolitionValueList:InitGridView(wishPowerData)
  local CurRound = _G.BattleManager:GetCurRound()
  local initInfo = BattleUtils.GetBattleInitInfo()
  if initInfo.final_battle then
    local wishPower = initInfo.final_battle.final_battle_energy
    if wishPower and wishPower < self.maxWishPower * 2 and CurRound > 2 then
      self:ShowUI()
      self:OpenTutorialDownloadData()
    end
  end
end

function UMG_WishPower_C:PlayEnterAnim()
  local initInfo = BattleUtils.GetBattleInitInfo()
  if initInfo.final_battle then
    local wishPower = initInfo.final_battle.final_battle_energy
    if wishPower then
      if wishPower >= self.maxWishPower * 2 then
        return
      else
        self:PlayWishPowerItemAnim(wishPower)
      end
    end
  end
end

function UMG_WishPower_C:OnBattleEvent(eventName, ...)
  if eventName == BattlePerformEvent.WishPowerChange then
    self:ChangeWishPower(...)
  elseif eventName == BattlePerformEvent.WishPowerShow then
    self:ShowUI()
  end
end

function UMG_WishPower_C:ChangeWishPower(performInfo)
  if performInfo.sync_data.comm_sync_info[1].final_battle_energy_result then
    local wishPower = performInfo.sync_data.comm_sync_info[1].final_battle_energy_result
    self:PlayWishPowerItemAnim(wishPower)
  end
end

function UMG_WishPower_C:PlayWishPowerItemAnim(wishPower)
  if self.wishPowerNum then
    if wishPower > self.wishPowerNum then
      self:PlayWishPowerItemAnimAdd(wishPower)
    else
      self:PlayWishPowerItemAnimSub(wishPower)
    end
  else
    self:PlayWishPowerItemAnimAdd(wishPower)
  end
end

function UMG_WishPower_C:PlayWishPowerItemAnimAdd(wishPower)
  if wishPower > self.maxWishPower * 2 then
    Log.Error("\230\132\191\229\138\155\229\128\188\232\182\133\229\135\186\228\184\138\233\153\144\228\186\134\239\188\129")
    wishPower = self.maxWishPower * 2
  end
  if wishPower == self.maxWishPower * 2 then
    self.WishPowerIsMax = true
  end
  local oldWishPower = self.wishPowerNum or 0
  self.wishPowerNum = wishPower
  local startIndex = math.floor((oldWishPower + 1) / 2)
  local endIndex = math.floor((wishPower + 1) / 2)
  local hasStartHalfHp = 1 == oldWishPower % 2
  local hasEndHalfHp = 1 == wishPower % 2
  local completeHP = self.wishPowerNum - oldWishPower
  if hasStartHalfHp then
    completeHP = completeHP - 1
  end
  if hasEndHalfHp then
    completeHP = completeHP - 1
  end
  completeHP = math.floor(completeHP / 2)
  if hasStartHalfHp then
    local item = self.VolitionValueList:GetItemByIndex(startIndex - 1)
    if item then
      _G.NRCAudioManager:PlaySound2DAuto(1037, "UMG_WishPower_C:Add")
      item:PlayAnimation(item.Complete)
    else
      Log.Error("item \228\184\141\229\173\152\229\156\168\239\188\140index\230\152\175" .. startIndex - 1)
    end
    for i = startIndex + 1, startIndex + completeHP do
      local item = self.VolitionValueList:GetItemByIndex(i - 1)
      self:DelaySeconds(0.57 + 0.88 * (i - (startIndex + 1)), function()
        _G.NRCAudioManager:PlaySound2DAuto(1037, "UMG_WishPower_C:Add")
        item:PlayAnimation(item.Once)
      end)
    end
    if hasEndHalfHp then
      self:DelaySeconds(0.57 + 0.88 * (endIndex - startIndex - 1), function()
        _G.NRCAudioManager:PlaySound2DAuto(1037, "UMG_WishPower_C:Add")
        local item = self.VolitionValueList:GetItemByIndex(endIndex - 1)
        item:PlayAnimation(item.Half)
      end)
    end
  else
    for i = startIndex + 1, startIndex + completeHP do
      self:DelaySeconds(0.88 * (i - (startIndex + 1)), function()
        _G.NRCAudioManager:PlaySound2DAuto(1037, "UMG_WishPower_C:Add")
        local item = self.VolitionValueList:GetItemByIndex(i - 1)
        item:PlayAnimation(item.Once)
      end)
    end
    if hasEndHalfHp then
      self:DelaySeconds(0.88 * completeHP, function()
        _G.NRCAudioManager:PlaySound2DAuto(1037, "UMG_WishPower_C:Add")
        local item = self.VolitionValueList:GetItemByIndex(endIndex - 1)
        item:PlayAnimation(item.Half)
      end)
    end
  end
end

function UMG_WishPower_C:PlayWishPowerItemAnimSub(wishPower)
  if wishPower > self.maxWishPower * 2 or wishPower < 0 then
    return
  end
  local oldWishPower = self.wishPowerNum
  self.wishPowerNum = wishPower
  local startIndex = math.floor((oldWishPower + 1) / 2)
  local endIndex = math.floor((wishPower + 1) / 2)
  local hasStartHalfHp = 1 == oldWishPower % 2
  local hasEndHalfHp = 1 == wishPower % 2
  local completeHP = oldWishPower - self.wishPowerNum
  if hasStartHalfHp then
    completeHP = completeHP - 1
  end
  if hasEndHalfHp then
    completeHP = completeHP - 1
  end
  completeHP = math.floor(completeHP / 2)
  if hasStartHalfHp then
    local item = self.VolitionValueList:GetItemByIndex(startIndex - 1)
    if item then
      _G.NRCAudioManager:PlaySound2DAuto(1023, "UMG_WishPower_C:Sub")
      item:PlayAnimation(item.BackHalf)
    else
      Log.Error("item \228\184\141\229\173\152\229\156\168\239\188\140index\230\152\175" .. startIndex - 1)
    end
    for i = startIndex - 1, startIndex - completeHP, -1 do
      self:DelaySeconds(0.22 + 0.55 * (startIndex - i), function()
        _G.NRCAudioManager:PlaySound2DAuto(1023, "UMG_WishPower_C:Sub")
        local item = self.VolitionValueList:GetItemByIndex(i - 1)
        item:PlayAnimation(item.Out)
      end)
    end
    if hasEndHalfHp then
      self:DelaySeconds(0.22 + 0.55 * completeHP, function()
        _G.NRCAudioManager:PlaySound2DAuto(1023, "UMG_WishPower_C:Sub")
        local item = self.VolitionValueList:GetItemByIndex(endIndex - 1)
        item:PlayAnimation(item.BackComplete)
      end)
    end
  else
    for i = startIndex, startIndex - completeHP + 1, -1 do
      self:DelaySeconds(0.55 * (startIndex - i), function()
        _G.NRCAudioManager:PlaySound2DAuto(1023, "UMG_WishPower_C:Sub")
        local item = self.VolitionValueList:GetItemByIndex(i - 1)
        item:PlayAnimation(item.Out)
      end)
    end
    if hasEndHalfHp then
      self:DelaySeconds(0.55 * completeHP, function()
        _G.NRCAudioManager:PlaySound2DAuto(1023, "UMG_WishPower_C:Sub")
        local item = self.VolitionValueList:GetItemByIndex(endIndex - 1)
        item:PlayAnimation(item.BackComplete)
      end)
    end
  end
end

function UMG_WishPower_C:UploadData()
  local List = ProtoMessage:newPointList()
  local point = ProtoMessage:newPoint()
  point.pos.x = 1
  table.insert(List.points, point)
  _G.DataModelMgr.RemoteStorage:Set("WishPowerTutorial", ".Next.PointList", List, self, self.OnPutResult)
end

function UMG_WishPower_C:OnPutResult(rsp)
  Log.Dump(rsp, 2, "UMG_WishPower_C:OnPutResult")
end

function UMG_WishPower_C:OpenTutorialDownloadData()
  if self.hasShowUI and not self.hasShowTutorial then
    self.hasShowTutorial = true
    NRCModuleManager:DoCmd(BattleUIModuleCmd.OpenWishPowerTutorial)
  end
end

function UMG_WishPower_C:ShowUI()
  if not self.hasShowUI then
    local CurRound = _G.BattleManager:GetCurRound()
    if CurRound > 1 then
      self.hasShowUI = true
      self.VolitionValueList:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self:PlayAnimation(self.WishPowerIn)
    end
  end
end

function UMG_WishPower_C:OnAnimationFinished(anim)
  if anim == self.WishPowerIn then
    self:PlayEnterAnim()
  end
end

function UMG_WishPower_C:UIVisible()
  self:PlayAnimation(self.WishPowerIn)
end

function UMG_WishPower_C:UIInVisible()
  self:PlayAnimationReverse(self.WishPowerIn)
end

function UMG_WishPower_C:WishPowerMaxShineOut()
  for i = 1, self.maxWishPower do
    local item = self.VolitionValueList:GetItemByIndex(i - 1)
    item:PlayAnimation(item.Shine_Out)
  end
end

function UMG_WishPower_C:OnDialogueStart()
  if self.hasShowUI == true then
    self.VolitionValueList:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_WishPower_C:OnDialogueEnded()
  if self.hasShowUI == true then
    self.VolitionValueList:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end

return UMG_WishPower_C
