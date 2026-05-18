local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local Base = NPCActionBase
local lastTime
local NPCActionRecoverAll = Base:Extend("NPCActionRecoverAll")

function NPCActionRecoverAll:OnNpcAction()
  local currentTime = os.clock()
  if lastTime and currentTime - lastTime < 3 then
    Log.Debug("\233\151\180\233\154\148\229\164\170\229\176\145\239\188\140\229\134\141\231\173\137\231\173\137")
    return false
  end
  return Base.OnNpcAction(self)
end

function NPCActionRecoverAll:Execute(playerId, needSendReq)
  lastTime = os.clock()
  Base.Execute(self, playerId, needSendReq)
end

return NPCActionRecoverAll
