/**
(c) Copyright CERN 2005. All rights not expressly granted are reserved.
icecontrols.support@cern.ch

SPDX-License-Identifier: LGPL-3.0-only
 **/

#uses "fwGeneral/fwGeneral.ctl"
/** Initializes global constants provided by the library

	@deprecated 2019-08-19
	
	The g_fwGeneral_dynDpeTypes constant is now initialized directly in fwGeneral.ctl
	(which was probably not possible at the time of the 1st implementation of this library).
	No need for such initailzer function anymore.

   @param exceptionInfo details of any exceptions
 */
void fwGeneral_init(dyn_string &exceptionInfo)
{
	FWDEPRECATED();
}