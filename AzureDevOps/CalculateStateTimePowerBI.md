# Calculate State Time

This article provides a series of recipes using DAX calculations to evaluate time spent by work items in any combination of states. Specifically, you'll learn how to add the following calculated columns and one measure and use them to generate various trend charts.

## Add State Sort Order

By default, Power BI will show states sorted alphabetically in a visualization. This can be misleading when you want to visualize time in state and `New` state shows up after `Active` state.

To resolve this issue, we will create a new calculated column for states and assign the order as per our requirement. Follow below steps to create a new column for states.

1. To add the `State Sort Order` calculated column, from the `Modeling` tab, choose `New Column`.
2. Replace the default text with the following code.
```
  State Sort Order = 
  SWITCH ( 
        '<ViewName>'[State], 
          "New", 1, 
          "Active", 2, 
          "Resolved", 3, 
          "Closed", 4, 
          "Removed",5, 
          6
      )
```
3. Update your desired states in above peice of code and click the checkmark.
4. From the `Modeling` tab, choose `Sort by Column` and then select the `State Sort Order field`.

## Add Date Previous
The next step for calculating time-in-state requires mapping the previous interval (day, week, month) for each row of data in the dataset.

To add the `Date Previous` calculated column, from the `Modeling` tab, choose `New Column` and then replace the default text with the following code and click the checkmark.
```
  Date Previous = 
  CALCULATE (
      MAX ( '<ViewName>'[Date] ),
      ALLEXCEPT ( '<ViewName>', '<ViewName>'[Work Item Id] ),
      '<ViewName>'[Date] < EARLIER ( '<ViewName>'[Date] )
  )
```

## Add Date Diff in Days
Date Previous calculates the difference between the previous and current date for each row. With Date Diff in Days, we'll calculate a count of days between each of those periods. For most rows in a daily snapshot, the value will equal 1. However, for many work items which have gaps in the dataset, the value will be larger than 1.

It is important to consider the first day of the dataset where Date Previous is blank. In this example we give that row a standard value of 1 to keep the calculation consistent.

From the `Modeling` tab, choose `New Column` and then replace the default text with the following code and click the checkmark.
```
  Date Diff in Days = 
  IF (
      ISBLANK ( '<ViewName>'[Date Previous] ),
      1,
      DATEDIFF (
            '<ViewName>'[Date Previous],
            '<ViewName>'[Date],
              DAY
      )
  )
```


## Add Is Last Day in State
In this next step, we calculate if a given row represents the last day a specific work item was in a state. This supports default aggregations in Power BI with the next column we'll add, the State Time in Days.

From the `Modeling` tab, choose `New Column` and then replace the default text with the following code and click the checkmark.
```
Is Last Day in State = 
ISBLANK (CALCULATE (
  COUNTROWS ( MyStories ),
    ALLEXCEPT ( 'MyStories', 'MyStories'[Work Item Id] ),
    'MyStories'[Date] > EARLIER ( 'MyStories'[Date] ),
    'MyStories'[State] = EARLIER ( 'MyStories'[State] )
))
```

## Add New State Time
In this next step, we will calculate the number of days spend by a work item in `New` State.

From the `Modeling` tab, choose `New Column` and then replace the default text with the following code and click the checkmark.
```
New State Time = 
  CALCULATE (
    SUM ( 'MyStories'[Date Diff in Days] ),
      ALLEXCEPT ( 'MyStories', 'MyStories'[Work Item Id] ),
      'MyStories'[Date] <= EARLIER('MyStories'[Date]),
      'MyStories'[State] = "New"
) + 0
```

