local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local a = require("Common.Coroutine.async")
local au = require("Common.Coroutine.async_util")
local Base = BattleActionBase
local BattlePreloadEssentailResAction = Base:Extend("BattlePreloadEssentailResAction")

function BattlePreloadEssentailResAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self:SetActionType(BattleActionBase.ActionType.ClientLoadResAction)
end

function BattlePreloadEssentailResAction:OnEnter()
  Log.Debug("show me BattlePreloadEssentailResAction time begin:", UE4.UNRCStatics.GetMilliSeconds())
  self.preloadResList = {
    _G.UEPath.BP_BattleFieldConf,
    BattleConst.BattleDepthCam
  }
  if BattleUtils.IsTeam() then
    table.insert(self.preloadResList, _G.UEPath.UMG_TransformLoading)
  end
  self:BeginLoadRes()
  if self:CheckIsAsync() then
    self:Finish()
  end
end

function BattlePreloadEssentailResAction:BeginLoadRes()
  self.preLoadAssetNumber = #self.preloadResList
  for i = 1, #self.preloadResList do
    Log.Debug("show me BattlePreloadEssentailResAction time do load:", UE4.UNRCStatics.GetMilliSeconds())
    _G.BattleResourceManager:LoadResAsync(self, self.preloadResList[i], self.PreloadAssetCallBack, self.PreloadAssetCallBack, nil, nil, nil, PriorityEnum.Passive_Battle_Preload)
  end
end

function BattlePreloadEssentailResAction:PreloadAssetCallBack()
  self.preLoadAssetNumber = self.preLoadAssetNumber - 1
  if 0 == self.preLoadAssetNumber then
    self:Finish()
  end
end

return BattlePreloadEssentailResAction
