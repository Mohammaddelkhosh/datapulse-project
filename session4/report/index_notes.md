# \# Database Indexing Report (Session 4)

# 

# \## 1. Overview

# The `orders` table contains columns such as `order\_id`, `customer\_id`, `amount`, and `order\_date`, storing approximately 10,000 records.

# 

# \## 2. Created Indexes

# \- \*\*`idx\_orders\_customer\_id`\*\*: Created for fast filtering by customer ID.

# \- \*\*`idx\_orders\_customer\_date`\*\*: Compound index created for queries filtering by both customer ID and order date.

# 

# \## 3. EXPLAIN ANALYZE Analysis

# \- Filtering by `customer\_id` utilizes \*\*Bitmap Index Scan / Index Scan\*\* instead of sequential scan.

# \- Execution time and scanned row counts decreased significantly.

# 

