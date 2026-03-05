/**
(c) Copyright CERN 2005. All rights not expressly granted are reserved.
icecontrols.support@cern.ch

SPDX-License-Identifier: LGPL-3.0-only
**/

const string FW_OPC_UA_TOOLS_CLIENT_DPT = "_OPCUA";
const string FW_OPC_UA_TOOLS_SERVER_DPT = "_OPCUAServer";
const string FW_OPC_UA_TOOLS_SUBSCRIPTION_DPT = "_OPCUASubscription";

//------------------------------------------
// Functions retrieving information from DPs

/** Returns list of datapoints of _OPCUA type in current system
  */
dyn_string fwOpcUaTools_getClientDps(dyn_string &exceptionInfo){
  dyn_string clientDps = dpNames("*", FW_OPC_UA_TOOLS_CLIENT_DPT);
  dyn_errClass lastError = getLastError();
  if(lastError.count() > 0){
    fwException_raise(exceptionInfo, "ERROR", "fwOpcUaTools_getClientDps " +
                      "- failed to get WinCC OA OPC UA client DPs. Reason: " +
                      getErrorText(lastError), "");
  }
  return clientDps;
}

/** Returns list of datapoints of _OPCUAServer type in current system
  */
dyn_string fwOpcUaTools_getServerDps(dyn_string &exceptionInfo){
  dyn_string serverDps = dpNames("*", FW_OPC_UA_TOOLS_SERVER_DPT);
  dyn_errClass lastError = getLastError();
  if(lastError.count() > 0){
    fwException_raise(exceptionInfo, "ERROR", "fwOpcUaTools_getServerDps " +
                      "- failed to get WinCC OA OPC UA server DPs. Reason: " +
                      getErrorText(lastError), "");
  }
  return serverDps;
}

/** Returns list of datapoints of _OPCUASubscription type in current system
  */
dyn_string fwOpcUaTools_getSubscriptionDps(dyn_string &exceptionInfo){
  dyn_string subscriptionDps = dpNames("*", FW_OPC_UA_TOOLS_SUBSCRIPTION_DPT);
  dyn_errClass lastError = getLastError();
  if(lastError.count() > 0){
    fwException_raise(exceptionInfo, "ERROR", "fwOpcUaTools_getSubscriptionDps " +
                      "- failed to get WinCC OA OPC UA subscription DPs. Reason: " +
                      getErrorText(lastError), "");
  }
  return subscriptionDps;
}

/** Returns list of WinCC OA OPC UA server connections assigned to an OPC UA client
  * @param clientDp (in)  WinCC OA OPC UA client DP (DPT=_OPCUA)
  * @param exceptionInfo (out)  Output list with details of any exceptions
  * @return List of WinCC OA OPC UA server connections
  */
dyn_string fwOpcUaTools_getServersInClientDp(string clientDp, dyn_string &exceptionInfo){
  dyn_string servers;
  int retCode = dpGet(clientDp + ".Config.Servers", servers);
  dyn_errClass lastError = getLastError();
  string lastErrText;
  if(lastError.count() > 0){
    lastErrText = getErrorText(lastError);
  }else if(retCode != 0){
    lastErrText = "dpGet failed with code " + (string)retCode;
  }
  if(!lastErrText.isEmpty()){
    fwException_raise(exceptionInfo, "ERROR", "fwOpcUaTools_getServersInClientDp " +
                      "- failed to retrieve servers list from " + clientDp +
                      ".Config.Servers DPE. Reason: " + lastErrText, "");
  }
  return servers;
}

/** Returns list of WinCC OA OPC UA subscription datapoints assigned
  * to an OPC UA server datapoint.
  * @param serverDp (in)  WinCC OA OPC UA server DP (DPT=_OPCUAServer)
  * @param exceptionInfo (out)  Output list with details of any exceptions
  * @return List of WinCC OA OPC UA subscription datapoints
  */
