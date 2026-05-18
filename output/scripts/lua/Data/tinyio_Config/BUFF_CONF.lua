BUFF_CONF = {}
local dataTable = {}

function dataTable:addCacheRecord(_key, r)
  local lua_record = {}
  lua_record.id = r.id
  lua_record.editor_name = r.editor_name
  if r.editor_name == "" then
    lua_record.editor_name = nil
  end
  lua_record.is_area = r.is_area
  lua_record.is_special = r.is_special
  lua_record.buff_list_priority = r.buff_list_priority
  lua_record.buff_groupsign = r.buff_groupsign
  lua_record.name = r.name
  if "" == r.name then
    lua_record.name = nil
  end
  lua_record.add_des = r.add_des
  if "" == r.add_des then
    lua_record.add_des = nil
  end
  lua_record.add_icon = r.add_icon
  lua_record.trigger_des = r.trigger_des
  if "" == r.trigger_des then
    lua_record.trigger_des = nil
  end
  lua_record.trigger_icon = r.trigger_icon
  lua_record.special_add = r.special_add
  lua_record.type = r.type
  lua_record.clean_group_id = r.clean_group_id
  lua_record.cover_id = r.cover_id
  lua_record.mutex = r.mutex
  lua_record.overlay = r.overlay
  lua_record.add_max = r.add_max
  lua_record.add_max_handle = r.add_max_handle
  lua_record.desc = r.desc
  if "" == r.desc then
    lua_record.desc = nil
  end
  lua_record.icon = r.icon
  if "" == r.icon then
    lua_record.icon = nil
  end
  lua_record.res_id_0 = r.res_id_0
  if "" == r.res_id_0 then
    lua_record.res_id_0 = nil
  end
  lua_record.res_id_1 = r.res_id_1
  if "" == r.res_id_1 then
    lua_record.res_id_1 = nil
  end
  lua_record.res_id_2 = r.res_id_2
  if "" == r.res_id_2 then
    lua_record.res_id_2 = nil
  end
  local _buff_group_reduce = {}
  for i = 0, #r.buff_group_reduce - 1 do
    local r_2 = r.buff_group_reduce[i]
    local lua_record_2 = {}
    lua_record_2.reduce_type = r_2.reduce_type
    _reduce_param = {}
    for i = 0, #r_2.reduce_param - 1 do
      table.insert(_reduce_param, r_2.reduce_param[i])
    end
    lua_record_2.reduce_param = _reduce_param
    table.insert(_buff_group_reduce, lua_record_2)
  end
  lua_record.buff_group_reduce = _buff_group_reduce
  _buff_base_ids = {}
  for i = 0, #r.buff_base_ids - 1 do
    table.insert(_buff_base_ids, r.buff_base_ids[i])
  end
  lua_record.buff_base_ids = _buff_base_ids
  lua_record.is_clean_when_rest = r.is_clean_when_rest
  lua_record.is_hide = r.is_hide
  lua_record.connect_buff = r.connect_buff
  _buff_can_react = {}
  for i = 0, #r.buff_can_react - 1 do
    table.insert(_buff_can_react, r.buff_can_react[i])
  end
  lua_record.buff_can_react = _buff_can_react
  BUFF_CONF[_key] = lua_record
end

function dataTable:GetData(_key)
  local r = BUFF_CONF[_key]
  if nil == r then
    local r = TinyData.GetRecord("BUFF_CONF", _key)
    if nil ~= r then
      self:addCacheRecord(_key, r)
      return BUFF_CONF[_key]
    else
      return nil
    end
  end
  return r
end

function dataTable:GetAllDatas()
  local confs = TinyData.GetTable("BUFF_CONF", true)
  local count = TinyDataTable.GetRecordsCount(confs)
  if count == #BUFF_CONF then
    return BUFF_CONF
  end
  for idx = 0, count - 1 do
    local record = TinyDataTable.GetRecordByIdx(confs, idx)
    if nil ~= record then
      self:addCacheRecord(record.id, record)
    end
  end
  TinyDataTable.SetCache(confs, false, true)
  return BUFF_CONF
end

function dataTable:GetDataCount()
  return TinyData.GetRecordsCount("BUFF_CONF")
end

return dataTable
