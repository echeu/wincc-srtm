
// generated using Cacophony, an optional module of quasar, see: https://github.com/quasar-team/Cacophony



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


bool configureRegs (
    int     docNum,
    int     childNode,
    string  prefix,
    bool    createDps,
    bool    assignAddresses,
    bool    continueOnError,
    mapping addressActiveControl,
    mapping connectionSettings)
{
    DebugTN("Configure.Regs called");
    string name;
    if(xmlGetElementAttribute(docNum, childNode, "name", name) != 0)
    {
        DebugTN("Configure.Regs instance configuration has no attribute [name]: invalid configuration, returning FALSE");
        return false;
    }

    string fullName = prefix+name;
    bool success = configureFromNameRegs(name, prefix, createDps, assignAddresses, continueOnError, addressActiveControl, connectionSettings);

    dyn_int children;

    return success;
}

bool configureFromNameRegs (
    string  name,
    string  prefix,
    bool    createDps,
    bool    assignAddresses,
    bool    continueOnError,
    mapping addressActiveControl,
    mapping connectionSettings)
{
    DebugTN("ConfigureFromName.Regs called");
    string fullName = prefix+name;
    string dpt = "SRTMRegs";

    if (dpTypeExists(dpt))
    {

        if (createDps)
        {

            DebugTN("Will create DP "+fullName);
            int result = dpCreate(fullName, dpt);
            if (result != 0)
            {
                DebugTN("dpCreate name='"+fullName+"' dpt='"+dpt+"' not successful or already existing");
                if (!continueOnError)
                    throw(makeError("Cacophony", PRIO_SEVERE, ERR_IMPL, 1, "XXX YYY ZZZ"));
            }
        }

        if (assignAddresses)
        {
            string dpe, address;
            dyn_string dsExceptionInfo;
            bool success;
            bool active = false;

            dpe = fullName+".Hwid";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "Hwid",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".Fwvers";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "Fwvers",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".Swvers";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "Swvers",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".SRTM_v00";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "SRTM_v00",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".SRTM_v01";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "SRTM_v01",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".SRTM_v02";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "SRTM_v02",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".SRTM_v03";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "SRTM_v03",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".SRTM_v04";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "SRTM_v04",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".SRTM_v05";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "SRTM_v05",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".SRTM_v06";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "SRTM_v06",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".SRTM_v07";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "SRTM_v07",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".SRTM_c00";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "SRTM_c00",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".SRTM_c01";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "SRTM_c01",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".SRTM_c02";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "SRTM_c02",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".SRTM_c03";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "SRTM_c03",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".SRTM_c04";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "SRTM_c04",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".SRTM_c05";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "SRTM_c05",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".SRTM_c06";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "SRTM_c06",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".SRTM_c07";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "SRTM_c07",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".SRTM_t00";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "SRTM_t00",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".SRTM_t01";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "SRTM_t01",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".SRTM_t02";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "SRTM_t02",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".SRTM_t03";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "SRTM_t03",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".SRTM_t04";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "SRTM_t04",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".SRTM_t05";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "SRTM_t05",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".SRTM_t06";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "SRTM_t06",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".SRTM_t07";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "SRTM_t07",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF11_present";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF11_present",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF11_status";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF11_status",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF11_txdisable";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF11_txdisable",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF11_cdrenable";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF11_cdrenable",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF11_cdrrate";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF11_cdrrate",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF11_cdrlol";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF11_cdrlol",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF11_los";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF11_los",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF11_txfault";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF11_txfault",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF11_tempfault";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF11_tempfault",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF11_voltfault";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF11_voltfault",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF11_powerfault";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF11_powerfault",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF11_uptime";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF11_uptime",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF11_tempC";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF11_tempC",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF11_rxpower_0";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF11_rxpower_0",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF11_rxpower_1";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF11_rxpower_1",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF11_rxpower_2";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF11_rxpower_2",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF11_rxpower_3";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF11_rxpower_3",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF11_id";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF11_id",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF11_model";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF11_model",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF11_serial";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF11_serial",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF11_fwversion";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF11_fwversion",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF12_present";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF12_present",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF12_status";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF12_status",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF12_txdisable";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF12_txdisable",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF12_cdrenable";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF12_cdrenable",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF12_cdrrate";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF12_cdrrate",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF12_cdrlol";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF12_cdrlol",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF12_los";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF12_los",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF12_txfault";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF12_txfault",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF12_tempfault";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF12_tempfault",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF12_voltfault";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF12_voltfault",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF12_powerfault";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF12_powerfault",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF12_uptime";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF12_uptime",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF12_tempC";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF12_tempC",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF12_rxpower_0";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF12_rxpower_0",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF12_rxpower_1";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF12_rxpower_1",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF12_rxpower_2";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF12_rxpower_2",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF12_rxpower_3";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF12_rxpower_3",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF12_id";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF12_id",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF12_model";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF12_model",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF12_serial";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF12_serial",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF12_fwversion";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF12_fwversion",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF13_present";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF13_present",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF13_status";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF13_status",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF13_txdisable";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF13_txdisable",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF13_cdrenable";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF13_cdrenable",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF13_cdrrate";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF13_cdrrate",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF13_cdrlol";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF13_cdrlol",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF13_los";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF13_los",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF13_txfault";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF13_txfault",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF13_tempfault";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF13_tempfault",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF13_voltfault";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF13_voltfault",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF13_powerfault";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF13_powerfault",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF13_uptime";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF13_uptime",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF13_tempC";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF13_tempC",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF13_rxpower_0";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF13_rxpower_0",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF13_rxpower_1";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF13_rxpower_1",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF13_rxpower_2";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF13_rxpower_2",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF13_rxpower_3";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF13_rxpower_3",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF13_id";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF13_id",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF13_model";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF13_model",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF13_serial";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF13_serial",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FF13_fwversion";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FF13_fwversion",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FPGA_up";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FPGA_up",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FPGA_temp";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FPGA_temp",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FPGA_vint";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FPGA_vint",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FPGA_vaux";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FPGA_vaux",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".FPGA_vbram";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "FPGA_vbram",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".IPMC_id";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "IPMC_id",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".IPMC_i2cVer";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "IPMC_i2cVer",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".IPMC_rev";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "IPMC_rev",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".IPMC_ver";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "IPMC_ver",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".IPMC_seq";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "IPMC_seq",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".IPMC_status";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "IPMC_status",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".IPMC_rawtime";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "IPMC_rawtime",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".IPMC_time";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "IPMC_time",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".IPMC_iQ_I";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "IPMC_iQ_I",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".IPMC_iQ_VA";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "IPMC_iQ_VA",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".IPMC_iQ_VB";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "IPMC_iQ_VB",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".IPMC_iQ_T";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "IPMC_iQ_T",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".IPMC_PCF_al";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "IPMC_PCF_al",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".IPMC_PCF_ah";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "IPMC_PCF_ah",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".IPMC_PCF_bl_V";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "IPMC_PCF_bl_V",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".IPMC_PCF_bh_I";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "IPMC_PCF_bh_I",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".IPMC_TMP100_fb";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "IPMC_TMP100_fb",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".IPMC_TMP100_bb";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "IPMC_TMP100_bb",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".IPMC_TMP100_ft";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "IPMC_TMP100_ft",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".IPMC_TMP100_bt";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "IPMC_TMP100_bt",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".IPMC_TMP100_z";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "IPMC_TMP100_z",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".IPMC_LTC_6A_V";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "IPMC_LTC_6A_V",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".IPMC_LTC_6A_I";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "IPMC_LTC_6A_I",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".IPMC_LTC_6A_T";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "IPMC_LTC_6A_T",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".IPMC_LTC_67_V";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "IPMC_LTC_67_V",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".IPMC_LTC_67_I";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "IPMC_LTC_67_I",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".IPMC_LTC_6B_V";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "IPMC_LTC_6B_V",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".IPMC_LTC_6B_I";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "IPMC_LTC_6B_I",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".IPMC_LTC_6D_V1";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "IPMC_LTC_6D_V1",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".IPMC_LTC_6D_I1";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "IPMC_LTC_6D_I1",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".IPMC_LTC_69_V";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "IPMC_LTC_69_V",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".IPMC_LTC_69_I";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "IPMC_LTC_69_I",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".IPMC_LTC_6C_V";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "IPMC_LTC_6C_V",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".IPMC_LTC_6C_I";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "IPMC_LTC_6C_I",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".IPMC_LTC_6D_V2";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "IPMC_LTC_6D_V2",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".IPMC_LTC_6D_I2";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "IPMC_LTC_6D_I2",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".IPMC_LTC_6E_V";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "IPMC_LTC_6E_V",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".IPMC_LTC_6E_I";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "IPMC_LTC_6E_I",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".Zynq_ps_temp";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "Zynq_ps_temp",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".Zynq_pl_temp";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "Zynq_pl_temp",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".Zynq_vcc_pspll0";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "Zynq_vcc_pspll0",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".Zynq_vccint";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "Zynq_vccint",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".Zynq_vccbram";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "Zynq_vccbram",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".Zynq_vccaux";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "Zynq_vccaux",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".Zynq_vcc_psddrpll";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "Zynq_vcc_psddrpll",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".Zynq_vcc_psintfp_ddr";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "Zynq_vcc_psintfp_ddr",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".Zynq_vcc_ps_lpd1";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "Zynq_vcc_ps_lpd1",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".Zynq_vcc_ps_lpd2";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "Zynq_vcc_ps_lpd2",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".Zynq_ps_aux3";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "Zynq_ps_aux3",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".Zynq_vcc_ddr_io";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "Zynq_vcc_ddr_io",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".Zynq_ps_bank_503";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "Zynq_ps_bank_503",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".Zynq_ps_bank_500";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "Zynq_ps_bank_500",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".Zynq_vcc0_psi01_1";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "Zynq_vcc0_psi01_1",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".Zynq_vcc0_psi01_2";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "Zynq_vcc0_psi01_2",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".Zynq_vcc_ps_gtr";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "Zynq_vcc_ps_gtr",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".Zynq_vtt_ps_gtr";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "Zynq_vtt_ps_gtr",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".Zynq_vcc_ps_adc";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "Zynq_vcc_ps_adc",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".Zynq_vcc_pl_int";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "Zynq_vcc_pl_int",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".Zynq_vcc_pl_aux";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "Zynq_vcc_pl_aux",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".Zynq_vref_p";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "Zynq_vref_p",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".Zynq_vref_n";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "Zynq_vref_n",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".Zynq_vcc_pl_bram";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "Zynq_vcc_pl_bram",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".Zynq_vcc_ps_intlp4";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "Zynq_vcc_ps_intlp4",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".Zynq_vcc_ps_intfp5";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "Zynq_vcc_ps_intfp5",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".Zynq_vcc_ps_aux";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "Zynq_vcc_ps_aux",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }
            dpe = fullName+".Zynq_vcc_pl_adc";
            address = dpe; // address can be generated from dpe after some mods ...
            strreplace(address, "/", ".");

            active = evaluateActive(
                         addressActiveControl,
                         "Regs",
                         "Zynq_vcc_pl_adc",
                         dpe);

            success = addressConfigWrapper(
                          dpe,
                          address,
                          DPATTR_ADDR_MODE_INPUT_SPONT /* mode */,
                          connectionSettings,
                          active);

            if (!success)
            {
                DebugTN("Failed setting address "+address+"; will terminate now.");
                return false;
            }


        }
    }


    return true;
}


