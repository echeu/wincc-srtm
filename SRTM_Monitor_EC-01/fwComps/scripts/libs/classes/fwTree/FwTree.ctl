/**
(c) Copyright CERN 2005. All rights not expressly granted are reserved.
icecontrols.support@cern.ch

SPDX-License-Identifier: LGPL-3.0-only
 **/


/** @file FwTree.ctl
    Object-Oriented API for the JCOP Framework Tree.

    The library delivers the implementation of the FwTreeNode class which
    provides the API to access and manipulate the JCOP Framework Tree information,
    and forms an alternative to the original function-based interface provided by
    the @ref fwTree.ctl library.

    The two libraries operate on the same underlying data stored in the datapoints
    of type _FwTreeNode; they are fully independent and could be used simultaneously.

    For more information please refer to the description provided by the manual
    of the FwTree component.
*/

#uses "classes/fwStdLib/FwException.ctl"

struct FwTreeNode;
using  FwTreeNodePtr = shared_ptr<FwTreeNode>; ///< shareable instances of FwTreeNode
using  FwTreeNodePVec = vector<FwTreeNodePtr> ; ///< vector of sharable instances of fwTreeNode


/**
    @todo consider better functions to search for nodes, something like
        public static FwTreeNodePtr findNode(string nodeName, bool excOnNoUniqueFound=true)
        public static FwTreeNodePVecfind(string nodeName, string treeType, string sysName="", bool excOnNotFound=false)
    For completeness: we already have the ::get(string treeNodeDP) and FwTree_Repository::findBy(string memberName, mixed value, ...)

    @todo: consider implementing the method to clone a node or subtree:
        public FwTreeNodePtr clone(string newName="", bool recursiveClone=true)

    @todo: consider a method that could create a complete path
    @todo: consider a method that returns the path to the node
 */

/// default implementation of tree repository to be used
/// -> see _getDefaultRepo()
global shared_ptr<void> _FwTree_treeRepoPtr=nullptr;

/** FwTreeNode is the public, object-oriented interface to access the JCOP Framework Tree data.

  It models a node in the tree, with identifiers, pointers to parent and child nodes
  (which define the actual dynamic tree structure) as well as attached properties
  (such as node type, attached object, user data, etc).

  The instances of the class may not be instantiated directly using the constructor, but rather
  through one of the "factory" methods: ref FwTreeNode::get or FwTreeNode::create.
  This is to guarantee that the API is used with "shareable" instances (shared_ptr<FwTreeNode>),
  which is essential for proper modelling of references to parent and child nodes, and functioning
  of the event-based notification system.
  For code clarity and convenience, the following type-aliases are also declared (with the `using` keyword)
  and used systematically in the API:
    - @ref FwTreeNodePtr - equivalent to @c shared_ptr<FwTreeNode>
    - @ref FwTreeNodePVec - equivalent to @c vector<FwTreeNodePtr>
    .
  It is recommended to employ these standard type-aliases when using the FwTreeNode API.

  The identity of each tree node is determined by its unique "ID" (accessible via getID(),
  or getDP() methods), which stores the name of the datapoint which persists the tree node.

  Certain properties of a tree node reflect its origins in the "FSM" component of the JCOP Framework,
  notably the notion of being a "master" (or "CU"), having an attached object (also called a "device")
  and user data.

  At the technical level, the FwTreeNode class defines the complete public interface which is abstract.
  The implementation is provided by internal classes: FwTreeNodeImpl, FwTree_Repository and
  FwTree_RepositoryImpl. The user is not supposed to ever refer to these internal classes directly:
  they are loaded and instantiated as needed to implement the functionality.
  In particular, the instances of shared_ptr<FwTreeNode> being actually manipulated are of type
  shared_ptr<FwTreeNodeImpl> (FwTreeNodeImpl is derived from the FwTreeNode "interface" class).
  The separation of the "interface" and "implementation" classes allows to properly resolve the
  challenges related to circular dependency between the classes, addressing also the use case
  of the classes being parsed for syntax-highlighting in the GEDI script editor.
  The implementation of the methods of FwTreeNode is therefore dummy, and actual implementation
  is provided by the FwTreeNodeImpl class derived from it.

  FwTreeNode has been implemented as a @c struct rather than a @c class,
  with all the members directly accessible for flexibility of its integration
  with the tree display panel (objects/fwTree/fwTree.pnl). However, to guarantee
  future compatibility as for convenience it is strongly recommended NOT to use
  the member variables directly but rather the dedicated "getter" and "setter" methods.

  The FwTreeNode objects are "live-connected" to the underlying datapoints in WinCC OA,
  and react to the changes in both: the data included in the elements as well as to
  the changes in instances (ie. datapoints being created/deleted, tree nodes being renamed).
  The underlying caching mechanism is implemented by the FwTree_DpObserver internal class,
  which should not ever be manipulated directly.
  The caching mechanism observes all connected dist systems and provisions instances of
  shared_ptr<FwTreeNode> referring to them. It reacts to connection/disconnection of systems,
  creating new instances or setting the _disconnected data member accordingly (and notifying
  about this fact using the event described below).

  FwTreeNode defines the @c evModified event which could be subscribed to if one wants to
  get asynchronous notifications about any change in the instance; separate subscription per
  every instance should be established using the `classConnect()` or `classConnectUserData()`
  functions.


  Some of the functionality that the user may be interested in is implemented in the
  @ref FwTree_Repository class, notably the notification about dist system connections,
  availability of new nodes, renames, etc. There are believed to be of rather rare use,
  unless one would like to implement a custom tree display panel.

  The rendering and interactions offered by the standard reference panel object,
  `objects/fwTree/fwTree.pnl` is customizable using the "tree delegate" classes.
  An instance of such class, derived from the @ref FwTreeNodeDelegate , may be
  passed to the above reference object using the `setTreeItemDelegate` method of
  the reference object panel instance. Please, refer to the documentation of the
  @ref FwTreeNodeDelegate class for more information.

  @nosubgrouping

  */
