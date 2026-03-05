/**
(c) Copyright CERN 2005. All rights not expressly granted are reserved.
icecontrols.support@cern.ch

SPDX-License-Identifier: LGPL-3.0-only
 **/


#uses "classes/fwStdLib/FwException.ctl"
#uses "CtrlOOUtils"
#uses "classes/fwTree/FwTree.ctl"
#uses "classes/fwTree/FwTree_Repository.ctl"
#uses "classes/fwTree/FwTree_DpObserver.ctl"


class FwTree_RepositoryImpl: FwTree_Repository
{
    protected FwTreeNodePVec                  allNodes;
    protected mapping                         treeNodeMap; // keys: tree dp names, values: shared_ptr<FwTreeNode?
    protected shared_ptr<FwTree_DpObserver>   dpObserver=nullptr;

    protected const string _mySysName=getSystemName();

    protected static bool _initialized=false;

    protected static shared_ptr<FwTree_Repository> _instance=nullptr;

    protected FwTree_RepositoryImpl()
    {
        fwGeneral_loadCtrlLib("classes/fwTree/FwTreeImpl.ctl", true, true);
        dpObserver = FwTree_DpObserver::get();
    }

    public static shared_ptr<FwTree_Repository> getInstance()
    {
        if (equalPtr(_instance,nullptr)) {
            _instance = new FwTree_RepositoryImpl();
            _instance._selfPtr=_instance;
            _instance.initialize(); // establish all connects, etc
        }
        return _instance;
    }

    //_________________________________________________________________________

    public FwTreeNodePtr get(string treeNodeDP, bool allowInvalid=false)
    {
        if (!treeNodeDP.contains(":")) treeNodeDP = _mySysName + treeNodeDP; // make it work for non-prefixed datapoints...
        FwTreeNodePtr tn=treeNodeMap.value(treeNodeDP,nullptr);
        // additionally, exclude the invalidated ones

        if (!allowInvalid && !equalPtr(tn,nullptr) && tn._invalid) tn=nullptr;
        return tn;
    }
    //_________________________________________________________________________


    //public synchronized FwTreeNodePtr _createTreeNode(string treeDp) synchronized(treeNodeMap)
    protected synchronized FwTreeNodePtr _createTreeNode(string treeDp) synchronized(treeNodeMap)
    {
        FwTreeNodePtr tn = FwTree_Repository::_createTreeNode(treeDp,"FwTreeNodeImpl");
        fwInvokeMethod(tn, "FwTreeNodeImpl", treeDp, false); // false =>no check of dpexists/dptype
        allNodes.append(tn);
        treeNodeMap.insert(treeDp, tn);
        return tn;
    }
    //_________________________________________________________________________

    protected bool _setTreeNodeData(FwTreeNodePtr treeNode, dyn_anytype data)
    {
        // Called to update the values - from a callback or creation.
        // it resets the _disconnected and respects the _invalid flag (ie. does nothing if it is set)
        // @param data - follows the structure/order of dpQuery
        // @returns true if there was actually a change for the node, false otherwise

        if (treeNode._invalid) return false;

        // would be nice to set multiple properties at once, or even deserialize them somehow from dyn_mixed
        //string treeDp=data[1];
        bool tnDataModified=false;
        if (treeNode.linkedObj!=data[2]) { treeNode.linkedObj  =   data[2]; tnDataModified=true;}
        if (treeNode.type     !=data[3]) { treeNode.type       =   data[3]; tnDataModified=true;}
        if (treeNode._children!=data[4]) { treeNode._children  =   data[4]; tnDataModified=true;}
        if (treeNode._parent  !=data[5]) { treeNode._parent    =   data[5]; tnDataModified=true;}
        if (treeNode.isMaster !=data[6]) { treeNode.isMaster   =   data[6]; tnDataModified=true;}
        if (treeNode.userData !=data[7]) { treeNode.userData   =   data[7]; tnDataModified=true;}
        if (treeNode._disconnected)      { treeNode._disconnected=false;    tnDataModified=true;}
        return tnDataModified;
    }
    //_________________________________________________________________________
    protected void _setTreeNodeDataNoDiff(FwTreeNodePtr treeNode, dyn_anytype data)
    {
        // Called to update the values - from a callback or creation.
        // it resets the _disconnected and respects the _invalid flag (ie. does nothing if it is set)
        // @param data - follows the structure/order of dpQuery
        // @returns true if there was actually a change for the node, false otherwise

        if (treeNode._invalid) return;

        //string treeDp=data[1];
        treeNode.linkedObj  =   data[2];
        treeNode.type       =   data[3];
        treeNode._children  =   data[4];
        treeNode._parent    =   data[5];
        treeNode.isMaster   =   data[6];
        treeNode.userData   =   data[7];
        treeNode._disconnected=false;
    }
    //_________________________________________________________________________

