GO

CREATE VIEW THI_view_09 AS
SELECT si.SiteName 'Site Name', sp.SponsorName 'Sponsor Name', mt.MealTypeDescription 'Meal Type', 
	st.ServiceTypeDescription 'Service Type', rr.ReimbursementRate 'Reimbursement Rate', mc.WeekBeginningDate 'Week Beginning Date', 
	mc.MealCount 'Meal Count', rr.ReimbursementRate * mc.MealCount 'Expected Reimbursement Amount'
FROM thi.dbo.Sites si
	INNER JOIN thi.dbo.Sponsors sp
		ON si.SiteSponsorID = sp.SponsorID
	INNER JOIN thi.dbo.MealCounts mc
		ON si.SiteID = mc.SiteID
	INNER JOIN thi.dbo.ServiceTypes st
		ON mc.ServiceTypeCode = st.ServiceTypeCode
	INNER JOIN thi.dbo.MealTypes mt
		ON mc.MealTypeCode = mt.MealTypeCode
	INNER JOIN thi.dbo.ReimbursementRate rr
		ON mt.MealTypeCode = rr.MealTypeCode
WHERE rr.EndDate IS NULL;

--DROP VIEW THI_view_09;

GO