struct FwTreeNode {


    string _dp;           // unique ID - the DP name
    shared_ptr<void> _repo; // pointer to the FwTree_Repository implementation used by this object
    string _sys;          // cache the system name (with trailing colon)
    string name;          // readable, non-unique, generated from DP name
    dyn_string _children; // .children
    string _parent;       // .parent
    bool isMaster;        // .cu
    string linkedObj;     // .device
    string type;          // .type
    dyn_string userData;  // .userdata
    bool _disconnected=true; // internal, set to false once data connection is valid, reset to true e.g. if dist system disconnects
    bool _invalid=true;    // internal, used to maintain object/datapoint lifetime; set to true if the object is invalid (should not be used)


     /// @name Events
     /// FwTreeNode objects emit the following class events which could be subscribed to:
     /// @{

    /// @fn FwTreeNode::evModified(shared_ptr<FwTreeNode> tn)
    #event evModified(shared_ptr<FwTreeNode> tn)

    /// @}

    ///@name Getters and Setters
    /// The following methods allow to access and manipulate the member variables
    /// (properties) of the FwTreeNode objects
    ///@{

    /** Returns the ID (datapoint) of the tree node; @sa getDP()  @ingroup gettersSetters */
    public string     getID()          { return _dp;}
    public string     getSys()         { return _sys;}

    /** Returns the datapoint (ID) corresponding to the tree node; @sa getID() */
    public string     getDP()           { return _dp;}
    public string     getName()         { return name;}
    public bool       getIsMaster()     { return isMaster;}
    public bool       getIsCU()         { return isMaster;}
    public string     getNodeType()     { return type;}
    public string     getLinkedObj()    { return linkedObj;}
    public string     getDevice()       { return linkedObj;}
    public dyn_string getUserData()     { return userData;}
    public bool       getInvalid()      { return _invalid;}
    public bool       getDisconnected() { return _disconnected;}
    shared_ptr<void>  getRepo()         { return _repo; }

