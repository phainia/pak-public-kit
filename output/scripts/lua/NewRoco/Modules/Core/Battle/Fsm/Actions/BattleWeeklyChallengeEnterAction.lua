local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local Base = BattleActionBase
local BattleWeeklyChallengeEnterAction = Base:Extend("BattleWeeklyChallengeEnterAction")

function BattleWeeklyChallengeEnterAction:OnEnter()
  self.materialPath = self:GetMaterialPath()
  if self.materialPath then
    _G.NRCResourceManager:LoadResAsync(self, self.materialPath, 0, 0, self.OnLoadSuccess, self.OnLoadFailed)
  end
  self:Finish()
end

function BattleWeeklyChallengeEnterAction:OnLoadSuccess(Request, Asset)
  self.MaterialClass = Asset
  local actors = UE.TArray(UE.AActor)
  local CurrentWorld = _G.UE4Helper.GetCurrentWorld()
  UE.UGameplayStatics.GetAllActorsWithTag(CurrentWorld, "CurtainAssetTag", actors)
  for _, actor in pairs(actors) do
    self:SetCurtainMaterial(actor)
  end
end

function BattleWeeklyChallengeEnterAction:OnLoadFailed(Request, message)
  Log.Warning("BattleWeeklyChallengeEnterAction \229\138\160\232\189\189\230\157\144\232\180\168\229\164\177\232\180\165\239\188\140\230\163\128\230\159\165\230\157\144\232\180\168\232\183\175\229\190\132 materialPath=", self.materialPath, "error=", message)
end

function BattleWeeklyChallengeEnterAction:SetCurtainMaterial(curtainActor)
  if not curtainActor then
    return
  end
  if self.MaterialClass then
    local bgMeshComponent = curtainActor:GetComponentByClass(UE4.UStaticMeshComponent)
    local dynamicAnimMaterial = bgMeshComponent:CreateDynamicMaterialInstance(0, self.MaterialClass)
    bgMeshComponent:SetMaterial(0, dynamicAnimMaterial)
  end
end

function BattleWeeklyChallengeEnterAction:GetMaterialPath()
  local NpcChallengeInfo = _G.BattleManager:GetBattleNpcChallengeInfo()
  if NpcChallengeInfo then
    local challengeId = NpcChallengeInfo.challenge_level_id
    if challengeId then
      local challengeConf = _G.DataConfigManager:GetWeeklyChallengeConf(challengeId)
      if challengeConf then
        local photoId = challengeConf.photo
        local materialName = _G.NRCModuleManager:DoCmd(_G.WeeklyChallengeBattleModuleCmd.GetMaterialFileNameFromPhotoID, photoId)
        if not materialName then
          local photoConf = _G.DataConfigManager:GetWeeklyPhotoConf(photoId)
          materialName = photoConf and photoConf.background or nil
        end
        if materialName then
          local result = string.match(materialName, "^MI_Curtain_(%d+_%d+)_Skeletal$")
          if not result then
            Log.Error("BattleWeeklyChallengeEnterAction.GetMaterialPath \230\139\141\231\133\167\233\133\141\231\189\174WEEKLY_PHOTO_CONF\229\188\130\229\184\184challengeId=", challengeId, "photoId=", photoId, "materialName=", materialName, "result=", result, "materialName\228\184\141\231\172\166\229\144\136\230\160\188\229\188\143\239\188\140\232\175\183\231\173\150\229\136\146\230\163\128\230\181\139\233\133\141\231\189\174")
            return nil
          end
          local stringList = {
            "MI_Curtain_",
            result,
            "_01_3uA"
          }
          local curMaterialName = table.concat(stringList)
          stringList = {
            "/Game/ArtRes/Asset/Environment/Interator/Curtain/TEX/",
            curMaterialName,
            ".",
            curMaterialName
          }
          local resPath = table.concat(stringList)
          return resPath
        else
          Log.Warning("BattleWeeklyChallengeEnterAction.GetMaterialPath \230\139\141\231\133\167\233\133\141\231\189\174WEEKLY_PHOTO_CONF\229\188\130\229\184\184challengeId=", challengeId, "photoId=", photoId)
          return nil
        end
      else
        Log.Warning("BattleWeeklyChallengeEnterAction.GetMaterialPath \229\145\168\230\140\145\230\136\152\233\133\141\231\189\174WEEKLY_CHALLENGE_CONF\229\188\130\229\184\184challengeId=", challengeId)
        return nil
      end
    else
      Log.Warning("BattleWeeklyChallengeEnterAction.GetMaterialPath \230\178\161\230\156\137\230\149\176\230\141\174challengeId=", challengeId)
      return nil
    end
  else
    Log.Warning("\231\187\147\231\174\151\230\149\176\230\141\174\229\188\130\229\184\184")
    return nil
  end
end

function BattleWeeklyChallengeEnterAction:OnExit()
end

return BattleWeeklyChallengeEnterAction