    protected void _treeDataModifiedCB(string what, const dyn_dyn_mixed &data) synchronized(treeNodeMap)
    {
        FwTreeNodePVec modifiedNodes; // keep the list of modified to trigger only once per node...
        //FwTreeNodePVec processedNodes; // all processed nodes (for the case of what="INIT" or "dist")
        dyn_string processedNodeIDs; // alternative to above - operate on node IDs

        bool dataChangedMode = (what=="DATA_CHANGED"); // cache! called many times
        int dataLen=dynlen(data); // "data" may be very long; makes sense cache the length

        for (int i=2; i<=dataLen; i++) { // we skip the first row (header);
            if (!dpExists(data[i][1])) continue; // skip the entries about already deleted DPs; see also ETM-1936;
            string treeDp=(string)data[i][1];

            string tnType=data[i][3];
            dyn_string children=data[i][4];
            string parent=data[i][5];
            // suppress the notifications from the FwTreeNodes that we've just created
            // and they are not yet initialised - ie. they have neither parent nor children
            // THIS ONE IS POTENTIALLY NOT NEEDED ANYMORE, AS DPQUERY IS FILTERING THIS FOR US ALREADY => TO BE CHECKED
            if (children.isEmpty() && parent.isEmpty() && tnType.isEmpty()) {
                DebugTN("### SKIP EMPTY");
                continue;
            }


            bool modified=false;
            FwTreeNodePtr tn=treeNodeMap.value(treeDp);

            if (tnType=="*RENAMED*") {
               if (equalPtr(tn,nullptr)) {
                   //DebugTN("OLD TN "+treeDp+" does not exist");
                   continue;
               }
               string renamedTo=data[i][2]; // transferred in the "linkedObj" a.k.a. ".device"
               tn._dp=renamedTo;
               string name= substr(fwNoSysName(renamedTo), 5); // cut the leading "fwTN_"
               if (name.startsWith("&")) name=substr(name, 5); // cut the &0001
               tn.name=name;
               treeNodeMap.remove(treeDp);
               treeNodeMap[renamedTo]=tn; // replace the one created in response to dpCreate()
               modified=true;
               // trigger the notification about the rename.
               triggerClassEventWait(evTreeNodeRenamed,tn, treeDp);
               //evTreeNodeRenamed(tn, treeDp);
               continue;
           } else {
               if (equalPtr(tn, nullptr)) {
                 tn = _createTreeNode(treeDp);
               }
               if (dataChangedMode){
                   modified=_setTreeNodeData(tn, data[i]);
               } else {
                    _setTreeNodeDataNoDiff(tn, data[i]);
               }
           }

            //if (!processedNodes.contains(tn)) processedNodes.append(tn);
            processedNodeIDs.append(treeDp);

            // maintain the modifiedNodes but only if this is an update (optimize init)
            if (dataChangedMode) {
                if (modified && !modifiedNodes.contains(tn)) modifiedNodes.append(tn); // unique() does not work for shared_ptr...
            }
        }

        dynSortAsc(processedNodeIDs);
        dynUnique(processedNodeIDs);

        if (!dataChangedMode) { // initialization or new dist connection/reconnection
            // in this case "what" holds the system name
            string sysName=what;

            // we will get a complete up-to-date data set retrieved by dpQuery FOR sysName.
            // hence we should invalidate/remove the nodes that are not there anymore...
            // by this point in the code the modifiedNodes will contain the current snapshot

            vector<int> nodeIds=allNodes.indexListOf("_sys", sysName);
            nodeIds.sort(false);
            for (int i=0;i<nodeIds.count();i++) {
                FwTreeNodePtr tn=allNodes.at(nodeIds.at(i));
                if (!processedNodeIDs.contains(tn._dp)) {
                    DebugTN("NODE DOES NOT EXIST ANYMORE", tn._dp);
                    tn._invalid=true;
                    tn._disconnected=true;
                    allNodes.removeAt(nodeIds.at(i));
                    i--; // update the index as we removed...
                    treeNodeMap.remove(tn._dp);
                }
            }
          }

        // trigger the events yet only if this is an update, not the initialization (in which
        // case one is expected to explore the tree using the repository rather than having callbacks)
        // or a new DIST connect (in which case it is conveyed with another signal)
        if (dataChangedMode) {
            evTreeNodesModified(modifiedNodes);
            // trigger on each modified nodes
            for (int i=0; i<modifiedNodes.count(); i++) modifiedNodes.at(i).triggerModified();
        }

    }
    //_________________________________________________________________________


