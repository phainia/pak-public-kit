local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local Base = BattleActionBase
local BattlePreparePveResAction = Base:Extend("BattlePreparePveResAction")
FsmUtils.MergeMembers(Base, BattlePreparePveResAction, {})

function BattlePreparePveResAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattlePreparePveResAction:OnEnter()
  self.loadResCount = 0
  NRCPanelManager:PreloadPanel("/Game/NewRoco/Modules/Core/Battle/UMG_EntryHud")
  self.preloadResList = {
    _G.UEPath.BP_BattleFieldConf,
    _G.UEPath.UMG_Battle_Buff,
    _G.UEPath.BP_BattlePlayerComponents
  }
  self:BeginLoadRes()
  if BattleUtils.IsPvp() then
    self.resList = {
      BattleConst.PvPEnter.TwoPlayerSkill_C,
      BattleConst.PvPEnter.TwoPlayerPetSkill_C,
      BattleConst.PvPEnter.TwoEnemyPetSkill_C,
      BattleConst.PvPEnter.TwoEnemySkill_C
    }
  else
    self.resList = {
      BattleConst.PveEnter.TwoPlayerSkill_C,
      BattleConst.PvPEnter.TwoPlayerPetSkill_C,
      BattleConst.PvPEnter.TwoEnemyPetSkill_C,
      BattleConst.PveEnter.TwoEnemySkill_C
    }
  end
  _G.BattleSkillManager:PreLoadRes(self.resList, false)
  local battleInitInfo = BattleUtils.GetBattleInitInfo()
  for playerPos, v in ipairs(battleInitInfo.player_team) do
    self:PrepareBattlePlayer(v)
  end
  for playerPos, v in ipairs(battleInitInfo.enemy_team) do
    self:PrepareBattlePlayer(v)
  end
  if self:CheckIsAsync() then
    self:Finish()
  end
end

function BattlePreparePveResAction:BeginLoadRes()
  for i = 1, #self.preloadResList do
    self.loadResCount = self.loadResCount + 1
    _G.BattleResourceManager:LoadResAsync(self, self.preloadResList[i], self.PreloadAssetCallBack, self.PreloadAssetCallBack)
  end
end

function BattlePreparePveResAction:PreloadAssetCallBack(asset)
  self.loadResCount = self.loadResCount - 1
  self:TryFinish()
end

function BattlePreparePveResAction:PrepareBattlePlayer(spawnData)
  local roleID = BattleUtils.GetPlayerModelId(spawnData)
  local modelConf = _G.DataConfigManager:GetModelConf(roleID)
  if modelConf then
    local modelPath = modelConf.path
    self.loadResCount = self.loadResCount + 1
    _G.BattleResourceManager:PreloadAssetAsync(self, modelPath, self.PawnPlayerOver, self.PawnPlayerFailed, nil, PriorityEnum.Passive_Battle_Preload)
  end
end

function BattlePreparePveResAction:PawnPlayerOver(e)
  self.loadResCount = self.loadResCount - 1
  self:TryFinish()
end

function BattlePreparePveResAction:PawnPlayerFailed(e)
  self.loadResCount = self.loadResCount - 1
  self:TryFinish()
end

function BattlePreparePveResAction:TryFinish()
  if 0 == self.loadResCount then
    self:Finish()
  end
end

return BattlePreparePveResAction
