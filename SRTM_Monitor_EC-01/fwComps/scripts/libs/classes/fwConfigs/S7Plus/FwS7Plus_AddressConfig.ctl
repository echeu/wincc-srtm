/**
  (c) Copyright CERN 2005. All rights not expressly granted are reserved.
  icecontrols.support@cern.ch

  SPDX-License-Identifier: LGPL-3.0-only
**/

#uses "classes/fwGeneral/FwException"
#uses "classes/fwConfigs/S7Plus/FwS7Plus_ConnectionConfig"
#uses "classes/fwConfigs/S7Plus/FwS7Plus_DataTransformationType"
#uses "classes/fwConfigs/S7Plus/FwS7Plus_Direction"
#uses "classes/fwConfigs/S7Plus/FwS7PlusReferenceUtils"

class FwS7Plus_AddressConfigTester;

struct FwS7Plus_AddressConfig
{
  friend FwS7Plus_AddressConfigTester;

  static const int DYN_INDEX_CONNECTION = 11;
  static const int DYN_INDEX_POLL_GROUP = 12;
  static const int DYN_INDEX_SUBINDEX = 13;
  static const int DYN_INDEX_LOWLEVEL = 14;
  static const int DYN_ANYTYPE_SIZE = 14;
  string driverType = fwPeriphAddress_TYPE_S7PLUS;
  char driverNumber;
  string connectionName;
  string reference;
  string pollgroup;
  FwS7Plus_DataTransformationType transformation;
  FwS7Plus_Direction direction;
  bool lowLevelComparison;
  uint subindex; // 0-31? only for TSPP input of bool transformation
  bool active;

  public static shared_ptr<FwS7Plus_AddressConfig> fromDynAnytype(const dyn_anytype& data)
  {
    if (dynlen(data) != DYN_ANYTYPE_SIZE) {
      FwException::raise("Invalid parameters count (" + dynlen(data) + "), expected " + DYN_ANYTYPE_SIZE);
    }

    if (data[FW_PARAMETER_FIELD_COMMUNICATION] != fwPeriphAddress_TYPE_S7PLUS) {
      FwException::raise("Parameters data type ('" + data[FW_PARAMETER_FIELD_COMMUNICATION] + "' not " + fwPeriphAddress_TYPE_S7PLUS + ")");
    }

    shared_ptr<FwS7Plus_AddressConfig> instance = new FwS7Plus_AddressConfig;
    instance.driverType = data[FW_PARAMETER_FIELD_COMMUNICATION];
    instance.driverNumber = (char)data[FW_PARAMETER_FIELD_DRIVER];
    instance.connectionName = data[DYN_INDEX_CONNECTION];
    instance.pollgroup = data[DYN_INDEX_POLL_GROUP];
    instance.transformation = (FwS7Plus_DataTransformationType)data[FW_PARAMETER_FIELD_DATATYPE];
    instance.direction = (FwS7Plus_Direction)data[FW_PARAMETER_FIELD_MODE];
    instance.reference = (string)data[FW_PARAMETER_FIELD_ADDRESS];
    instance.lowLevelComparison = (bool)data[DYN_INDEX_LOWLEVEL];
    instance.subindex = (uint)data[DYN_INDEX_SUBINDEX];
    instance.active = (bool)data[FW_PARAMETER_FIELD_ACTIVE];
    return instance;
  }

  public dyn_anytype toDynAnytype()
  {
    anytype emptyValue;
    dyn_anytype data;
    data[DYN_ANYTYPE_SIZE] = emptyValue;

    data[FW_PARAMETER_FIELD_COMMUNICATION] = driverType;
    data[FW_PARAMETER_FIELD_DRIVER] = driverNumber;
    data[DYN_INDEX_CONNECTION] = connectionName;
    data[FW_PARAMETER_FIELD_ADDRESS] = reference;
    data[DYN_INDEX_POLL_GROUP] = pollgroup;
    data[FW_PARAMETER_FIELD_DATATYPE] = transformation;
    data[FW_PARAMETER_FIELD_MODE] = direction;
    data[DYN_INDEX_LOWLEVEL] = lowLevelComparison;
    data[DYN_INDEX_SUBINDEX] = subindex;
    data[FW_PARAMETER_FIELD_ACTIVE] = active;

    return data;
  }

  /**
   * Check the address config data for validity
   *
   * It performs several checks and reports identified problem in exception.
   */
  public void checkData()
  {
    checkDriverType();
    checkTransformationType();
    checkDirection();
    checkDriverNumber();

    checkConnectionName();
    FwS7PlusReferenceUtils::validateReference(this.reference, FwS7Plus_DirectionConverter::toValue(this.direction));
    checkPollgroup();
    checkSubindex();
  }

  private void checkDriverType()
  {
    FwException::assert(driverType == "S7PLUS", "Invalid driver type " + driverType);
  }

  private void checkTransformationType()
  {
    FwException::assert(transformation != FwS7Plus_DataTransformationType::INVALID, "Invalid S7+ address data transformation");
  }

  private void checkDirection()
  {
    FwException::assert(direction != FwS7Plus_Direction::INVALID, "Invalid S7+ address direction");
  }

  private void checkDriverNumber()
  {
    FwException::assert(driverNumber > 0, "Invalid S7+ address driver number");
  }

  private void checkConnectionName()
  {
    FwException::assertDP(connectionName, FwS7Plus_ConnectionConfig::DPT_NAME, "Not valid S7+ connection '" + connectionName + "'");
  }

  private void checkSubindex()
  {
    FwException::assert(subindex >= 0 && subindex <= 31, "Not valid S7+ subindex '" + subindex + "', range is [0 ; 31]");
  }

  private void checkPollgroup()
  {
    if (direction == FwS7Plus_Direction::IN_OUT_POLLING
        || direction == FwS7Plus_Direction::IN_OUT_POLLINGONUSE
        || direction == FwS7Plus_Direction::IN_OUT_SUBSCRIPTION
        || direction == FwS7Plus_Direction::IN_POLLING
        || direction == FwS7Plus_Direction::IN_POLLINGONUSE
        || direction == FwS7Plus_Direction::IN_SUBSCRIPTION) {
      FwException::assertDP(pollgroup, fwPeriphAddress_S7PLUS_DPT_POLL_GROUP, "Not valid S7+ poll group '" + pollgroup + "'");
    }
  }
};
