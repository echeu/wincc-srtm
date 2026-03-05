FwCaVPlantDU_initialize(string domain, string device)
{
}

FwCaVPlantDU_valueChanged( string domain, string device,
      int Actual_dot_status,
      bool Warnings_dot_summary, string &fwState )
{ 
      int StatusValue;  
        
      StatusValue = Actual_dot_status & 7; 

	if (
	(StatusValue == 1) &&
	(Warnings_dot_summary == FALSE) )
	{
		fwState = "OFF";
	}
	else if (
	(StatusValue == 2) &&
	(Warnings_dot_summary == FALSE) )
	{
		fwState = "Stand-By";
	}
	else if (
	(StatusValue == 4) &&
	(Warnings_dot_summary == FALSE) )
	{
		fwState = "Run";
	}
	else if (Warnings_dot_summary == TRUE)
	{
		fwState = "Warning";
	}
	else 
	{
		fwState = "ERROR";
	}
}


FwCaVPlantDU_doCommand(string domain, string device, string command)
{
}

