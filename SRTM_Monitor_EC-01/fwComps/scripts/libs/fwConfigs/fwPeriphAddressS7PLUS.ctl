/**
  (c) Copyright CERN 2005. All rights not expressly granted are reserved.
  icecontrols.support@cern.ch

  SPDX-License-Identifier: LGPL-3.0-only
**/

#uses "classes/fwGeneral/FwException"
#uses "classes/fwConfigs/S7Plus/FwS7Plus_AddressConfig"
#uses "classes/fwConfigs/S7Plus/FwS7Plus_ConnectionConfig"
#uses "classes/fwConfigs/S7Plus/FwS7Plus_Direction"
#uses "classes/fwConfigs/S7Plus/FwS7Plus_Subscriptions"
#uses "fwGeneral/fwGeneral"
#uses "fwInstallation/fwInstallationRedu"

const string fwPeriphAddress_S7PLUS_DPT_POLL_GROUP = "_PollGroup";

void _fwPeriphAddressS7PLUS_get(const string &dpe, dyn_anytype &data, bool &isActive, dyn_string &exceptionInfo)
{
  try {
    FwException::assertDP(dpe, "", "Cannot get address config for non-existing element '" + dpe + "'");

    shared_ptr<FwS7Plus_AddressConfig> addressConfig = new FwS7Plus_AddressConfig;
    uint direction;
    string referenceString;
    dpGet(dpe + ":_address.._drv_ident", addressConfig.driverType,
          dpe + ":_distrib.._driver", addressConfig.driverNumber,
          dpe + ":_address.._reference", referenceString,
          dpe + ":_address.._direction", direction,
          dpe + ":_address.._datatype", addressConfig.transformation,
          dpe + ":_address.._connection", addressConfig.connectionName,
          dpe + ":_address.._poll_group", addressConfig.pollgroup,
          dpe + ":_address.._subindex", addressConfig.subindex,
          dpe + ":_address.._lowlevel", addressConfig.lowLevelComparison,
          dpe + ":_address.._active", addressConfig.active);
    FwException::checkLastError();

    FwException::assert(addressConfig.driverType != "fwPeriphAddress_TYPE_S7PLUS", "Element '" + dpe + "' address config is not " + fwPeriphAddress_TYPE_S7PLUS);

    string dpeSystemName = fwSysName(dpe, true);
    if (dpeSystemName == "") {
      dpeSystemName = getSystemName();
    }

    addressConfig.pollgroup = dpSubStr(addressConfig.pollgroup, DPSUB_DP);
    addressConfig.connectionName = dpSubStr(addressConfig.connectionName, DPSUB_DP);
    bool isSubscription = false;
    if (!addressConfig.pollgroup.isEmpty()) {
      // To know if it's subscription or polling, we need to know the subscriptions list
      FwS7Plus_Subscriptions allSubscriptions = FwS7Plus_Subscriptions(dpeSystemName);
      allSubscriptions.loadFromDp();
      isSubscription = allSubscriptions.isSubscriptionPresent(addressConfig.pollgroup);
    }

    addressConfig.direction = FwS7Plus_DirectionConverter::fromValue(direction, isSubscription);
    addressConfig.reference = referenceString;

    isActive = addressConfig.active;
    data = addressConfig.toDynAnytype();
  } catch {
    FwException::bridge(exceptionInfo);
  }
}

void _fwPeriphAddressS7PLUS_set(string dpe, dyn_anytype &addressConfigData, dyn_string &exceptionInfo)
{
  try {
    FwException::assertDP(dpe, "", "Cannot set address config for non-existing element '" + dpe + "'");
    shared_ptr<FwS7Plus_AddressConfig> addressConfig = FwS7Plus_AddressConfig::fromDynAnytype(addressConfigData);
    addressConfig.checkData();

    dpSetWait(dpe + ":_distrib.._type", DPCONFIG_DISTRIBUTION_INFO,
              dpe + ":_distrib.._driver", addressConfig.driverNumber);
    FwException::checkLastError();
    dpSetWait(dpe + ":_address.._type", DPCONFIG_PERIPH_ADDR_MAIN,
              dpe + ":_address.._drv_ident", addressConfig.driverType,
              dpe + ":_address.._reference", addressConfig.reference,
              dpe + ":_address.._direction", FwS7Plus_DirectionConverter::toValue(addressConfig.direction),
              dpe + ":_address.._datatype", FwS7Plus_DataTransformationTypeConverter::toValue(addressConfig.transformation),
              dpe + ":_address.._connection", addressConfig.connectionName,
              dpe + ":_address.._poll_group", addressConfig.pollgroup,
              dpe + ":_address.._subindex", addressConfig.subindex,
              dpe + ":_address.._lowlevel", addressConfig.lowLevelComparison,
              dpe + ":_address.._active", addressConfig.active);
    FwException::checkLastError();
  } catch {
    FwException::bridge(exceptionInfo);
  }
}

