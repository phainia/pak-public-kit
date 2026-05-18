local SleepingOwlModuleEvent = require("NewRoco.Modules.System.SleepingOwl.SleepingOwlModuleEvent")
local NavigationComponent = require("NewRoco.Modules.Core.Scene.Component.Movement.NavigationComponent")
local UMG_SleepingOwlSanctuary_C = _G.NRCPanelBase:Extend("UMG_SleepingOwlSanctuary_C")

function UMG_SleepingOwlSanctuary_C:Construct()
  _G.NRCPanelBase.Construct(self)
end

function UMG_SleepingOwlSanctuary_C:OnActive(RefugeId, Action)
  self.HandScrolling = false
  self.SelectedIndex = nil
  self.ChestMap = nil
  self.RefugeNpcId = RefugeId
  self.ChestListInited = false
  self.CurrentAction = Action
  self:RegisterEvents()
  self:InitView()
  _G.NRCProfilerLog:NRCPanelOpenAnimation(true, self.panelName)
  self:PlayAnimation(self.In)
  local selectIndex = self.ChestList:SelectItemByOffset(297)
  self.ChestList:SelectItemByIndex(selectIndex - 1)
end

function UMG_SleepingOwlSanctuary_C:InitView()
  self.ChestListInited = false
  self:RefreshView()
end

function UMG_SleepingOwlSanctuary_C:RefreshData(Info, InConfig)
  local function findAreaNameByInConfig(Config)
    local AreaId = Config.owl_area_id
    
    local AreaConf = _G.DataConfigManager:GetAreaConf(AreaId, true)
    return AreaConf.editor_name[1]
  end
  
  if InConfig then
    self.AreaName = findAreaNameByInConfig(InConfig)
    self.NofChests = #InConfig.reward
    self.NofLiberatedSleepingOwl = Info.obtained_owl_time
    self.OpenedChestIdxs = {}
    if Info.obtained_reward_idxs then
      for i = 1, #Info.obtained_reward_idxs do
        table.insert(self.OpenedChestIdxs, i, Info.obtained_reward_idxs[i] + 1 + 2)
      end
    end
    self.ChestMap = InConfig.reward
    self.ConfigId = Info.owl_refuge_cfg_id
  end
  if self.ChestMap == nil then
    return
  end
end

function UMG_SleepingOwlSanctuary_C:RefreshView()
  self:SetVisibility(UE4.ESlateVisibility.Visible)
  local RefugeInfo = NRCModeManager:DoCmd(SleepingOwlModuleCmd.GetInfoFromNpcId, self.RefugeNpcId)
  RefugeInfo = RefugeInfo or {
    owl_refuge_cfg_id = 1,
    obj_id = 120000006,
    obtained_reward_idxs = {
      1,
      2,
      3
    },
    obtained_owl_time = 5,
    pos = nil
  }
  local RefugeConf = _G.DataConfigManager:GetOwlSanctuaryConf(RefugeInfo.owl_refuge_cfg_id)
  self:RefreshData(RefugeInfo, RefugeConf)
  if nil == self.ChestMap then
    return
  end
  local Chestlist = {}
  for i = 1, #self.ChestMap do
    table.insert(Chestlist, {
      State = "",
      reward_level = self.ChestMap[i].reward_level,
      reward_id = self.ChestMap[i].reward_id
    })
  end
  table.insert(Chestlist, 1, {State = "", reward_level = -1})
  table.insert(Chestlist, 2, {State = "", reward_level = -1})
  table.insert(Chestlist, {State = "", reward_level = -1})
  table.insert(Chestlist, {State = "", reward_level = -1})
  table.insert(Chestlist, {State = "", reward_level = -1})
  for i = 1, #Chestlist do
    if Chestlist[i].reward_level > -1 then
      if Chestlist[i].reward_level > self.NofLiberatedSleepingOwl then
        Chestlist[i].State = "Locked"
      else
        for j = 1, #self.OpenedChestIdxs do
          if self.OpenedChestIdxs[j] == i then
            Chestlist[i].State = "Opened"
            goto lbl_137
          end
        end
        Chestlist[i].State = "CanBeOpen"
      end
    end
    ::lbl_137::
  end
  if not self.ChestListInited then
    self.ChestList:InitList(Chestlist)
  end
  table.clear(Chestlist)
  self.ConfirmBtn:SetBtnText(LuaText.umg_sleepingowlsanctuary_1)
  self.Address:SetText(self.AreaName)
  self.Quantity:SetText(tostring(self.NofLiberatedSleepingOwl))
