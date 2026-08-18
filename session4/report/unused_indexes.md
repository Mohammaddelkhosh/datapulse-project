# گزارش بررسی و مدیریت ایندکس‌های بلااستفاده (Unused Indexes)

## ۱. کوئری استخراج ایندکس‌های بدون استفاده
از کاتالوگ سیستمی `pg_stat_user_indexes` برای بررسی تعداد دفعات اسکن ایندکس‌ها (`idx_scan`) استفاده شد:
```sql
SELECT 
schemaname,
relname AS table_name,
indexrelname AS index_name,
idx_scan,
pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
FROM 
pg_stat_user_indexes
JOIN 
pg_index USING (indexrelid)
WHERE 
indisunique IS FALSE 
AND indisprimary IS FALSE
ORDER BY 
idx_scan ASC, 
pg_relation_size(indexrelid) DESC;
