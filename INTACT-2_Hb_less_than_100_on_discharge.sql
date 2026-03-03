/*
===============================================================================
Title:		INTACT-2 Hb <= 100g/l on Discharge
Author:		Jonathan Bentley
Email:		jonathan.bentley@ouh.nhs.uk
Date:		2025-03-01 
-------------------------------------------------------------------------------
Specification:

A report that shows Hb less than or equal to 100g/l on discharge from ICU.

The DischargeHb CTE grabs all Hb values for patients within date range, 
and organises them in descending date order, partitioned by encounterId. 

The second SELECT then takes only the most recent Hb value if it is less than
or equal to 100.

There is the option to add the flag isDiscahrged to the CTE if needed, but
our research team felt that wasn't needed.

-------------------------------------------------------------------------------
Revision History: 
Author				Date		Change
------------------------------------------------
JonathanBentley		2025-03-01	Initial Version

===============================================================================
*/


DECLARE @startDate AS DATETIME = '2026-01-01'
DECLARE @endDate AS DATETIME = GETDATE();

WITH DischargeHb AS
(
SELECT 
  l.encounterId, 
  e.lifetimeNumber, 
  l.clinicalUnitId, 
  l.utcChartTime, 
  CAST(l.valueNumber AS DECIMAL(5,0)) AS [Hb Value], -- remove trailing zeros
  ROW_NUMBER() OVER(PARTITION BY l.encounterID ORDER BY utcChartTime DESC) AS RowNumbr
FROM DAR.PtLabResult AS l
INNER JOIN DAR.PtCensus AS c ON l.encounterId = c.encounterId
INNER JOIN DAR.D_Encounter AS e ON l.encounterId = e.encounterId
WHERE 
	attributeDictionaryPropName = 'HgbInt.HaemoglobinMeas'
	AND l.utcChartTime > @startDate
	AND l.utcChartTime < @endDate
	AND l.clinicalUnitId IN ('41', '47', '53', '54', '57')
	--AND isDischarged = 1
)

SELECT 
	lifeTimeNumber AS [MRN], 
	CASE 
		WHEN clinicalUnitId IN ('47') THEN 'CICU'
		WHEN clinicalUnitId IN ('57') THEN 'OCC L1'
		WHEN clinicalUnitId IN ('41') THEN 'AICU'
		WHEN clinicalUnitId IN ('53') THEN 'OCC L3'
		ELSE 'OCC L2'
	END AS [Clinical Unit], 
	utcChartTime AS [Date/Time Received],
	[Hb Value]
FROM DischargeHb AS dhb
WHERE
RowNumbr = 1
AND [Hb Value] <= '100'
ORDER BY utcChartTime DESC

