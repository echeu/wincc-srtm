/**
  (c) Copyright CERN 2005. All rights not expressly granted are reserved.
  icecontrols.support@cern.ch

  SPDX-License-Identifier: LGPL-3.0-only
**/

#uses "classes/fwConfigs/S7Plus/FwS7Plus_PlcType"
#uses "classes/fwConfigs/S7Plus/FwS7Plus_RedundantSwitchMode"
#uses "classes/fwGeneral/FwException"

/**
 * Structure to hold S7+ connection data
 */
struct FwS7Plus_ConnectionConfig
{
  static const string DPT_NAME = "_S7PlusConnection";
  static const string STATIONNAME_ONLINE_ONLINE = "S7Plus$Online|Online";
  static const string ACCESSPOINT_S7ONLINE = "S7ONLINE";
  static const uint REDUNDANT_CONNECTION_OFF = 0;
  static const uint REDUNDANT_CONNECTION_ON = 1;
  static const int USE_TLS_OFF = -1;
  static const int USE_TLS_ON = 0;
  static const int SYNC_TIME_OFF = 0;
  static const int SYNC_TIME_ON = -1;
  static const int SYNC_TIME_OFFSET_MIN = -1440;
  static const int SYNC_TIME_OFFSET_MAX = 1440;
  static const uint TSPP_OFF = 0;
  static const uint TSPP_ON = 1;
  static const uint CODEPAGE_UTF8 = 106;
  static const uint ALARMMODE_OFF = 0;
  static const uint ALARMMODE_ON = 1;

  uint redundantConnection;
  string ipAddress;
  string accessPoint;
  string reduIpAddress;
  string reduAccessPoint;
  FwS7Plus_RedundantSwitchMode reduSwitchCondition;
  string reduSwitchTag;
  string stationName;
  FwS7Plus_PlcType plcType;
  uint driverNumber;
  bool active;
  int useTls;
  blob tlsPassword;
  string tlsCertificate;
  uint keepAliveTimeout;
  uint reconnectTimeout;
  bool readOpState;
  bool setInvalidBit;
  bool acquireValuesOnConnect;
  bool enableStatistics;
  bool enableDiagnostics;
  int timeSyncMode;
  uint timeSyncInterval;
  bool timeSyncUseUtc;
  int timeSyncOffsetFromServer;
  uint tsppMode;
  uint tsppReadInterval;
  string tsppBufferAddress;
  uint codepage;
  uint alarmMode;
  bool useFulltextAlarms;
  string displayClassFilter;

  /**
   * Get prefilled default connection data
   *
   * @return connection instance pointer
   */
  public static shared_ptr<FwS7Plus_ConnectionConfig> getDefaultConnectionConfiguration()
  {
    shared_ptr<FwS7Plus_ConnectionConfig> instance = new FwS7Plus_ConnectionConfig;
    instance.redundantConnection = REDUNDANT_CONNECTION_OFF;
    instance.accessPoint = ACCESSPOINT_S7ONLINE;
    instance.stationName = STATIONNAME_ONLINE_ONLINE;
    instance.reduAccessPoint = ACCESSPOINT_S7ONLINE;
    instance.plcType = FwS7Plus_PlcType::AUTOMATIC;
    instance.active = true;
    instance.reduSwitchCondition = FwS7Plus_RedundantSwitchMode::OPSTATE_CONNSTATE;
    instance.driverNumber = 1;
    instance.useTls = USE_TLS_OFF;
    instance.keepAliveTimeout = 20;
    instance.reconnectTimeout = 20;
    instance.readOpState = true;
    instance.setInvalidBit = false;
    instance.acquireValuesOnConnect = true;
    instance.enableStatistics = true;
    instance.enableDiagnostics = false;
    instance.timeSyncMode = SYNC_TIME_OFF;
    instance.tsppMode = TSPP_OFF;
    instance.codepage = CODEPAGE_UTF8;
    instance.alarmMode = ALARMMODE_OFF;
    instance.useFulltextAlarms = true;
    return instance;
  }

  /**
   * Get redu IP address
   *
   * @return configured value if redundant connection is enabled, empty otherwise
   */
  public string getReduIpAddress()
  {
    return isRedundantConnection() ? reduIpAddress : "";
  }

  /**
   * Get redu access point configuration
   *
   * @return configured value if redundant connection is enabled, empty otherwise
   */
  public string getReduAccessPoint()
  {
    return isRedundantConnection() ? reduAccessPoint : "";
  }