    protected string generateNewID(string name)
    {
        FwException::assert(name!="", "Tree node name may not be empty");

        // we need to have a unique ID - construct it taking into account what's already there
        string sysName=_mySysName;
        if (name.contains(":")) {
            sysName=fwSysName(name, true);
            name=fwNoSysName(name);
        }

        int sysID=getSystemId(sysName);
        FwException::assert(sysID>0,           "Invalid tree node name: system does not exist for specified node "+sysName+":"+name);
        FwException::assert(nameCheck(name)==0,   "Invalid tree node name: characters not permitted "+name);

        string newID=sysName+"fwTN_"+name;
        if (dpExists(newID)) {
            dyn_string matches=getMatchingDPs(name,sysName);
            // "matches" already contain our preferred ID; we remove it to keep only fwTN_&NNNNXXX items
            // then get the last of it
            matches.removeAt(matches.indexOf(newID));
            if (matches.isEmpty()) {
                newID=sysName+"fwTN_&0001"+name;
            } else {
                matches.sort();
                string lastMatch=matches.last();
                int idx=strpos(lastMatch, ":");
                int lastNum=(int)(lastMatch.mid(idx+7, 4));
                FwException::assert(lastNum>0, "Could not generate ID for tree node "+name+" - failed to parse the id of tree node "+lastMatch);
                sprintf(newID, "%sfwTN_&%04d%s", sysName, lastNum+1, name);
            }
        }
        return newID;
    }

    public FwTreeNodePtr create(string name, FwTreeNodePtr parent, string type="",
                                string linkedObject="", dyn_string userData=makeDynString(),
                                bool isMaster=false)
    {
        FwException::assertNotNull(parent,     "Cannot create a node with empty parent: "+name);
        FwException::assert(!parent._invalid,  "Cannot create node "+name+" with invalid parent "+parent._dp);
        FwException::assert(equalPtr(parent._repo,this._selfPtr),"Cannot create node "+name+" , parrent repository do not match: "+parent._dp);


        string sysName;
        if (name.contains(":")) {
            sysName=fwSysName(name, true);
            name=fwNoSysName(name);
        } else {
            sysName=fwSysName(parent._dp,true);
        }

        int sysID=getSystemId(sysName); // we need it for dpCreate on local/remote system...

        string newID=generateNewID(sysName+name);
        string newIDNoSysName=fwNoSysName(newID);


        // prepare what we will dpSet (we will complete it below);
        // bulking them into a single dpSet helps
        //dyn_string dpesToSet    = makeDynString(newID+".device", newID+".type", newID+".cu", newID+".userdata");
        //dyn_mixed  valsToSet    = makeDynMixed(linkedObject, type, isMaster, userData);

        // firstly create our own FwTreeNode instance and register it,
        // so that we could return it already; then we will deal with dpCreate/dpSet
        FwTreeNodePtr newNode = _createTreeNode(newID);
        dyn_string emptyChildren; // will be set below anyway
        string emptyParent="";
        _setTreeNodeData(newNode, makeDynMixed(newID, linkedObject, type, emptyChildren, emptyParent, isMaster, userData));


        // link the new child to the parent
        dyn_string newChildrenList=parent._children;
        dynAppend(newChildrenList, newIDNoSysName); // TO REVIEW: SHOULD WE NOT HAVE A SYSTEM PREFIX (CHANGE OF CONVENTION!)
        parent._children=newChildrenList;
        string parentDP=parent._dp;
        newNode._parent = fwNoSysName(parentDP);

        //dpesToSet.append(newID+".parent");
        //valsToSet.append(fwNoSysName(parentDP));
        //dpesToSet.append(parentDP+".children");
        //valsToSet.append(newChildrenList);

        // Don't forget to intialize new node's children list with empty set (hence reset the TS and ManID on the DPE)
        //dpesToSet.append(newID+".children");
        //valsToSet.append(makeDynString());

        newNode._disconnected=false;
        newNode._invalid=false;
        FwTreeNodePVec modifiedNodes;
        modifiedNodes.append(parent);
        modifiedNodes.append(newNode);
        evTreeNodesModified(modifiedNodes);
        for (int i=0; i<modifiedNodes.count(); i++) modifiedNodes.at(i).triggerModified();

        dpCreate(newIDNoSysName, "_FwTreeNode", sysID);
        FwException::checkLastError();

        persist(newNode,false);
        persist(parent,true); // TODO: check if we should trigger notifications really
        //dpSetWait(dpesToSet, valsToSet);
        //FwException::checkLastError();

        return newNode;
    }
    //_________________________________________________________________________