end

function UMG_SleepingOwlSanctuary_C:RegisterEvents()
  self:AddButtonListener(self.ConfirmBtn.btnLevelUp, self.OnClickFeed)
  self:AddButtonListener(self.CloseBtn.btnClose, self.OnClickClose)
  self.ChestList.OnUserScrolled:Add(self, self.OnLevelListScrolled)
end

function UMG_SleepingOwlSanctuary_C:OnClickFeed()
  local selectedItem = self.ChestList:GetSelectedItem()
  if not selectedItem then
    Log.Error("nothing selected, thats weird")
    return
  end
  local itemState = selectedItem.uiData.State
  if "CanBeOpen" == itemState then
    local idx = selectedItem.index - 3
    selectedItem:OpenBox(self, function(this, Item)
      this.OnBoxOpened(this, Item)
      local RewardInfos = {}
      local RewardConf = _G.DataConfigManager:GetRewardConf(self.ChestMap[idx + 1].reward_id)
      local RewardsInConf = RewardConf.RewardItem
      for _, item in ipairs(RewardsInConf) do
        table.insert(RewardInfos, {
          itemId = item.Id,
          id = item.Id,
          num = item.Count,
          type = item.Type
        })
      end
      _G.NRCModuleManager:DoCmd(NPCShopUIModuleCmd.OpenNPCShopItemRewardsPanel, RewardInfos)
    end)
  end
end

function UMG_SleepingOwlSanctuary_C:OnBoxOpened(Item)
  Item.uiData.State = "Opened"
  self:SendRewardReq(Item.index - 3)
end

function UMG_SleepingOwlSanctuary_C:SendRewardReq(RewardIdx)
  local req = _G.ProtoMessage:newZoneSceneReceiveOwlRefugeRewardReq()
  req.npc_id = self.RefugeNpcId
  req.reward_idx = RewardIdx
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrCmd.ZONE_SCENE_RECEIVE_OWL_REFUGE_REWARD_REQ, req)
end

function UMG_SleepingOwlSanctuary_C:OnClickClose()
  Log.Debug("UMG_SleepingOwlSanctuary_C:OnClickClose")
  self:PlayAnimation(self.Out)
end

function UMG_SleepingOwlSanctuary_C:OnAnimationFinished(Animation)
  if Animation == self.In then
    _G.NRCProfilerLog:NRCPanelOpenAnimation(false, self.panelName)
  elseif Animation == self.Out then
    if self.CurrentAction then
      self.CurrentAction:Finish()
    end
    self:DoClose()
    NRCModuleManager:DoCmd(FunctionBanModuleCmd.RemoveCondition, Enum.PlayerConditionType.PCT_OPTION)
    NRCModeManager:GetCurMode():RevertPanelEnableStateByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
    self.CurrentAction = nil
  end
end

function UMG_SleepingOwlSanctuary_C:OnTick(deltaTime)
  if self.HandScrolling == false then
    self.ChestList:TempTick(deltaTime, 0)
  end
  local index = self.ChestList:SelectItemByOffset(297)
  if index ~= self.SelectedIndex and false == self.ChestList.bScrollBySelf and index >= 0 and index < #self.ChestList + 1 + 3 then
    self.ChestList:SelectItemByIndex(index)
  end
  local SelectedItem = self.ChestList:GetSelectedItem()
  if SelectedItem then
    if SelectedItem.uiData.State == "CanBeOpen" then
      self.ConfirmBtn:SetIsEnabled(true)
    else
      self.ConfirmBtn:SetIsEnabled(false)
    end
  end
  self.SelectedIndex = index
  self.HandScrolling = false
end

function UMG_SleepingOwlSanctuary_C:OnLevelListScrolled(offset)
  self.HandScrolling = true
end

function UMG_SleepingOwlSanctuary_C:OnDeactive()
end

function UMG_SleepingOwlSanctuary_C:OnAddEventListener()
end

return UMG_SleepingOwlSanctuary_C
