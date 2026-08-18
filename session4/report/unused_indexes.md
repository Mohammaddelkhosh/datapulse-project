# گزارش بهینه‌سازی دیتابیس: شناسایی و حذف ایندکس‌های بلااستفاده (Unused Indexes)

- **پروژه:** DataPulse Behavior Analytics
- **پایگاه داده:** PostgreSQL 16 (Containerized via Docker)
- **مسئول گزارش:** محمد عسگری دلخوش

---

## ۱. هدف گزارش
ایندکس‌ها با وجود افزایش سرعت عملیات `SELECT`، در زمان اجرای دستورات نوشتن (`INSERT` ،`UPDATE` ،`DELETE`) بار پردازشی اضافی (Overhead) و اشغال فضای دیسک ایجاد می‌کنند. هدف از این تحلیل، پایش وضعیت ایندکس‌های سیستم با استفاده از کاتالوگ‌های آماری PostgreSQL و حذف ایندکس‌های بدون استفاده و افزونه (Redundant) است.

---

## ۲. کوئری استخراج وضعیت مصرف ایندکس‌ها
از کاتالوگ سیستمی `pg_stat_user_indexes` و ترکیب آن با `pg_index` جهت بررسی تعداد دفعات اسکن ایندکس (`idx_scan`)، بدون اعمال روی کلیدهای اصلی (PK) یا شروط یکتایی (Unique)، استفاده شد:
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
