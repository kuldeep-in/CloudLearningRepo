## BCP Commands to inport export data

```
bcp "dbo.WorkItem" FORMAT nul -f "D:bcp1\WorkItem.xml" -x -S ".\SQL2016" -d "db1" -U "sa" -P "Password" -m 1 -C -w
bcp "dbo.WorkItemTranslation" FORMAT nul -f "D:bcp1\WorkItemTranslation.xml" -x -S ".\SQL2016" -d "db1" -U "sa" -P "Password" -m 1 -C -w

bcp "dbo.WorkItem" out "D:\bcp1\WorkItem.dat" -f "D:\bcp1\WorkItem.xml" -S ".\SQL2016" -d "db1" -U "sa" -P "Password"  
bcp "dbo.WorkItemTranslation" out "D:\bcp1\WorkItemTranslation.dat" -f "D:\bcp1\WorkItemTranslation.xml" -S ".\SQL2016" -d "db1" -U "sa" -P "Password"  

bcp "dbo.WorkItem" IN "D:\bcp1\WorkItem.dat"  -S ".\SQL2016" -d "db2" -U "sa" -P "Password" -f "D:\bcp1\WorkItem.xml" –h “CHECK_CONSTRAINTS” 
bcp "dbo.WorkItemTranslation" IN "D:\bcp1\WorkItemTranslation.dat"  -S ".\SQL2016" -d "db2" -U "sa" -P "Password" -f "D:\bcp1\WorkItemTranslation.xml" –h “CHECK_CONSTRAINTS” 
```
