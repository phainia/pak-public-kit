local LevelUpUtils = require("NewRoco.Modules.System.LevelUpUI.LevelUpUtils")
local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local UMG_LevelMagician_C = _G.NRCPanelBase:Extend("UMG_LevelMagician_C")
local LevelUpType = {
  None = 0,
  Primary = 1,
  Normal = 2,
  Master = 3,
  CloseCountDown = 4
}

function UMG_LevelMagician_C:OnActive(param)
  if _G.GlobalConfig.DebugOpenUI then
    self:OnAddEventListener()
    return
  end
  if nil == param then
    Log.Error("UMG_LevelMagician_C\231\154\132param\230\151\160\232\174\186\229\166\130\228\189\149\233\131\189\228\184\141\232\131\189\228\184\186\231\169\186\239\188\140\228\184\186\231\169\186\231\154\132\232\175\157\228\184\128\229\174\154\230\152\175\230\156\137\228\186\186\229\164\141\229\136\182\228\186\134\228\184\128\228\187\189UMG\231\132\182\229\144\142\230\178\161\230\156\137\230\148\185Lua\229\188\149\231\148\168\239\188\140\232\175\183\231\156\139\229\136\176\232\191\153\232\161\140\230\138\165\233\148\153\231\154\132\228\186\186\232\189\172\229\145\138\228\184\128\228\184\139marvynwang\228\189\160\228\185\139\229\137\141\231\154\132\230\147\141\228\189\156\230\152\175\228\187\128\228\185\136\239\188\140\230\152\175\229\156\168\229\176\157\232\175\149\229\188\128\228\187\128\228\185\136\231\149\140\233\157\162")
    self:DoClose()
    return
  end
  self:SetChildViews(self.Star_0, self.Star_1, self.Star_2, self.Star_3, self.Star_4, self.Star_5, self.Star_6, self.Star_7, self.Star_8, self.Star_9)
  self.BtnClose:SetIsEnabled(false)
  self.action = param.action
  self:OnAddEventListener()
  local world_level = _G.DataModelMgr.PlayerDataModel:GetPlayerWorldLevel()
  self.TargetWorldLevelConf = LevelUpUtils.GetWorldLevelConfByWorldLevel(world_level)
  self.CurrentWorldLevelConf = LevelUpUtils.GetWorldLevelConfByWorldLevel(world_level - 1)
  if self.TargetWorldLevelConf and self.CurrentWorldLevelConf then
    self.MagicianTitle:SetText(self.CurrentWorldLevelConf.title)
    self.Fx_Title_1:SetText(self.TargetWorldLevelConf.title)
    self.levelUplist:InitGridView()
  end
  self.State = LevelUpType.None
  self.DelayCancelList = true
  _G.UpdateManager:UnRegister(self)
  self.DeltaTimer = 0.0
  self.FinishTime = 0.5
  self:UpgradeToWorldLevel(world_level)
  self:PlayAnimation(self.PrimaryUp_1)
  self:PlayAnimation(self.Star_move_1)
end

function UMG_LevelMagician_C:OnDeactive()
  self:OnRemoveEventListener()
end

function UMG_LevelMagician_C:OnAddEventListener()
  self:AddButtonListener(self.BtnClose, self.CloseBtnClick)
  _G.NRCEventCenter:RegisterEvent("UMG_LevelMagician_C", self, DialogueModuleEvent.DialogueEnded, self.OnDialogueEnded)
end

function UMG_LevelMagician_C:OnRemoveEventListener()
  _G.NRCEventCenter:UnRegisterEvent(self, DialogueModuleEvent.DialogueEnded, self.OnDialogueEnded)
end

function UMG_LevelMagician_C:OnDialogueEnded()
  self:DoClose()
end

function UMG_LevelMagician_C:CloseBtnClick()
  self:PlayAnimation(self.Out)
end

function UMG_LevelMagician_C:UpgradeToWorldLevel(worldLevel)
  if worldLevel < 1 then
    return
  end
  if 1 == worldLevel then
    self.State = LevelUpType.Primary
  elseif 10 == worldLevel then
    self.State = LevelUpType.Master
  else
    self.State = LevelUpType.Normal
  end
  self:PrepareStarList()
  self.TargetStar = self["Star_" .. worldLevel - 1]
  self.FinishPos = self["Star_" .. worldLevel - 1].Slot:GetPosition()
  self.StartPos = self.Fx_bg_star.Slot:GetPosition()
  self:DoPerform()
end

function UMG_LevelMagician_C:DoPerform()
  if self.State == LevelUpType.Primary then
  elseif self.State == LevelUpType.Normal then
  elseif self.State == LevelUpType.Master then
  end
  self:PrepareLevelUpList()