    /** Returns the properties of the tree node into the parameters passed in the call

          @param[out] aNodeType      - will contain the node type
          @param[out] aLinkedObject  - will contain the linkedObject information
          @param[out] aIsMaster      - will contain the isMaster (or isCU) information
          @param[out] aUserData      - will contain the userData
      */
    public void       getProps(string &aNodeType, string &aLinkedObject, bool &aIsMaster, dyn_string &aUserData)
    {
        aNodeType=aNodeType; aLinkedObject=linkedObj; aIsMaster=isMaster; aUserData=userData;
    }

    ///@}


    /// @name Factories
    /// @{
    /** Get the shared-pointer (FwTreeNodePtr) of this object
      */
    public FwTreeNodePtr selfPtr() { return get(_dp);} // get a shared pointer to ourselves

    /// @}



    /// @name Getters and Setters
    /// @{
    public void setIsCU(bool bIsCU)             { setIsMaster(bIsCU);}
    public void setDevice(string sDevice)       { setLinkedObj(sDevice); }
    public void setIsMaster(bool bIsMaster)     { this.isMaster  = bIsMaster;   _doSet();}

    public void setNodeType(string sNodeType)   { this.type      = sNodeType;   _doSet();}
    public void setLinkedObj(string sLinkedObj) { this.linkedObj = sLinkedObj;  _doSet();}
    public void setUserData(dyn_string uData)   { this.userData  = uData;       _doSet();}

    /** Sets the properties of the tree node

        The new values will be set immediately in the object and also persisted in the datapoint

      @param[in] newNodeType     - the new value for the node type property
      @param[in] newLinkedObject - the new value for the linkedObject property
      @param[in] newUserData     - the new value for the userData property; for convenience this
                                      parameter is optional with default value of empty dyn_string
      @param[in] newIsMaster     - the new value for the isMaster (isCU) property; for convenience this
                                      parameter is optional with default value of false
      */
    public void setProps(string newNodeType, string newLinkedObject, dyn_string newUserData=makeDynString(), bool newIsMaster=false)
    {
        this.type = newNodeType;
        this.linkedObj = newLinkedObject;
        this.userData = newUserData;
        this.isMaster = newIsMaster;
        _doSet();
    }

    /// @}

    /// @name Hierarchy modification
    /// @{
    /** Create a new tree node as a child of this node

      The new node is created with ID which is generated following the internal convention and corresponding
        to the name specified in the @c aName parameter, hence the tree display will present the name as
        specified, while a unique ID will be generated.
        The current node will be modified immediately to have the new node set as a child, and the information
        will be persisted in the datapoint (for this object having a new child, and for the newly created tree node).

      @returns the FwTreeNodePtr object corresponding to the new node.
      @throws an exception on invalid node name

      @param[in] aName          - the name of the new node
      @param[in] aType          - the node type; for convenience this is an optional parameter with
                                    default value set to empty string
      @param[in] aLinkedObject  - the value for the linked object property; for convenience this is an optional parameter with
                                    default value set to empty string
      @param[in] aUserData      - the value for the user data property; for convenience this is an optional parameter with
                                    default value set to empty dyn_string
      @param[in] aIsMaster      - the value for the isMaster property; for convenience this is an optional parameter with
                                    default value set to false
      */
    public FwTreeNodePtr addChild(string aName, string aType="", string aLinkedObject="", dyn_string aUserData=makeDynString(), bool aIsMaster=false)
    {
        if (aName.contains("---Clipboard")) {  // check if this tree already has a clipbord...
            FwException::assert(equalPtr(getRootNode().getClipboard(),nullptr),"Clipboard already exists in the tree to which the "+this.name+" belongs");
        }
        return _repo.create(aName, selfPtr(), aType, aLinkedObject, aUserData, aIsMaster);
    }

    ///@}

    // INTERNAL: get the pointer to the repository object
    // this one is tricky from the point of view of circular dependencies,
    // because at this point the FwTree_Repository class is not yet known
    // (only through its forward declaration).
    synchronized protected static shared_ptr<void> _getDefaultRepo()
    {
        if (equalPtr(_FwTree_treeRepoPtr,nullptr)) {
            if (!fwClassExists("FwTree_Repository")) fwGeneral_loadCtrlLib("classes/fwTree/FwTree_Repository.ctl",true,true);
            _FwTree_treeRepoPtr = callFunction(fwGetFuncPtr("FwTree_Repository::getDefault"));
        }
        return _FwTree_treeRepoPtr;
    }

