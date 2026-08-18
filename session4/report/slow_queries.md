# گزارش شناسایی و تحلیل کوئری‌های کند با pg_stat_statements

**پروژه:** DataPulse  
**دانشجو:** محمد عسگری دلخوش  
**موضوع:** بهینه‌سازی کوئری و مانیتورینگ عملکرد پایگاه داده (تمرین چهارم آزمایشگاه)

---

## ۱. هدف گزارش

هدف از این مستند، پیکربندی افزونه‌ی آماری `pg_stat_statements` بر روی کانتینر PostgreSQL، ثبت سوابق اجرای کوئری‌ها، استخراج پرهزینه‌ترین کوئری‌ها بر اساس زمان اجرا و ارائه‌ی راهکارهای فنی جهت ایندکس‌گذاری و بهینه‌سازی آن‌ها می‌باشد.

---

## ۲. پیکربندی و فعال‌سازی افزونه

جهت فعال‌سازی ماژول، ابتدا تنظیمات زیر در فایل `postgresql.conf` کانتینر اعمال شد:
```conf
shared_preload_libraries = 'pg_stat_statements'
pg_stat_statements.track = all



## ۳. فعال‌سازی و تایید افزونه
پس از اجرای دستور `CREATE EXTENSION pg_stat_statements;` در پایگاه داده مربوطه، افزونه فعال شد. برای تایید وضعیت اجرای کوئری‌ها، کوئری زیر روی ویوی `pg_stat_statements` اجرا گردید:
```sql
SELECT query, calls, total_exec_time, mean_exec_time
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 5;

۴. تحلیل کوئری‌های پرهزینه (Slow Queries)
با بررسی خروجی کوئری فوق، سه کوئری با بالاترین total_exec_time شناسایی شدند که نیاز به بهینه‌سازی دارند:

کوئری اول: جستجوی کامل روی لاگ‌های سیستم (Full Table Scan)
sql
SELECT * FROM system_logs WHERE status = 'ERROR' ORDER BY created_at DESC LIMIT 100;
مشکل: نبود ایندکس بر روی ستون status و created_at باعث شده که دیتابیس تمام جدول را پیمایش (Seq Scan) کند.
راهکار: ایجاد یک ایندکس ترکیبی (Composite Index).
کوئری دوم: محاسبات تجمیعی سنگین
sql
SELECT user_id, AVG(duration) FROM session_metrics GROUP BY user_id;
مشکل: محاسبه میانگین روی تمام رکوردهای جدول در زمان اجرا، فشار I/O بالایی ایجاد می‌کند.
راهکار: استفاده از Materialized View برای کش کردن نتایج محاسباتی.
۵. راهکارهای پیشنهادی و بهینه‌سازی (Optimization Strategies)
الف) بهینه‌سازی کوئری اول با ایندکس B-Tree
برای کوئری لاگ‌ها، ایندکس زیر پیشنهاد می‌شود تا عملیات Sort و Search بهینه شود:

sql
CREATE INDEX idx_logs_status_created_at ON system_logs (status, created_at DESC);
تحلیل: با این ایندکس، دیتابیس به جای Seq Scan از Index Scan استفاده کرده و مرتب‌سازی از پیش انجام شده است.
ب) بهینه‌سازی کوئری دوم با Materialized View
به دلیل اینکه نتایج session_metrics به صورت لحظه‌ای تغییر اساسی نمی‌کنند، از Materialized View استفاده می‌کنیم:

sql
CREATE MATERIALIZED VIEW mv_user_avg_duration AS
SELECT user_id, AVG(duration) as avg_duration
FROM session_metrics
GROUP BY user_id;

CREATE UNIQUE INDEX ON mv_user_avg_duration (user_id);
تحلیل: اکنون به جای اجرای کوئری سنگین، کوئری مستقیماً از ویوی آماده خوانده می‌شود. برای به‌روزرسانی نیز می‌توان از دستور REFRESH MATERIALIZED VIEW در بازه‌های زمانی مشخص استفاده کرد.
۶. نتیجه‌گیری
پیکربندی pg_stat_statements دید بسیار دقیقی از گلوگاه‌های دیتابیس به ما داد. با جایگزینی Full Table Scanها با Index Scan و استفاده از Materialized Viewها، انتظار می‌رود زمان اجرای کوئری‌های پرهزینه تا بیش از ۸۰٪ کاهش یابد.
