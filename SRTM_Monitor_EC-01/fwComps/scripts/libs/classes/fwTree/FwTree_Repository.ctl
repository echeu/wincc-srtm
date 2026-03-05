/**
(c) Copyright CERN 2005. All rights not expressly granted are reserved.
icecontrols.support@cern.ch

SPDX-License-Identifier: LGPL-3.0-only
 **/


/** @file
*/

#uses "fwGeneral/fwGeneral.ctl" // for FWDEPRECATED()
#uses "classes/fwStdLib/FwException.ctl"
#uses "classes/fwTree/FwTree.ctl"

class FwTree_Repository;
private global shared_ptr<FwTree_Repository> _FwTree_defaultRepositoryImpl=nullptr;

/** Interface class for FwTree Repository

    The repository manages (creates, deletes, manipulates) the FwTreeNode objects
    and its methods are invoked from FwTreeNode methods. Each FwTreeNode contains
    a reference to its FwTree_Repository instance in the _repo data member.

    The FwTree_Repository acts as an interface that defines the method that need
    to be implemented in "concrete" classes. The methods that need to be implemented
    are described below.

    It also provides the getDefault() (and its deprecated getInstance()) methods that
    return the singleton instance of default implementation (FwTree_RepositoryImpl) which
    uses the _FwTreeNode datapoints to persist the underlying data model and synchronise it
    across instances of managers and dist systems.

    Customized implementations derived from FwTree_Repository does not need to be necessarily
    singletons, yet they need to be available as a shared_ptr that is stored in the _repo
    data member of FwTreeNode instances. They would instantiate the objects that
    are derived (implement the API) of FwTreeNode, customized to the particular needs of the
    implementation. However, the FwTreeNode implementations are rich enough (data members,
    methods that invoke the FwTree_Repository, default implementations) so it could be used
    directly.
*/
class FwTree_Repository
{

    #event evTreeNodesModified(FwTreeNodePVec modifiedNodes) // alternatively, each FwTreeNode could also be connected to
    #event evTreeNodeDeleted(FwTreeNodePtr deletedNode)
    #event evTreeNodeRenamed(FwTreeNodePtr tn, string oldTnId)
    #event evDistChanged(string sysName, bool connected)

    protected FwTree_Repository() { } // restrict!
    public static shared_ptr<FwTree_Repository> getDefault()
    {
        if (equalPtr(_FwTree_defaultRepositoryImpl, nullptr)) {
            fwGeneral_loadCtrlLib("classes/fwTree/FwTree_RepositoryImpl.ctl", true, true);
            _FwTree_defaultRepositoryImpl=callFunction(fwGetFuncPtr("FwTree_RepositoryImpl::getInstance"));
        }
        return _FwTree_defaultRepositoryImpl;
    }

    /** Get the repository instance: PLEASE USE THE ONE FROM CONCRETE IMPLEMENTATION

        The FwTree_Repository::getInstance() implementation is for backward compatibility only
        and returns the default implementation (FwTree_RepositoryImpl) singleton.

        @deprecated use the concrete implementation's getInstance() or FwTree_Repository::getDefault
      */
    public static shared_ptr<FwTree_Repository> getInstance()
    {
        FWDEPRECATED();
        return getDefault();
    }

    protected shared_ptr<FwTree_Repository> _selfPtr=nullptr;

    /** Initializes the repository (starts caching of values, connect to change notifications, etc)
      */
    public void initialize() {} // optional

    /** Reinitialize, clear caches, etc
     */
    public void reset() {} // this one is optional

    /** Creates a clone of other TreeNode, using the current repository.

      This method allows to clone the tree nodes and also copy nodes from other trees.

      As we use create() it should also persist the settings.

      */
    public FwTreeNodePtr clone(FwTreeNodePtr tnToClone, FwTreeNodePtr parentTN, bool recursive=false)
    {
        FwTreeNodePtr theClone=create(tnToClone.name,parentTN,tnToClone.type, tnToClone.linkedObj,tnToClone.userData, tnToClone.isMaster);
        if (recursive) {
            FwTreeNodePVec childTNs=tnToClone.getChildren();
            for (int i=0;i<childTNs.count();i++) {
                clone(childTNs.at(i),theClone,recursive);
            }
        }
        return theClone;
    }

