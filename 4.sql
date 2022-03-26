--4
--.���� �������� �����. ��������� ����� ����� �� ����� ��� ����� )��� ������ �
--������ ��� ���(, ���� ��� ��� ������ ����� ������.
--����� ����


--������ �� �� ���� ���

ALTER TRIGGER update_movement ON [dbo].[movements]
FOR UPDATE
AS
BEGIN
	DECLARE @date DATETIME

	SELECT @date=[date]
	FROM deleted	

	IF UPDATE([sum])
		AND DATEDIFF(DAY,@date,GETDATE())!=0 
		AND (DATEPART(WEEKDAY,@date)NOT IN(1,7)OR DATEPART(WEEKDAY,GETDATE())NOT IN(7,1,2) OR ABS((DATEDIFF(DAY,@date,GETDATE())))>2)
	BEGIN
		PRINT '��� ������ �����'

		DECLARE @sum MONEY
		SELECT @sum=[sum]
		FROM deleted

		UPDATE [dbo].[movements]
		SET [sum]=@sum
		WHERE [move_id]IN(SELECT[move_id]
						FROM deleted)


	END
END



UPDATE [dbo].[movements]
SET [sum]=32000
WHERE [move_id]=21--�� �����
