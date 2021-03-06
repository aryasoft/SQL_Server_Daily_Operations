CREATE PROCEDURE [can].[MoveIndexToAnotheFileGroup]
(
 @DBName varchar(max),   
 @SchemaName varchar(max),       
 @ObjectName varchar(Max),        
 @indexName varchar(max) = NULL,  
 @FileGroupName varchar(100),
 @IndexType varchar(100) = NULL,
 @Online bit =0 
)  
AS
BEGIN

-- select 'exec [can].[MoveIndexToAnotheFileGroup] ''DBNAME'''+','''+ SCHEMA_NAME(schema_id)+''','''+ o.name+''','''+i.name+''',''FG_INDEX'',2,1' from sys.indexes i
--	 INNER JOIN sys.objects o ON i.object_id=o.object_id
--where data_space_id<>4 and i.type=2   and o.type='U'
 



IF(@IndexType IS NULL)
BEGIN
	DECLARE @TypeId int 
	DECLARE @SQL nvarchar(max) = N'select @TypeId= type from ['+@DBName+'].sys.indexes where object_id=OBJECT_ID('''+@DBName+'.'+@SchemaName+'.'+@ObjectName+''') and type=0'
	exec sp_executesql @SQL, N'@TypeId int out', @TypeId out

	select @IndexType=
	CASE  WHEN @TypeId=0 THEN 'HEAP'
	WHEN  @TypeId=1 THEN 'CLUSTERED'
	WHEN @TypeId>1 THEN 'NONCLUSTERED'
	END
END



DECLARE @return_value int;
print @IndexType
exec @return_value= can.MoveIndexToAnotherFileGroupCheck @DBName,@SchemaName,@ObjectName,@indexName,@FileGroupName,@IndexType,@Online

IF (@return_value = 0) 
BEGIN	
	RETURN 0; 
END
ELSE
BEGIN
	IF (@IndexType='HEAP')
	BEGIN
		print 'Heap Object'
		exec @return_value= can.MoveHeapTableToAnotherFileGroup @DBName,@SchemaName,@ObjectName,@indexName,@FileGroupName,@Online
	END
	ELSE
	BEGIN
		exec @return_value= can.MoveNonClusteredIndexToAnotherFileGroup @DBName,@SchemaName,@ObjectName,@indexName,@FileGroupName
	END
END
END



GO
