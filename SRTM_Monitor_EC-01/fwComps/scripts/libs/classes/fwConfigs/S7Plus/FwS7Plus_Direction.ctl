/**
  (c) Copyright CERN 2005. All rights not expressly granted are reserved.
  icecontrols.support@cern.ch

  SPDX-License-Identifier: LGPL-3.0-only
**/

#uses "classes/fwGeneral/FwException"

/**
 * S7+ direction enum
 */
enum FwS7Plus_Direction
{
  INVALID = -1,
  IN_SUBSCRIPTION = 0,
  IN_POLLING = 1,
  IN_SINGLEQUERY = 2,
  IN_POLLINGONUSE = 3,
  IN_ALARM = 4,
  IN_TSPP = 5,
  OUT = 6,
  IN_OUT_SUBSCRIPTION = 7,
  IN_OUT_POLLING = 8,
  IN_OUT_SINGLEQUERY = 9,
  IN_OUT_POLLINGONUSE = 10
//   IN_SUBSCRIPTION = DPATTR_ADDR_MODE_INPUT_POLL,
//   IN_POLLING = DPATTR_ADDR_MODE_INPUT_POLL,
//   IN_SINGLEQUERY = DPATTR_ADDR_MODE_INPUT_SQUERY,
//   IN_POLLINGONUSE = DPATTR_ADDR_MODE_INPUT_CYCLIC_ON_USE,
//   IN_ALARM = 9, // DPATTR_ADDR_MODE_AM_ALERT
//   IN_TSPP = DPATTR_ADDR_MODE_INPUT_SPONT,
//   OUT = DPATTR_ADDR_MODE_OUTPUT,
//   IN_OUT_SUBSCRIPTION = DPATTR_ADDR_MODE_IO_POLL,
//   IN_OUT_POLLING = DPATTR_ADDR_MODE_IO_POLL,
//   IN_OUT_SINGLEQUERY = DPATTR_ADDR_MODE_IO_SQUERY,
//   IN_OUT_POLLINGONUSE = DPATTR_ADDR_MODE_IO_CYCLIC_ON_USE
//    case DPATTR_ADDR_MODE_IO_SPONT - "In/Out TSPP is not valid S7+ option
};

/**
 * S7+ direction enum to and from (u)int converter for address config attribute
 */
class FwS7Plus_DirectionConverter
{
  static dyn_int values;

  private FwS7Plus_DirectionConverter()
  {
  }

  private static void initialize()
  {
    mapping allItems = enumValues("FwS7Plus_Direction");
    for (int i = 0; i < allItems.count(); ++i) {
      values.append(allItems.valueAt(i));
    }
  }

  /**
   * Convert S7+ direction enum to uint value to be stored in address config attribute
   *
   * @param item enum item to convert
   * @return uint corresponding WinCC OA direction attribute value
   */
  public static uint toValue(FwS7Plus_Direction item)
  {
    switch (item)
    {
      case FwS7Plus_Direction::IN_SUBSCRIPTION:
        return DPATTR_ADDR_MODE_INPUT_POLL;
      case FwS7Plus_Direction::IN_POLLING:
        return DPATTR_ADDR_MODE_INPUT_POLL;
      case FwS7Plus_Direction::IN_SINGLEQUERY:
        return DPATTR_ADDR_MODE_INPUT_SQUERY;
      case FwS7Plus_Direction::IN_POLLINGONUSE:
        return DPATTR_ADDR_MODE_INPUT_CYCLIC_ON_USE;
      case FwS7Plus_Direction::IN_ALARM:
        return 9; // DPATTR_ADDR_MODE_AM_ALERT;
      case FwS7Plus_Direction::IN_TSPP:
        return DPATTR_ADDR_MODE_INPUT_SPONT;
      case FwS7Plus_Direction::OUT:
        return DPATTR_ADDR_MODE_OUTPUT;
      case FwS7Plus_Direction::IN_OUT_SUBSCRIPTION:
        return DPATTR_ADDR_MODE_IO_POLL;
      case FwS7Plus_Direction::IN_OUT_POLLING:
        return DPATTR_ADDR_MODE_IO_POLL;
      case FwS7Plus_Direction::IN_OUT_SINGLEQUERY:
        return DPATTR_ADDR_MODE_IO_SQUERY;
      case FwS7Plus_Direction::IN_OUT_POLLINGONUSE:
        return DPATTR_ADDR_MODE_IO_CYCLIC_ON_USE;
      default:
        FwException::raise("Invalid enum item " + item);
    }
  }

