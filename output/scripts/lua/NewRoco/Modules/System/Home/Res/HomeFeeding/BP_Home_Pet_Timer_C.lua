local BP_Home_Pet_Timer_C = Class()

function BP_Home_Pet_Timer_C:ReceivePlay()
  self.timer = _G.TimerManager:CreateTimer(self, "HomeNestProduceTimer", math.maxinteger, self.RefreshShowTimer, nil, 60)
end

function BP_Home_Pet_Timer_C:UpdateData(petData)
  if not petData then
    Log.Error("BP_Home_Pet_Timer_C updateData with invalid petData")
    return
  end
  self.gid = petData.pet_gid or nil
  self.ownerFurnitureId = petData.furniture_guid or nil
  local petFeedInfo = petData.pet_feed_info or nil
  if petFeedInfo then
    local petFeedId = self.petFeedInfo.pet_feed_id
    self.petFeedStartTime = self.petFeedInfo.timestamp
    self.petFeedConfig = _G.DataConfigManager:GetHomePetFeedConf(petFeedId)
    if self.petFeedConfig then
      self.needTime = self.petFeedConfig.need_time * 60 or 0
    end
  end
end

function BP_Home_Pet_Timer_C:RefreshShowTimer()
  if not self.petFeedStartTime then
    Log.Error("RefreshShowTimer with no petFeedStartTime")
    return
  end
  local nowTime = math.floor(_G.ZoneServer:GetServerTime() / 1000 / 60 / 60)
  self.remainTime = self.needTime - (nowTime - self.petFeedStartTime)
  if self.remainTime <= 0 then
    self.showHour = 0
    self.showMinute = 0
    return
  elseif self.remainTime >= 6039 then
    self.showHour = 99
    self.showMinute = 99
    return
  end
  self.showHour = math.floor(self.remainTime / 60)
  self.showMinute = math.floor((self.remainTime - self.showHour * 60) / 60)
end

function BP_Home_Pet_Timer_C:EndTimer()
  if self.remainTime <= 0 and self.timer then
    _G.TimerManager:RemoveTimer(self.timer)
  end
end

return BP_Home_Pet_Timer_C
