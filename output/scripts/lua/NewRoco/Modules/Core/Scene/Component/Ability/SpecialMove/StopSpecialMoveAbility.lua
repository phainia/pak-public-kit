local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityBase")
local StopSpecialMoveAbility = Base:Extend("StopCrouchAbility")

function StopSpecialMoveAbility:Init(abilityConf)
  Base.Init(self, abilityConf)
  self.swimmingMaxSpeedLimitRadio = 1
end

function StopSpecialMoveAbility:Start(onFinished, taskId)
  local player = self.caster
  if player.isLocal then
    Base.Start(self, onFinished)
    local taskStateConf = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.TASK_STATE_CONF):GetAllDatas()
    local showTime = _G.DataConfigManager:GetGlobalConfigByKeyType("task_state_tips_time", _G.DataConfigManager.ConfigTableId.GLOBAL_CONFIG).num
    if taskId and taskStateConf[taskId] and taskStateConf[taskId].end_tips and taskStateConf[taskId].end_tips ~= "" then
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, taskStateConf[taskId].end_tips, nil, nil, showTime)
    end
    local moveComponent = player.viewObj:GetMovementComponent()
    moveComponent:SetEnableClimb(false)
    moveComponent:SetSwimmingMaxSpeedLimitRadio(self.swimmingMaxSpeedLimitRadio)
    player.viewObj:RecoverWalkRun()
  end
end

function StopSpecialMoveAbility:Recover(owner)
end

return StopSpecialMoveAbility
