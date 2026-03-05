/**
(c) Copyright CERN 2005. All rights not expressly granted are reserved.
icecontrols.support@cern.ch

SPDX-License-Identifier: LGPL-3.0-only
 **/

#uses "fwAlarmHandling/fwAlarmScreenGeneric.ctl"

// invokedAESUserFunc is the WinCC OA's alarm screen hook for customisable cell click actions

void invokedAESUserFunc( string shapeName, int screenType, int tabType, int row, int column, string value, mapping mTableRow)
{
  fwAlarmScreenGeneric_invokedAESUserFunc(shapeName, screenType, tabType, row, column, value, mTableRow);
}
