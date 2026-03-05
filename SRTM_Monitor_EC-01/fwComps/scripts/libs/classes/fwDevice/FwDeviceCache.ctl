/**
(c) Copyright CERN 2005. All rights not expressly granted are reserved.
icecontrols.support@cern.ch

SPDX-License-Identifier: LGPL-3.0-only
 **/

#uses "fwGeneral/fwGeneral"

/**
 * Cache for device related information
 *
 * The cache key is device DP name. If the device gets deleted, the cache receives
 * dpDeleted system message and removed all the data stored for that device.
 *
 * Potentially the cache could be extended for remote systems as well but an additional
 * cache level must be introduced and sysConnect to "dist" event must be implemented
 * to wipe all the data if dist "disconnected" event occurs.
 */
class FwDeviceCache
{
  private static mapping cache;
  private static bool initialized;
  private static const string cacheSystemName = getSystemName();

  private FwDeviceCache()
  {
  }

  /**
   * Initialize internal system connection
   */
  private static void initialize()
  {
    int rc = sysConnect(systemCallback, "dpDeleted");
    initialized = rc == 0;
  }

  /**
   * Callback that removes data for deleted datapoint
   */
  private static void systemCallback(string event, mapping object)
  {
    if (event == "dpDeleted")
    {
      removeAllDpEntries(object["dp"]);
    }
  }

  private static void removeAllDpEntries(const string &dpName)
  {
    int colonPosition = dpName.indexOf(":");
    bool isLocalSystem = colonPosition < 0 || dpName.startsWith(cacheSystemName);
    if (!isLocalSystem)
    {
      return;
    }

    string dpWithoutSystem = dpName.mid(colonPosition + 1);
    synchronized (cache)
    {
      if (cache.contains(dpWithoutSystem))
      {
        cache.remove(dpWithoutSystem);
      }
    }
  }

  /**
   * Set cache entry for device
   *
   * Only local system information is cached, any other request is ignored.
   *
   * @param deviceName device DP
   * @param entry name of the cached entry
   * @param value cached value
   */
  public static void setEntry(const string &deviceName, const string &entry, anytype value)
  {
    int colonPosition = deviceName.indexOf(":");
    bool isLocalSystem = colonPosition < 0 || deviceName.startsWith(cacheSystemName);
    if (!isLocalSystem)
    {
      // Don't store non-local system information as the dpDeleted messages might not be delivered, e.g. dist connection broken
      // and thus the cache would serve an invalid data
      return;
    }

    if (!initialized)
    {
      initialize();
      if (!initialized)
      {
        return;
      }
    }

    string deviceWithoutSystem = deviceName.mid(colonPosition + 1);
    synchronized (cache)
    {
      if (!cache.contains(deviceWithoutSystem))
      {
        cache[deviceWithoutSystem] = makeMapping();
      }

      cache[deviceWithoutSystem][entry] = value;
    }
  }

  /**
   * Get cached value for device
   *
   * @param deviceName device DP to look the entry for
   * @param entry name of the cached entry
   * @param defaultValue value to return if no cached value is present
   * @param [out] cacheHit true if the return value comes from cache, false otherwise
   * @return cached or default value
   */
  public static anytype getValueOrDefault(const string &deviceName, const string &entry, anytype defaultValue, bool &cacheHit) synchronized (cache)
  {
    if (cache.contains(deviceName))
    {
      cacheHit = cache[deviceName].contains(entry);
      if (cacheHit)
      {
        return cache[deviceName][entry];
      }

      return defaultValue;
    }

    int colonPosition = deviceName.indexOf(":");
    bool isLocalSystem = colonPosition < 0 || deviceName.startsWith(cacheSystemName);
    if (isLocalSystem)
    {
      string deviceWithoutSystem = deviceName.mid(colonPosition + 1);
      if (cache.contains(deviceWithoutSystem))
      {
        cacheHit = cache[deviceWithoutSystem].contains(entry);
        if (cacheHit)
        {
          return cache[deviceWithoutSystem][entry];
        }

        return defaultValue;
      }
    }

    cacheHit = false;
    return defaultValue;
  }

  /**
   * Wipe all the cache, disconnect from the system message
   *
   * This is required to be called to e.g. allow manager to exit at the end of its main() function which doesn't ends with exit() call.
   */
  public static void destroy()
  {
    if (initialized)
    {
      cache.clear();
      sysDisconnect(systemCallback, "dpDeleted");
      initialized = false;
    }
  }

};
