require("UnLua")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local ActivityModuleCmd = require("NewRoco.Modules.System.Activity.ActivityModuleCmd")
local PlayerModuleCmd = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleCmd")
local BP_NPC_ClothesRack_C = Base:Extend("BP_NPC_ClothesRack_C")

function BP_NPC_ClothesRack_C:ReceiveBeginPlay()
end

function BP_NPC_ClothesRack_C:LuaBeginPlay()
end

function BP_NPC_ClothesRack_C:SetSceneCharacter(sceneCharacter)
  local pikaActivityInst = _G.NRCModuleManager:DoCmd(ActivityModuleCmd.GetActivityInstByType, Enum.ActivityType.ATP_PIKA)
  if pikaActivityInst and #pikaActivityInst > 0 then
    local subItemIds = pikaActivityInst[1]:GetPartIds()
    local activityPikaConf = _G.DataConfigManager:GetActivityPikaConf(subItemIds[1])
    local player = _G.NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
    if player then
      for k, v in ipairs(activityPikaConf.kv_path) do
        if v.gender == player.gender then
          for key, pkgId in ipairs(v.package_id1) do
            local skmPath = self:GetShowSKM(pkgId, sceneCharacter)
            if skmPath then
              self.NRCSkeletalMesh.CustomSkeletalPath = skmPath
            end
            break
          end
        end
      end
    end
  end
  Base.SetSceneCharacter(self, sceneCharacter)
end

function BP_NPC_ClothesRack_C:OnVisible()
  Base.OnVisible(self)
end

function BP_NPC_ClothesRack_C:GetShowSKM(curPkgId, sceneCharacter)
  if sceneCharacter then
    local fashionDressformConf = _G.DataConfigManager:GetFashionDressformConf(curPkgId)
    if fashionDressformConf then
      local DressList = fashionDressformConf.dressform_set
      for k, v in ipairs(DressList) do
        if v.dressform_content_id == sceneCharacter.serverData.npc_base.npc_content_cfg_id then
          return v.dressform
        end
      end
    end
  end
  return nil
end

function BP_NPC_ClothesRack_C:OnInVisible()
end

return BP_NPC_ClothesRack_C
