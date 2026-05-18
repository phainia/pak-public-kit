local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local LoadingUIModuleEvent = require("NewRoco.Modules.System.LoadingUIModule.LoadingUIModuleEvent")
local UMG_BattleLoading_C = NRCPanelBase:Extend("UMG_BattleLoading_C")

function UMG_BattleLoading_C:OnConstruct()
  self.uiData = {}
  self.isIn = false
  NRCEventCenter:RegisterEvent("UMG_BattleLoading_C", self, BattleEvent.StartTweenOut, self.PlayTweenOut)
end

function UMG_BattleLoading_C:OnActive(_param)
  _G.NRCEventCenter:DispatchEvent(LoadingUIModuleEvent.LOADING_UI_OPENED)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(BattleConst.SoundId.BattleLoading, "UMG_BattleLoading_C")
  _G.NRCPanelBase.OnActive(self, _param)
  self.uiData.paramIn = _param
  self:PlayAnimation(self.TweenIn)
end

function UMG_BattleLoading_C:PlayTweenOut(_param)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(BattleConst.SoundId.CloseLoading, "UMG_BattleLoading_C")
  self.uiData.paramOut = _param
  self:PlayAnimation(self.TweenOut)
end

function UMG_BattleLoading_C:OnAnimationFinished(Animation)
  if Animation == self.TweenOut then
    self.isIn = false
    NRCEventCenter:DispatchEvent(BattleEvent.LoadingTweenOutComplete)
    _G.NRCEventCenter:DispatchEvent(LoadingUIModuleEvent.LOADING_UI_CLOSED)
    local paramOut = self.uiData.paramOut
    if paramOut and paramOut.owner and paramOut.callback then
      local Callback = paramOut.callback
      local Owner = paramOut.owner
      paramOut.owner = nil
      paramOut.callback = nil
      self.uiData.paramOut = nil
      if Callback then
        Callback(Owner)
      end
    end
    self:DoClose()
  elseif Animation == self.TweenIn then
    self.isIn = true
    NRCEventCenter:DispatchEvent(BattleEvent.LoadingTweenInComplete)
    local paramIn = self.uiData.paramIn
    if paramIn and paramIn.owner and paramIn.callback then
      local Callback = paramIn.callback
      local Owner = paramIn.owner
      paramIn.owner = nil
      paramIn.callback = nil
      self.uiData.paramIn = nil
      if Callback then
        Callback(Owner)
      end
    end
  end
end

function UMG_BattleLoading_C:OnDeactive()
end

function UMG_BattleLoading_C:OnDestruct()
  NRCEventCenter:UnRegisterEvent(self, BattleEvent.StartTweenOut, self.PlayTweenOut)
  self.uiData = nil
end

return UMG_BattleLoading_C
