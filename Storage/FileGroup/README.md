<h1>Usage:</h1>

--only shows the result under 10 percent free space in the filegroup
exec [dbo].[FilegroupFreeSpace] 10,1,0 

--write out log on your error log with filegroup name, database name and free percentage value
exec [dbo].[FilegroupFreeSpace] 20,0,1 