    /** Utility: get all DPs matching a node name

        @param name the name of the node to be looked up; may be prefixed with the system name and colon,
                in which case this takes precedence over the @c sysName parameter
        @param sysName specifies the system name in which to find the node;
                - empty string (default) means the current system
                - "*" means all connected systems
     */
    public dyn_string getMatchingDPs(string name, string sysName="")
    {
        if (name.contains(":")) {
            sysName=fwSysName(name, true);
            name=fwNoSysName(name);
        }
        string pattern1=sysName+"fwTN_"+name;
        string pattern2=sysName+"fwTN_&*{0,1,2,3,4,5,6,7,8,9}"+name;
        dyn_string matches=dpNames("{"+pattern1+","+pattern2+"}", "_FwTreeNode");
        return matches;
    }
    //_________________________________________________________________________

    /** Find FwTreeNode instances by the value of their member
      */
    public FwTreeNodePVec findBy(string memberName, mixed value, ...)
    {
        FwTreeNodePVec matchingNodes;
        dyn_int foundIdxList = allNodes.indexListOf(memberName, value);
        for (int i=0; i<foundIdxList.count(); i++) {
          FwTreeNodePtr tn = allNodes.at(foundIdxList.at(i));
          // exclude the nodes that are invalid
          if (!equalPtr(tn,nullptr) && tn._invalid==false) matchingNodes.append(tn);
        }

        // now iterate over extra params...
        va_list parameters;
        int len=va_start(parameters)/2;
        for (int va_iter=1; va_iter<=len; va_iter++) {
            memberName=va_arg(parameters);
            value=va_arg(parameters);
            foundIdxList.clear();
            foundIdxList = matchingNodes.indexListOf(memberName, value);
            FwTreeNodePVec tmpMatchingNodes;
            for (int i=0; i<foundIdxList.count(); i++) tmpMatchingNodes.append(matchingNodes.at(foundIdxList.at(i)));
            matchingNodes=tmpMatchingNodes;
        }

        return matchingNodes;
    }
    //_________________________________________________________________________


