--CREATE TABLE
GO--account
CREATE TABLE account(
[account_id][int]IDENTITY(1,1) NOT NULL,
[last_name][nvarchar](30) NULL,
[first_name][nvarchar](30)NOT NULL,
[full_name]  AS (([first_name]+'  ')+[last_name]),
[tz][nchar](9) NOT NULL,
[phone][nvarchar](10) NULL,
[brunch_id][int]NOT NULL,
[type][nvarchar](10) NOT NULL,
[framework][money] NOT NULL

PRIMARY KEY ([account_id]) ,
CONSTRAINT [FK_brunch_id]FOREIGN KEY(brunch_id)REFERENCES brunches([brunch_id]),
CHECK([type]in('פרטי','עסקי'))
)



CREATE TRIGGER open_account ON[dbo].[account]
FOR INSERT
AS
BEGIN
	DECLARE @account_id INT
	DECLARE crs1 CURSOR
	FOR SELECT [account_id]
		FROM inserted
	OPEN crs1
	FETCH NEXT FROM crs1 INTO @account_id
	WHILE @@FETCH_STATUS=0
	BEGIN
		INSERT [dbo].[movements]([date],[account_id],[desc],[sum],[balance])
		VALUES(GETDATE(),@account_id,'פתיחת חשבון',0,0)
		FETCH NEXT FROM crs1 INTO @account_id
	END
	CLOSE crs1
	DEALLOCATE crs1
END

GO--movements
CREATE TABLE movements(
[move_id][int]IDENTITY(1,1) NOT NULL,
[date][datetime]NOT NULL,
[account_id][int]NOT NULL,
[desc][nvarchar](100) NULL,
[sum][money] NOT NULL,
[balance][money] NULL

PRIMARY KEY ([move_id]),
CONSTRAINT [FK_account_id]FOREIGN KEY(account_id)REFERENCES account([account_id]),

)
--ALTER TABLE[dbo].[movements]
--ALTER COLUMN [balance]AS([dbo].[compute_balance]([account_id]))


--GO

--CREATE FUNCTION compute_balance(@account_id INT)
--RETURNS MONEY
--AS
--BEGIN
--	RETURN (SELECT SUM([sum])
--	FROM [dbo].[movements]
--	WHERE[account_id]= @account_id)
--END


ALTER TABLE[dbo].[movements]
ALTER COLUMN[balance][money]

GO--brunches
CREATE TABLE brunches(
[brunch_id][int]IDENTITY(1,1) NOT NULL,
[brunch_num][int]NOT NULL,
[brunch_name][nvarchar](20)NULL

PRIMARY KEY ([brunch_id]) 
)