dyn_string fwOpcUaTools_getSubscriptionDpsInServerDp(string serverDp,
                                                     dyn_string &exceptionInfo){
  dyn_string subscriptionDps;
  int retCode = dpGet(serverDp + ".Config.Subscriptions", subscriptionDps);
  dyn_errClass lastError = getLastError();
  string lastErrText;
  if(lastError.count() > 0){
    lastErrText = getErrorText(lastError);
  }else if(retCode != 0){
    lastErrText = "dpGet failed with code " + (string)retCode;
  }
  if(!lastErrText.isEmpty()){
    fwException_raise(exceptionInfo, "ERROR", "fwOpcUaTools_getSubscriptionDpsInServerDp " +
                      "- failed to retrieve subscription DPs list from " + serverDp +
                      ".Config.Subscriptions DPE. Reason: " + lastErrText, "");
  }
  return subscriptionDps;
}

/** Returns map where keys are the given WinCC OA OPC UA client DPs
  * and values are list of OPC UA server connections assigned to them
  * @param clientDps (in)  List of WinCC OA OPC UA client DPs
  * @param exceptionInfo (out)  Output list with details of any exceptions
  * @return Mapping of WinCC OA OPC UA client DPs and their assigned server connections
  *         e.g. "dist1:_OPCUA1" : ["OPCUA_DummyServerConnection"]
  *         Value is always a list. If no servers assigned to client, then value is an empty list,
  *         If one server assigned, then list has one element
  */
mapping fwOpcUaTools_getClientDpsServersMap(const dyn_string &clientDps,
                                            dyn_string &exceptionInfo){
  mapping clientDpsServersMap;
  for(int i=0;i<clientDps.count();i++){
    string clientDp = clientDps.at(i);
    clientDpsServersMap[clientDp] =
        fwOpcUaTools_getServersInClientDp(clientDp, exceptionInfo);
    if(exceptionInfo.count() > 0){
      fwException_raise(exceptionInfo, "ERROR", "fwOpcUaTools_getClientDpsServersMap " +
                        "- error creating mapping of client DPs and their assigned " +
                        "server connections", "");
      break;
    }
  }
  return clientDpsServersMap;
}

/** Returns map where keys are the given WinCC OA OPC UA server DPs
  * and values are list of OPC UA subscription DPs assigned to them
  * @param serverDps (in)  List of WinCC OA OPC UA server DPs
  * @param exceptionInfo (out)  Output list with details of any exceptions
  * @return Mapping of WinCC OA OPC UA server DPs and their assigned subscription DPs
  *         e.g. "dist1:_OPCUA_DummyServerConnection" : ["dist_1:OPCUA_DummySubscription"]
  *         Value is always a list. If no subscription DPs assigned to server, then value is an empty list,
  *         If one subscription DP assigned, then list has one element
  */
mapping fwOpcUaTools_getServerDpsSubscriptionDpsMap(const dyn_string &serverDps,
                                                    dyn_string &exceptionInfo){
  mapping serverDpsSubscriptionDpsMap;
  for(int i=0;i<serverDps.count();i++){
    string serverDp = serverDps.at(i);
    serverDpsSubscriptionDpsMap[serverDp] =
        fwOpcUaTools_getSubscriptionDpsInServerDp(serverDp, exceptionInfo);
    if(exceptionInfo.count() > 0){
      fwException_raise(exceptionInfo, "ERROR",
                        "fwOpcUaTools_getServerDpsSubscriptionDpsMap - error creating" +
                        " mapping of server DPs and their assigned subscription DPs", "");
      break;
    }
  }
  return serverDpsSubscriptionDpsMap;
}


//-----------------
// Functions for conversion between datapoint names and titles

const string FW_OPC_UA_TOOLS_SYS_DP_SEPARATOR = ":";
const string FW_OPC_UA_TOOLS_CLIENT_DP_PREFIX = "_OPCUA";

/** Returns WinCC OA OPC UA client DP for a given driver number
  * @param driverNum (in)  WinCC OA driver number
  * @return WinCC OA OPC UA client DP (incl. system name)
  */
string fwOpcUaTools_driverNum2ClientDp(int driverNum){
  return (driverNum<=0)?"":
      (getSystemName() + FW_OPC_UA_TOOLS_CLIENT_DP_PREFIX + (string)driverNum);
}

/** Returns driver number corresponding to given WinCC OA OPC UA client DP
  * @param clientDp (in)  WinCC OA OPC UA client DP
  * @return WinCC OA driver number if > 0, if <= 0 then invalid result
  */
