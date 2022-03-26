--1
GO
ALTER VIEW helper_daily_summary([account_id],[tz],[full_name],[date],[pos_sum],[neg_sum],[balance],[exception])
AS
SELECT a.account_id,a.tz,a.full_name,m.date,[dbo].[neg_pos]([sum],1),[dbo].[neg_pos]([sum],-1),[balance],[dbo].[calc_exception]([balance],[framework])--([dbo].[day_balance](a.account_id,m.date),a.framework)
FROM [dbo].[account] a JOIN [dbo].[movements] m
ON a.account_id=m.account_id


GO
ALTER VIEW daily_summary ([account_id],[tz],[full_name],[date],[pos_sum],[neg_sum],[balance],[exception])
AS 
SELECT [account_id], [tz],[full_name],CONVERT(DATE,[date]),SUM([pos_sum]),SUM([neg_sum]),[balance],[exception]
FROM [dbo].[helper_daily_summary]
WHERE [date]IN(SELECT MAX([date])FROM[dbo].[movements]GROUP BY [account_id],CONVERT(DATE,[date]))
GROUP BY[account_id],[tz],[full_name],CONVERT(DATE,[date]),[balance],[exception]

--GO
--CREATE FUNCTION day_balance (@account_id INT,@date DATE)
--RETURNS MONEY
--AS
--BEGIN
--	DECLARE @balance MONEY
--	SET @balance=0
--	SELECT TOP 1 @balance=[balance]
--	FROM [dbo].[movements]
--	WHERE [account_id]=@account_id AND DATEDIFF(DAY,[date],@date)=0
--	ORDER BY [date] DESC
--	RETURN @balance
--END
GO
CREATE FUNCTION calc_exception (@balance MONEY,@framework MONEY)
RETURNS MONEY
AS
BEGIN
	IF @balance>0
		RETURN 0
	DECLARE @exception MONEY
	SET @exception=@framework+@balance
	IF @exception>0
		RETURN 0
	RETURN @exception
END

GO
CREATE FUNCTION neg_pos(@sum MONEY,@sign INT)
RETURNS MONEY
AS 
BEGIN
	IF @sum*@sign>0 RETURN @sum
	RETURN 0
END


--CREATE FUNCTION select_day_balance()
--RETURNS TABLE 
--AS
--RETURN
--SELECT SUM([sum]) AS 'R'FROM[dbo].[movements]GROUP BY DAY([date]),[account_id]
--SELECT*FROM[dbo].[daily_summary]
--SELECT*FROM[dbo].[select_day_balance]()


SELECT*FROM[dbo].[helper_daily_summary]
SELECT*FROM[dbo].[daily_summary]