    /** Merge/update a subtree into another subtree.

      */
    public void merge(FwTreeNodePtr mergeFrom, FwTreeNodePtr mergeTo, bool subTreeOnly=false)
    {
        FwException::assert(equalPtr(mergeTo._repo, this._selfPtr),"Cannot merge trees: wrong repo in the target tree, "+mergeTo._dp);

        // let's firstly process only the children...
        FwTreeNodePVec newChildren=mergeFrom.getChildren();
        FwTreeNodePVec curChildren=mergeTo.getChildren();

        // diff, including the list of children checked recursively yet with no order-checking
        if (mergeFrom.equals(mergeTo,true,false)) return;

        if (subTreeOnly==false && !mergeFrom.isClipboard()) mergeTo.assign(mergeFrom); // assign all properties but not links...

        // now treat the list of children, with recursion

        for (int i=0;i<newChildren.count();i++) {
            FwTreeNodePtr c = newChildren.at(i);
            // now we check by node *name* if a similar one exists
            FwTreeNodePtr newChild=nullptr;
            vector<int> foundIdxs = curChildren.indexListOf("name",c.name);
            if (foundIdxs.isEmpty()) {
                newChild = create(c.name,mergeTo,c.type, c.linkedObj, c.userData, c.isMaster);
            } else {
                newChild=curChildren.at(foundIdxs.first());
            }
            // recurse the merge over children...
            merge(c,newChild);
        }
        persist(mergeTo);
    }


    public FwTreeNodePVec findBy(string memberName, mixed value, ...)
    {
        FwException::raise("Not implemented; abstract implementation invoked",__FUNCTION__);
        FwTreeNodePVec tnVec;
        return tnVec;
    }

    //_______________________________________________________________________

    /** Create a new node
     */
    public FwTreeNodePtr create(string name, FwTreeNodePtr parent,
                                string type="", string linkedObject="",
                                dyn_string userData=makeDynString(), bool isMaster=false) {
        FwException::raise("Not implemented; abstract implementation invoked",__FUNCTION__);
        return nullptr;
    }

    /** Delete the node
     */
    public void drop(FwTreeNodePtr tn, bool recursively=false) {
        FwException::raise("Not implemented; abstract implementation invoked",__FUNCTION__);
    }

    /** get an instance of FwTreeNode for a particular id (FwTreeNode datapoint) ;

        if allowInvalid is set, then the function will also resolve the nodes that are marked
        as invalid (used internally); otherwise invalid nodes are not returned
     */
    public FwTreeNodePtr get(string treeNodeDP, bool allowInvalid=false) {
        FwException::raise("Not implemented; abstract implementation invoked",__FUNCTION__);
        return nullptr;
    }

    /** reorder children of the tree node

      this is a reference implementation that does some simple checks and modifies the _children
      data member, and emits the signals; it is up to the derived class to implement eg. persisting
      the changes in a datapoint, etc.
      */
    public void reorderChildren(FwTreeNodePtr parent, FwTreeNodePVec children) {
        FwException::assert(!parent._invalid,"Cannot reorder children on invalid tree node"+parent._dp);

        dyn_string newChildrenList;
        dyn_string oldChildrenList=parent._children;

        for (int i=0; i<children.count(); i++) {
            FwTreeNode child=children.at(i);
            FwException::assertEqual(parent._sys, child._sys, "Cannot reorder tree items: Child item "+child._dp+" is from different system that the parent "+parent._dp);
            FwException::assert(equalPtr(parent._repo,child._repo),"Cannot reorder tree items across tree repositories");
            string childID = fwNoSysName(child._dp);
            int idx=oldChildrenList.indexOf(childID);
            FwException::assert(idx>=0, "Cannot reorder tree items: item "+childID+" is not a child of "+parent._dp);
            newChildrenList.append(childID);
            oldChildrenList.removeAt(idx);
        }
        // check/treat the clipboard node...
        for (int i=0; i<oldChildrenList.count(); i++) {
            string tnName=oldChildrenList.at(i);
            if (tnName.contains("---Clipboard")) {
                oldChildrenList.removeAt(i);
                newChildrenList.prepend(tnName);
                break;
            }
        }
        // ensure all of children are in the new list...
        FwException::assert(oldChildrenList.isEmpty(), "Cannot reorder tree items: not all children included in the new list , "+strjoin(oldChildrenList, " , "));

        parent._children=newChildrenList; // immediately modify our entry and trigger the events
        FwTreeNodePVec modifiedNodes;
        modifiedNodes.append(parent);
        evTreeNodesModified(modifiedNodes);
        parent.triggerModified();

    }

