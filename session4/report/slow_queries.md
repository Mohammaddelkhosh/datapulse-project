# گزارش شناسایی و تحلیل کوئری‌های کند با pg_stat_statements
## ۱. مقدمه و هدف
هدف از این گزارش، شناسایی گلوگاه‌های عملکردی پایگاه داده در پروژه DataPulse با استفاده از افزونه قدرتمند `pg_stat_statements`، تحلیل خروجی‌های `EXPLAIN ANALYZE` و ارائه راهکارهای مهندسی جهت بهینه‌سازی کوئری‌های پرهزینه است.

---

## ۲. پیکربندی و فعال‌سازی افزونه
جهت فعال‌سازی ماژول `pg_stat_statements`، تنظیمات زیر در فایل `postgresql.conf` کانتینر داکر اعمال شد:
```conf
shared_preload_libraries = 'pg_stat_statements'
pg_stat_statements.track = all