    public void drop(FwTreeNodePtr tn, bool recursively=false)
    {
        // note! we MUST be able to remove the tree node that is marked as invalid!
        dyn_string dpsToDrop = makeDynString(tn._dp);

        FwTreeNodePVec childrenList;
        FwTreeNodePtr parentNode=tn.getParent();

        if (!tn._invalid) {
            FwException::assert(!equalPtr(parentNode, nullptr), "Cannot drop the top tree node: "+tn._dp);
            childrenList = tn.getAllChildren(); // recursive list of children
        }

        FwException::assert(childrenList.isEmpty() || recursively, "Cannot remove a tree node that has children nodes attached: "+tn._dp);

        // mark the nodes invalid ASAP to avoid e.g. dpDelete callbacks
        // fo attempt mainpulating our ._children
        tn._invalid=true;
        tn._disconnected=true;
        tn.triggerModified();

        for (int i=0; i<childrenList.count(); i++) {
            FwTreeNodePtr childTn = childrenList.at(i);
            if (childTn._invalid) continue; // already being deleted...
            dpsToDrop.append(childTn._dp);
            childTn._disconnected=true;
            childTn._invalid=true;
            // trigger the notification to the node as it gets invalid...
            childTn.triggerModified();
        }

        FwTreeNodePVec modifiedNodes = childrenList;
        modifiedNodes.append(tn);

        if (!equalPtr(parentNode, nullptr) && (!parentNode._invalid) && (!parentNode._disconnected)) {
            // remove ourselves from the parent
            dyn_string childrenList2=parentNode._children;
            int idx=dynContains(childrenList2, fwNoSysName(tn._dp));
            if (idx) dynRemove(childrenList2, idx);
            parentNode._children=childrenList2;

            dpSetWait(parentNode._dp+".children", childrenList2); // this will trigger the update on parent
            parentNode.triggerModified();
            modifiedNodes.append(parentNode);
        }

        // trigger update on all impacted nodes
        evTreeNodesModified(modifiedNodes);

        // already now remove from our lists
        FwTreeNodePVec toRemove=childrenList;
        toRemove.append(tn);
        for (int i=0;i<toRemove.count();i++) {
            FwTreeNodePtr removedItem=toRemove.at(i);
            int idx=allNodes.indexOf(removedItem);
            if (idx>=0) allNodes.removeAt(idx);
            if (treeNodeMap.contains(removedItem._dp)) treeNodeMap.remove(removedItem._dp);
        }

        // THE DELAY BELOW MAY ACTUALLY NOT BE NEEDED ANYMORE WITH THE NEW DPQUERYCONNECTSINGLE:
        // IT IS LIKELY THAT WE WILL NOT GET WRONG CALLBACKS ANYMORE, HENCE NO NEED FOR DELAY, PROBABLY

        // delayed dpDelete() to avoid the infamous warning
        // "DpIdentifier, formatValue, could not convert DpIdentifier to string";
        //  Still, we need to wait for it to finish to make sure
        // that DPs were really deleted (tried async execution of it via startScript
        // yet it is not guaranteed to finish when unit test stop).
        //delay(0, 600);
        for (int i=0; i<dpsToDrop.count(); i++) {
            string dp=dpsToDrop.at(i);
            if (dpExists(dp)) dpDelete(dp);
        }
        //delay(0, 600);
        delay(0, 100);
    }
    //_________________________________________________________________________

    protected void _treeDpDeletedCB(string treeNodeDP)
    {
        FwTreeNodePtr deletedNode = get(treeNodeDP,true);
        if (equalPtr(deletedNode,nullptr)) return; // not found anymore...
        deletedNode._invalid=true;
        triggerClassEventWait(evTreeNodeDeleted, deletedNode);

        string parentNodeID=deletedNode._parent;
        FwTreeNodePtr parentNode=get(parentNodeID);
        if (!equalPtr(parentNode, nullptr) && !parentNode._invalid) {
            dyn_string childrenList=parentNode._children;
            dynUnique(childrenList);
            int idx = dynContains(childrenList, fwNoSysName(treeNodeDP));
            if (idx>0) {
                dynRemove(childrenList, idx);
                parentNode._children=childrenList;
            }
        }

        // now remove the node from our lists
        int idx=allNodes.indexOf(deletedNode);
        if (idx>=0) allNodes.removeAt(idx);
        if (treeNodeMap.contains(treeNodeDP)) treeNodeMap.remove(treeNodeDP);
    }
    //_________________________________________________________________________