    // INTERNAL: triggers the setting to the DP via the repo and fires all the classConnect'ed events
    protected void _doSet() { evModified(selfPtr()); _repo.persist(selfPtr());}


    /// @name Factories
    /// @{

    /** Retrieves the FwTreeNodePtr object for a tree node with given ID

      @param[in] treeNodeID - specifies the ID (ie. datapoint name) for the tree node;
                                  note that the ID starts with "fwTN_" and may be prefixed
                                  with the system name
      @returns the tree node that was found
      @throws exception if a tree node with the specified treeNodeID does not exist or may
                  not be accessed (e.g. dist system not yet connected)
      */
    public FwTreeNodePtr get(string treeNodeID)
    {
        return _repo.get(treeNodeID);
    }


    /** Create a new tree node with aribitrary parent node.

        This is a static method, ie. it could be used without any instance of FwTreeNode.
        The new node will be created using the default TreeRepository implementation.
        To create instances with custom TreeRepository implementations, invoke their methods directly instead.

        The new node is created with ID which is generated following the internal convention and corresponding
        to the name specified in the @c aName parameter, hence the tree display will present the name as
        specified, while a unique ID will be generated.

        The parent node specified in @c theParent must exist, and it will be modified immediately to have the
        new node set as a child, and the information will be persisted in the datapoints
        (for the parent having a new child, and for the newly created tree node).

        Note that it is not possible to create a root node of a tree using this function (design decision).
        One should use the dedicated method FwTree_Repository::createRootNode instead

      @returns the FwTreeNodePtr object corresponding to the new node.
      @throws an exception on invalid node name or non-existing/invalid parent, or if multiple clipboard creation is requested

      @param[in] aName          - the name of the new node
      @param[in,out] theParent  - the parent node; its list of children will be modified to contain the new node at the end
      @param[in] aType          - the node type; for convenience this is an optional parameter with
                                    default value set to empty string
      @param[in] aLinkedObject  - the value for the linked object property; for convenience this is an optional parameter with
                                    default value set to empty string
      @param[in] aUserData      - the value for the user data property; for convenience this is an optional parameter with
                                    default value set to empty dyn_string
      @param[in] aIsMaster      - the value for the isMaster property; for convenience this is an optional parameter with
                                    default value set to false

      */
    public static FwTreeNodePtr create(string aName, FwTreeNodePtr theParent, string aType="", string aLinkedObject="", dyn_string aUserData=makeDynString(), bool aIsMaster=false)
    {
        if (aName.contains("---Clipboard")) {  // check if this tree already has a clipbord...
            FwException::assert(!equalPtr(theParent,nullptr),"Cannot create a clipboard node as a root node");
            FwException::assert(equalPtr(theParent.getRootNode().getClipboard(),nullptr),"Clipboard already exists in the tree to which the "+this.name+" belongs");
        }

        return _getDefaultRepo().create(aName, theParent, aType, aLinkedObject, aUserData, aIsMaster);
    }

    /// @}

    /// @name Tree navigation
    /// @{

