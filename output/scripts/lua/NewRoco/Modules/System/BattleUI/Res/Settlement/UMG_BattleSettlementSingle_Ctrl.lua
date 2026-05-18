local BattlePawnManager = require("NewRoco.Modules.Battle.View.BattlePawnManager")
local BattleCard = require("NewRoco.Modules.Battle.Entity.Card.BattleCard")
local Timer = require("Utils.Timer")
local PetUtils = require("NewRoco.UI.LobbyPet.PetUtils")
local WindowID = require("NewRoco.Modules.UI.WindowID")
local ProtoEnum = require("NewRoco.PB.ProtoEnum")
local Base = require("NewRoco.Modules.UI.UIWindowCtrlBase")
local UMG_BattleSettlementSingle_Ctrl = Base:Extend("UMG_BattleSettlementSingle_Ctrl")

function UMG_BattleSettlementSingle_Ctrl:OnInit()
  self.bagItems = {}
end

function UMG_BattleSettlementSingle_Ctrl:OnClosed()
  self.OnExit = nil
  self.bagItems = {}
  self.CanClose = false
end

function UMG_BattleSettlementSingle_Ctrl:OnBeforeOpen()
  local data = _G.BattleManager.battleRuntimeData.battleSettleData.data
  if not data then
    Log.ErrorFormat("Settle Data is nil")
    return
  end
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1024, "UMG_BattleSettlementSingle_Ctrl:OnBeforeOpen")
  if _G.BattleManager.battleRuntimeData.battleSettleData:BattleResult() == ProtoEnum.BATTLE_RESULT_TYPE.TRUE_BATTLE_RESULT_WIN then
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1025, "UMG_BattleSettlementSingle_Ctrl:OnBeforeOpen")
  else
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1026, "UMG_BattleSettlementSingle_Ctrl:OnBeforeOpen")
  end
  local petchanges = data.ret_info.goods_change_info.changes
  local rewards = data.reward.rewards
  local items = {}
  local petDatas = {}
  if petchanges then
    for i, change in ipairs(petchanges) do
      if change.type == ProtoEnum.GoodsType.GT_PET then
        petDatas[#petDatas + 1] = change.pet_data
      end
    end
  end
  if rewards then
    for i, reward in ipairs(rewards) do
      if reward.type == ProtoEnum.GoodsType.GT_BAGITEM or reward.type == ProtoEnum.GoodsType.GT_VITEM then
        items[#items + 1] = {data = reward, item = nil}
      end
    end
  end
  if 0 == #items then
    self.bind.BagItemListView:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.bind.NoItemPanel:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.bind.BagItemListView:SetVisibility(UE4.ESlateVisibility.Visible)
    self.bind.NoItemPanel:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.bind.BagItemListView:SetDatas(items)
  end
  local oldPetDatas = _G.BattleManager.battleRuntimeData.battleStartParam.petDatas
  local oldPetDatasMap = {}
  for _, p in ipairs(oldPetDatas) do
    oldPetDatasMap[p.gid] = p
  end
  local learnedSkillPets = {}
  for i, petData in ipairs(petDatas) do
    local oldPetData = oldPetDatasMap[petData.gid]
    if oldPetData then
      self.bind.petInfoUI[i]:SetVisibility(_G.UE4.ESlateVisibility.Visible)
      self.bind.petInfoUI[i]:SetData(oldPetData, petData)
      local learned = PetUtils.CheckLearnNewSkill(oldPetData, petData)
      if learned then
        learnedSkillPets[#learnedSkillPets + 1] = {oldPetData, petData}
      end
    else
      self.bind.petInfoUI[i]:SetVisibility(_G.UE4.ESlateVisibility.Hidden)
    end
  end
  self.waitSeconds = 5
  self.timer = Timer()
  self.bind:BindToAnimationFinished(self.bind.MainAnim, {
    self:CreateUDelegate(function(self)
      if #items > 0 then
        local curIdx = 1
        local showBagItemHandle
        showBagItemHandle = self.timer:Every(0.25, function()
          if curIdx > #items then
            self.timer:Cancel(showBagItemHandle)
            return
          end
          local item = items[curIdx].item
          item:SetVisibility(UE4.ESlateVisibility.Visible)
          item:PlayAnimation(item.appear)
          UE4.UNRCAudioManager.Get():PlaySound2DAuto(1027, "UMG_BattleSettlementSingle_Ctrl:OnBeforeOpen")
          curIdx = curIdx + 1
        end)
      end
      self.timer:After(4, function()
        if 0 == #learnedSkillPets then
          local updateWaitSecondsHandle
          updateWaitSecondsHandle = self.timer:Every(1, function()
            self.waitSeconds = self.waitSeconds - 1
            self.bind.WaitSecondsTxt:SetText(string.format("%ds", self.waitSeconds))
            if 0 == self.waitSeconds then
              self.timer:Cancel(updateWaitSecondsHandle)
              self:OnCloseBtnClicked()
            end
          end)
        else
          local currentIdx = 1
          local showNewSkillCallback
          
          function showNewSkillCallback()
            if currentIdx < #learnedSkillPets then
              self.timer:After(0.1, function()
                currentIdx = currentIdx + 1
                _G.UIManager:OpenWindow(WindowID.UMG_PageNewSkill, {caller = self, callback = showNewSkillCallback}, {
                  learnedSkillPets[currentIdx][1],
                  learnedSkillPets[currentIdx][2]
                })
              end)
            else
              local updateWaitSecondsHandle
              updateWaitSecondsHandle = self.timer:Every(1, function()
                self.waitSeconds = self.waitSeconds - 1
                self.bind.WaitSecondsTxt:SetText(string.format("%ds", self.waitSeconds))
                if 0 == self.waitSeconds then
                  self.timer:Cancel(updateWaitSecondsHandle)
                  self:OnCloseBtnClicked()
                end
              end)
            end
          end
          
          _G.UIManager:OpenWindow(WindowID.UMG_PageNewSkill, {caller = self, callback = showNewSkillCallback}, {
            learnedSkillPets[1][1],
            learnedSkillPets[1][2]
          })
        end
      end)
    end)
  })
end

function UMG_BattleSettlementSingle_Ctrl:OnTick(deltaTime)
  self.timer:Update(deltaTime)
end

function UMG_BattleSettlementSingle_Ctrl:OnAddEventListener()
  self:AddClickListener(self.bind.CloseBtn, self.OnCloseBtnClicked)
end

function UMG_BattleSettlementSingle_Ctrl:OnCloseBtnClicked()
  if not self.CanClose then
    return
  end
  if self.OnExit then
    self.OnExit()
  end
  self:CloseSelf()
end

return UMG_BattleSettlementSingle_Ctrl
