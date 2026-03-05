/**
  (c) Copyright CERN 2005. All rights not expressly granted are reserved.
  icecontrols.support@cern.ch

  SPDX-License-Identifier: LGPL-3.0-only
**/

/**
 * S7+ redundant switch mode enum
 */
enum FwS7Plus_RedundantSwitchMode
{
  MANUAL = 0,
  OPSTATE = 1,
  CONNSTATE = 2,
  OPSTATE_CONNSTATE = 3,
  SWITCHTAG = 4
};
