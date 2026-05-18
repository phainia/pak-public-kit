require("UnLuaEx")
local BagModuleEnum = require("NewRoco.Modules.System.Bag.BagModuleEnum")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local UMG_BattleBallEntryMore_C = NRCUmgClass:Extend("UMG_BattleBallEntryMore_C")

function UMG_BattleBallEntryMore_C:Initialize(Initializer)
  self.battleManager = _G.BattleManager
  self.ballData = nil
  self.ballBagCfg = nil
end

function UMG_BattleBallEntryMore_C:OnMouseButtonDown(MyGeometry, MouseEvent)
  Log.Debug("UMG_BattleBallEntryMore_C:OnMouseButtonDown")
  return UE4.UWidgetBlueprintLibrary.Handled()
end

function UMG_BattleBallEntryMore_C:OnMouseButtonUp(MyGeometry, MouseEvent)
  Log.Debug("UMG_BattleBallEntryMore_C:OnMouseButtonUp")
  return UE4.UWidgetBlueprintLibrary.Handled()
end

function UMG_BattleBallEntryMore_C:Construct()
  _G.BattleEventCenter:Bind(self, BattleEvent.BATTLE_CLICKED_BALL, BattleEvent.CHANGE_OPERATE_TYPE)
  self._timer = 0
  self._longPressThreshold = BattleConst.ItemLongPressThreshold
  self._pressed = false
  self._isSelect = false
  self.curOperateType = BattleEnum.Operation.ENUM_CATCH
end

function UMG_BattleBallEntryMore_C:Destruct()
  _G.BattleEventCenter:UnBind(self)
  NRCUmgClass.Destruct(self)
end

function UMG_BattleBallEntryMore_C:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.BATTLE_CLICKED_BALL then
    self:OnClickedBall(...)
  elseif eventName == BattleEvent.CHANGE_OPERATE_TYPE then
    self:OnOperatePanelChanged(...)
  end
end

function UMG_BattleBallEntryMore_C:OnOperatePanelChanged(operateType)
  self.curOperateType = operateType
end

function UMG_BattleBallEntryMore_C:OnItemPressed()
end

function UMG_BattleBallEntryMore_C:OnItemRelease()
end

function UMG_BattleBallEntryMore_C:_OnItemPressed()
  self._pressed = true
  self._timer = self._longPressThreshold
end

function UMG_BattleBallEntryMore_C:_OnItemRelease()
  if self._pressed then
    self:DoClick()
  end
  self._pressed = false
end

function UMG_BattleBallEntryMore_C:Tick(geometry, deltaTime)
  if not self._pressed then
    return
  end
  self._timer = self._timer - deltaTime
  if self._timer <= 0 then
    self:DoLongClick()
  end
end

function UMG_BattleBallEntryMore_C:OnClickedBall(ballData)
  if not (self.ballData and ballData) or ballData.id ~= self.ballData.id then
    self._isSelect = false
  end
end

function UMG_BattleBallEntryMore_C:OnAnimationFinished(Animation)
  if self.Btn_Click ~= Animation or self._isSelect then
  end
end

function UMG_BattleBallEntryMore_C:DoClick()
  if self.bCanCatch == false then
    return
  end
  if self.curOperateType == BattleEnum.Operation.ENUM_CATCH then
    self._isSelect = true
    self:PlayAnimation(self.Btn_Click)
    _G.NRCModuleManager:DoCmd(BagModuleCmd.OpenBagMainPanel, BagModuleEnum.DisplayMode.BattleCatch)
    _G.NRCModuleManager:DoCmd(BagModuleCmd.SetBattleSelectItemData, _G.BattleManager.battleRuntimeData.catchInfo)
    _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.ShowOrHideBattlePopUpTips, false)
    NRCModuleManager:DoCmd(BattleUIModuleCmd.HideChangePetConfirm3, true, true)
    NRCModuleManager:DoCmd(BattleUIModuleCmd.HideChangePetConfirm, true, true)
  end
end

function UMG_BattleBallEntryMore_C:DoLongClick()
  self._pressed = false
  self._timer = 0
end

function UMG_BattleBallEntryMore_C:SetData(itemData)
  Log.Debug("UMG_BattleBallEntry_C SetData")
  if not itemData then
    self.ballData = itemData
    return
  else
  end
  self.ballData = itemData
  if self.ballData then
    self.ballBagCfg = _G.DataConfigManager:GetBagItemConf(self.ballData.conf_id)
    if not self.ballBagCfg then
      Log.Error("UMG_BattleBallEntry_C Bag Conf not found " .. self.ballData.conf_id)
    end
    _G.BattleManager.battleRuntimeData.catchInfo.curUseBallId = self.ballData.id
    _G.BattleManager.battleRuntimeData.catchInfo.curUseBallGID = self.ballData.gid
    _G.BattleEventCenter:Dispatch(BattleEvent.BATTLE_CLICKED_BALL, self.ballData)
  end
end

function UMG_BattleBallEntryMore_C:SetCanCatch(bCanCatch, CatchMsg)
  self.CatchMsg = CatchMsg
  self.bCanCatch = bCanCatch
  self.BanImage:SetVisibility(bCanCatch and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible)
end

return UMG_BattleBallEntryMore_C