  /**
   * Get redu switch condition configuration
   *
   * @return configured value if redundant connection is enabled, 0 otherwise
   */
  public uint getReduSwitchCondition()
  {
    return isRedundantConnection() ? (uint)reduSwitchCondition : 0u;
  }

  /**
   * Get redi switch condition tag configuration
   *
   * @return configured value if redundant connection is enabled, empty otherwise
   */
  public string getReduSwitchTag()
  {
    return isRedundantConnection() ? reduSwitchTag : "";
  }

  public bool isRedundantConnection()
  {
    return redundantConnection == 1;
  }

  public uint getPlcTypeUint()
  {
    return (uint)plcType;
  }

  public bool isTsppEnabled()
  {
    return tsppMode == TSPP_ON;
  }

  /**
   * Get TSPP read interval
   *
   * @return configured value if TSPP is enabled, 0 otherwise
   */
  public uint getTsppReadInterval()
  {
    return isTsppEnabled() ? tsppReadInterval : 0u;
  }

  /**
   * Get TSPP buffer address
   *
   * @return configured value if TSPP is enabled, empty otherwise
   */
  public string getTsppBufferAddress()
  {
    return isTsppEnabled() ? tsppBufferAddress : "";
  }

  public bool isTimeSyncEnabled()
  {
    return timeSyncMode == SYNC_TIME_ON;
  }

  /**
   * Get time synchronization interval
   *
   * @return configured value if time synchronization is enabled, 0 otherwise
   */
  public uint getTimeSyncInterval()
  {
    return isTimeSyncEnabled() ? timeSyncInterval : 0u;
  }

  /**
   * Get use UTC time flag
   *
   * @return configured value if time synchronization is enabled, false otherwise
   */
  public bool getTimeSyncUseUtc()
  {
    return isTimeSyncEnabled() ? timeSyncUseUtc : false;
  }

  /**
   * Get time offset to server
   *
   * @return configured value if time synchronization is enabled, 0 otherwise
   */
  public uint getTimeSyncOffsetFromServer()
  {
    return isTimeSyncEnabled() ? timeSyncOffsetFromServer : 0u;
  }

  public bool isTlsEnabled()
  {
    return useTls == USE_TLS_ON;
  }

  /**
   * Get TLS certificate
   *
   * @return configured value if TLS is enabled, empty otherwise
   */
  public string getTlsCertificate()
  {
    return isTlsEnabled() ? tlsCertificate : "";
  }

  /**
   * Get TLS password
   *
   * @return configured value if TLS is enabled, empty otherwise
   */
  public blob getTlsPassword()
  {
    return isTlsEnabled() ? tlsPassword : (blob)"";
  }

  public void setTlsPassword(const string& password)
  {
    tlsPassword = cryptoHash(password, "SHA1");
  }

  /**
   * Check the connection data for validity
   *
   * It performs several checks and reports identified problem in exception.
   */
  public void checkData()
  {
    FwException::assert(ipAddress != "", "Empty S7Plus IP address/host");
    FwException::assert(accessPoint != "", "Invalid S7Plus access point " + accessPoint);
    checkRedundantConnection();
    if (isRedundantConnection()) {
      FwException::assert(reduIpAddress != "", "Empty S7Plus redundant IP address/host");
      FwException::assert(reduAccessPoint != "", "Invalid S7Plus redundant access point " + reduAccessPoint);
      checkRedundantSwitchTag();
    }

    FwException::assert(driverNumber > 0, "Invalid S7Plus driver number " + driverNumber);
    checkPlcType();
    checkUseTls();
    if (isTlsEnabled()) {
      FwException::assert(bloblen(tlsPassword) > 0, "Invalid S7Plus TLS password");
      checkTlsCertificate();
    }

    FwException::assert(keepAliveTimeout > 0, "Invalid S7Plus keep alive timeout " + keepAliveTimeout);
    FwException::assert(reconnectTimeout > 0, "Invalid S7Plus reconnect timeout " + reconnectTimeout);
    checkTimeSyncMode();
    if (isTimeSyncEnabled()) {
      FwException::assert(timeSyncInterval > 0, "Invalid S7Plus time sync interval " + timeSyncInterval);
      checkTimeSyncOffsetFromServer();
    }

    checkTsppMode();
    if (isTsppEnabled()) {
      FwException::assert(tsppReadInterval > 0, "Invalid S7Plus TSPP read interval " + tsppReadInterval);
      FwException::assert(tsppBufferAddress != "", "Invalid S7Plus TSPP buffer address " + tsppBufferAddress);
    }

    checkCodepage();
    checkAlarmMode();

    FwException::assert(displayClassFilter == "", "Invalid S7Plus display class filter " + displayClassFilter + " not supported");
  }

