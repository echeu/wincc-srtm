/**
  (c) Copyright CERN 2005. All rights not expressly granted are reserved.
  icecontrols.support@cern.ch

  SPDX-License-Identifier: LGPL-3.0-only
**/

void main(string dpe, string fn) {
    string val;
    dpGet(dpe, val);
    file f = fopen(fn,"w");
    fputs(val, f);
    fclose(f);
}
