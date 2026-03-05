FwCaVLoopDU_initialize(string domain, string device)
{
}

FwCaVLoopDU_valueChanged( string domain, string device,
      int Actual_dot_status,
      bool Actual_dot_fault01,
      bool Actual_dot_fault02,
      bool Actual_dot_fault03, string &fwState )
{ 
      int StatusValue;    
          
      StatusValue = Actual_dot_status & 15;   
 
	if ( 
       (StatusValue == 1) && 
       (Actual_dot_fault01 == FALSE) && 
	 (Actual_dot_fault02 == FALSE) && 
	 (Actual_dot_fault03 == FALSE) )  

	{ 
		fwState = "OFF"; 
	} 
	else if ( 
       (StatusValue == 2) && 
       (Actual_dot_fault01 == FALSE) && 
	 (Actual_dot_fault02 == FALSE) && 
	 (Actual_dot_fault03 == FALSE) ) 
	{ 
		fwState = "STAND-BY"; 
	} 
	else if ( 
       (StatusValue == 4) && 
       (Actual_dot_fault01 == FALSE) && 
	 (Actual_dot_fault02 == FALSE) && 
	 (Actual_dot_fault03 == FALSE) ) 
	{ 
		fwState = "ON"; 
	} 
	else if ( 
       (StatusValue == 8) && 
       (Actual_dot_fault01 == FALSE) && 
	 (Actual_dot_fault02 == FALSE) && 
	 (Actual_dot_fault03 == FALSE) ) 
	{ 
		fwState = "LOCKED"; 
	}
	else if (
	(Actual_dot_fault01 == TRUE) ||
	(Actual_dot_fault02 == TRUE) ||
	(Actual_dot_fault03 == TRUE) )
	{
		fwState = "WARNING";
	}
	else 
	{
		fwState = "ERROR";
	}
}



