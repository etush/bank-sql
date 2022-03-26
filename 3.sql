--3 
--.���� �������� ����� ����� ������. ��������� ���� �� ����� �� ����� ���� ���
--����� ������� ����� ������� ������ ������. ��������� ����� �� �������, �� ����
--����� ���� ���� ����� �����.

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
		PRINT '������ ������ ������'
	END
	ELSE
	BEGIN
		RAISERROR('���� ������ �� ���� ',11,1)
	END
END