int fwOpcUaTools_clientDp2DriverNum(string clientDp){
  clientDp = clientDp.mid(clientDp.indexOf(FW_OPC_UA_TOOLS_SYS_DP_SEPARATOR) + 1);
  string driverNumStr = clientDp.mid(FW_OPC_UA_TOOLS_CLIENT_DP_PREFIX.length());
  return (int)driverNumStr;
}

/** Returns WinCC OA OPC UA server DP for a given server connection name
  * @param serverName (in)  WinCC OA OPC UA server connection name
  * @return WinCC OA OPC UA server DP (incl. system name)
            or empty string if server connection name not provided
  */
string fwOpcUaTools_serverName2dp(string serverName){
  return serverName.isEmpty()?"":(getSystemName() + "_" + serverName);
}

/** Returns WinCC OA OPC UA server connection name resolved from a given datapoint name
  * @param serverDp (in)  WinCC OA OPC UA server DP
  * @return WinCC OA OPC UA server connection name
  */
string fwOpcUaTools_serverDp2name(string serverDp){
  // additional '+1' to discard leading underscore "_" character
  return serverDp.mid(serverDp.indexOf(FW_OPC_UA_TOOLS_SYS_DP_SEPARATOR) + 1 + 1);
}

/** Returns WinCC OA OPC UA subscription DP for a given subscription name
  * @param subscription (in)  WinCC OA OPC UA subscription name
  * @return WinCC OA OPC UA subscription DP (incl. system name)
            or empty string if server connection name not provided
  */
string fwOpcUaTools_subscriptionName2dp(string subscription){
  return subscription.isEmpty()?"":(getSystemName() + "_" + subscription);
}

/** Returns WinCC OA OPC UA subscription name resolved from a given datapoint name
  * @param subscriptionDp (in)  WinCC OA OPC UA subscription DP
  * @return WinCC OA OPC UA subscription name or input argument
  *         if it is not a valid datapoint name
  */
string fwOpcUaTools_subscriptionDp2name(string subscriptionDp){
  if(!dpExists(subscriptionDp)){
    return subscriptionDp;
  }
  // additional '+1' to discard leading underscore "_" character
  return subscriptionDp.mid(subscriptionDp.indexOf(FW_OPC_UA_TOOLS_SYS_DP_SEPARATOR) + 1 + 1);
}


//---------------------------------------------------------
// Configuration diagnostic and consistency check functions

/** Returns WinCC OA OPC UA server DPs, not assigned to any client DP
  * @param serverDps (in)  List of WinCC OA OPC UA server DPs in the system
  * @param clientDpsServersMap (in)  Mapping of WinCC OA OPC UA client DPs
  *                                  and their assigned server connections
  * @return List of unassigned WinCC OA OPC UA server DPs
  */
dyn_string fwOpcUaTools_getUnusedServerDps(
    const dyn_string &serverDps,
    const mapping &clientDpsServersMap){
  dyn_string usedServers = _fwOpcUaTools_mappingValuesToList(clientDpsServersMap);
  usedServers.unique();
  dyn_string unusedServerDps;
  for(int i=0;i<serverDps.count();i++){
    string serverDp = serverDps.at(i);
    if(!_fwOpcUaTools_isSecondReduPeerDp(serverDp, serverDps) &&
       !usedServers.contains(fwOpcUaTools_serverDp2name(serverDp))){
      unusedServerDps.append(serverDp);
    }
  }
  return unusedServerDps;
}

/** Returns WinCC OA OPC UA subscription DPs, not assigned to any server DP
  * @param subscriptionDps (in)  List of WinCC OA OPC UA subscription DPs in the system
  * @param serverDpsSubscriptionDpsMap (in)  Mapping of WinCC OA OPC UA server DPs
  *                                          and their assigned subscription DPs
  * @return List of unassigned WinCC OA OPC UA subscription DPs
  */
dyn_string fwOpcUaTools_getUnusedSubscriptionDps(
    const dyn_string &subscriptionDps,
    const mapping &serverDpsSubscriptionDpsMap){
  dyn_string usedSubscriptionDps =
      _fwOpcUaTools_mappingValuesToList(serverDpsSubscriptionDpsMap);
  usedSubscriptionDps.unique();
  dyn_string unusedSubscriptionDps;
  for(int i=0;i<subscriptionDps.count();i++){
    string subscriptionDp = subscriptionDps.at(i);
    if(!_fwOpcUaTools_isSecondReduPeerDp(subscriptionDp, subscriptionDps) &&
       !usedSubscriptionDps.contains(subscriptionDp)){
      unusedSubscriptionDps.append(subscriptionDp);
    }
  }
  return unusedSubscriptionDps;
}

/** Returns WinCC OA OPC UA client DPs having invalid server connections in a mapping structure
  * @param serverDps (in)  List of WinCC OA OPC UA server DPs in the system
  * @param clientDpsServersMap (in)  Mapping of WinCC OA OPC UA client DPs
  *                                  and their assigned server connections
  * @return Mapping of WinCC OA OPC UA client DPs and their assigned invalid server connections
  *         e.g. "dist1:_OPCUA1" : ["OPCUA_NotAValidOne"]
  *         Value is always a list of length >= 1
  */
mapping fwOpcUaTools_getClientDpsAssignedInvalidServersMap(
    const dyn_string &serverDps,
    const mapping &clientDpsServersMap){
  return _fwOpcUaTools_getFilteredMap_keysWithValuesNotMatchingElementsOfList(
      clientDpsServersMap, serverDps, "fwOpcUaTools_serverName2dp");
}

/** Returns WinCC OA OPC UA server DPs having invalid subscription DPs in a mapping structure
  * @param subscriptionDps (in)  List of WinCC OA OPC UA subscription DPs in the system
  * @param serverDpsSubscriptionDpsMap (in)  Mapping of WinCC OA OPC UA server DPs
  *                                          and their assigned subscription DPs
  * @return Mapping of WinCC OA OPC UA server DPs and their assigned invalid subscription DPs
  *         e.g. "dist1:_OPCUA_DummyServerConnection" : ["dist_1:OPCUA_InvalidSubscription"]
  *         Value is always a list of length >= 1
  */
mapping fwOpcUaTools_getServerDpsAssignedInvalidSubscriptionDpsMap(
    const dyn_string &subscriptionDps,
    const mapping &serverDpsSubscriptionDpsMap){
  return _fwOpcUaTools_getFilteredMap_keysWithValuesNotMatchingElementsOfList(
      serverDpsSubscriptionDpsMap, subscriptionDps);
}

/** Returns WinCC OA OPC UA server connections assigned to more than one client DP in a mapping stucture
  * @param clientDpsServersMap (in)  Mapping of WinCC OA OPC UA client DPs
  *                                  and their assigned server connections
  * @return Mapping of reused WinCC OA OPC UA server connections and client DPs that are using them
  *         e.g. "OPCUA_DummyServerConnection" : ["dist_1:_OPCUA1", "dist_1:_OPCUA2"]
  *         Value is always a list of length >= 2
  */
mapping fwOpcUaTools_getReusedServersClientDpsMap(
    const mapping &clientDpsServersMap){
  mapping serversClientDpsMap =
      _fwOpcUaTools_getInvertedMap(clientDpsServersMap);
  return _fwOpcUaTools_getFilteredMap_keysWithMultipleValues(serversClientDpsMap);
}

/** Returns WinCC OA OPC UA subscription DPs assigned to more than one server DP in a mapping stucture
  * @param serverDpsSubscriptionDpsMap (in)  Mapping of WinCC OA OPC UA server DPs
  *                                          and their assigned subscription DPs
  * @return Mapping of reused WinCC OA OPC UA subscription DPs and server DPs that are using them
  *         e.g. "dist_1:_OPCUA_DummySubscription" : ["dist_1:_OPCUA_ServerConn1", "dist_1:_OPCUA_ServerConn2"]
  *         Value is always a list of length >= 2
  */
mapping fwOpcUaTools_getReusedSubscriptionDpsServerDpsMap(
    const mapping &serverDpsSubscriptionDpsMap){
  mapping subscriptionDpsServerDpsMap =
      _fwOpcUaTools_getFilteredMap_removedSecondReduPeerDpsFromValueList(
          _fwOpcUaTools_getInvertedMap(serverDpsSubscriptionDpsMap));
  return _fwOpcUaTools_getFilteredMap_keysWithMultipleValues(subscriptionDpsServerDpsMap);
}

// Define datapoints excluded from redu consistency check (own tool DPs)
const dyn_string FW_OPC_UA_TOOLS_REDU_CHECK_EXCLUDED_SERVER_DPS =
    makeDynString(getSystemName() + "_OPCUA_TOOLS");
const dyn_string FW_OPC_UA_TOOLS_REDU_CHECK_EXCLUDED_SUBSCRIPTION_DPS =
    makeDynString(getSystemName() + "_OPCUA_TOOLS_DEFAULT");

/** Returns WinCC OA OPC UA server DPs that do not have a redu peer DP (ending with '_2')
  * @param serverDps (in)  List of WinCC OA OPC UA server DPs in the system
  * @return List of WinCC OA OPC UA server DPs without redu peer DP
  */
dyn_string fwOpcUaTools_getMissingReduPeerServerDps(const dyn_string &serverDps){
  dyn_string serverDpsToCheck = _fwOpcUaTools_getDpsForReduPeerDpCheck(
      serverDps, FW_OPC_UA_TOOLS_REDU_CHECK_EXCLUDED_SERVER_DPS);
  return _fwOpcUaTools_getMissingReduPeerDps(serverDpsToCheck, serverDps);
}

/** Returns WinCC OA OPC UA subscription DPs that do not have a redu peer DP (ending with '_2')
  * @param subscriptionDps (in)  List of WinCC OA OPC UA subscription DPs in the system
  * @return List of WinCC OA OPC UA subscription DPs without redu peer DP
  */
dyn_string fwOpcUaTools_getMissingReduPeerSubscriptionDps(const dyn_string &subscriptionDps){
  dyn_string subscriptionDpsToCheck = _fwOpcUaTools_getDpsForReduPeerDpCheck(
      subscriptionDps, FW_OPC_UA_TOOLS_REDU_CHECK_EXCLUDED_SUBSCRIPTION_DPS);
  return _fwOpcUaTools_getMissingReduPeerDps(subscriptionDpsToCheck, subscriptionDps);
}

//--------------------

const string FW_OPC_UA_TOOLS_ADDR_CFG_ISSUE_TYPE_DRV_NOT_CONFIGURED = "driverNotConfigured";
const string FW_OPC_UA_TOOLS_ADDR_CFG_ISSUE_TYPE_WRONG_SERVER = "wrongServerForDriverNumSet";
const string FW_OPC_UA_TOOLS_ADDR_CFG_ISSUE_TYPE_WRONG_SUBSCRIPTION = "wrongSubscriptionForServerSet";
const string FW_OPC_UA_TOOLS_ADDR_CFG_NO_ISSUE = "";

string fwOpcUaTools_getAddressConfigIssue(const dyn_anytype &addressConfig,
                                          const mapping &clientDpsServersMap,
                                          const mapping &serverDpsSubscriptionDpsMap){
  int drvNum = addressConfig[fwPeriphAddress_DRIVER_NUMBER];
  string serverConnection = addressConfig[fwPeriphAddress_OPCUA_SERVER_NAME];
  string subscription = addressConfig[fwPeriphAddress_OPCUA_SUBSCRIPTION];

  string clientDp = fwOpcUaTools_driverNum2ClientDp(drvNum);

  if(!clientDpsServersMap.contains(clientDp)){
    return FW_OPC_UA_TOOLS_ADDR_CFG_ISSUE_TYPE_DRV_NOT_CONFIGURED;
  }
  if(!clientDpsServersMap[clientDp].contains(serverConnection)){
    return FW_OPC_UA_TOOLS_ADDR_CFG_ISSUE_TYPE_WRONG_SERVER;
  }
  if(!subscription.isEmpty()){
    string serverDp = fwOpcUaTools_serverName2dp(serverConnection);
    string subscriptionDp = fwOpcUaTools_subscriptionName2dp(subscription);
    if(!serverDpsSubscriptionDpsMap[serverDp].contains(subscriptionDp)){
      return FW_OPC_UA_TOOLS_ADDR_CFG_ISSUE_TYPE_WRONG_SUBSCRIPTION;
    }
  }
  return FW_OPC_UA_TOOLS_ADDR_CFG_NO_ISSUE;
}

//------------------
// Private functions

private dyn_string _fwOpcUaTools_mappingValuesToList(const mapping &map){
  dyn_anytype list;
  for(int i=0;i<map.count();i++){
    dynAppendConst(list, map.valueAt(i));
  }
  return list;
}