/**
 * Create interval based polling group
 *
 * The polling group is set as active at the creation time
 *
 * @param pollingGroupName Polling group name to create
 * @param pollInterval Polling interval in milliseconds
 * @param exceptionInfo [out] Exception information
 */
void fwPeriphAddressS7PLUS_createPollingGroupWithInterval(const string &pollingGroupName, int pollInterval, dyn_string &exceptionInfo, string systemName = "")
{
  try {
    string pollingGroupWithoutSystem = fwNoSysName(pollingGroupName);
    string pollingGroupSystem = fwSysName(pollingGroupName, true);
    if (systemName.isEmpty() && !pollingGroupSystem.isEmpty())
    {
      systemName = pollingGroupSystem;
    }

    _fwPeriphAddressS7PLUS_checkSystemNames(pollingGroupSystem, systemName, true);

    string pollingGroupFullDpName = systemName + pollingGroupWithoutSystem;
    if (!dpExists(pollingGroupFullDpName)) {
      dpCreate(pollingGroupFullDpName, FwS7Plus_Subscriptions::DPT_POLLGROUP);
      FwException::checkLastError();
    }

    FwException::assertDP(pollingGroupFullDpName, FwS7Plus_Subscriptions::DPT_POLLGROUP, "Cannot prepare " + pollingGroupFullDpName + " poll group");

    const int syncMode = 0;
    dpSetWait(pollingGroupFullDpName + ".SyncMode", syncMode,
              pollingGroupFullDpName + ".Active", true,
              pollingGroupFullDpName + ".PollInterval", pollInterval);
    FwException::checkLastError();
  } catch {
    FwException::bridge(exceptionInfo);
  }
}

private void _fwPeriphAddressS7PLUS_checkSystemNames(const string &dpSystemName, const string &targetSystemName, const bool isPollgroup)
{
  if (!dpSystemName.isEmpty() && dpSystemName != targetSystemName)
  {
    string message = "S7+ " + (isPollgroup ? "polling group" : "subscription") + " system (" + dpSystemName
                     + ") is different from the desired target system (" + targetSystemName + ")";
    FwException::raise(message);
  }
}

/**
 * Prepare list of S7+ connection datapoints for the given connection
 *
 * Based on the target system, there might be one or multiple connection datapoints.
 *
 * @param connectionName S7+ connection name
 * @result list of all datapoints for the connection
 */
vector<string> fwPeriphAddressS7PLUS_prepareConnectionDatapoints(const string &connectionName)
{
  string systemDpName = fwSysName(connectionName);
  string dpName = fwNoSysName(connectionName);
  dpName = systemDpName + dpName.startsWith("_") ? dpName : "_" + dpName;
  vector<string> dps = makeVector(dpName);
  int systemRedundantResult = fwInstallationRedu_isSystemRedundant(systemDpName);
  if (systemRedundantResult == -1) {
    throw(makeError("", PRIO_SEVERE, ERR_CONTROL, 0, "System '" + systemDpName + "' not available, cannot check its redu configuration"));
  } else if (systemRedundantResult == 1) {
    dps.append(dpName + "_2");
  }

  return dps;
}

/**
 * Delete S7+ internal datapoint
 *
 * @param connectionName Connection name to create, an underscore (_) is prepended if not present
 * @param exceptionInfo [out] Exception information
 */
void fwPeriphAddressS7PLUS_deleteS7PlusConnection(const string &connectionName, dyn_string &exceptionInfo)
{
  try {
    FwException::assert(connectionName != "", "No connection name provided");

    vector<string> connectionDps = fwPeriphAddressS7PLUS_prepareConnectionDatapoints(connectionName);
    for (int i = 0; i < connectionDps.count(); ++i)
    {
      string dp = connectionDps.at(i);
      if (!dpExists(dp))
        continue;

      dpDelete(dp);
      FwException::checkLastError();
    }
  } catch {
    FwException::bridge(exceptionInfo);
  }
}