    protected void _distChangedCB(string sysName, bool connected) synchronized(treeNodeMap)
    {
        string sys=sysName+":";
        vector<int> nodeIds=allNodes.indexListOf("_sys",sys);
//        DebugTN("OK",nodeIds.count());

        bool gotDisconnected=!connected;
        vector<shared_ptr<FwTreeNode> > modifiedNodes;
        for (int i=0;i<nodeIds.count();i++) {
            FwTreeNodePtr tn=allNodes.at(nodeIds.at(i));
            if (tn._disconnected != gotDisconnected) {
                tn._disconnected = gotDisconnected;
                modifiedNodes.append(tn);  // MOVED FROM BELOW (?)
                tn.triggerModified();
            }
//            modifiedNodes.append(tn);  // MOVED ABOVE (?)
        }

        triggerClassEventWait(evDistChanged, sysName, connected);
        triggerClassEventWait(evTreeNodesModified, modifiedNodes);
    }
    //_________________________________________________________________________

    public void initialize()
    {
        // NOTE that it does not hurt to classConnect many times the same object to the same callback
        // it will be only once that it will be invoked anyway.
        // and in order to deal with re-running the panel when the objects kept in static data members
        // survive, we would rather have the classConnect's below called every time (it won't hurt)
        // rather that too few times...

        //DebugTN(__FUNCTION__);
        classConnect(this, this._treeDataModifiedCB, dpObserver, FwTree_DpObserver::evTreeDataModified);
        classConnect(this, this._treeDpDeletedCB,    dpObserver, FwTree_DpObserver::evDatapointDeleted);
        classConnect(this, this._distChangedCB,      dpObserver, FwTree_DpObserver::evDistConnectionChanged);

        synchronized(_initialized) {
            if (!_initialized) {
                dpObserver.initialize();
                _initialized=true;
            }
        }
    }
    //_________________________________________________________________________

    // reset the cache...
    public void reset() synchronized(treeNodeMap)
    {
        allNodes.clear();
        treeNodeMap.clear();
        initialize();
    }
    //_________________________________________________________________________

    public void showCache(bool full=true)
    {
        DebugTN(__FUNCTION__, full);
        if (!full) {
            dyn_string keys=mappingKeys(treeNodeMap);
            dynSort(keys);
            DebugTN(keys);
            return;
        }
        // otherwise... print full
        for (int i=0; i<allNodes.count(); i++) {
            allNodes.at(i).ls();
        }
    }
    //_________________________________________________________________________


    public void reorderChildren(FwTreeNodePtr parent, FwTreeNodePVec children)
    {
        FwTree_Repository::reorderChildren(parent,children); // bulk of job already done there
        dpSetWait(parent._dp+".children", parent._children);
        FwException::checkLastError();
    }
    //_________________________________________________________________________


    public void moveNode(FwTreeNodePtr tn, FwTreeNodePtr newParent, FwTreeNodePtr beforeTN=nullptr)
    {
        FwTreeNodePtr prevParent=tn.getParent();

        FwTree_Repository::moveNode(tn,newParent,beforeTN);

        dpSetWait(tn._dp+".parent", tn._parent,
                  newParent._dp+".children", newParent._children,
                  prevParent._dp+".children", prevParent._children);
        FwException::checkLastError();
    }
    //_________________________________________________________________________

    public void persist(FwTreeNodePtr tn, bool triggerNotification=true)
    {
        FwException::assert(!tn._invalid, "Cannot set tree node data from invalid object "+tn._dp);
        string dp=tn._dp;
        dyn_string dpes =  makeDynString(dp+".type", dp+".device" , dp+".cu"    , dp+".userdata", dp+".parent", dp+".children");
        dyn_mixed values = makeDynMixed (  tn.type , tn.linkedObj , tn.isMaster ,   tn.userData,   tn._parent,   tn._children);
        dpSetWait(dpes,values);
        FwException::checkLastError();
        FwTreeNodePVec modifiedNodes;
        modifiedNodes.append(tn);
        if (triggerNotification) evTreeNodesModified(modifiedNodes);
        // tn.triggerModified();    // we leave calling this up to the FwTreeNode that invokes us
    }
    //_________________________________________________________________________


