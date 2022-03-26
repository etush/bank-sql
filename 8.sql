
--8
--.���� ����� ������ �� ���� ������ ������� �� �����, ����� ������. ���� ���
--������ ���� �����. )������ � cursor.
GO
ALTER DATABASE[my_bank] SET RECURSIVE_TRIGGERS OFF--�� ����� ����� ���� ������ ������ ����� ��� ���

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

		IF @cnt_delete>0 AND @cnt_insert>0--����� ����� ��� ������ 
		BEGIN
			SELECT  @balance=[balance],@last_move=[move_id]
			FROM [dbo].[movements]
			WHERE [account_id]=@account_id AND[move_id]=@move_id
			
			PRINT 'UPDATE'
			PRINT '���� �����'
			PRINT @balance
		END
		ELSE
		BEGIN		
			SELECT TOP 1 @balance=[balance],@last_move=[move_id]
			FROM [dbo].[movements]
			WHERE [account_id]=@account_id AND[move_id]<@move_id		
			ORDER BY [move_id] DESC

			PRINT 'DELETE OR INSERT'
			PRINT '���� �����'			
			PRINT @balance
		END				

		SELECT @balance= ISNULL(@balance,0)--�� �� ����� ����  ���� ������ �����	

		UPDATE [dbo].[movements]
		SET [balance]=@balance
		WHERE [move_id]=@move_id 

		DECLARE @total MONEY=0		

		SELECT  @total-=ISNULL([sum],0)--���� �� ��� ���� ������� �����
		FROM deleted
		WHERE [account_id]=@account_id AND([move_id] BETWEEN @last_move AND @move_id)--����� �� ������� ���� �� �������

		--SELECT @balance=ISNULL(@total,0)--�����

		SELECT  @total+=ISNULL([sum],0)
		FROM inserted
		WHERE [account_id]=@account_id AND([move_id]BETWEEN @last_move AND @move_id)

		PRINT '����� ������'
		PRINT @total

		--SELECT @balance=ISNULL(@total,0)--�����

		UPDATE [dbo].[movements]
		SET [balance]=[balance]+@total
		WHERE [move_id]>=@move_id-- AND [balance] IS NOT NULL

		FETCH NEXT FROM crs INTO @move_id,@account_id
	END
	CLOSE crs
	DEALLOCATE crs
END