    /** Get the list of children tree nodes.

      If the invoking object corresponds to the tree node on a remote dist system, the function
      takes care of retrieving the FwTreeNodePtr corresponding for this system (even though the
      datapoint does not have them prefixed with the system name).
      It also skips the clipboard node, which may be obtained via the @ref FwTreeNode::getClipboard
      or FwTreeNode::getClipboardForTreeType methods.

      @sa FwTreeNode::getAllChildren()

      @returns the vector containing FwTreeNodePtr objects being direct children of this node;
                  the vector is empty if the node has no children.
     */
    public FwTreeNodePVec getChildren()
    {
        // this is the default implementation that assuems the parent/child information is in the
        // _children and _parent data members, and uses the get() to resolve them
        FwTreeNodePVec childNodes;
        for (int i=0; i<_children.count(); i++) {

            string childID=_children.at(i);
            if (childID.contains("---Clipboard")) continue;
            childID=this._sys+childID;
            FwTreeNodePtr childTN = _repo.get(childID);

            if (equalPtr(childTN, nullptr)) {
                DebugTN("WARNING in "+__FUNCTION__, "Cannot find child node "+childID+" for "+this._dp);
                this.ls();
                continue;
            } else if (childTN._invalid) {
                DebugTN("Child node is invalid; skipping it", childTN._dp);
                continue;
            } else {
                childNodes.append(childTN);
            }
        }
        return childNodes;
    }

    /** Get list of all direct and non-direct children (recursively).

      @sa FwTreeNode::getChildren()
      */
    public FwTreeNodePVec getAllChildren()
    {
        FwTreeNodePVec allChildren = getChildren();
        int direct_children_cnt=allChildren.count(); //we will keep appending beyond this index inside the loop
        for (int i=0; i<direct_children_cnt; i++) {
            FwTreeNodePVec grandChildren=allChildren.at(i).getAllChildren();
            for (int j=0; j<grandChildren.count(); j++) allChildren.append(grandChildren.at(j));
        }
        return allChildren;
    }

    /**
      Returns the parent tree node.

      @returns the FwTreeNodePtr to the parent, or a nullptr if this is a root node
    */
    public FwTreeNodePtr getParent()
    {
        if (_parent.isEmpty()) {
            return nullptr;
        } else {
            return get(_sys+_parent);
        }
    }

    /// @}

    /// @name Factories
    /// @{

    /** Constructor is restricted. Use the factory methods to get the instances.
    */
    protected FwTreeNode() {}

    /// @}

    /// @name Hierarchy modification
    /// @{
    /** Change the order of children

      The new list of children must contain all and only the current children

      @exception Exception is thrown if the new list of children does not contain all the
                  tree nodes of the current children list, or contains new ones

      @param[in,out] newChildrenList - the list of children in the order they should be set

    */
    public void reorderChildren(FwTreeNodePVec newChildrenList)
    {
        _repo.reorderChildren(selfPtr(), newChildrenList);
    }

    /** Move this node to another place in the tree

      The data in all affected nodes (this one, the new parent, and all the direct
        child nodes will be modified immediately and persisted in their datapoints.

      @throws Exception if the new parent is invalid

      @param[in,out] newParent - the new parent tree node
      @param[in] beforeTN - specifies the place at which it will be inserted in
                    the list of children of the new parent. It will be inserted
                    in the place before the specified node.
                    Specifying nullptr (default) means that it will be appended
                    at the end of the children list

      */
    public void move(FwTreeNodePtr newParent, FwTreeNodePtr beforeTN=nullptr)
    {
        _repo.moveNode(selfPtr(), newParent, beforeTN);
    }

    /** Drops the specified tree node

          This is a static method that could be called without an instance of FwTreeNode.

          After the call to the function the specified FwTreeNodePtr object becomes invalid
          and should never be used.

          @throws Exception if specified tree node does not exist
          @throws Exception if the specified node has children and @c recursively not set to true

          @param[in,out] tn      - the tree node to be dropped.
          @param[in] recursively - should be set to true if the subtree starting at @c tn should
                          be recursively dropped
      */
    /*
    public static void drop(FwTreeNodePtr tn, bool recursively) {}
*/

    /** Clones the specified tree node

        Produces a clone of this tree with the same name and data, (but different ID which is generated),
        and attaches this clone as the child of the node specified in the @c parent parameter.

        Note that the parent node must be managed by the same repository as this node.

      @param[in,out] parent       - the parent tree node to which the clone will be attached
      @param[in] recursively      - specifies if cloning should be done for the whole subtree of this node


     */
    public FwTreeNodePtr clone(FwTreeNodePtr parent, bool recursively)
    {
        return _repo.clone(selfPtr(),parent,recursively);
    }

    /** Merge another tree node into this node

        Merge another sub-tree to this node, by cloning the nodes that do not exist or updating
        the nodes in our subtree if they exist. The merge relies on the node names (not IDs) and it
        is recursive.

      @param[in] tn - the tree node to be merged; it does not necessarily need to be managed by the same repository
      @param[in] subTreeOnly - (optional, default false) if set to true then the properties of this node will not be
                                  updated/overwritten, and only the subtree will be merged

      */
    public void merge(FwTreeNodePtr tn, bool subTreeOnly=false)
    {
        _repo.merge(tn,selfPtr());
    }

    /** Drops this tree node.

          After the call the object becomes invalid: all references to it
          must not be used anymore.

          @throws Exception if this node has children and @c recursively not set to true

          @param[in] recursively - should be set to true if the subtree starting at @c tn should
                          be recursively dropped (optional parameter, by default set to false)

    */
    public void removeMe(bool recursively=false)
    {
        _repo.drop(selfPtr(), recursively);
    }

    ///@}


    // Trigger the event passing this object's shared_ptr as parameter. INTERNAL
    public void triggerModified()
    {
        triggerClassEvent(evModified, selfPtr());
    }

    /// @name Getters and Setters
    /// @{

    public bool isRoot()      { return _parent.isEmpty();}
    public bool hasChildren() { return !_children.isEmpty();}
    public bool isClipboard() { return _dp.contains("---Clipboard");}

    /// @}

    /// @name Tree navigation
    /// @{

    /** Get the root node of the tree to which this node belongs.

        Traverses the list of parents in search of the top node
          (ie one that has no parent).

        @returns FwTreeNodePtr of the root node.
            Returns self pointer if this is already the root node
      */
    public FwTreeNodePtr getRootNode()
    {
        // we may have different implementations in future,
        // e.g. every node could cache the root tree node ID
        // and resolution is traced...

        return getRootRecursively();
    }

    /** Get the master node of this node

        Returns the closest parent that is flagged as a master (or CU).

          Note that the function may return a nullptr if there is
          no master up to the root node of this tree

      */
    public FwTreeNodePtr getMasterNode()
    {
        return getMasterRecursively();
    }

    /** Get the clipboard node

      Returns the FwTreeNodePtr for the clipboard node that
      belongs to the same tree as this node

      @returns the clipboard node; may be nullptr if this tree has no clipboard node
      */
    public FwTreeNodePtr getClipboard()
    {
        FwTreeNodePtr  rootNode=getRootNode();
        dyn_string clipNodeNames=dynPatternMatch("*---Clipboard*", rootNode._children);
        if (clipNodeNames.isEmpty()) return nullptr;
        return get(clipNodeNames.first());
    }


    protected FwTreeNodePtr getRootRecursively(int recursionLevel=0)
    {

        FwTreeNodePtr parent = getParent();
        if (equalPtr(parent, nullptr)) return get(this._dp); // we are the rootNode
        FwException::assert(recursionLevel<30, "Cannot find the tree root node - too deep recusion", this._dp);
        return parent.getRootRecursively(recursionLevel+1);
    }

    protected FwTreeNodePtr getMasterRecursively(int recursionLevel=0)
    {
        if (this.isMaster) return selfPtr();
        FwTreeNodePtr parent = getParent();
        if (equalPtr(parent, nullptr)) return nullptr; // we reached the top of the tree...
        FwException::assert(recursionLevel<30, "Cannot find the tree master node - too deep recusion", this._dp);
        return parent.getMasterRecursively(recursionLevel+1);
    }


    /// @}

    /// @name Hierarchy modification
    /// @{
    /** Change the name of this tree node

      The FwTreeNodePtr of this object is modified immediately
      to reflect the changes (and the caching mechanism updated,
      so that eg. the FwTreeNode::get() works as expected), and then
      the change is persisted in the datapoint (though a combination
      of dpCreate/dpDelete with some extra notification) so that other
      managers making use of the FwTreeNode become aware of the change

      @throws Exception when the new node name is invalid.

      */
    public void renameNode(string newNodeName)
    {
        _repo.renameNode(selfPtr(), newNodeName);
    }
    /// @}

