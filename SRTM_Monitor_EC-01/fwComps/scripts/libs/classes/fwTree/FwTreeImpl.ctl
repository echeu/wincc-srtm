/**
(c) Copyright CERN 2005. All rights not expressly granted are reserved.
icecontrols.support@cern.ch

SPDX-License-Identifier: LGPL-3.0-only
 **/


#uses "classes/fwTree/FwTree.ctl"
#uses "classes/fwTree/FwTree_Repository.ctl"

struct FwTreeNodeImpl: FwTreeNode {


    protected FwTreeNodeImpl(string treeDp, bool checkDpExists=true)
    {
        string dpNoSys=treeDp;
        int idx=strpos(treeDp,":")+1;
        if (idx>=1) {
            this._sys=substr(treeDp,0,idx);
            this._dp=treeDp;
            dpNoSys=substr(treeDp,idx);
        } else {
            this._sys=getSystemName();
            this._dp=this._sys+treeDp;
        }
        //FwException::assert(dpNoSys.startsWith("fwTN_"), "FwTreeNodeImpl constructor: datapoint must start with fwTN_ (got "+treeDp+").");
        if (checkDpExists) {
            FwException::assertDP(treeDp, "_FwTreeNode", "FwTreeNodeImpl constructor: datapoint must exist and be of dptype _FwTreeNode ("+treeDp+")");
        }
        // fwTN_NAME or fwTN_&0001NAME etc
        this.name = substr(dpNoSys, 5); // cut the leading "fwTN_"
        if (this.name.startsWith("&")) this.name=substr(this.name, 5); // cut the &0001
        this._invalid=false;
    }

    // this one works with default TreeRepository only (because it is static)
    public static void drop(FwTreeNodePtr tn, bool recursively)
    {
        FWDEPRECATED();
        _getDefaultRepo().drop(tn, recursively);
    }
};
