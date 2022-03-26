
--8
--.כתבי טריגר המעדכן את יתרת החשבון בפעולות של הוספה, עדכון ומחיקה. חשבי כמה
--רשומות עליך לעדכן. )השתמשי ב cursor.
GO
ALTER DATABASE[my_bank] SET RECURSIVE_TRIGGERS OFF--אם יתבצע עדכון בתוך הטריגר הטריגר יופעל פעם אחת

GO
ALTER TRIGGER [dbo].[update_balance] ON [dbo].[movements]
FOR UPDATE,INSERT,DELETE
AS
BEGIN
	DECLARE @move_id INT,@account_id INT
	DECLARE crs CURSOR LOCAL
	FOR SELECT [move_id],[account_id]FROM deleted 
		UNION
		SELECT [move_id],[account_id]FROM inserted			
	OPEN crs
	FETCH NEXT FROM crs INTO @move_id,@account_id
	WHILE @@FETCH_STATUS=0
	BEGIN
		DECLARE @balance MONEY
		--SET @balance=0
		--SELECT @balance+= [sum]
		--FROM [dbo].[movements]
		--WHERE [account_id]=@account_id

		--UPDATE [dbo].[movements]
		--SET [balance]=@balance
		--WHERE [move_id]=@move_id
		DECLARE @last_move INT	

		DECLARE @cnt_insert INT, @cnt_delete INT

		SELECT @cnt_insert= COUNT(*)
		FROM inserted
		where [move_id]=@move_id
		
		SELECT @cnt_delete= COUNT(*)
		FROM deleted
		where [move_id]=@move_id

		IF @cnt_delete>0 AND @cnt_insert>0--במקום לשאול איף אפדייט 
		BEGIN
			SELECT  @balance=[balance],@last_move=[move_id]
			FROM [dbo].[movements]
			WHERE [account_id]=@account_id AND[move_id]=@move_id
			
			PRINT 'UPDATE'
			PRINT 'יתרה קודמת'
			PRINT @balance
		END
		ELSE
		BEGIN		
			SELECT TOP 1 @balance=[balance],@last_move=[move_id]
			FROM [dbo].[movements]
			WHERE [account_id]=@account_id AND[move_id]<@move_id		
			ORDER BY [move_id] DESC

			PRINT 'DELETE OR INSERT'
			PRINT 'יתרה קודמת'			
			PRINT @balance
		END				

		SELECT @balance= ISNULL(@balance,0)--אם לא נמצאה שורה  למשל בפתיחת חשבון	

		UPDATE [dbo].[movements]
		SET [balance]=@balance
		WHERE [move_id]=@move_id 

		DECLARE @total MONEY=0		

		SELECT  @total-=ISNULL([sum],0)--האיז נל הוא עבור חשבונות חדשים
		FROM deleted
		WHERE [account_id]=@account_id AND([move_id] BETWEEN @last_move AND @move_id)--לבדוק אם הביטוין כולל את הגבולות

		--SELECT @balance=ISNULL(@total,0)--מיותר

		SELECT  @total+=ISNULL([sum],0)
		FROM inserted
		WHERE [account_id]=@account_id AND([move_id]BETWEEN @last_move AND @move_id)

		PRINT 'הסכום לשינוי'
		PRINT @total

		--SELECT @balance=ISNULL(@total,0)--מיותר

		UPDATE [dbo].[movements]
		SET [balance]=[balance]+@total
		WHERE [move_id]>=@move_id-- AND [balance] IS NOT NULL

		FETCH NEXT FROM crs INTO @move_id,@account_id
	END
	CLOSE crs
	DEALLOCATE crs
END

