/**
  (c) Copyright CERN 2005. All rights not expressly granted are reserved.
  icecontrols.support@cern.ch

  SPDX-License-Identifier: LGPL-3.0-only
**/

/**
 * S7+ data transformation enum
 */
enum FwS7Plus_DataTransformationType
{
  INVALID = 0,
  DEFAULT = 1001,
  BOOL = 1002,
  BYTE = 1003,
  WORD = 1004,
  DWORD = 1005,
  LWORD = 1006,
  USINT = 1007,
  UINT = 1008,
  UDINT = 1009,
  ULINT = 1010,
  SINT = 1011,
  INT = 1012,
  DINT = 1013,
  LINT = 1014,
  REAL = 1015,
  LREAL = 1016,
  DATE = 1017,
  DT = 1018,
  TIME = 1019,
  TOD = 1020,
  LDT = 1021,
  LTIME = 1022,
  LTOD = 1023,
  DTL = 1024,
  S5TIME = 1025,
  STRING = 1026,
  WSTRING = 1027
};

/**
 * S7+ data transformation enum to and from (u)int converter for address config attribute
 */
class FwS7Plus_DataTransformationTypeConverter
{
  private FwS7Plus_DataTransformationTypeConverter()
  {
  }

  /**
   * Convert S7+ data transformation enum to uint value to be stored in address config attribute
   *
   * @param item enum item to convert
   * @return uint representation of the given item
   */
  public static uint toValue(FwS7Plus_DataTransformationType item)
  {
    return (uint)item;
  }

  /**
   * Try to convert (u)int value to S7+ data transformation enum
   *
   * @param value numeric value to map to enum item
   * @return enum item for valid given value, INVALID item otherwise
   */
  public static FwS7Plus_DataTransformationType fromValue(int value)
  {
    try
    {
      return (FwS7Plus_DataTransformationType) value;
    }
    catch
    {
      return FwS7Plus_DataTransformationType::INVALID;
    }

    return FwS7Plus_DataTransformationType::INVALID;
  }
};

/**
 * S7+ data transformation converter for S7+ configuration panel
 */
class FwS7Plus_DataTransformationTypePanelConverter
{
  static mapping enumDetails;

  private FwS7Plus_DataTransformationTypePanelConverter()
  {
  }

  private static void initialize()
  {
    if (enumDetails.count() > 0)
    {
      return;
    }

    enumDetails = enumValues("FwS7Plus_DataTransformationType");
  }

  /**
   * S7+ data transformation enum to and from (u)int converter for address config attribute
   *
   * @param value string label selected in panel
   * @return mapped enum entry if valid, INVALID otherwise
   */
  public static FwS7Plus_DataTransformationType fromPanelDisplayValue(const string &value)
  {
    initialize();

    FwS7Plus_DataTransformationType item = enumDetails.value(strtoupper(value), FwS7Plus_DataTransformationType::INVALID);
    DebugTN(__FUNCTION__, item);
    return item;
  }

  public static string toPanelDisplayValue(FwS7Plus_DataTransformationType item)
  {
    string displayValue;
    switch (item)
    {
      case FwS7Plus_DataTransformationType::INVALID:
        return "";
    }
    return displayValue;
  }
};
