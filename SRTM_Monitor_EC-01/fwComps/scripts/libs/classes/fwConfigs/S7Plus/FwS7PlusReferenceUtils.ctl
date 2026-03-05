/**
  (c) Copyright CERN 2005. All rights not expressly granted are reserved.
  icecontrols.support@cern.ch

  SPDX-License-Identifier: LGPL-3.0-only
**/

#uses "classes/fwStdLib/FwException"

class FwS7PlusReferenceUtils
{
    public static const string TSPP_ADDRESS_PREFIX = "@TSPP@.";
    public static const int TSPP_ADDRESS_PREFIX_LENGTH = strlen(TSPP_ADDRESS_PREFIX);
    public static const int ADDRESS_DIRECTION_TSPP = DPATTR_ADDR_MODE_INPUT_SPONT;
    public static const int ADDRESS_DIRECTION_ALARM = 9; //corresponds to undefined but documented DPATTR_ADDR_MODE_AM_ALERT

    public static const int TSPP_MIN_ID = 0;
    public static const int TSPP_MAX_ID = 2147483646;

    public static void validateReference(string addressReference, int addressDirection)
    {
        string address;
        if (addressDirection == ADDRESS_DIRECTION_ALARM) {
            int associatedValue, additionalText;
            parseAlarmReference(addressReference, address, associatedValue, additionalText);
        } else if (addressDirection == ADDRESS_DIRECTION_TSPP) {
            int tsppId;
            parseTsppReference(addressReference, tsppId);
        } else {
            int length;
            parseDataReference(addressReference, address, length);
        }
    }

    public static void parseAlarmReference(string addressReference, string &address, int &associatedValue, int &additionalText)
    {
        FwException::assert(addressReference != "", "Invalid S7+ alarm address - may not be empty");
        dyn_string addressParts = addressReference.split(":");
        FwException::assert(addressParts.count() == 3, "Invalid S7+ alarm address - need three values separated by colons, " + addressReference);
        address = addressParts[1];
        FwException::assert(address.trimmed() == address,
                            "Invalid S7+ alarm address - first part has leading/trailing spaces, " + addressReference);
        FwException::assert(address != "", "Invalid S7+ alarm address - missing first part of address, " + addressReference);
        if (addressParts[2] != "") {
            int rc = sscanf(addressParts[2], "%d", associatedValue);
            FwException::assert(rc == 1, "Invalid S7+ alarm address - associatedValue cannot be parsed, " + addressReference);
            FwException::assert((associatedValue >= 0 && associatedValue <= 10),
                                "Invalid S7+ alarm address - associatedValue must be 1-10 or 0, " + addressReference);
        } else {
            associatedValue = 0;
        }

        if (addressParts[3] != "") {
            int rc = sscanf(addressParts[3], "%d", additionalText);
            FwException::assert(rc == 1, "Invalid S7+ alarm address - additionalText cannot be parsed, " + addressReference);
            FwException::assert(additionalText == 0 || additionalText == 1,
                                "Invalid S7+ alarm address - additionalText must be 0 or 1, " + addressReference);
        } else {
            additionalText = 0;
        }
    }

    public static void parseTsppReference(string addressReference, int &tsppId)
    {
        FwException::assert(addressReference !="", "Invalid S7+ TSPP address - may not be empty");
        FwException::assert(addressReference.startsWith(TSPP_ADDRESS_PREFIX),
                            "Invalid S7+ TSPP address - must start with " + TSPP_ADDRESS_PREFIX + ", " + addressReference);
        string tsppPart = addressReference.mid(TSPP_ADDRESS_PREFIX_LENGTH);
        FwException::assert(tsppPart != "", "Invalid S7+ TSPP address - TSPP ID may not be empty, " + addressReference);
        int rc = sscanf(tsppPart, "%d", tsppId);
        FwException::assert(rc == 1, "Invalid S7+ TSPP address - could not parse the TSPP ID, " + addressReference);
        FwException::assert(tsppId >= TSPP_MIN_ID && tsppId <= TSPP_MAX_ID,
                            "Invalid S7+ TSPP address - TSPP ID is out of range, " + addressReference);
    }

    public static void parseDataReference(string addressReference, string &address, int &length)
    {

        FwException::assert(addressReference!="", "Invalid S7+ data address - may not be empty");
        dyn_string addressParts = addressReference.split(":");
        FwException::assert(addressParts.count() <= 2,
                            "Invalid S7+ data address - may contain only one colon, " + addressReference);
        address = addressParts[1];
        FwException::assert(address.trimmed() == address,
                            "Invalid S7+ data address - contains leading/trailing spaces, " + addressReference);
        FwException::assert(address != "", "Invalid S7+ data address - main part of address may not be empty, " + addressReference);
        FwException::assert(!address.startsWith(TSPP_ADDRESS_PREFIX),
                            "Invalid S7+ data address - did you mean TSPP instead, " + addressReference);
        if (addressParts.count() == 2) {
            FwException::assert(addressParts[2] != "", "Invalid S7+ data address - length may not be empty, " + addressReference);
            int rc = sscanf(addressParts[2], "%d", length);
            FwException::assert(rc == 1, "Invalid S7+ data address - length cannot be parsed, " + addressReference);
            FwException::assert(length >= 0 && length < 1000000,
                                "Invalid S7+ data address - length out of range, " + addressReference);
        }
    }

    public static string refStringFromDataReference(string address, int length)
    {
        return (length <= 0) ? address : address + ":" + length;
    }

    public static string refStringFromAlarmReference(string address, int associatedValue, int additionalText)
    {
        if (address == "")
            return "";

        return address
               + ":" + (associatedValue > 0 ? associatedValue : "")
               + ":" + (additionalText > 0 ? 1 : "");
    }

    public static string refStringFromTsppReference(string address)
    {
        return address;
    }

};