/**
 * Create and configure S7+ internal datapoint
 *
 * In redundant systems, it creates and configures the _2 datapoint as well.
 *
 * @param connectionName Connection name to create, an underscore (_) is prepended if not present
 * @param connection S7+ connection configuration data
 * @param exceptionInfo [out] Exception information
 */
void fwPeriphAddressS7PLUS_createS7PlusConnection(const string &connectionName, shared_ptr<FwS7Plus_ConnectionConfig> connection, dyn_string &exceptionInfo)
{
  try {
    FwException::assert(connectionName != "", "No connection name provided");

    vector<string> connectionDps = fwPeriphAddressS7PLUS_prepareConnectionDatapoints(connectionName);
    for (int i = 0; i < connectionDps.count(); ++i)
    {
      string dp = connectionDps.at(i);
      dpCreate(dp, FwS7Plus_ConnectionConfig::DPT_NAME);
      FwException::assertDP(dp, FwS7Plus_ConnectionConfig::DPT_NAME, "Cannot prepare '" + connectionName + "' S7+ connection DP '" + dp + "'");
    }

    fwPeriphAddressS7PLUS_setS7PlusConnection(connectionName, connection, exceptionInfo);
  } catch {
    FwException::bridge(exceptionInfo);
  }
}

/**
 * Create and configure S7+ internal datapoint
 *
 * In redundant systems, it configures the _2 datapoint as well.
 *
 * @param connectionName Connection name to configure, an underscore (_) is prepended if not present
 * @param connection S7+ connection configuration data
 * @param exceptionInfo [out] Exception information
 */
void fwPeriphAddressS7PLUS_setS7PlusConnection(const string &connectionName, shared_ptr<FwS7Plus_ConnectionConfig> connection, dyn_string &exceptionInfo)
{
  try {
    FwException::assert(connectionName != "", "No connection name provided");
    FwException::assertNotNull(connection, "No connection data provided");
    connection.checkData();

    vector<string> connectionDps = fwPeriphAddressS7PLUS_prepareConnectionDatapoints(connectionName);
    for (int i = 0; i < connectionDps.count(); ++i)
    {
      string connectionDp = connectionDps.at(i);
      FwException::assertDP(connectionDp, FwS7Plus_ConnectionConfig::DPT_NAME, "Cannot configure '" + connectionDp + "' S7+ connection");

      dpSetWait(connectionDp + ".Config.Address", connection.ipAddress,
                connectionDp + ".Config.AccessPoint", connection.accessPoint,
                connectionDp + ".Config.ReduConnection.Address", connection.getReduIpAddress(),
                connectionDp + ".Config.ReduConnection.AccessPoint", connection.getReduAccessPoint(),
                connectionDp + ".Config.ReduConnection.SwitchCondition", connection.getReduSwitchCondition(),
                connectionDp + ".Config.ReduConnection.SwitchTag", connection.getReduSwitchTag(),
                connectionDp + ".Config.PLCType", connection.getPlcTypeUint(),
                connectionDp + ".Config.StationName", connection.stationName,
                connectionDp + ".Config.DrvNumber", connection.driverNumber,
                connectionDp + ".Config.EstablishmentMode", connection.active,
                connectionDp + ".Config.ConnType", connection.redundantConnection,
                connectionDp + ".Config.LegitimationLevel", connection.useTls,
                connectionDp + ".Config.Password", connection.getTlsPassword(),
                connectionDp + ".Config.Certificate", connection.getTlsCertificate(),
                connectionDp + ".Config.KeepAliveTimeout", connection.keepAliveTimeout,
                connectionDp + ".Config.ReconnectTimeout", connection.reconnectTimeout,
                connectionDp + ".Config.ReadOpState", connection.readOpState,
                connectionDp + ".Config.SetInvalidBit", connection.setInvalidBit,
                connectionDp + ".Config.AcquireValuesOnConnect", connection.acquireValuesOnConnect,
                connectionDp + ".Config.EnableStatistics", connection.enableStatistics,
                connectionDp + ".Config.EnableDiagnostics", connection.enableDiagnostics,
                connectionDp + ".Config.TimeSyncMode", connection.timeSyncMode,
                connectionDp + ".Config.TimeSyncInterval", connection.getTimeSyncInterval(),
                connectionDp + ".Config.UseUTC", connection.getTimeSyncUseUtc(),
                connectionDp + ".Config.Timezone", connection.getTimeSyncOffsetFromServer(),
                connectionDp + ".Config.Tspp.Mode", connection.tsppMode,
                connectionDp + ".Config.Tspp.ReadInterval", connection.getTsppReadInterval(),
                connectionDp + ".Config.Tspp.BufferAddress", connection.getTsppBufferAddress(),
                connectionDp + ".Config.Codepage", connection.codepage,
                connectionDp + ".Config.AlarmMode", connection.alarmMode,
                connectionDp + ".Config.FullTextAlarms", connection.useFulltextAlarms,
                connectionDp + ".Config.DisplayClassFilter", connection.displayClassFilter);
      FwException::checkLastError();
    }
  } catch {
    FwException::bridge(exceptionInfo);
  }
}