  /**
   * Check the alarm mode enabled configuration
   *
   * Only ALARMMODE_OFF, ALARMMODE_ON values are allowed.
   */
  private void checkAlarmMode()
  {
    const dyn_uint possibleValues = makeDynUInt(ALARMMODE_OFF, ALARMMODE_ON);
    FwException::assertInSet(alarmMode, possibleValues, "Invalid S7Plus alarm mode " + alarmMode);
  }

  /**
   * Check the codepage configuration
   *
   * Only UTF8 is supported.
   */
  private void checkCodepage()
  {
    FwException::assert(codepage == CODEPAGE_UTF8, "Invalid S7Plus TSPP codepage " + codepage);
  }

  /**
   * Check the TSPP enabled configuration
   *
   * Only TSPP_OFF, TSPP_ON values are allowed.
   */
  private void checkTsppMode()
  {
    const dyn_uint possibleValues = makeDynUInt(TSPP_OFF, TSPP_ON);
    FwException::assertInSet(tsppMode, possibleValues, "Invalid S7Plus TSPP mode " + tsppMode);
  }

  /**
   * Check the PLC time offset to server configuration
   *
   * The offset must be in [SYNC_TIME_OFFSET_MIN , SYNC_TIME_OFFSET_MAX] interval
   */
  private void checkTimeSyncOffsetFromServer()
  {
    if (timeSyncOffsetFromServer < SYNC_TIME_OFFSET_MIN || timeSyncOffsetFromServer > SYNC_TIME_OFFSET_MAX) {
      FwException::raise("Invalid S7Plus time sync offset, value out of range " + timeSyncOffsetFromServer);
    }
  }

  /**
   * Check the PLC time synchronization configuration
   *
   * Only SYNC_TIME_OFF, SYNC_TIME_ON values are allowed.
   */
  private void checkTimeSyncMode()
  {
    const dyn_int possibleValues = makeDynInt(SYNC_TIME_OFF, SYNC_TIME_ON);
    FwException::assertInSet(timeSyncMode, possibleValues, "Invalid S7Plus time sync mode " + timeSyncMode);
  }

  /**
   * Check the TLS enabled configuration
   *
   * Only USE_TLS_OFF, USE_TLS_ON values are allowed.
   */
  private void checkUseTls()
  {
    const dyn_int possibleValues = makeDynInt(USE_TLS_OFF, USE_TLS_ON);
    FwException::assertInSet(useTls, possibleValues, "Invalid S7Plus TLS mode " + useTls);
  }

  /**
   * Check the TLS certificate file exist
   *
   */
  private void checkTlsCertificate()
  {
    FwException::assert(tlsCertificate != "", "Invalid S7Plus TLS certificate file " + tlsCertificate);
    const string tlsCertFolder = "data/s7plus/cert/";
    // TODO review - this cannot work on distributed remote system
    string certficatePath = getPath(tlsCertFolder, tlsCertificate);
    FwException::assert(certficatePath != "", "Given S7Plus TLS certificate file doesn't exist " + tlsCertificate);
  }

  /**
   * Check the PLC redundant switch tag
   *
   * If the PLC redundant connection condition is set to switch based on tag value, the tag must be present.
   */
  private void checkRedundantSwitchTag()
  {
    if (reduSwitchCondition == FwS7Plus_RedundantSwitchMode::SWITCHTAG
        && reduSwitchTag == "") {
      FwException::raise("Invalid S7Plus redundant switch tag " + reduSwitchTag);
    }
  }

  /**
   * Check the PLC redundant connection
   *
   * Only REDUNDANT_CONNECTION_OFF, REDUNDANT_CONNECTION_ON values are allowed.
   */
  private void checkRedundantConnection()
  {
    const dyn_uint possibleValues = makeDynUInt(REDUNDANT_CONNECTION_OFF, REDUNDANT_CONNECTION_ON);
    FwException::assertInSet(redundantConnection, possibleValues, "Invalid S7Plus redundant mode " + redundantConnection);
  }

  /**
   * Check the selected PLC type
   *
   * Any enum item but INVALID is valid configuration.
   */
  private void checkPlcType()
  {
    if (plcType == FwS7Plus_PlcType::INVALID) {
      FwException::raise("Invalid S7Plus PLC type " + plcType);
    }
  }
};