    public void moveNode(FwTreeNodePtr tn, FwTreeNodePtr newParent, FwTreeNodePtr beforeTN=nullptr)
    {
        FwException::assert(!tn._invalid,"Cannot move tree node that is invalid: "+tn._dp);
        FwException::assertNotNull(newParent,"Cannot move tree node "+tn._dp+" to a null parent");
        FwException::assert(equalPtr(tn._repo,newParent._repo),"Cannot move tree node "+tn._dp+" to another tree repository");
        // DebugTN(__FUNCTION__, tn._dp, newParent._dp);
        if (tn.getParent()==newParent) return; // moving to the current parent - just skip it.
        FwException::assert(!newParent._invalid,"Cannot move tree node "+tn._dp+ " to a invalid parent "+newParent._dp);
        FwException::assertEqual(tn._sys,newParent._sys, "Cannot move tree node "+tn._dp+" - new parent is in different system: "+newParent._dp);
        FwException::assert(!tn.isRoot(), "Cannot move the tree root node");

        string nodeDP=tn._dp;
        string parentDP=newParent._dp;
/*
        if (nodeDP==parentDP) {
            DebugTN(__FUNCTION__, "TODO: MAYBE WE SHOULD DO reorderChildren here");
            return; // nothing to do
        }
*/
        string nodeID=fwNoSysName(nodeDP);
        string parentID=fwNoSysName(parentDP);

        // make sure we are not moving this node to one of its children
        FwTreeNodePVec allChildren=tn.getAllChildren();
        FwException::assert(!allChildren.contains(newParent),"Cannot move tree node "+nodeDP+" below itself in the tree");

        FwTreeNodePtr prevParent=tn.getParent(); // we know it is not null as it is not a root node
        string prevParentDP = prevParent._dp;
        dyn_string prevParentChildren = prevParent._children;
        dyn_string newParentChildren = newParent._children;

        int idx=prevParentChildren.indexOf(nodeID);
        // note: it may happen that it was not found if the parent's list of children was inconsistent...
        if (idx>=0) prevParentChildren.removeAt(idx);

        int newPos=-1; // means append; notably if beforeTN==nullptr
        if (!equalPtr(beforeTN, nullptr)) {
            // find the place at which we should insert it
            newPos=newParentChildren.indexOf(fwNoSysName(beforeTN._dp));
        }
        if (newPos>=0 && newPos<newParentChildren.count()) {
            newParentChildren.insertAt(newPos, nodeID);
        } else {
            newParentChildren.append(nodeID);
        }

        prevParent._children=prevParentChildren;
        newParent._children=newParentChildren;
        tn._parent=parentID;
        // trigger all the local events to have immediate feedback
        FwTreeNodePVec modifiedNodes;
        modifiedNodes.append(prevParent);
        modifiedNodes.append(newParent);
        modifiedNodes.append(tn);
        evTreeNodesModified(modifiedNodes);
        prevParent.triggerModified();
        newParent.triggerModified();
        tn.triggerModified();

    }
    //_________________________________________________________________________

    public void renameNode(FwTreeNodePtr tn, string newNodeName) {
        FwException::raise("Not implemented; abstract implementation invoked",__FUNCTION__);
    }

    /** Persist the changes in underlying system (eg. datapoints, etc)

      */
    public void persist(FwTreeNodePtr tn) {
        FwException::raise("Not implemented; abstract implementation invoked",__FUNCTION__);
    }

    public FwTreeNodePtr createRootNode(string name) {
        FwException::raise("Not implemented; abstract implementation invoked",__FUNCTION__);
        return nullptr;
    }

    /** get the list of root nodes for the tree;

      This default implementation checks for empty _parent data member,
      and does not apply any further filtering

      */
    public FwTreeNodePVec getRootNodes(string filter="") {
        if (filter=="") {
            return findBy("_parent","");
        } else {
            return findBy("_parent","","name",filter);
        }
    }




    // utility to create an instance - constructor of FwTreeNode disabled on purpose
    protected synchronized FwTreeNodePtr _createTreeNode(string treeDp="", string treeNodeClassName="FwTreeNode")
    {
        FwTreeNodePtr newNode = fwCreateInstance(treeNodeClassName);
        FwException::assert(fwIsInstanceOf(newNode,"FwTreeNode"),"Created object is not derived from FwTreeNode (class "+treeNodeClassName+")");
        newNode._dp=treeDp;
        newNode._repo=this._selfPtr;
        return newNode;
    }



    /** Checks the integrity of all nodes and returns the list of inconsistencies.

      */
    public dyn_string checkLinks() { return makeDynString();} // this one is optional

};
