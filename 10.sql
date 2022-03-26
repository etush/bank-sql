--10 
--.���� �������� ������ ������ ������ ���.
--��������� ���� ����� ������� �����:
--a .���� ������ ��� ��� ���� ������ ���, ���� ����� ��� ����� ��� �����
--������ ������� �� ��� 50000 � ������� ����� ��� ��� ����� ����
--����� ������ ������. ������ � cursor.
--b .���� ������� ��� ��� ������ �� ����� ������� �� ��� 50000 ���� �����,
--������ ���� ������ ���� ������� �� ��� 50000.�

ALTER	PROCEDURE money_laundering
AS
BEGIN
	DECLARE @account_id NVARCHAR(1000)='',@tz NVARCHAR(1000)=''
	--a
	PRINT
'��	 ������ ��� ��� ���� ������ ���, ���� ����� ��� ����� ��� �����
������ ������� �� ��� 50000 � ������� ����� ��� ��� ����� ����
����� ������ ������.'
	
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
				WHERE CAST([date]AS DATE)IN(SELECT  CAST([date]AS DATE)--���� �� ��� ������
								FROM [dbo].[account]a2 JOIN [dbo].[movements] m
								ON a2.account_id=m.account_id
								WHERE a2.[tz]=a1.[tz] 
								GROUP BY [tz], CAST([date]AS DATE)
								HAVING SUM(ABS([sum]))>50000 AND  COUNT([tz])>1 )	
		)AS A--���� �� �� �������  �� ����� ����� ���
		WHERE next_date=-1)AS B--���� �� ������ ������� ����� ������ ����� ������ �� �����
		WHERE DATEDIFF(MONTH,pre_date,[date])=1 AND DATEDIFF(MONTH,[date],next_date)=1)AS C--���� �� �� �� ���� ������ ������
		--���� �� �� ���
		PRINT @tz

	--b
	PRINT
	'������� ��� ��� ������ �� ����� ������� �� ��� 50000 ���� �����,
������ ���� ������ ���� ������� �� ��� 50000.�'
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