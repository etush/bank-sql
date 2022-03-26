--2 
--.כתבי פרוצדורת שליפה המציגה את הנתונים מטבלת פעולות. השדות: מזהה פעולה, שם
--מלא, מספר חשבון, מספר סניף, סכום, תיאור, יתרה.
--הפרוצדורה תקבל כפרמטר מזהה פעולה )ב"מ null .)אם לא נשלח מזהה תחזורנה כל
--הרשומות.

ALTER PROCEDURE select_move_id @move_id INT=NULL
AS
BEGIN
	SELECT [move_id],[full_name],a.[account_id],[brunch_id],[sum],[desc],[balance]
	FROM [dbo].[movements]m JOIN[dbo].[account]a
	ON m.account_id=a.account_id 
	WHERE [move_id]=@move_id OR @move_id iS NULL

END

EXEC [dbo].[select_move_id] 