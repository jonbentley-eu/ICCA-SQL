/*
===============================================================================
Title:		Formulary Category Finder
Author:		Jonathan Bentley
Email:		jonathan.bentley@ouh.nhs.uk
Date:		2026-02-20
-------------------------------------------------------------------------------
Specification:
This report shows all medications in the ICCA formulary, their corresponding
pharmaceutical and therapeutic category, along with catergoryId numbers.

This is useful for further reporting where you want to query against specific
medication categories.

-------------------------------------------------------------------------------
Revision History: 
Author				Date		      Change
------------------------------------------------
JBentley		  2024-12-06	  Initial Version
===============================================================================
*/


WITH CTE_pharm AS
(
SELECT mat.longLabel, cat.shortLabel, cat.type, cat.categoryId
FROM DAR.Category AS cat
JOIN DAR.MaterialCategory AS matcat ON matcat.categoryId = cat.categoryId
JOIN DAR.Material AS mat ON matcat.materialId = mat.materialId
WHERE cat.type = ('Pharmaceutical Categories')
)

, CTE_therap AS
(
SELECT mat.longLabel, cat.shortLabel, cat.type, cat.categoryId
FROM DAR.Category AS cat
JOIN DAR.MaterialCategory AS matcat ON matcat.categoryId = cat.categoryId
JOIN DAR.Material AS mat ON matcat.materialId = mat.materialId
WHERE cat.type = ('Therapeutic Categories')
)

SELECT  pharm.longLabel as [Medication], pharm.shortLabel AS [pharmaceutical category], pharm.categoryId AS [pharmaceutical categoryId], therap.shortLabel AS [therapeutic category], therap.categoryId AS [therapeutic categoryId]
FROM CTE_pharm as pharm
JOIN CTE_therap AS therap ON pharm.longLabel = therap.longLabel

ORDER BY Medication ASC
