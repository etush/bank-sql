--5 
--.כתבי פרוצדורת מחיקה, המחיקה תמחק את הרשומה מטבלת הפעולות ותאכסן אותה
--בטבלת היסטוריה.]צרי טבלה זו[
GO
CREATE TABLE archion(
[move_id] INT,
[date][datetime]NOT NULL,
[account_id][int]NOT NULL,
[desc][nvarchar](100) NULL,
[sum][decimal](30,2) NOT NULL,
[balance][decimal](30,2) NULL,
[delete_date] AS(GETDATE())

PRIMARY KEY ([move_id]),
CONSTRAINT [FK_archion_account_id]FOREIGN KEY(account_id)REFERENCES account([account_id])
)

GO
CREATE TRIGGER delete_movement ON [dbo].[movements]
FOR DELETE
AS
BEGIN
	INSERT INTO[dbo].[archion]
	SELECT *
	FROM deleted
END