dyn_int getChildNodesWithName (int docNum, int parentNode, string name)
{
    dyn_int result;
    int node = xmlFirstChild(docNum, parentNode);
    while (node >= 0)
    {
        if (xmlNodeName(docNum, node)==name)
            dynAppend(result, node);
        node = xmlNextSibling (docNum, node);
    }
    return result;
}

int parseConfig (
    string  configFileName,
    bool    createDps,
    bool    assignAddresses,
    bool    continueOnError,
    mapping addressActiveControl = makeMapping(),
    mapping connectionSettings = makeMapping())
/* Create instances */
{

    /* Apply defaults in connectionSettings, when not concretized by the user */
    if (!mappingHasKey(connectionSettings, CONNECTIONSETTING_KEY_DRIVER_NUMBER))
    {
        connectionSettings[CONNECTIONSETTING_KEY_DRIVER_NUMBER] = 10;
    }
    if (!mappingHasKey(connectionSettings, CONNECTIONSETTING_KEY_SERVER_NAME))
    {
        connectionSettings[CONNECTIONSETTING_KEY_SERVER_NAME] = "SRTM";
    }
    if (!mappingHasKey(connectionSettings, CONNECTIONSETTING_KEY_SUBSCRIPTION_NAME))
    {
        connectionSettings[CONNECTIONSETTING_KEY_SUBSCRIPTION_NAME] = "SRTM_SUBSCRIPTIONS";
    }

    /* Pre/Suffix the expression with ^$ to enable exact matches and also check if given patterns make sense */
    for (int i=1; i<=mappinglen(addressActiveControl); i++)
    {
        string regexp = mappingGetValue(addressActiveControl, i);
        regexp = "^"+regexp+"$";
        addressActiveControl[mappingGetKey(addressActiveControl, i)] = regexp;
        int regexpResult = regexpIndex(regexp, "thisdoesntmatter");
        if (regexpResult <= -2)
        {
            DebugTN("It seems that the given regular expression is wrong: "+regexp+"    the process will be aborted");
            return -1;
        }
    }

    string errMsg;
    int errLine;
    int errColumn;

    string configFileToLoad = configFileName;

    if (! _UNIX)
    {
        DebugTN("This code was validated only on Linux systems. For Windows, BE-ICS should perform the validation and release the component. See at https://its.cern.ch/jira/browse/OPCUA-1519 for more information.");
        return -1;
    }

    // try to perform entity substitution
    string tempFile = configFileToLoad + ".temp";
    int result = system("xmllint --noent " + configFileToLoad + " > " + tempFile);
    DebugTN("The call to 'xmllint --noent' resulted in: "+result);
    if (result != 0)
    {
        DebugTN("It was impossible to run xmllint to inflate entities. WinCC OA might load this file incorrectly if entity references are used. So we decided it wont be possible. See at https://its.cern.ch/jira/browse/OPCUA-1519 for more information.");
        return -1;
    }
    configFileToLoad = tempFile;

    int docNum = xmlDocumentFromFile(configFileToLoad, errMsg, errLine, errColumn);
    if (docNum < 0)
    {
        DebugN("Didn't open the file: at Line="+errLine+" Column="+errColumn+" Message=" + errMsg);
        return -1;
    }

    int firstNode = xmlFirstChild(docNum);
    if (firstNode < 0)
    {
        DebugN("Cant get the first child of the config file.");
        return -1;
    }

    while (xmlNodeName(docNum, firstNode) != "configuration")
    {
        firstNode = xmlNextSibling(docNum, firstNode);
        if (firstNode < 0)
        {
            DebugTN("configuration node not found, sorry.");
            return -1;
        }
    }

    // now firstNode holds configuration node
    dyn_int children;
    dyn_int children = getChildNodesWithName(docNum, firstNode, "Regs");
    for (int i = 1; i<=dynlen(children); i++)
    {
        configureRegs (docNum, children[i], "", createDps, assignAddresses, continueOnError, addressActiveControl, connectionSettings);
    }


    return 0;
}