/**
 * Upgrade standard pollgroup to S7+ subscription
 *
 * The pollgroup must exist otherwise an exception is raised
 *
 * @param subscriptionName Name of the pollgroup that becomes subscription
 * @param exceptionInfo
 * @param systemName Target system where to create the subscription, default is local system
 */
void fwPeriphAddressS7PLUS_createSubscription(const string &subscriptionName, dyn_string &exceptionInfo, string systemName = "")
{
  try {
    string subscriptionNameWithoutSystem = fwNoSysName(subscriptionName);
    string subscriptionSystem = fwSysName(subscriptionName, true);
    if (systemName.isEmpty() && !subscriptionSystem.isEmpty())
    {
      systemName = subscriptionSystem;
    }

    _fwPeriphAddressS7PLUS_checkSystemNames(subscriptionSystem, systemName, false);

    shared_ptr<FwS7Plus_Subscriptions> subscriptions = new FwS7Plus_Subscriptions(systemName);
    subscriptions.ensureConfigDpExists();
    subscriptions.loadFromDp();
    subscriptions.addSubscription(subscriptionNameWithoutSystem);
    subscriptions.saveToDp();
  } catch {
    FwException::bridge(exceptionInfo);
  }
}

/**
 * Delete S7+ subscription optionally including the underlying polling group
 *
 * @param subscriptionName Name of the subscription to delete
 * @param deletePollgroup Flag to delete or keep underlying pollgroup
 * @param exceptionInfo
 * @param systemName Target system in which to delete the subscription, default is local system
 */
void fwPeriphAddressS7PLUS_deleteSubscription(const string &subscriptionName, dyn_string &exceptionInfo, bool deletePollgroup = true, string systemName = "")
{
  try {
    string subscriptionNameWithoutSystem = fwNoSysName(subscriptionName);
    string subscriptionSystem = fwSysName(subscriptionName, true);
    if (systemName.isEmpty() && !subscriptionSystem.isEmpty())
    {
      systemName = subscriptionSystem;
    }

    _fwPeriphAddressS7PLUS_checkSystemNames(subscriptionSystem, systemName, false);

    shared_ptr<FwS7Plus_Subscriptions> subscriptions = new FwS7Plus_Subscriptions(systemName);
    subscriptions.ensureConfigDpExists();
    subscriptions.loadFromDp();
    subscriptions.removeSubscription(subscriptionNameWithoutSystem);
    subscriptions.saveToDp();

    if (deletePollgroup) {
      dpDelete(subscriptionSystem + subscriptionNameWithoutSystem);
      FwException::checkLastError();
    }
  } catch {
    FwException::bridge(exceptionInfo);
  }
}

/**
 * Function used to initiate the panel for periphery address configuration
 *
 * @param sDpe              input    DataPoint element
 * @param dsExceptionInfo   output   Exception information
 */
void _fwPeriphAddressS7PLUS_initPanel(const string &dpe, dyn_string &exceptionInfo, bool inMultiDpes = false, int inPanelMode = -1)
{
  try {
    bool configExists, active;
    dyn_anytype addressConfig;
    fwPeriphAddress_get(dpe, configExists, addressConfig, active, exceptionInfo);
    FwException::checkRaise(exceptionInfo);
    shape s7plusShape = getShape("fwPeriphAddressS7PLUS");
    if (s7plusShape) {
      invokeMethod(s7plusShape, "setUpPanel", dpe, configExists, addressConfig);
    } else {
      throw(makeError("", PRIO_SEVERE, ERR_CONTROL, 0, "Cannot find S7+ address panel shape"));
    }
  } catch {
    FwException::bridge(exceptionInfo);
  }
}
