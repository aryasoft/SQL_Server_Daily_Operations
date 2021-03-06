IF OBJECT_ID('FilegroupFreeSpace', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[FilegroupFreeSpace]
END

GO
/*
Usage
--only shows the result under 10 percent free space in the filegroup
exec [dbo].[FilegroupFreeSpace] 10,1,0 

--write out log on your error log with filegroup name, database name and free percentage value
exec [dbo].[FilegroupFreeSpace] 20,0,1 

*/

CREATE PROCEDURE [dbo].[FilegroupFreeSpace](
@Threashold int = 10, --threashold default: 10%
@ShowMe bit =0, --show the result on result pane default: disabled
@WriteLog bit =1 --writing out the log default: enabled
)
AS
BEGIN
	--adding necessary message template
	IF NOT EXISTS(select * from sys.sysmessages where error=75006)
	BEGIN
		EXEC sp_addmessage @msgnum = 75006, @severity = 1,   
		   @msgtext = N'"%s" Filegroup has %s percent free space in %s.',   
		   @lang = 'us_english';  
	END

IF OBJECT_ID('tempdb..#ALL_DB_Files') IS NOT NULL
  DROP TABLE #ALL_DB_Files; 

DECLARE @DbName nvarchar(200), @FreeSpacePercent decimal(18,2), @FileGroupName varchar(100), @PercentStr varchar(10);

CREATE TABLE #ALL_DB_Files (
dbname SYSNAME,
[FileGroupName] nvarchar(200),
[spaceused] BIGINT NOT NULL,
fileid smallint,
groupid smallint,
[size] BIGINT NOT NULL,
[maxsize] INT NOT NULL,
growth INT NOT NULL,
status INT,
perf INT,
[name] SYSNAME NOT NULL,
[filename] NVARCHAR(260) NOT NULL
)
EXEC sp_MsForEachDB 'use [?];Insert into #ALL_DB_Files select db_name(),b.groupname,FILEPROPERTY([name], ''spaceused'') as Spaceused,  a.* from sysfiles a INNER JOIN sys.sysfilegroups b ON a.groupid=b.groupid'
 

 IF (@ShowMe=1)
BEGIN
	select  
	dbname,
	FileGroupName,
	SUM(size)*CONVERT(FLOAT,8) / 1024.0 as totalsizeMB
	,SUM(spaceused)*CONVERT(FLOAT,8) / 1024.0 as usedsize
	,(SUM(size)-SUM(spaceused))/cast(SUM(size) as decimal(18,2))*100 as PercentFreePerByGroup
	,count(1) as FileCountInTheFileGroup
	from #ALL_DB_Files
	where dbname <>'tempdb'
	group by dbname,FileGroupName
	having ((SUM(size)-SUM(spaceused))/cast(SUM(size) as decimal(18,2))*100)<@Threashold
	order by 5





	SELECT  DISTINCT
	dovs.volume_mount_point AS Drive,
	CONVERT(INT,dovs.available_bytes/1048576.0) AS FreeSpaceInMB
	FROM sys.master_files mf
	CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.file_id) dovs
	ORDER BY 1 ASC
END



IF(@WriteLog=1)
BEGIN
	--loop through all rows
	WHILE EXISTS(SELECT NULL FROM #ALL_DB_Files 
									where dbname<>'tempdb' 
									group by dbname,FileGroupName
									having ((SUM(size)-SUM(spaceused))/cast(SUM(size) as decimal(18,2))*100)<@Threashold)
	BEGIN
	
		--work through each database
		SELECT TOP 1
			@DbName = dbname,
			@FreeSpacePercent = (SUM(size)-SUM(spaceused))/cast(SUM(size) as decimal(18,2))*100,
			@FileGroupName = FileGroupName
		FROM #ALL_DB_Files
			where dbname <>'tempdb'
			group by dbname,FileGroupName
			having ((SUM(size)-SUM(spaceused))/cast(SUM(size) as decimal(18,2))*100)<@Threashold

			set @PercentStr= cast(@FreeSpacePercent as varchar(10));

		--if we have databases that have reached our threshold, then we raise the alert
		RAISERROR  (75006, 10,1,@FileGroupName,@PercentStr,@DbName) WITH LOG;

		--remove the processed entry
		DELETE FROM #ALL_DB_Files WHERE dbname = @DbName;

	END
END

END