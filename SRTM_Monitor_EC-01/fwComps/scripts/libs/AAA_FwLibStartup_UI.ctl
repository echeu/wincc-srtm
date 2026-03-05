/**
(c) Copyright CERN 2005. All rights not expressly granted are reserved.
icecontrols.support@cern.ch
 
SPDX-License-Identifier: LGPL-3.0-only
**/

// Library loaded as first by every UI manager
//
// Due to its name staring with "AAA", this is the first library that will
// be loaded by every UI manager and hence could contain the #uses statements
// for all the other libs that need to be loaded *before* anything else
//
// Note that having the filename start with "_" or with a digit is not sufficient,
// because of a peculiar sorting algorithm that is applied.

#uses "fwCore/fwCore_UI.ctl"