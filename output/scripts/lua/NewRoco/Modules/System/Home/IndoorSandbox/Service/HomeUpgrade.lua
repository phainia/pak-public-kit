local HomeUpgrade = Class("HomeUpgrade")

function HomeUpgrade:Ctor()
  self.bUpgrading = false
  local home_room_expand_select = DataConfigManager:GetHomeGlobalConfig("home_room_expand_select")
  local numList = home_room_expand_select and home_room_expand_select.numList
  self.StartUpgradeSelectId = numList and numList[1]
  self.FinishUpgradeSelectId = numList and numList[2]
end

function HomeUpgrade:OnExitHome()
  self.bUpgrading = false
end

function HomeUpgrade:ReqUpgradeHome()
  if self.bUpgrading then
    HomeIndoorSandbox:LogWarn("wait for upgrade")
    return false
  end
  self.bUpgrading = true
  HomeIndoorSandbox.Module:CloseEditPanels()
  HomeIndoorSandbox.TaskMgr:EnQueTaskWithFeedback(HomeIndoorSandbox.TaskMgr.TaskModules.ProtoSendTask, FPartial(self.OnResUpgrade, self), "ReqUpgradeHome")
  return true
end

function HomeUpgrade:IsUpgradeEstablished()
  return not self.bUpgrading
end

function HomeUpgrade:OnResUpgrade(bSuccess)
  self.bUpgrading = false
  if bSuccess then
    local RoomLevel = HomeIndoorSandbox.Server.WorldData.RoomLevel
    local RoomConf = DataConfigManager:GetRoomConf(RoomLevel)
    local bPerformSuccess = false
    if RoomConf and RoomConf.movie then
      local conf = _G.DataConfigManager:GetMovieConf(RoomConf.movie)
      if conf then
        bPerformSuccess = true
        local param = {}
        param.file_path = conf.movie_path
        param.bSkip = true
        param.soundID = conf.sound_id
        param.caller = {}
        
        function param.callback()
          _G.NRCEventCenter:DispatchEvent(NRCGlobalEvent.OPEN_BLACK_SCREEN, false)
          _G.NRCEventCenter:DispatchEvent(NRCGlobalEvent.CLOSE_BLACK_SCREEN)
          _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.RemoveInputBlockMappingContext, "HomeUpgrade:OnResUpgrade")
          _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.CloseInputBlocker, "HomeUpgrade:OnResUpgrade")
        end
        
        local function OnFadeOut()
          if HomeIndoorSandbox:InLocalMasterIndoor() then
            HomeIndoorSandbox.World:ReLoadWorldSync()
            HomeIndoorSandbox.Module:OpenPanel("HomeVideo", param)
            DelayManager:DelaySeconds(RoomConf.movie_ui_time / 1000, function()
              if HomeIndoorSandbox:InLocalMasterIndoor() then
                HomeIndoorSandbox.HomeTipsServ:ShowFinishExpandTip()
              end
            end)
          else
            _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.RemoveInputBlockMappingContext, "HomeUpgrade:OnResUpgrade")
            _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.CloseInputBlocker, "HomeUpgrade:OnResUpgrade")
          end
        end
        
        _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.AddInputBlockMappingContext, "HomeUpgrade:OnResUpgrade")
        _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.OpenInputBlocker, "HomeUpgrade:OnResUpgrade")
        _G.NRCEventCenter:DispatchEvent(NRCGlobalEvent.OPEN_BLACK_SCREEN, true, {}, function()
          OnFadeOut()
        end)
      end
    end
    if not bPerformSuccess then
      HomeIndoorSandbox.World:ReLoadWorldSync()
      HomeIndoorSandbox.HomeTipsServ:ShowFinishExpandTip()
    end
  end
end

function HomeUpgrade:StartReplaceSelectView()
  if not self.bHasRegisterSelectModify then
    self.bHasRegisterSelectModify = true
    _G.NRCModuleManager:DoCmd(DialogueModuleCmd.AddOverrideCallback, "ReplaceSelectView", self, self.AddOverrideSelectViewCallback)
  end
end

function HomeUpgrade:AddOverrideSelectViewCallback(SelectId)
  if SelectId == self.StartUpgradeSelectId and HomeIndoorSandbox:InLocalMasterIndoor() then
    local Status, Arg1, Arg2, Arg3 = HomeIndoorSandbox.Server.WorldData:GetExpansionStatus()
    if Status == HomeIndoorSandbox.Enum.EnmExpandStatus.ExpandEstablished then
      DelayManager:DelayFrames(1, function()
        self.bHasRegisterSelectModify = false
        _G.NRCModuleManager:DoCmd(DialogueModuleCmd.RemoveOverrideCallback, "ReplaceSelectView", self, self.AddOverrideSelectViewCallback)
      end)
      return {
        SelectConf = DataConfigManager:GetSelectConf(self.FinishUpgradeSelectId),
        DynamicReplaceLevel = 2
      }
    end
  end
end

return HomeUpgrade
