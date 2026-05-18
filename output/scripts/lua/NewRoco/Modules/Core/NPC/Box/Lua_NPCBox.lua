local Base = require("NewRoco.Modules.Core.NPC.Lua_NPCBase")
local Lua_NPCBox = Base:Extend("Lua_NPCBox")

function Lua_NPCBox:UpdateData(npcInfo, isReconnect)
  if isReconnect and self.viewObj and self.viewObj.resourceLoaded then
    self.viewObj:ResetOpenState()
  end
end

function Lua_NPCBox:LuaBeginPlay()
  Base.LuaBeginPlay(self)
  self.POIKLass = 1
end

function Lua_NPCBox:InitActStatus(optionInfo)
  local option_config = DataConfigManager:GetNpcOptionConf(optionInfo.option_id)
  if option_config.action.action_type == Enum.ActionType.ACT_OPENCHEST then
    local enable = 0 ~= optionInfo.executable_times
    self.old_enable = enable
    if not enable then
      self.opened = true
    end
  end
end

function Lua_NPCBox:UpdateActStatus(optionInfo)
  Log.Debug("Lua_NPCBox:UpdateActStatus", self:GetDebugInfo())
  local option_config = DataConfigManager:GetNpcOptionConf(optionInfo.option_id)
  if option_config.action.action_type == Enum.ActionType.ACT_OPENCHEST then
    local enable = 0 ~= optionInfo.executable_times
    if self.old_enable and not enable then
      self.enable_has_changed = true
    end
  end
end

function Lua_NPCBox:GetForwardModify()
  local forward = UE4.FVector(1, 0, 0)
  local dir = self.sceneCharacter.serverData.base.pt.dir.z / 10
  return UE4.UKismetMathLibrary.RotateAngleAxis(forward, dir, _G.FVectorUp)
end

return Lua_NPCBox
