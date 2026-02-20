/*
===============================================================================
Title:		New Meds Review
Author:		Jonathan Bentley
Email:		jonathan.bentley@ouh.nhs.uk
Date:		2026-02-20
-------------------------------------------------------------------------------
Specification:
This report shows all new prescriptions since 16:00 the day before without 
pharmacy approval across specified clinical units, which have not been 
discontinued prior to the current time.
Excludes all prescriptions made for patients who have now been discharged.

Must  be run against the Server where CISReportingActiveDB0, although the DB
is specified in the query.

-------------------------------------------------------------------------------
Revision History: 
Author			Date		    Change
------------------------------------------------
JBentley		2026-02-20	Initial Version

===============================================================================
*/

DECLARE @startDate AS DATETIME = DATEADD(hour, 16, CAST(DATEADD(day, -1, CAST(GETDATE() AS date)) AS datetime2(0)));

WITH bedrank AS
(
SELECT en.encounterId, lifeTimeNumber AS [MRN], bedId, bedLabel, Rank() OVER(PARTITION BY bed.encounterId ORDER BY utcInTime DESC) AS RankNum
FROM CISReportingActiveDB0.DAR.PtBedStay AS bed
INNER JOIN CISReportingActiveDB0.DAR.D_Encounter AS en ON bed.encounterId = en.encounterId
WHERE bed.clinicalUnitId IN (/* CLINICAL UNIT ID HERE */)
AND bedLabel NOT LIKE 'No bed'
)

, approved AS
(
SELECT DISTINCT ptMedicationOrderId
FROM CISReportingActiveDB0.DAR.PtMedicationOrder AS med
WHERE med.clinicalUnitId IN (/* CLINICAL UNIT ID HERE */)
AND utcStartTime > @startDate
AND attributePropName LIKE ('pharmacyApproved')
)


SELECT bedLabel AS [Bed], lifeTimeNumber AS [MRN], CONCAT(firstName, ' ', lastName) AS Name, orderLongDisplayLabel AS [Prescription], utcStartTime AS [Prescribed at:], utcEndTime AS [Prescription Ends:]
FROM CISReportingActiveDB0.DAR.PtMedicationOrder AS med
INNER JOIN CISReportingActiveDB0.DAR.D_Encounter AS en ON med.encounterId = en.encounterId
INNER JOIN bedrank AS bed ON med.encounterId = bed.encounterId
WHERE med.clinicalUnitId IN (/* CLINICAL UNIT ID HERE */)
AND utcStartTime > @startDate
AND attributePropName LIKE 'orderStatus'
AND orderLongDisplayLabel COLLATE Latin1_General_BIN2 NOT LIKE N'%√%'
AND (utcEndTime > GETUTCDATE() OR utcEndTime IS NULL)
AND RankNum = 1

AND NOT EXISTS (
SELECT *
FROM approved
WHERE approved.ptMedicationOrderId = med.ptMedicationOrderId
)

GROUP BY lifeTimeNumber, bedLabel, lastName, firstName, orderLongDisplayLabel, attributePropName, utcStartTime, utcEndTime
ORDER BY bedLabel, utcStartTime, utcEndTime
