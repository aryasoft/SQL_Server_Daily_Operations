<h1>Usage:</h1>

<h2>Parameters:</h2>
@Threashold int = 10, --threashold default: 10%
@ShowMe bit =0, --show the result on result pane default: disabled
@WriteLog bit =1 --writing out the log default: enabled

exec [dbo].[FilegroupFreeSpace] 10,1,0 
--only shows the result under 10 percent free space in the filegroup


exec [dbo].[FilegroupFreeSpace] 20,0,1 
--write out log on your error log with filegroup name, database name and free percentage value

