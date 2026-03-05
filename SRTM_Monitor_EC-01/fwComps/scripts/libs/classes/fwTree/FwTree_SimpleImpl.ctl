/**
(c) Copyright CERN 2005. All rights not expressly granted are reserved.
icecontrols.support@cern.ch

SPDX-License-Identifier: LGPL-3.0-only
**/

#uses "classes/fwTree/FwTree.ctl"
#uses "classes/fwTree/FwTree_Repository.ctl"


class FwTree_RepositorySimple: FwTree_Repository {

    protected static int _cnt=0; // to generate instance ids...


    protected mapping treeNodeMap; // key: id, value: shared_ptr<FwTreeNode>, for quick lookups
    protected FwTreeNodePVec allTreeNodes;

    protected FwTree_RepositorySimple(){} // disable to make sure we only get share'able instances, and we have the _selfPtr right

    // main factory method to get new instances. Note: NOT A SINGLETON!
    public static shared_ptr<FwTree_Repository> getInstance()
    {
        shared_ptr<FwTree_Repository> newInstance = new FwTree_RepositorySimple;
        newInstance._selfPtr=newInstance;

        return newInstance;
    }

    protected string generateId(string name)
    {
        string id;
        sprintf(id,"ST_%s_%05d",name,_cnt++);
        return id;
    }

    // creates a new node...
    public FwTreeNodePtr createRootNode(string name)
    {
        FwTreeNodePtr tn=_createTreeNode();
        tn._dp=generateId(name);
        tn.name=name;
        tn._invalid=false;
        tn._disconnected=false;

        treeNodeMap[tn._dp]=tn;
        allTreeNodes.append(tn);
        return tn;
    }

    // another factory, allowing to also specify the nodeId, eg. when reading from a file
    public FwTreeNodePtr createNodeWithId(string nodeId, string name, FwTreeNodePtr parent)
    {
        FwException::assert(!treeNodeMap.contains(nodeId),"Tree Node with such ID already exists:",nodeName);
        FwException::assertNotNull(parent,     "Cannot create a node with empty parent: "+name+" , consider using createRootNode()");
        FwException::assert(!parent._invalid,  "Cannot create node "+name+" with invalid parent "+parent._dp);
        FwTreeNodePtr tn=_createTreeNode(nodeId);
        tn.name=name;
        tn._invalid=false;
        tn._disconnected=false;
        tn._parent=parent._dp;
        dynAppend(parent._children, tn._dp);
        treeNodeMap[nodeId]=tn;
        allTreeNodes.append(tn);

        FwTreeNodePVec modifiedNodes;
        modifiedNodes.append(parent);
        modifiedNodes.append(tn);
        evTreeNodesModified(modifiedNodes);
        for (int i=0; i<modifiedNodes.count(); i++) modifiedNodes.at(i).triggerModified();

        return tn;
    }

    public FwTreeNodePtr create(string name, FwTreeNodePtr parent,
                                string type="", string linkedObject="",
                                dyn_string userData=makeDynString(), bool isMaster=false)
    {
        FwException::assertNotNull(parent,     "Cannot create a node with empty parent: "+name+" , consider using createRootNode()");
        FwException::assert(!parent._invalid,  "Cannot create node "+name+" with invalid parent "+parent._dp);
        FwException::assert(equalPtr(parent._repo,this._selfPtr),"Cannot create node "+name+" , parrent repository do not match: "+parent._dp);

        FwTreeNodePtr tn=_createTreeNode();
        tn._dp=generateId(name);
        tn.name=name;
        tn._parent=parent._dp;
        dynAppend(parent._children, tn._dp);
        tn._invalid=false;
        tn._disconnected=false;
        tn.setProps(type,linkedObject,userData,isMaster);
        FwException::assert(!treeNodeMap.contains(tn._dp),"SimpleTreeNode "+name+" already exists");
        treeNodeMap[tn._dp]=tn;
        allTreeNodes.append(tn);

        FwTreeNodePVec modifiedNodes;
        modifiedNodes.append(parent);
        modifiedNodes.append(tn);
        evTreeNodesModified(modifiedNodes);
        for (int i=0; i<modifiedNodes.count(); i++) modifiedNodes.at(i).triggerModified();

        return tn;
    }

    public FwTreeNodePtr get(string treeNodeId, bool allowInvalid=false)
    {
        FwTreeNodePtr tn = treeNodeMap.value(treeNodeId,nullptr);
        if (!equalPtr(tn,nullptr) && tn._invalid) return false;
        return tn;
    }
    //_________________________________________________________________________

    /** Find FwTreeNode instances by the value of their member
      */
    public FwTreeNodePVec findBy(string memberName, mixed value, ...)
    {
        FwTreeNodePVec matchingNodes;
        dyn_int foundIdxList = allTreeNodes.indexListOf(memberName, value);
        for (int i=0; i<foundIdxList.count(); i++) {
          FwTreeNodePtr tn = allTreeNodes.at(foundIdxList.at(i));
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

        FwException::assertNotNull(tn,"Cannot drop non-existing tree node");
        int idx = allTreeNodes.indexOf(tn);
        FwException::assert(idx>=0,"Tree node to drop not found "+tn._dp);

        FwTreeNodePtr tnFromMap=treeNodeMap.value(tn._dp);
        FwException::assertNotNull(tnFromMap,"Tree node to drop not found "+tn._dp);

        FwTreeNodePVec children=tn.getAllChildren();
        FwTreeNodePtr parent=tn.getParent();
        if (!recursively) FwException::assert(children.isEmpty(),"Cannot remove a tree node that has children "+tn._dp);


        if (!equalPtr(parent,nullptr)) {
            FwTreeNodePVec modifiedNodes;
            dyn_string parentChildren=parent._children;
            int idx=parentChildren.indexOf(tn._dp); // we do not need fwNoSysName for simple nodes...
            FwException::assert(idx>=0,"Tree node "+tn._dp+" was not found in the list of children of "+parent._dp);
            parentChildren.removeAt(idx);
            parent._children=parentChildren;
            modifiedNodes.append(parent);
            parent.triggerModified();
            evTreeNodesModified(modifiedNodes);
        }

        for (int i=0;i<children.count();i++) {
            FwTreeNodePtr childTN=children.at(i);
            int idx = allTreeNodes.contains(childTN);
            if (idx>=0) allTreeNodes.removeAt(idx);
            if (treeNodeMap.contains(childTN._dp)) treeNodeMap.remove(childTN._dp);
            childTN._invalid=true;
            evTreeNodeDeleted(childTN);
        }

        treeNodeMap.remove(tn._dp);
        allTreeNodes.removeAt(idx);
        tn._invalid=true;
        evTreeNodeDeleted(tn);
    }

    public void persist(FwTreeNodePtr tn)
    {
        // nothing to be done for this implementation
    }

    public void renameNode(FwTreeNodePtr tn, string newNodeName)
    {
        FwException::assert(newNodeName!="","Tree node name may not be empty");
        if (tn.name==newNodeName) return;

        tn.name=newNodeName;
        tn.triggerModified();
        FwTreeNodePVec modifiedNodes;
        modifiedNodes.append(tn);
        evTreeNodesModified(modifiedNodes);
    }

};
