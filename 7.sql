
--7 
--.כתבי פונקציה הבודקת עבור תנועה שלילית האם היא מורשה.
--תנועה הינה תנועה העונה על אחד מהכללים הבאים:
--a .היתרה בחשבון לא תהיה נמוכה יותר מהמסגרת המוגדרת בחשבון.
--b .אם מדובר בסכום של עד 1000 ₪ מעבר למסגרת, ואשר ללקוח זה אם היו חריגות
--הן כוסו תוך שבוע ימים.




ALTER FUNCTION is_neg_move_allowed(@move_id INT)
RETURNS INT
AS
BEGIN
	DECLARE @sum MONEY, @acount_id INT, @date DATETIME,@exception MONEY

	SELECT @sum=[sum]
	FROM [dbo].[movements]
	WHERE [move_id]=@move_id	

	IF @sum IS NULL RETURN -1--אם לא קיימת כזו תנועה

	IF @sum>0 RETURN 1--אם התנועה חיובית 

	SELECT @acount_id=[account_id]
	FROM [dbo].[movements]
	WHERE [move_id]=@move_id

	SELECT @date=[date]
	FROM [dbo].[movements]
	WHERE [move_id]=@move_id

	--a .היתרה בחשבון לא תהיה נמוכה יותר מהמסגרת המוגדרת בחשבון.

	SELECT @exception= [exception]
	FROM [dbo].[helper_daily_summary] 
	WHERE[account_id]=@acount_id AND [date]=(SELECT TOP 1[date]
											FROM[dbo].[movements]
											WHERE [account_id]=@acount_id AND [date]<@date
											ORDER BY [date] DESC)--תת שאילתא שמחזירה את תאריך התנועה הקודמת של בעל החשבון
	--IF @exception IS NULL RETURN -1								
	IF @exception=0	RETURN 1
	--b
	--אם מדובר בסכום של עד 1000 ₪ מעבר למסגרת
	IF @exception+@sum<-1000 RETURN 0

	-- אם היו חריגות הן כוסו תוך שבוע ימים
	--לעבור עם הקרסר על כל בחריגות הקודמות
	--ולבדוק תוך כמה ימים כל אחת כוסתה
	DECLARE @date_exception DATE 
	DECLARE crs CURSOR
	FOR SELECT[date]
		FROM[dbo].[daily_summary]
		WHERE DATEDIFF(DAY,[date],@date)>0 AND [account_id]=@acount_id AND [exception]<0
	OPEN crs
	FETCH NEXT FROM crs INTO @date_exception
	WHILE @@FETCH_STATUS=0
	BEGIN
		DECLARE @days_cover INT=[dbo].[days_for_cover_exception](@acount_id,@date_exception)
		IF @days_cover>7 OR @days_cover=-1
			RETURN 0
	FETCH NEXT FROM crs INTO @date_exception
	END
	CLOSE crs
	DEALLOCATE crs

	RETURN 1
END


PRINT [dbo].[is_neg_move_allowed](1)

SELECT *FROM[dbo].[daily_summary]

--SELECT *FROM[dbo].[movements]

SELECT*FROM[dbo].[helper_daily_summary]
GO