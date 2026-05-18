local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local Base = NPCActionBase
local SkillSeqProxy = require("NewRoco/Modules/System/Home/IndoorSandbox/Proxy/SkillSeqProxy")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local M = Base:Extend("NPCActionHomeIndoorOpenFoodProcessing")

function M:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function M:BeforeSubmit()
  self.needSendReq = false
end

function M:Execute(...)
  Base.Execute(self, ...)
  local owner = self:GetOwnerNPC()
  if not owner or not owner.viewObj then
    self:Finish(true)
    return
  end
  local player = self:GetPlayer()
  if player then
    player:SetVisible(true)
  end
  if HomeIndoorSandbox and HomeIndoorSandbox:InHomeIndoor() and 0 ~= (owner.serverData.attach_item_info and owner.serverData.attach_item_info.attach_item_id or 0) then
    self.PropsData = HomeIndoorSandbox.HomePropsServ:GetPropsDataById(owner.serverData.attach_item_info.attach_item_id)
    if self.PropsData then
      HomeIndoorSandbox.HomePropsServ:RequestPropsCamera(self.PropsData)
      self:OpenFoodProcessingPanel()
    end
    return
  end
  local skillComp = player.viewObj.RocoSkill
  local skill = RocoSkillProxy.Create("/Game/ArtRes/Effects/G6Skill/Home/G6_Home_JiaGong", skillComp)
  self.skill = skill
  if not skill then
    Log.Error("\230\137\190\228\184\141\229\136\176Skill\239\188\154G6_Home_JiaGong")
    self:Finish(false)
    return
  end
  skill:SetCaster(player.viewObj)
  skill:SetTargets({
    owner.viewObj
  })
  skill:RegisterEventCallback("EndCam", self, self.OpenFoodProcessingPanel)
  skill:PlaySkill()
end

function M:OnClosePanel(PanelData)
  local Name = PanelData.panelName
  if "FoodProcessingPanel" == Name then
    self:Finish(true)
  end
end

function M:OpenFoodProcessingPanel()
  if self.bEventRegistered then
    return
  end
  self.bEventRegistered = true
  _G.NRCEventCenter:RegisterEvent("NPCActionHomeIndoorOpenFurnitureExchange", self, _G.NRCPanelEvent.ClosePanel, self.OnClosePanel)
  _G.NRCModuleManager:DoCmd(_G.HomeModuleCmd.OpenFoodProcessingPanel)
end

function M:Finish(success, data, param)
  Base.Finish(self, success, data, param)
  if self.bEventRegistered then
    _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCPanelEvent.ClosePanel, self.OnClosePanel)
  end
  self.bEventRegistered = false
  if self.skill then
    local player = self:GetPlayer()
    if player then
      local playerController = player:GetUEController()
      if playerController and UE4.UObject.IsValid(playerController) then
        playerController:ReleaseRocoCamera(0, nil, nil, true)
      end
    end
    self.skill:CancelSkill(UE4.ESkillActionResult.SkillActionResultSuccessful)
    self.skill:Destroy()
  elseif self.PropsData then
    self.PropsData = nil
    HomeIndoorSandbox.HomePropsServ:ReleasePropsCamera()
  end
end

return M
