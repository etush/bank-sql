--10 
--.כתבי פרוצדורה המשמשת לאיתור הלבנות הון.
--הפרוצדורה תבצע חיפוש באופנים הבאים:
--a .תזהה לקוחות אשר להם יותר מחשבון אחד, ואשר בוצעו בהם באותו יום עסקים
--פעולות בסכומים של מעל 50000 ₪ שהתרחשו לפחות פעם אחת בחודש במשך
--שלושה חודשים רצופים. השתמשי ב cursor.
--b .תזהה חשבונות אשר בהם פעולות של זיכוי בסכומים של מעל 50000 ביום עסקים,
--ובאותו שבוע פעולות חיוב בסכומים של מעל 50000.₪

ALTER	PROCEDURE money_laundering
AS
BEGIN
	DECLARE @account_id NVARCHAR(1000)='',@tz NVARCHAR(1000)=''
	--a
	PRINT
'תז	 לקוחות אשר להם יותר מחשבון אחד, ואשר בוצעו בהם באותו יום עסקים
פעולות בסכומים של מעל 50000 ₪ שהתרחשו לפחות פעם אחת בחודש במשך
שלושה חודשים רצופים.'
	
	SELECT DISTINCT @tz+=	CONVERT(NVARCHAR(9),[tz])+', '
	FROM(SELECT *
		FROM(SELECT *
			FROM (SELECT [tz],
					LAG([date],1,-1) OVER (
						PARTITION BY [tz]
						ORDER BY [date]
						) pre_date,
					[date],
					LEAD([date],1,-1) OVER (
						PARTITION BY [tz],MONTH([date])
						ORDER BY [date]
						) next_date
				FROM[dbo].[account]a1 JOIN [dbo].[movements] m
				ON a1.account_id=m.account_id
				WHERE CAST([date]AS DATE)IN(SELECT  CAST([date]AS DATE)--תנאי על התז והסכום
								FROM [dbo].[account]a2 JOIN [dbo].[movements] m
								ON a2.account_id=m.account_id
								WHERE a2.[tz]=a1.[tz] 
								GROUP BY [tz], CAST([date]AS DATE)
								HAVING SUM(ABS([sum]))>50000 AND  COUNT([tz])>1 )	
		)AS A--שולף את כל התנועות  של הלקוח באותו יום
		WHERE next_date=-1)AS B--שולף את התנועה האחרונה מהיום האחרון בחודש שמקיים את התנאי
		WHERE DATEDIFF(MONTH,pre_date,[date])=1 AND DATEDIFF(MONTH,[date],next_date)=1)AS C--שולף רק אם יש שלוש חודשים רצופים
		--שולף רק את התז
		PRINT @tz

	--b
	PRINT
	'חשבונות אשר בהם פעולות של זיכוי בסכומים של מעל 50000 ביום עסקים,
ובאותו שבוע פעולות חיוב בסכומים של מעל 50000.₪'
	SELECT DISTINCT @account_id+=CONVERT(NVARCHAR(10),[account_id])+', '
	FROM  [dbo].[movements]
	WHERE DATEPART(WK,[date])IN(SELECT DATEPART(WK,[date])
								FROM[dbo].[movements]
								GROUP BY  DATEPART(WK,[date]),DATEPART(DAY,[date])
								HAVING SUM([sum])<50000 )
	GROUP BY [account_id],DATEPART(WK,[date])
	HAVING SUM([sum])>50000

	PRINT @account_id

END

EXEC[dbo].[money_laundering]