/**
  (c) Copyright CERN 2005. All rights not expressly granted are reserved.
  icecontrols.support@cern.ch

  SPDX-License-Identifier: LGPL-3.0-only
**/

int main()
{
  fwInstallation_throw("Building Qt Help Collection for components", "INFO", 27);
  if(fwInstallationQtHelp_buildCollection() != 0){
    fwInstallation_throw("Building Qt Help Collection falied", "ERROR", 27);
    return -1;
  }
  fwInstallation_throw("Building Qt Help Collection succesfully completed", "INFO", 27);
  return 0;
}
