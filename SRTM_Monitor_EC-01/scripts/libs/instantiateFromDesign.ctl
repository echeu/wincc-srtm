
const string CONNECTIONSETTING_KEY_DRIVER_NUMBER = "DRIVER_NUMBER";
const string CONNECTIONSETTING_KEY_SERVER_NAME = "SERVER_NAME";
const string CONNECTIONSETTING_KEY_SUBSCRIPTION_NAME = "SUBSCRIPTION_NAME";

bool dpTypeExists(string dpt)
{
    dyn_string queriedTypes = dpTypes(dpt);
    return (dynlen(queriedTypes) >= 1);
}



bool addressConfigWrapper (
    string  dpe,
    string  address,
    int     mode,
    mapping connectionSettings,
    bool active=true
)
{
    string subscription = "";
    if (mode != DPATTR_ADDR_MODE_IO_SQUERY && mode != DPATTR_ADDR_MODE_INPUT_SQUERY)
    {
        subscription = connectionSettings[CONNECTIONSETTING_KEY_SUBSCRIPTION_NAME];
    }
    dyn_string dsExceptionInfo;
    fwPeriphAddress_setOPCUA (
        dpe /*dpe*/,
        connectionSettings[CONNECTIONSETTING_KEY_SERVER_NAME],
        connectionSettings[CONNECTIONSETTING_KEY_DRIVER_NUMBER],
        "ns=2;s="+address,
        subscription /* subscription*/,
        1 /* kind */,
        1 /* variant */,
        750 /* datatype */,
        mode,
        "" /*poll group */,
        dsExceptionInfo
    );
    if (dynlen(dsExceptionInfo)>0)
        return false;
    DebugTN("Setting active on dpe: "+dpe+" to "+active);
    dpSetWait(dpe + ":_address.._active", active);

    return true;
}

bool evaluateActive(
    mapping addressActiveControl,
    string className,
    string varName,
    string dpe)
{
    bool active = false;
    if (mappingHasKey(addressActiveControl, className))
    {
        string regex = addressActiveControl[className];
        int regexMatchResult = regexpIndex(regex, varName, makeMapping("caseSensitive", true));
        DebugTN("The result of evaluating regex: '"+regex+"' with string: '"+varName+" was: "+regexMatchResult);
        if (regexMatchResult>=0)
            active = true;
        else
        {
            active = false;
            DebugN("Note: the address on dpe: "+dpe+" will be non-active because such instructions were passed in the addressActive mapping.");
        }
    }
    else
        active = true; // by default
    return active;
}

int instantiateFromDesign(
    string prefix,
    bool createDps,
    bool assignAddresses,
    bool continueOnError,
    mapping addressActiveControl = makeMapping(),
    mapping connectionSettings = makeMapping())
{
}