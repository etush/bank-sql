--3 
--.כתבי פרוצדורת הוספה לטבלת תנועות. הפרוצדורה תקבל את נתוני כל השדות למעט שדה
--תאריך שיתעדכן באופן אוטומטי לתאריך הנוכחי. הפרוצדורה תוסיף את הנתונים, אם מספר
--חשבון אינו קיים תזרוק שגיאה.

CREATE PROCEDURE add_movement 
@account_id INT,
@desc VARCHAR(100),
@sum MONEY=0,
@balance MONEY=0
AS
BEGIN
	IF @account_id IN (SELECT [account_id]
						FROM [dbo].[account])
	BEGIN
		INSERT [dbo].[movements]([date],[account_id],[desc],[sum],[balance])
		VALUES(GETDATE(),@account_id,@desc,@sum,@balance)
		PRINT 'הפעולה התבצעה בהצלחה'
	END
	ELSE
	BEGIN
		RAISERROR('מספר החשבון לא קיים ',11,1)
	END
END
