<h1>Usage:</h1>

<h2>Parameters:</h2>

<p>
@Threashold int = 10, --threashold default: 10%<br/>
@ShowMe bit =0, --show the result on result pane default: disabled<br/>
@WriteLog bit =1 --writing out the log default: enabled<br/>
</p>
<br/>
<p>This scripts runs against all databases on your server also system databases as well. Sample output showing below<br/>
database name | file group name | free space percentage</p>
<p>
exec [dbo].[FilegroupFreeSpace] 10,1,0 <br/>
--Shows the result under 10 percent free spaces on result pane
</p>
<br/>
<p>
exec [dbo].[FilegroupFreeSpace] 20,0,1 <br/>
--write out log on your error log with filegroup name, database name and free percentage value<br/>
--you can see the result on your sql server error log under the management tab
</p>