    /// @name Utilities
    /// @{

    /** Prints this node to log in a compact form
      */
    public void ls()
    {
        string s;
        sprintf(s, "=> %s (%s) TYPE=[:%s]", this._dp, this.name, this.type);
        if (this._invalid) s+= " #INVALID# ";
        if (this._invalid) s+= " #DISCONNECTED# ";
        s+= "  OBJ=["+this.linkedObj+"]";
        if (isMaster) s+=" MASTER ";
        s+= "\n      PARENT  :("+_parent+")";
        s+= "\n      CHILDREN:("+ strjoin(this._children, ",")+")";
        s+= "\n      DATA:    ("+strjoin(userData, ",")+")";
        DebugTN(s);
    }

    /** Prints the specified vector of FwTreeNodePtr to the log in a compact form

      This is a static method that does not need an instance of FwTreeNode to be invoked.

      @param[in] tnVec        - the vector of FwTreeNodePtr objects to be printed
      @param[in] fullPrintout - if set to false (default) then only the list of tree node
                                  IDs will be printed, otherwise the compact printout of
                                  complete information will be done (using FwTreeNode::ls)
      */
    public static void printVector(FwTreeNodePVec tnVec, bool fullPrintout=false)
    {
        DebugTN(__FUNCTION__+":");
        for (int i=0; i<tnVec.count(); i++) {
            if (fullPrintout) tnVec.at(i).ls();
            else DebugTN(" ["+i+"] => "+tnVec.at(i)._dp);
        }
    }
    /// @}

    /// @name Others
    /// @{

    /** Checks if objects are equal, excluding the node id

      This method checks if the content of two objects is equal;
      it does not take into account the node ID (_dp), and the check
      of parent and children is done by checking their names, not IDs

      The order of children does not matter
      */
    public bool equals(const FwTreeNode& tn2, bool recursively=true, bool childrenOrderMatters=false)
    {
        if (this.name      != tn2.name       ||
            this.isMaster  != tn2.isMaster   ||
            this.linkedObj != tn2.linkedObj  ||
            this.type      != tn2.type       ||
            this.userData  != tn2.userData) return false;

        FwTreeNodePtr parent1=this.getParent();
        FwTreeNodePtr parent2=tn2.getParent();

        string parentName1 = !equalPtr(parent1,nullptr) ? parent1.name : "";
        string parentName2 = !equalPtr(parent2,nullptr) ? parent2.name : "";
        if (parent1!=parent2) return false;

        dyn_string childrenNames1, childrenNames2;
        FwTreeNodePVec children1=this.getChildren();
        FwTreeNodePVec children2=tn2.getChildren();
        // we should have something like fwExtract() or fwMap() or fwBulkCollect in CtrlOOUtils one day...
        for (int i=0;i<children1.count();i++) childrenNames1.append(children1.at(i).name);
        for (int i=0;i<children2.count();i++) childrenNames2.append(children2.at(i).name);
        if (childrenOrderMatters) {
            childrenNames1.sort();
            childrenNames2.sort();
        }
        if (childrenNames1!=childrenNames2) return false;

        if (recursively) {
            for (int i=0;i<children1.count();i++) {
                FwTreeNodePtr c1=children1.at(i);
                // find the partner with the same name
                vector<int> idxList=children2.indexListOf("name",c1.name);
                if (idxList.isEmpty()) return false; // could not find...
                FwTreeNodePtr c2=children2.at(idxList.first());
                if (!c1.equals(c2,recursively,childrenOrderMatters)) return false;
            }
        }
        return true;
    }

    /** Assigns settings from another object.

      Id (_dp), name, parent and children are not modified
      */
    public void assign(FwTreeNode &tn2)
    {
        if (tn2.isClipboard()) return;

        this.isMaster = tn2.isMaster;
        this.linkedObj = tn2.linkedObj;
        this.type = tn2.type;
        this.userData = tn2.userData;
        _doSet();
    }

    /// @}
};