    public FwTreeNodePtr createRootNode(string name)
    {
        FwException::assert(name!="", "Cannot create root tree node with empty name");

        // we need to have a unique ID - construct it taking into account what's already there
        string sysName=_mySysName;
        if (name.contains(":")) {
            sysName=fwSysName(name, true);
            name=fwNoSysName(name);
        }
        FwException::assert(!name.startsWith("fwTN"), "Need to specify tree node NAME (not ID, starting fwTN) in createRootNode: "+name);
        string treeDP = sysName+"fwTN_"+name;

        int sysID=getSystemId(sysName);
        FwException::assert(sysID>0, "Cannot create root tree node - system does not exist for specified node "+sysName+name);
        FwException::assert(nameCheck(name)==0,      "Cannot create root tree node - invalid name (chars not permitted) "+name);
        FwException::assert(!dpExists(treeDP),      "Cannot create root tree node - datapoint already in use "+treeDP);

        FwTreeNodePtr newNode = _createTreeNode(treeDP);
        dpCreate(fwNoSysName(treeDP), "_FwTreeNode", sysID);
        FwException::checkLastError();

        // immediately set it as valid and connected (usually done with _setTreeNodeData, which we don't call here as no need for it)
        newNode._invalid=false;
        newNode._disconnected=false;
        return newNode;
    }
    //_________________________________________________________________________

    public void renameNode(FwTreeNodePtr tn, string newNodeName) synchronized(treeNodeMap)
    {
        if (newNodeName==tn.getName()) return; // nothing to be done
        // Implemented through drop/create rathen than dpRename, as we would
        // otherwise have problems with interpreting the callbacks.
        // We want the original tn ro remain valid, ie. have it updated
        // (as well as all the mappings, etc).

        string oldNodeDP=tn._dp;
        string sysName=fwSysName(tn._dp,true);
        if (newNodeName.contains(":")) {
            FwException::assertEqual(fwSysName(newNodeName),sysName,
                                 "Tree node rename does not work across systems: "+tn._dp+"->"+newNodeName);
            newNodeName=fwNoSysName(newNodeName);
            sysName=fwSysName(newNodeName,true);
        }
        string newID=generateNewID(sysName+newNodeName); // throws as necessary

        int sysID=getSystemId(sysName); // we need it for dpCreate on local/remote system...
        string newIDNoSysName=fwNoSysName(newID);



        // preserve the list of children, as we will need to update them
        FwTreeNodePVec children = tn.getChildren();
        FwTreeNodePtr  parent   = tn.getParent();

        // create the tree node DP
        dpCreate(newIDNoSysName, "_FwTreeNode", getSystemId(sysName));
        FwException::checkLastError();
        // now we have it. Let us modify the map and our own tn to be used by the subsequent callbacks!
        tn._dp=newID;
        tn.name=newNodeName;
        //tn._disconnected=true; // will help us to get the notification later
        treeNodeMap.remove(oldNodeDP);
        treeNodeMap.insert(newID,tn);

        // prepare to re-link parent/children pointers
        dyn_string dpes;
        dyn_mixed values;
        for (int i=0;i<children.count();i++) {
            dpes.append(children.at(i)._dp+".parent");
            values.append(newIDNoSysName);
        }
        if (!equalPtr(parent,nullptr)) {
            dyn_string pChildren=parent._children;
            int idx=pChildren.indexOf(fwNoSysName(oldNodeDP));
            if (idx>=0) pChildren[idx+1]=newIDNoSysName;
            parent._children=pChildren;
            dpes.append(parent._dp+".children");
            values.append(pChildren);
        }

        // yet before we set everything to datapoints...

        // trigger the notification locally already...
        triggerClassEventWait(evTreeNodeRenamed,tn, oldNodeDP);
        //evTreeNodeRenamed(tn, oldNodeDP);

        //  ... and remotel by setting special values:
        // note that for local system it means another notification...

        dpSetWait( oldNodeDP+".type","*RENAMED*",
                   oldNodeDP+".device",newID);

        // now flush all the necessary modifications to DPs...
        persist(tn); // dump to DP, including parent and children; it triggers evTreeNodesModified()!
        dpSetWait(dpes,values);


        delay(0,500); // to avoid callbacks from setting the oldNodeDP (e.g. the "*RENAMED*" thing above);
        dpDelete(oldNodeDP);
    }
    //_________________________________________________________________________