private mapping _fwOpcUaTools_getInvertedMap(const mapping &map){
  mapping invertedMap;
  for(int i=0;i<map.count();i++){
    string key = map.keyAt(i);
    dyn_string values = map.valueAt(i);
    for(int j=0;j<values.count();j++){
      string value = values.at(j);
      if(invertedMap.contains(value)){
        dynAppend(invertedMap[value], key);
      }else{
        invertedMap[value] = makeDynString(key);
      }
    }
  }
  return invertedMap;
}

private mapping _fwOpcUaTools_getFilteredMap_keysWithValuesNotMatchingElementsOfList(
    const mapping &map, const dyn_string &list, string valueFormattingFunction = ""){
  mapping keyValuesNotMatchingElementsOfListMap;
  for(int i=0;i<map.count();i++){
    dyn_string values = map.valueAt(i);
    dyn_string valuesNotMatchingElementsOfList;
    for(int j=0;j<values.count();j++){
      string value = values.at(j);
      string formattedValue = valueFormattingFunction.isEmpty()?
                              value:callFunction(valueFormattingFunction, value);
      if(!list.contains(formattedValue)){
        valuesNotMatchingElementsOfList.append(value);
      }
    }
    if(valuesNotMatchingElementsOfList.count() > 0){
      keyValuesNotMatchingElementsOfListMap[map.keyAt(i)] =
          valuesNotMatchingElementsOfList;
    }
  }
  return keyValuesNotMatchingElementsOfListMap;
}

private mapping _fwOpcUaTools_getFilteredMap_keysWithMultipleValues(const mapping &map){
  mapping keysWithMultipleValuesMap;
  for(int i=0;i<map.count();i++){
    dyn_string values = map.valueAt(i);
    if(values.count() > 1){
      keysWithMultipleValuesMap[map.keyAt(i)] = values;
    }
  }
  return keysWithMultipleValuesMap;
}

private mapping _fwOpcUaTools_getFilteredMap_removedSecondReduPeerDpsFromValueList(
    const mapping &map){
  mapping keyValuesWithoutSecondReduPeerDpsMap;
  for(int i=0;i<map.count();i++){
    dyn_string valueListWithoutSecondReduPeerDps;
    dyn_string values = map.valueAt(i);
    for(int j=0;j<values.count();j++){
      string value = values.at(j);
      if(!_fwOpcUaTools_isSecondReduPeerDp(value, values)){
        valueListWithoutSecondReduPeerDps.append(value);
      }
    }
    keyValuesWithoutSecondReduPeerDpsMap[map.keyAt(i)] =
        valueListWithoutSecondReduPeerDps;
  }
  return keyValuesWithoutSecondReduPeerDpsMap;
}

const string FW_OPC_UA_TOOLS_REDU_PEER_DP_SUFFIX = "_2";

private bool _fwOpcUaTools_isSecondReduPeerDp(string dp, const dyn_string &dpList){
  return (dp.endsWith(FW_OPC_UA_TOOLS_REDU_PEER_DP_SUFFIX) &&
          dpList.contains(dp.left(
              dp.length() - FW_OPC_UA_TOOLS_REDU_PEER_DP_SUFFIX.length())));
}

private dyn_string _fwOpcUaTools_getDpsForReduPeerDpCheck(
    const dyn_string &dpList, const dyn_string &excludedDps){
  dyn_string dpsForReduPeerDpCheck;
  for(int i=0;i<dpList.count();i++){
    string dp = dpList.at(i);
    if(!_fwOpcUaTools_isSecondReduPeerDp(dp, dpList) && !excludedDps.contains(dp)){
      dpsForReduPeerDpCheck.append(dp);
    }
  }
  return dpsForReduPeerDpCheck;
}

private dyn_string _fwOpcUaTools_getMissingReduPeerDps(const dyn_string &dpsToCheck,
                                                      const dyn_string &dpList){
  dyn_string missingReduPeerDps;
  for(int i=0;i<dpsToCheck.count();i++){
    string dpToCheck = dpsToCheck.at(i);
    if(!dpList.contains(dpToCheck + FW_OPC_UA_TOOLS_REDU_PEER_DP_SUFFIX)){
      missingReduPeerDps.append(dpToCheck);
    }
  }
  return missingReduPeerDps;
}
