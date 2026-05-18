local StatusUtils = Class()

function StatusUtils.StatusToString(status)
  if status == ProtoEnum.WorldPlayerStatusType.WPST_RIDING then
    return "RIDING"
  elseif status == ProtoEnum.WorldPlayerStatusType.WPST_GLIDING then
    return "GLIDING"
  elseif status == ProtoEnum.WorldPlayerStatusType.WPST_SWIMMING then
    return "SWIMMING"
  elseif status == ProtoEnum.WorldPlayerStatusType.WPST_FALLING then
    return "FALLING"
  elseif status == ProtoEnum.WorldPlayerStatusType.WPST_LANDING then
    return "LANDING"
  elseif status == ProtoEnum.WorldPlayerStatusType.WPST_LANDED then
    return "LANDED"
  elseif status == ProtoEnum.WorldPlayerStatusType.WPST_SLIDING then
    return "SLIDING"
  elseif status == ProtoEnum.WorldPlayerStatusType.WPST_DASHING then
    return "DASHING"
  elseif status == ProtoEnum.WorldPlayerStatusType.WPST_RIDE_DASHING then
    return "RIDE_DASHING"
  elseif status == ProtoEnum.WorldPlayerStatusType.WPST_GLIDING_ASCENDING then
    return "GLIDING_ASCENDING"
  elseif status == ProtoEnum.WorldPlayerStatusType.WPST_BALLOON_ASCENDING then
    return "BALLOON_ASCENDING"
  elseif status == ProtoEnum.WorldPlayerStatusType.WPST_AIMTHROWING then
    return "AIMTHROWING"
  elseif status == ProtoEnum.WorldPlayerStatusType.WPST_CLIMB then
    return "CLIMB"
  elseif status == ProtoEnum.WorldPlayerStatusType.WPST_CLIMB_DASH then
    return "CLIMB_DASH"
  elseif status == ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL then
    return "RIDE_ALL"
  end
  return "STATUS STRING UNDEFINED " .. tostring(status)
end

function StatusUtils.OpCodeToString(opCode)
  if opCode == ProtoEnum.WPST_OpCode.WPST_OPCODE_NONE then
    return "NONE"
  elseif opCode == ProtoEnum.WPST_OpCode.WPST_OPCODE_OVERRIDE then
    return "OVERRIDE"
  elseif opCode == ProtoEnum.WPST_OpCode.WPST_OPCODE_MAINTAIN then
    return "MAINTAIN"
  elseif opCode == ProtoEnum.WPST_OpCode.WPST_OPCODE_BLOCK then
    return "BLOCK"
  elseif opCode == ProtoEnum.WPST_OpCode.WPST_OPCODE_ADD then
    return "ADD"
  elseif opCode == ProtoEnum.WPST_OpCode.WPST_OPCODE_REMOVE then
    return "REMOVE"
  elseif opCode == ProtoEnum.WPST_OpCode.WPST_OPCODE_RECOVER then
    return "RECOVER"
  elseif opCode == ProtoEnum.WPST_OpCode.WPST_OPCODE_REQUIRE then
    return "REQUIRE"
  end
  return ""
end

return StatusUtils
