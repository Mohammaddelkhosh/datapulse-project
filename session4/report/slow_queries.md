# گزارش شناسایی و تحلیل کوئری‌های کند با pg_stat_statements
## ۱. مقدمه و هدف
هدف از این گزارش، شناسایی گلوگاه‌های عملکردی پایگاه داده در پروژه DataPulse با استفاده از افزونه قدرتمند `pg_stat_statements`، تحلیل پلن‌های اجرایی با `EXPLAIN (ANALYZE, BUFFERS)` و ارزیابی عملی راهکارهای بهینه‌سازی نظیر ایندکس‌گذاری و Materialized View است.

---

## ۲. پیکربندی و فعال‌سازی افزونه
جهت فعال‌سازی ماژول `pg_stat_statements`، پیکربندی زیر در تنظیمات PostgreSQL فعال گردید:
```sql
-- بررسی فعال بودن افزونه
SELECT extname, extversion FROM pg_extension WHERE extname = 'pg_stat_statements';
