--6
--.כתבי פונקציה המקבלת תאריך חריגה מהמסגרת, ומחזירה תוך כמה ימים כוסתה החריגה



GO
ALTER FUNCTION days_for_cover_exception (@account_id INT, @date DATETIME)
RETURNS INT
AS
BEGIN
	DECLARE @date_cover DATE

	SET @date=CONVERT(DATE,@date)

	IF (SELECT COUNT([account_id])
		FROM [dbo].[daily_summary]
		WHERE [exception]<0 AND @date=[date] AND @account_id=[account_id])>0
	BEGIN
		SELECT TOP 1 @date_cover=[date]
		FROM [dbo].[daily_summary]
		WHERE @account_id=[account_id] AND DATEDIFF(DAY,@date,[date])>0 AND [exception]>=0
		ORDER BY [date]

		IF @date_cover IS NULL 
		BEGIN
			--PRINT 'החריגה לא כוסתה עדיין'
			--PRINT 'עבור חשבון '+CAST(@account_id AS VARCHAR(10))
			RETURN -1
		END
		ELSE
		BEGIN
			RETURN DATEDIFF(DAY,@date,@date_cover) 	
		END
	END
	--ELSE
	--PRINT'לא נמצאה חריגה בתאריך '+CAST(@date AS VARCHAR(10))
		
	RETURN 0
END

SELECT *
FROM[dbo].[daily_summary]

PRINT [dbo].[days_for_cover_exception](4,'2021-07-05')