end

function UMG_LevelMagician_C:PrepareLevelUpList()
  self.reward_data = {}
  local oldDesc = self.CurrentWorldLevelConf.revival_desc
  for i, item in ipairs(self.TargetWorldLevelConf.revival_desc) do
    local reward = {}
    local oldreward = {}
    if oldDesc and oldDesc[i] then
      oldreward = {
        content = oldDesc[i].desc,
        value = oldDesc[i].upvalue,
        icon = oldDesc[i].up_icon or ""
      }
    end
    local iconPath = ""
    if item.up_icon then
      iconPath = item.up_icon
    end
    if item.upvalue then
      reward = {
        content = item.desc,
        value = item.upvalue,
        icon = iconPath
      }
    else
      reward = {
        content = item.desc,
        value = nil,
        icon = iconPath
      }
    end
    table.insert(self.reward_data, {
      reward = reward,
      oldreward = oldreward,
      panel = self
    })
  end
  _G.NRCAudioManager:PlaySound2DAuto(1220002061, "UMG_LevelMagician_C:PrepareLevelUpList")
  self.levelUplist:InitGridView(self.reward_data)
  local count = self.levelUplist:GetItemCount()
  for i = 1, count do
    local item = self.levelUplist:GetItemByIndex(i - 1)
    self:DelaySeconds(0.05 * i, function()
      item:SetVisibility(UE.ESlateVisibility.Visible)
      item:PlayAnimation(item.In)
    end)
  end
end

function UMG_LevelMagician_C:PrepareStarList()
  local starData = LevelUpUtils.GetStarListData()
  for i, item in ipairs(starData) do
    local index = i - 1
    self["Star_" .. index]:OnItemUpdate(item)
    if item.isStar or item.isNext then
      self["Star_" .. index]:SetVisibility(UE4.ESlateVisibility.Visible)
    end
  end
end

function UMG_LevelMagician_C:SetCloseBtnClick()
end

function UMG_LevelMagician_C:OnTick(DeltaTime)
  if self.FinishPos and self.StartPos then
    self.DeltaTimer = self.DeltaTimer + DeltaTime
    if self.DeltaTimer >= self.FinishTime then
      self.Fx_bg_star.Slot:SetPosition(self.FinishPos)
      self.MagicianTitle:SetText(self.TargetWorldLevelConf.title)
      self:PlayAnimation(self.Title_levelup)
      self:PlayAnimation(self.PrimaryUp2)
      self.TargetStar:PlayAnimationIn()
      _G.UpdateManager:UnRegister(self)
    else
      local ratio = self.DeltaTimer / self.FinishTime
      local x = (self.FinishPos.x - self.StartPos.x) * ratio + self.StartPos.x
      local y = (self.FinishPos.y - self.StartPos.y) * ratio + self.StartPos.y
      local pos = UE4.FVector2D(x, y)
      self.Fx_bg_star.Slot:SetPosition(pos)
    end
  end
end

function UMG_LevelMagician_C:SetBtnClick()
  if not self.BtnEnable then
    self.BtnEnable = true
    self.BtnClose:SetIsEnabled(true)
  end
end

function UMG_LevelMagician_C:OnAnimationFinished(Animation)
  if Animation == self.Out then
    if self.action and self.action.EndAction then
      self.action:EndAction()
    end
    self:DoClose()
  end
  if Animation == self.PrimaryUp_1 then
    local world_level = _G.DataModelMgr.PlayerDataModel:GetPlayerWorldLevel()
    if 0 == world_level then
      Log.Error("\230\156\137\229\164\167\233\151\174\233\162\152,\228\186\186\231\137\169\232\191\155\233\152\182\231\154\132\230\152\159\233\152\182\230\152\1750,\231\155\180\230\142\165\229\133\179\233\151\173\231\149\140\233\157\162")
      if self.action and self.action.EndAction then
        self.action:EndAction()
      end
      self:DoClose()
    end
  end
  if Animation == self.Star_move_1 then
    self:PlayAnimation(self.Star_move_2)
    _G.UpdateManager:Register(self)
  end
  if Animation == self.Title_levelup then
    self:PlayAnimation(self.Title_loop)
  end
  if Animation == self.Title_loop then
    self:PlayAnimation(self.Title_loop)
  end
  if Animation == self.PrimaryUp2 then
    self:CancelDelay()
    local count = self.levelUplist:GetItemCount()
    for i = 1, count do
      local item = self.levelUplist:GetItemByIndex(i - 1)
      item:SetVisibility(UE.ESlateVisibility.Visible)
      item:PlayAnimation(item.Star_in)
      item:UpdateValue()
    end
  end
end

return UMG_LevelMagician_C
