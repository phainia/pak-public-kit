local M = Class("HomeVisitData")

function M:Ctor()
  self.VisitRecords = {}
  self.DynamicDescMap = {
    [ProtoEnum.HomeDynamic.HomeDynamicType.STEAL_INSPIRATION] = LuaText.home_kanban_guest_steal_success,
    [ProtoEnum.HomeDynamic.HomeDynamicType.STEAL_INSPIRATION_REPELLED] = LuaText.home_kanban_guest_steal_fail,
    [ProtoEnum.HomeDynamic.HomeDynamicType.WATER_PLANT] = LuaText.plant_home_log_water,
    [ProtoEnum.HomeDynamic.HomeDynamicType.FERTILIZE_PLANT] = LuaText.plant_home_log_manure,
    [ProtoEnum.HomeDynamic.HomeDynamicType.STEAL_PLANT] = LuaText.plant_home_log_steal,
    [ProtoEnum.HomeDynamic.HomeDynamicType.STEAL_PLANT_REPELLED] = LuaText.plant_home_log_steal_guard
  }
end

function M:ToLocalZeroClock(Timestamp)
  local d = os.date("*t", math.floor(Timestamp))
  d.hour, d.min, d.sec = 0, 0, 0
  return os.time(d)
end

function M:DiffDays(ZeroDay2, ZeroDay1)
  return math.floor(os.difftime(ZeroDay2, ZeroDay1) / 86400)
end

function M:GetDynamicDesc(Type, ...)
  local Fmt = Type and self.DynamicDescMap[Type] or ""
  return string.format(Fmt, ...)
end

function M:GetRecordList()
  return self.VisitRecords
end

function M:Deserialize(Notify)
  local records = (Notify and Notify.visit_history or {}).visit_records or {}
  table.sort(records, function(a, b)
    return a.visit_timestamp > b.visit_timestamp
  end)
  local clientTodayZeroClock = self:ToLocalZeroClock(ZoneServer:GetServerTime() / 1000)
  
  local function sortDynamics(home_dynamics)
    table.sort(home_dynamics, function(a, b)
      return a.type < b.type
    end)
  end
  
  for i, record in ipairs(records) do
    local recordDayZeroClock = self:ToLocalZeroClock(record.visit_timestamp)
    local recordDayOffset = self:DiffDays(clientTodayZeroClock, recordDayZeroClock)
    record.visit_day_offset = recordDayOffset
    if 0 == recordDayOffset then
      record.visit_day_desc = LuaText.offline_visit_today
    else
      record.visit_day_desc = string.format(LuaText.offline_visit_day, recordDayOffset)
    end
    local message_list = {}
    local home_dynamics = record.home_dynamics
    record.message_list = message_list
    sortDynamics(home_dynamics)
    for j, dynamic in ipairs(home_dynamics) do
      local desc = self:GetDynamicDesc(dynamic.type, dynamic.value)
      if desc and "" ~= desc then
        table.insert(message_list, desc)
      end
    end
  end
  self.VisitRecords = records
end

return M
