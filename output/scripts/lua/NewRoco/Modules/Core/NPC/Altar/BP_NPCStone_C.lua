require("UnLuaEx")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local BP_NPCStone_C = Base:Extend("BP_NPCStone_C")

function BP_NPCStone_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
end

function BP_NPCStone_C:UpdateActStatus(optionInfo)
  if not self.resourceLoaded then
    return
  end
  local enable = 0 ~= optionInfo.executable_times
  local Path
  if enable then
    Path = UE4.UClass.Load("/Game/ArtRes/Effects/G6Skill/SceneEffect/791235_light")
  else
    Path = UE4.UClass.Load("/Game/ArtRes/Effects/G6Skill/SceneEffect/791235_dark")
  end
  local skillObj = RocoSkillProxy.Create(Path, self.RocoSkill, PriorityEnum.Active_Player_Action)
  if not skillObj then
    return
  end
  skillObj:SetCaster(self)
  local player = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  skillObj:SetTargets({
    player.viewObj
  })
  skillObj:PlaySkill()
end

return BP_NPCStone_C