  /**
   * Try to convert (u)int value to S7+ direction enum
   *
   * @param value numeric value to map to enum item
   * @param isSubscription flag if the direction should be subscription or polling
   * @return enum item for valid given value, INVALID item otherwise
   */
  public static FwS7Plus_Direction fromValue(uint value, bool isSubscription)
  {
    if (values.isEmpty()) {
      initialize();
    }

    switch ((int)value) {
      case DPATTR_ADDR_MODE_INPUT_POLL:
        return isSubscription ? FwS7Plus_Direction::IN_SUBSCRIPTION : FwS7Plus_Direction::IN_POLLING;
      case DPATTR_ADDR_MODE_INPUT_SQUERY:
        return FwS7Plus_Direction::IN_SINGLEQUERY;
      case DPATTR_ADDR_MODE_INPUT_CYCLIC_ON_USE:
        return FwS7Plus_Direction::IN_POLLINGONUSE;
      case 9: // DPATTR_ADDR_MODE_AM_ALERT;
        return FwS7Plus_Direction::IN_ALARM;
      case DPATTR_ADDR_MODE_INPUT_SPONT:
        return FwS7Plus_Direction::IN_TSPP;
      case DPATTR_ADDR_MODE_OUTPUT:
        return FwS7Plus_Direction::OUT;
      case DPATTR_ADDR_MODE_IO_POLL:
        return isSubscription ? FwS7Plus_Direction::IN_OUT_SUBSCRIPTION : FwS7Plus_Direction::IN_OUT_POLLING;
      case DPATTR_ADDR_MODE_IO_SQUERY:
        return FwS7Plus_Direction::IN_OUT_SINGLEQUERY;
      case DPATTR_ADDR_MODE_IO_CYCLIC_ON_USE:
        return FwS7Plus_Direction::IN_OUT_POLLINGONUSE;
      default:
        FwException::raise("Invalid value for FwS7Plus_Direction enum item " + value);
    }
  }

};

/**
 * S7+ direction converter for S7+ configuration panel
 */
class FwS7Plus_DirectionPanelConverter
{
  static const int PANEL_INDEX_DIRECTION_IN = 1;
  static const int PANEL_INDEX_DIRECTION_IN_OUT = 2;
  static const int PANEL_INDEX_DIRECTION_OUT = 0;

  static const int PANEL_INDEX_RECEIVE_MODE_SUBSCRIPTION = 0;
  static const int PANEL_INDEX_RECEIVE_MODE_POLLING = 1;
  static const int PANEL_INDEX_RECEIVE_MODE_SINGLEQUERY = 2;
  static const int PANEL_INDEX_RECEIVE_MODE_POLLONUSE = 3;
  static const int PANEL_INDEX_RECEIVE_MODE_ALARM = 4;
  static const int PANEL_INDEX_RECEIVE_MODE_TSPP = 5;

  private FwS7Plus_DirectionPanelConverter()
  {
  }

  /**
   * Convert direction to direction radio button index
   *
   * @param item direction enum entry
   * @return corresponding direction radio button position
   */
  public static int toPanelDirectionSelectionIndex(FwS7Plus_Direction item)
  {
    switch (item)
    {
      case FwS7Plus_Direction::IN_ALARM:
      case FwS7Plus_Direction::IN_POLLING:
      case FwS7Plus_Direction::IN_POLLINGONUSE:
      case FwS7Plus_Direction::IN_SINGLEQUERY:
      case FwS7Plus_Direction::IN_SUBSCRIPTION:
      case FwS7Plus_Direction::IN_TSPP:
        return PANEL_INDEX_DIRECTION_IN;
      case FwS7Plus_Direction::IN_OUT_POLLING:
      case FwS7Plus_Direction::IN_OUT_POLLINGONUSE:
      case FwS7Plus_Direction::IN_OUT_SINGLEQUERY:
      case FwS7Plus_Direction::IN_OUT_SUBSCRIPTION:
        return PANEL_INDEX_DIRECTION_IN_OUT;
      case FwS7Plus_Direction::OUT:
        return PANEL_INDEX_DIRECTION_OUT;
      default:
      {
        FwException::raise("Invalid FwS7Plus_Direction item: " + item);
      }
    }
  }

