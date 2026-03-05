/**
  (c) Copyright CERN 2005. All rights not expressly granted are reserved.
  icecontrols.support@cern.ch

  SPDX-License-Identifier: LGPL-3.0-only
**/

enum FwS7Plus_PlcType
{
  INVALID = 0,
  AUTOMATIC = 1,
  S7_1200 = 272,
  S7_1500 = 16,
  S7_1500_RH = 2,
  S7_1500_RH_SINGLE = 3,
  S7_1500_SOFT_PLC = 528,
  PLCSIM = 768
};

/**
 * Converter for S7Plus PlcType enum
 */
class FwS7Plus_PlcTypeConverter
{
  private static FwS7Plus_PlcTypeConverter()
  {
  }

  /**
   * Convert frontend name to enum item
   *
   * @param frontEndName frontend name
   * @result matching enum item for the given input
   */
  public static FwS7Plus_PlcType fromFrontendName(const string &frontendName)
  {
    switch (frontendName)
    {
      case "S7-1200":
        return FwS7Plus_PlcType::S7_1200;
      case "S7-1500":
        return FwS7Plus_PlcType::S7_1500;
      case "S7-1500 R/H":
        return FwS7Plus_PlcType::S7_1500_RH;
      case "S7-1500 R/H Single":
        return FwS7Plus_PlcType::S7_1500_RH_SINGLE;
      case "S7-1500 Soft PLC":
        return FwS7Plus_PlcType::S7_1500_SOFT_PLC;
      case "PLCSim":
        return FwS7Plus_PlcType::PLCSIM;
      case "Automatic":
        return FwS7Plus_PlcType::AUTOMATIC;
      default:
        throw(makeError("", PRIO_SEVERE, ERR_CONTROL, 0, __FUNCTION__ + ": " + frontendName + " unknown S7Plus name"));
    }
  }
};
