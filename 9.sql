--9
--.כתבי פונקציה המקבלת תאריך ומספר ימים ומחזירה את סיכומי הפעולות מתוך ה View ,
--אשר בוצעו במשך מספר הימים שהתקבל כפרמטר מאז התאריך הנשלח. הפונקציה תחזיר
--טבלה כמה כסף הופקד לחשבון, כמה כסף נמשך מהחשבון ומה היתרה העכשווית


ALTER FUNCTION daily_summary_from_date_for_days(@date DATE,@num_days INT)
RETURNS TABLE
AS
RETURN 
SELECT [pos_sum],[neg_sum],[balance]
FROM [dbo].[daily_summary]
WHERE [date] BETWEEN @date AND DATEADD(DAY,@num_days,@date)

SELECT *
FROM [dbo].[daily_summary_from_date_for_days]('2021-06-29',7)