  /**
   * Convert direction to receive mode radio button index
   *
   * @param item direction enum entry
   * @return corresponding receive mode radio button position
   */
  public static int toPanelReceiveModeSelectionIndex(FwS7Plus_Direction item)
  {
    switch (item)
    {
      case FwS7Plus_Direction::IN_SUBSCRIPTION:
      case FwS7Plus_Direction::IN_OUT_SUBSCRIPTION:
        return PANEL_INDEX_RECEIVE_MODE_SUBSCRIPTION;
      case FwS7Plus_Direction::IN_POLLING:
      case FwS7Plus_Direction::IN_OUT_POLLING:
        return PANEL_INDEX_RECEIVE_MODE_POLLING;
      case FwS7Plus_Direction::IN_SINGLEQUERY:
      case FwS7Plus_Direction::IN_OUT_SINGLEQUERY:
        return PANEL_INDEX_RECEIVE_MODE_SINGLEQUERY;
      case FwS7Plus_Direction::IN_POLLINGONUSE:
      case FwS7Plus_Direction::IN_OUT_POLLINGONUSE:
        return PANEL_INDEX_RECEIVE_MODE_POLLONUSE;
      case FwS7Plus_Direction::IN_ALARM:
        return PANEL_INDEX_RECEIVE_MODE_ALARM;
      case FwS7Plus_Direction::IN_TSPP:
        return PANEL_INDEX_RECEIVE_MODE_TSPP;
      case FwS7Plus_Direction::OUT:
        return -1;
      default:
        FwException::raise("Invalid FwS7Plus_Direction item: " + item);
    }
  }

  /**
   * Convert direction radio button and receive mode radio button index into enum entry
   *
   * @param direction direction radio button position
   * @param receiveMode receive mode radio button position
   * @param corresponding enum entry for valid combination
   */
  public static FwS7Plus_Direction fromPanelDirectionAndReceiveModeSelection(int direction, int receiveMode)
  {
    switch (direction)
    {
      case PANEL_INDEX_DIRECTION_IN:
        switch (receiveMode) {
          case PANEL_INDEX_RECEIVE_MODE_SUBSCRIPTION:
            return FwS7Plus_Direction::IN_SUBSCRIPTION;
          case PANEL_INDEX_RECEIVE_MODE_POLLING:
            return FwS7Plus_Direction::IN_POLLING;
          case PANEL_INDEX_RECEIVE_MODE_SINGLEQUERY:
            return FwS7Plus_Direction::IN_SINGLEQUERY;
          case PANEL_INDEX_RECEIVE_MODE_POLLONUSE:
            return FwS7Plus_Direction::IN_POLLINGONUSE;
          case PANEL_INDEX_RECEIVE_MODE_ALARM:
            return FwS7Plus_Direction::IN_ALARM;
          case PANEL_INDEX_RECEIVE_MODE_TSPP:
            return FwS7Plus_Direction::IN_TSPP;
          default:
            FwException::raise("Invalid receive mode for IN FwS7Plus_Direction item: " + receiveMode);
        }
        break;
      case PANEL_INDEX_DIRECTION_IN_OUT:
        switch (receiveMode) {
          case PANEL_INDEX_RECEIVE_MODE_SUBSCRIPTION:
            return FwS7Plus_Direction::IN_OUT_SUBSCRIPTION;
          case PANEL_INDEX_RECEIVE_MODE_POLLING:
            return FwS7Plus_Direction::IN_OUT_POLLING;
          case PANEL_INDEX_RECEIVE_MODE_SINGLEQUERY:
            return FwS7Plus_Direction::IN_OUT_SINGLEQUERY;
          case PANEL_INDEX_RECEIVE_MODE_POLLONUSE:
            return FwS7Plus_Direction::IN_OUT_POLLINGONUSE;
          default:
            FwException::raise("Invalid receive mode for IN/OUT FwS7Plus_Direction item: " + receiveMode);
        }
        break;
      case PANEL_INDEX_DIRECTION_OUT:
        return FwS7Plus_Direction::OUT;
      default:
        FwException::raise("Invalid FwS7Plus_Direction item: " + item);
    }
  }
};
