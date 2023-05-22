/* *************************************************************************
 Query 1:   Display all menus and the number of times the menu has been  
            distributed.  Display the results in order of the meal types 
            and then listing menus with the most distributions first.  
            All menus should appear in the results, even if they have not
            been distributed.
************************************************************************* */

SELECT m.MealName AS 'Meal Name', SUM(sd.NumberMealsDelivered) AS 'Number of Time Menu Distributed', mt.MealTypeDescription AS 'Meal Type'
FROM thi.dbo.Menus m 
	LEFT JOIN thi.dbo.SiteDistributions sd
		ON m.MenuID = sd.MenuID
	LEFT JOIN thi.dbo.MealTypes mt
		ON m.MealTypeCode = mt.MealTypeCode
GROUP BY m.MealName, mt.MealTypeDescription
ORDER BY mt.MealTypeDescription, SUM(sd.NumberMealsDelivered) DESC;

/* *************************************************************************
 Query 2:   For each sponsor display total purchase-related costs to-date.        
            A cost is purchase-related if the cost description has the             
            word “purchase” in it.                   
************************************************************************* */

SELECT s.SponsorName 'Sponsor Name', SUM(c.totalcost) AS 'Total Purchase-related Costs To-date'
FROM thi.dbo.Sponsors s
	INNER JOIN thi.dbo.Costs c
		ON s.SponsorID = c.SponsorID
	INNER JOIN thi.dbo.CostTypes ct
		ON c.CostTypeID = ct.CostTypeID
WHERE ct.CostTypeDescription LIKE '%purchase%'
GROUP BY s.SponsorName;

/* ************************************************************************
 Query 3:   Display the 5 sites serving the most meals within the past 12 years. 
            Also display the total number of meals served by those sites.    
************************************************************************* */

SELECT TOP 5 s.SiteName AS 'Site Name', SUM(mc.MealCount) AS 'Total Number of Meals'
FROM thi.dbo.Sites s
	INNER JOIN thi.dbo.MealCounts mc
		ON s.siteID = mc.SiteID
	INNER JOIN thi.dbo.SiteDistributions sd
		ON s.siteID = sd.SiteID
WHERE YEAR(GETDATE()) - YEAR(mc.MealCountDate) <= 12
GROUP BY s.SiteName
ORDER BY SUM(mc.MealCount) DESC;

/* *************************************************************************
 Query 4:   Display total number of meals served and anticipated total   
            reimbursement by sponsor, year, month, and meal type, in this order.
            The reimbursement rate for each meal type is in the ReimbursementRate
            table.  The current reimbursement rate has an EndDate of NULL.                          
************************************************************************* */

SELECT ss.sponsorID AS 'Sponsor ID', 
	YEAR(mc.MealCountDate) AS 'Year', 
	MONTH(mc.MealCountDate) AS 'Month',
	mt.MealTypeCode AS 'Meal Type Code',
	SUM(mc.MealCount) AS 'Number of Meals Served', 
	SUM(mc.MealCount) * AVG(rr.ReimbursementRate) AS 'Anticipated Total Reimbursement'
FROM thi.dbo.MealCounts mc
	INNER JOIN thi.dbo.MealTypes mt
		ON mc.MealTypeCode = mt.MealTypeCode
	INNER JOIN thi.dbo.ReimbursementRate rr
		ON mt.MealTypeCode = rr.MealTypeCode
	INNER JOIN thi.dbo.sites st 
		ON mc.SiteID = st.SiteID
	INNER JOIN thi.dbo.Sponsors ss
		ON st.SiteSponsorID = ss.SponsorID
WHERE rr.EndDate IS NULL
GROUP BY ss.sponsorID, YEAR(mc.MealCountDate), MONTH(mc.MealCountDate), mt.MealTypeCode;

/* ************************************************************************* 
 Query 5:    For each sponsor by month, display their total Operational costs 
             to-date, total Meals Served to-date, and total Operational costs 
             per meal to-date. Calculate the latter number based on the first 
             two numbers.                                                    
************************************************************************* */

SELECT sp.SponsorName AS 'Sponsor Name', MONTH(cs.DateofCost) AS 'Month', 
	SUM(cs.TotalCost) AS 'Total Cost', SUM(mc.MealCount) AS 'Total Meal Count', 
	SUM(cs.totalCost) / SUM(mc.MealCount) AS 'Cost per Meal'
FROM thi.dbo.Sponsors sp
	INNER JOIN thi.dbo.Costs cs
		ON sp.SponsorID = cs.SponsorID
	INNER JOIN thi.dbo.CostTypes ct
		ON ct.CostTypeID = cs.CostTypeID
	INNER JOIN thi.dbo.Sites st
		ON st.SiteSponsorID = sp.SponsorID
	INNER JOIN thi.dbo.MealCounts mc
		ON st.SiteID = mc.SiteID
WHERE ct.CostTypeCategory = 'Operational'
GROUP BY sp.SponsorName, MONTH(cs.DateOfCost);

/* *************************************************************************
 STORED      Display sites that did not report meal counts for a user-        
 PROCEDURE:  specified week-beginning date. Do NOT hardcode information.                                                     
             USE a cursor and use a print statement.                     
************************************************************************* */

SELECT st.SiteID AS 'Site ID', st.SiteName AS 'Site Name', 
mc.MealCount AS 'Meal Count', mc.WeekBeginningDate AS 'Week Beginning Date'
FROM thi.dbo.sites st
	INNER JOIN thi.dbo.MealCounts mc
		ON st.SiteID = mc.SiteID
WHERE mc.MealCount IS NULL
AND mc.WeekBeginningDate = '2013-08-05';