    public dyn_string checkLinks()
    {
        dyn_string problemList;
        dyn_string allDps=dpNames("*","_FwTreeNode");
        dyn_string knownTNs=mappingKeys(this.treeNodeMap);
        dynSortAsc(knownTNs);
        dynSortAsc(allDps);
        problemList.append("INFO: # Datapoints:"+allDps.count());
        problemList.append("INFO: # AllObjects:"+this.allNodes.count());
        problemList.append("INFO: # TNObjInMap:"+knownTNs.count());
        vector<int> invalidTNs=allNodes.indexListOf("_invalid",true);
        problemList.append("INFO: # InvalidObj:"+invalidTNs.count());
        for (int i=0;i<allDps.count();i++) {
            if (!knownTNs.contains(allDps.at(i))) problemList.append("NOT_IN_CACHE:"+allDps.at(i));
        }
        for (int i=0;i<allNodes.count();i++) {
            if (i%500==0 && i!=0) DebugTN(__FUNCTION__,"Processing..."+i+"/"+allNodes.count()+"->"+(int)(100*i/allNodes.count())+"%");
            FwTreeNodePtr tn=allNodes.at(i);
            if (tn._invalid) {
                problemList.append("INVALID: ITEM:"+tn._dp);
            }
            if (!allDps.contains(tn._dp)) problemList.append("NO_DATAPOINT:"+tn._dp);
            if (tn._parent!="" && ! tn.isClipboard()) {
                FwTreeNodePtr parent=tn.getParent();
                if (equalPtr(parent,nullptr)) {
                    problemList.append("NO_PARENT: ITEM:"+tn._dp+" PARENT: "+tn._parent);
                } else {
                    FwTreeNodePVec children=parent.getChildren();
                    if (children.indexListOf("_dp",tn._dp).isEmpty()) problemList.append("NOT_IN_PARENT: ITEM:"+tn._dp+" PARENT: "+tn._parent);
                }
            }
            if (!tn._children.isEmpty()) {
                for (int j=0;j<tn._children.count();j++) {
                    string childID=tn._children.at(j);
                    if (!childID.contains(":")) childID=fwSysName(tn._dp, true)+childID;
                    FwTreeNodePtr childTN = get(childID);
                    if (equalPtr(childTN, nullptr)) {
                        problemList.append("NOT_CHILD: ITEM:"+tn._dp+" CHILD: "+childID);
                    } else if (childTN._invalid) {
                        problemList.append("CHILD_INVALID: ITEM:"+tn._dp+" CHILD: "+childID);
                    } else {
                        if (childTN._parent!="") {
                            FwTreeNodePtr parent=childTN.getParent();
                            if (equalPtr(parent,nullptr)) {
                                problemList.append("NOT_IN_CHILD: ITEM:"+tn._dp+" CHILD: "+childID+ " PARENT NOT FOUND");
                            } else if (parent._dp!=tn._dp) {
                                problemList.append("NOT_IN_CHILD: ITEM:"+tn._dp+" CHILD: "+childID+ " POINTS TO PARENT "+parent._dp);
                            }
                        }
                    }
                }

            }
        }

        return problemList;
    }

    public FwTreeNodePVec getRootNodes(string filter="") {


       FwException::assert(filter!="","Configured tree type or top node may not be empty");

       // the value of the filter is set from the treeType property on the widget, and could be
       // the tree node that should be used, which could be prefixed by the system name
       // or "*:" if all systems should be permitted.

       string sysName=fwSysName(filter,true);
       if (sysName=="") sysName=_mySysName;
       string tnName=fwNoSysName(filter);

       if (tnName.contains("fwTN_")) {
           // top node specified explicitly
           string topNodeName=dpSubStr(filter,DPSUB_SYS_DP); // canonical name even if no sysName: specified in filter
           FwException::assertDP(topNodeName, "_FwTreeNode", "Tree top node "+filter+" invalid");
           FwTreeNodePVec treeTops;
           treeTops.append(get(topNodeName));
           return treeTops;
       }

       // otherwise, look it up, assuming it is a root node
       if (sysName=="*:") {
           return FwTree_Repository::getRootNodes(tnName);
       } else {
           return findBy("_parent", "", "name", tnName,"_sys",sysName);
       }
   }


};

