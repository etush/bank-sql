--9
--.���� ������� ������ ����� ����� ���� ������� �� ������ ������� ���� � View ,
--��� ����� ���� ���� ����� ������ ������ ��� ������ �����. �������� �����
--���� ��� ��� ����� ������, ��� ��� ���� ������� ��� ����� ��������


ALTER FUNCTION daily_summary_from_date_for_days(@date DATE,@num_days INT)
RETURNS TABLE
AS
RETURN 
SELECT [pos_sum],[neg_sum],[balance]
FROM [dbo].[daily_summary]
WHERE [date] BETWEEN @date AND DATEADD(DAY,@num_days,@date)

SELECT *
FROM [dbo].[daily_summary_from_date_for_days]('2021-06-29',7)
