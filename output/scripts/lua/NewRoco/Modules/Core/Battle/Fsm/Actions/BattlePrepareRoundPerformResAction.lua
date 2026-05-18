local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local Base = BattleActionBase
local BattlePrepareRoundPerformResAction = Base:Extend("BattlePrepareRoundPerformResAction")
FsmUtils.MergeMembers(Base, BattlePrepareRoundPerformResAction, {})

function BattlePrepareRoundPerformResAction:OnEnter()
  local resList = {
    BattleConst.AttackHitSpeedCurve
  }
  for i, v in ipairs(resList) do
    BattleResourceManager:LoadAssetAsync(self, v, self.OnLoad)
  end
  self:PreloadPopupUMG()
  if BattleUtils.IsB1FinalBattleP3() then
    BattleSkillManager:PreLoadSingleResInternal(_G.BattleConst.B1P3TwoPetCamG6, true)
    NRCPanelManager:PreloadPanel("/Game/NewRoco/Modules/System/B1FinalBattleModule/Res/UMG_TwoScreenDialogue")
  end
  self:Finish()
end

function BattlePrepareRoundPerformResAction:OnLoad()
end

function BattlePrepareRoundPerformResAction:PreloadPopupUMG()
  if not _G.BattleManager or not _G.BattleManager.battlePawnManager then
    Log.Warn("[PreEnterBattlePerformAction] BattleManager or battlePawnManager not available for preloading")
    return
  end
  local allPets = _G.BattleManager.battlePawnManager:GetAllPets()
  local preloadCount = 0
  for _, pet in ipairs(allPets) do
    if pet and pet.buffAEffectPopupComponent then
      pet.buffAEffectPopupComponent:PreloadUMGPool(function(success)
        if success then
          preloadCount = preloadCount + 1
        end
      end)
    end
  end
  Log.DebugFormat("[PreEnterBattlePerformAction] Preload triggered for %d pets", preloadCount)
end

return BattlePrepareRoundPerformResAction
