local BattleModuleHead = NRCModuleHeadBase:Extend("BattleModuleHead")

function BattleModuleHead:OnConstruct()
  _G.BattleEnv = reload("NewRoco.Modules.Core.Battle.Common.BattleEnv")
  _G.BattleModuleCmd = reload("NewRoco.Modules.Core.Battle.BattleModuleCmd")
  _G.BattleDefine = reload("NewRoco.Modules.Core.Battle.Common.BattleDefine")
  _G.BattleConst = reload("NewRoco.Modules.Core.Battle.Common.BattleConst")
  _G.BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
  _G.BattleBossChallengeUtils = require("NewRoco.Modules.Core.Battle.Common.BattleBossChallengeUtils")
  self:BindCmd(BattleModuleCmd.IsInBattle, "OnIsInBattle")
  self:BindCmd(BattleModuleCmd.GetBattleFieldCenterPos, "OnGetBattleFieldCenterPos")
  self:BindCmd(BattleModuleCmd.GetBattleFieldRadius, "OnGetBattleFieldRadius")
  self:BindCmd(BattleModuleCmd.CheckNpcInHideRange, "OnCheckNpcInHideRange")
  self:BindCmd(BattleModuleCmd.OnSelectExtraCatchBall, "OnSelectExtraCatchBall")
  self:BindCmd(BattleModuleCmd.LoadBattleFieldLevel, "OnCmdLoadBattleFieldLevel")
  self:BindCmd(BattleModuleCmd.GetBattleFieldLevelIsReady, "OnCmdGetBattleFieldLevelIsReady")
  self:BindCmd(BattleModuleCmd.GetCurrentBattleFieldActor, "OnCmdGetCurrentBattleFieldActor")
  self:BindCmd(BattleModuleCmd.CollectSkillEnhanceInfoForChangePetAttr, "OnCmdCollectSkillEnhanceInfoForChangePetAttr")
  self:BindCmd(BattleModuleCmd.GetPvpConfByBattleType, "OnCmdGetPvpConfByBattleType")
end

return BattleModuleHead
