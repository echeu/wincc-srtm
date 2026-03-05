/**
  (c) Copyright CERN 2005. All rights not expressly granted are reserved.
  icecontrols.support@cern.ch

  SPDX-License-Identifier: LGPL-3.0-only
**/

#uses "classes/fwGeneral/FwException"

class FwS7Plus_SubscriptionsTester;

/**
 * Class to manager S7+ subscriptions configuration datapoint
 *
 * It supports configuring both local and remote systems. The prerequisite is
 * that all the operations with subscriptions are performed without system names.
 */
class FwS7Plus_Subscriptions
{
  friend FwS7Plus_SubscriptionsTester;

  public static const string DPT_POLLGROUP = "_PollGroup";
  public static const string DPT_S7PLUSCONFIG = "_S7PlusConfig";
  public static const string DP_S7PLUSCONFIG = "_S7PlusConfig";
  private static const string DEFAULT_ACTIVE_SUBSCRIPTION_OPTIONS = "1";
  string systemName;
  string configDp;
  dyn_string names;
  dyn_string pollGroups;
  dyn_string options;

  /**
   * Constructor
   *
   * @param systemName system for which to manage S7+ subscriptions
   */
  public FwS7Plus_Subscriptions(const string &systemName)
  {
    this.systemName = systemName.isEmpty() ? getSystemName() : systemName;
    this.configDp = this.systemName + DP_S7PLUSCONFIG;
  }

  /**
   * Check that the required internal datapoint exists otherwise try to create it
   */
  public void ensureConfigDpExists()
  {
    if (!dpExists(configDp)) {
      dpCreate(configDp, DPT_S7PLUSCONFIG);
      FwException::checkLastError();
    }

    FwException::assertDP(configDp, DPT_S7PLUSCONFIG, "S7Plus config DP doesn't exist" + (systemName.isEmpty() ? "" : " in system " + systemName));
  }

  /**
   * Check that the given subscription is present in the configured subscriptions
   *
   * @param subscription name of subscription to check presence for
   * @return true if present, false otherwise
   */
  public bool isSubscriptionPresent(const string &subscription)
  {
    return names.contains(subscription);
  }

  /**
   * Add new subscription to the configuration list if not present already
   *
   * The subscription is added in memory and not being saved in DP, see @ref saveToDp
   *
   * @param subscription name of subscription to add; if name includes system name,
   *                     it's excluded but compared to the one which was defined when
   *                     creating FwS7Plus_Subscriptions instance
   */
  public void addSubscription(const string &subscription)
  {
    string subscriptionNameWithoutSystem = fwNoSysName(subscription);
    if (subscription != subscriptionNameWithoutSystem)
    {
      string subscriptionSystem = fwSysName(subscription, true);
      if (subscriptionSystem != systemName)
      {
        string message = "S7Plus subscription system (" + subscriptionSystem
                         + ") is different from the desired target system (" + systemName + ")";
        FwException::raise(message);
      }
    }

    string subscriptionFullDpName = systemName + subscriptionNameWithoutSystem;
    FwException::assertDP(subscriptionFullDpName,
                          fwPeriphAddress_S7PLUS_DPT_POLL_GROUP,
                          "S7Plus poll group for subscription " + subscriptionFullDpName + " doesn't exist");


    if (!isSubscriptionPresent(subscriptionNameWithoutSystem))
    {
      names.append(subscriptionNameWithoutSystem);
      pollGroups.append(subscriptionNameWithoutSystem);
      options.append(DEFAULT_ACTIVE_SUBSCRIPTION_OPTIONS);
    }
  }

  /**
   * Remove subscription from the configuration list
   *
   * The subscription is removed in memory and not being saved in DP, see @ref saveToDp
   *
   * @param subscription name of subscription to remove; if name includes system name,
   *                     it's excluded but compared to the one which was defined when
   *                     creating FwS7Plus_Subscriptions instance
   */
  public void removeSubscription(const string &subscription)
  {
    string subscriptionNameWithoutSystem = fwNoSysName(subscription);
    if (subscription != subscriptionNameWithoutSystem)
    {
      string subscriptionSystem = fwSysName(subscription, true);
      if (subscriptionSystem != systemName)
      {
        string message = "S7Plus subscription system (" + subscriptionSystem
                         + ") is different from the desired target system (" + systemName + ")";
        FwException::raise(message);
      }
    }

    int index = names.indexOf(subscriptionNameWithoutSystem);
    if (index > -1)
    {
      names.removeAt(index);
      pollGroups.removeAt(index);
      options.removeAt(index);
    }
  }

  /**
   * Load configuration from datapoint
   */
  public void loadFromDp()
  {
    if (!dpExists(configDp))
    {
      FwException::raise("Subscription config datapoint doesn't exist: " + configDp);
    }

    dpGet(configDp + ".Subscriptions.Names", names,
          configDp + ".Subscriptions.Pollgroups", pollGroups,
          configDp + ".Subscriptions.Options", options);
    FwException::checkLastError();
  }

  /**
   * Save configuration from memory into datapoint
   */
  public void saveToDp()
  {
    if (!dpExists(configDp))
    {
      FwException::raise("Subscription config datapoint doesn't exist: " + configDp);
    }

    dpSetWait(configDp + ".Subscriptions.Names", names,
              configDp + ".Subscriptions.Pollgroups", pollGroups,
              configDp + ".Subscriptions.Options", options);
    FwException::checkLastError();
  }


  /**
   * Get subscription names from the configuration snapshot
   *
   * @return subscription names
   */
  public dyn_string getNames()
  {
    return names;
  }

  /**
   * Check the data is consitent, i.e. length of all array is equal
   */
  public void checkConsistency()
  {
    FwException::assert(names.count() == pollGroups.count() && names.count() == options.count(),
                        "Subscriptions data not consistent");
  }
};
