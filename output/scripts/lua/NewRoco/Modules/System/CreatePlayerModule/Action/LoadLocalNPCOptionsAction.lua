local NRCModeAction = require("Core.NRCMode.NRCModeAction")
local NPCModuleCmd = require("NewRoco.Modules.Core.NPC.NPCModuleCmd")
local Base = NRCModeAction
local LoadLocalNPCOptionsAction = Base:Extend("LoadLocalNPCOptionsAction")

function LoadLocalNPCOptionsAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.properties = properties
end

function LoadLocalNPCOptionsAction:OnEnter()
  local npcs = _G.NRCModeManager:DoCmd(NPCModuleCmd.GetAllNPC)
  if npcs and #npcs > 0 then
    for i, NPC in pairs(npcs) do
      if NPC then
        local NPCConf = _G.DataConfigManager:GetNpcConf(NPC.config.id)
        for _, NPCOptionID in ipairs(NPCConf.option_id) do
          local AddNPCOption = _G.ProtoMessage:newSpaceAct_AddNpcOption()
          AddNPCOption.npc_id = NPC:GetServerId()
          AddNPCOption.opt_info.option_id = NPCOptionID
          AddNPCOption.opt_info.enabled = true
          AddNPCOption.opt_info.executable_times = -1
          local NPCOptionConf = _G.DataConfigManager:GetNpcOptionConf(NPCOptionID)
          if NPCOptionConf.action.action_type == Enum.ActionType.ACT_DIALOGUE_LOCAL then
            AddNPCOption.opt_info.first_dialog_id = tonumber(NPCOptionConf.action.action_param1)
          end
          _G.NRCModuleManager:DoCmd(NPCModuleCmd.AddOptionAction, AddNPCOption)
        end
      end
    end
  end
  self:Finish()
end

return LoadLocalNPCOptionsAction
