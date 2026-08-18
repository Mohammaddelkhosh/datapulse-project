# Session 5 - Exercise 4: OLTP vs OLAP Comparison

## Objective
Compare the performance of the same analytical query executed on the operational table `public.orders`
and on the analytical star schema composed of `analytics.fact_sales` and `analytics.dim_date`.

## Implementation
Two equivalent monthly aggregation queries were executed:

- OLTP query on `public.orders`
- OLAP query on `analytics.fact_sales` joined with `analytics.dim_date`

The following metrics were measured:

- execution time
- row count
- monthly aggregation correctness

## Results

- OLTP execution time: **56.492 ms**
- OLAP execution time: **40.268 ms**
- Performance improvement: **28.72% faster in OLAP**

## Validation
The monthly aggregated results of both approaches were compared using a FULL OUTER JOIN.
All rows were validated successfully and the `validation_status` column returned `MATCH` for every month.

## Conclusion
The OLAP star schema provided better performance for analytical aggregation than querying the operational table directly.
This confirms the benefit of separating transactional and analytical workloads.
