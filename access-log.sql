/*
===============================================================================
Title:		Access Log
Author:		Jonathan Bentley
Email:		jonathan.bentley@ouh.nhs.uk
Date:		2025-05-20 
-------------------------------------------------------------------------------
Specification:
This report is for monitoring user access of sensitive charts, if 
confidentiality is suspected to have been breached. It is run off MrcLogDb 
database.

It can be adjusted to show a log of the records a specified user has accessed
or a log of users accessing a specific patient's records.

-------------------------------------------------------------------------------
Revision History: 
Author				Date		Change
------------------------------------------------
JonathanBentley		2025-05-20	Initial Version

===============================================================================
*/

SELECT 
	cen.patientLifetimeNumber, 
	cen.patientFullName, 
	LoggedUser, 
	access.Target, 
	access.Action, 
	TimeCreated
FROM 
	MrcLogDb.dbo.AccessLog AS access
	JOIN CISReportingActiveDB0.DAR.PatientDocument AS cen 
		ON access.PtEncounterId = cen.cisEncounterId
WHERE	
	---LoggedUser LIKE '%%' --- if you want to check a user's browsing history, put name here within wildcards and uncomment.
		cen.patientLifetimeNumber = '' --- if you want to check who is accessing a patient's records, put patient MRN here and uncomment.
GROUP BY 
	cen.patientLifetimeNumber, 
	cen.patientFullName, 
	LoggedUser, 
	access.Target, 
	access.Action, 
	TimeCreated, 
	Message, 
	Station
ORDER BY 
	TimeCreated DESC


