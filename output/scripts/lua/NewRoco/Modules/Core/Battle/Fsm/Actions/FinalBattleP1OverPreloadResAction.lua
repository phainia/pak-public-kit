local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local a = require("Common.Coroutine.async")
local au = require("Common.Coroutine.async_util")
local Base = BattleActionBase
local FinalBattleP1OverPreloadResAction = Base:Extend("FinalBattleP1OverPreloadResAction")

function FinalBattleP1OverPreloadResAction:Ctor()
  Base.Ctor(self)
  self.preloadResList = {
    _G.BattleConst.FinalBattleP1ToP2Seq
  }
  self:SetActionType(BattleActionBase.ActionType.ClientLoadResAction)
end

function FinalBattleP1OverPreloadResAction:OnEnter()
  self.preLoadAssetNumber = #self.preloadResList
  for i = 1, #self.preloadResList do
    _G.BattleResourceManager:LoadResAsync(self, self.preloadResList[i], self.PreloadAssetCallBack, self.PreloadAssetCallBack)
  end
end

function FinalBattleP1OverPreloadResAction:PreloadAssetCallBack(Resource)
  if not Resource then
    Log.Error("cannot preload assert", #self.preloadResList - self.preLoadAssetNumber + 1)
  end
  if not Resource.GetDefaultObject then
    Log.Error("loaded assert is not a uclass resource", Resource)
  end
  Log.Info("preload", self.preLoadAssetNumber, Resource)
  self.preLoadAssetNumber = self.preLoadAssetNumber - 1
  if 0 == self.preLoadAssetNumber then
    self:Finish()
  end
end

return FinalBattleP1OverPreloadResAction
