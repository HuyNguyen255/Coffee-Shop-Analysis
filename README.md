# Coffee Shop Analysis (Phân tích tình hình kinh doanh của quán Cà phê) ☕

## Introduction (Giới Thiệu) 📚

Nhằm mục đích để phân tích 📊 dữ liệu tổng quan về hoạt động kinh doanh của quán từ đó giúp có được 🔎 cái nhìn tổng quan cũng như ra quyết định chiến lược, kế hoạch cho việc 📈 phát triển của quán

## Problems (Vấn đề) ⁉️
### Những vấn đề (yêu cầu) 🔍 về việc phân tích hoạt động kinh doanh của quán:

1. Tính tổng doanh số cho từng tháng tương ứng.
2. Xác định mức chênh lệch doanh số so với tháng trước đó.
3. Xác định mức tăng hoặc giảm doanh số theo tháng.
4. Tính tổng số lượng đơn Order cho từng tháng tương ứng.
5. Xác định mức chênh lệch lượng đơn Order so với tháng trước đo.
6. Xác định mức tăng hoặc giảm lượng đơn Order theo tháng.
7. Tính tổng sản lượng bán được cho từng tháng.
8. Xác định mức chênh lệch sản lượng.
9. Xác định mức tăng hoặc giảm sản lượng bán được.

## Tool I Used (Những công cụ sử dụng trong bài phân tích này) 🛠️

- **SQL Server:** Dùng để truy vấn (query)
  
- **Power BI:** Trực quan hóa những truy vấn thành bảng biểu, biểu đồ
  
- **Github:** Đăng các truy vấn, file dữ liệu cũng như file trực quan hóa dữ liệu để chia sẻ cho mọi người và bài phân tích của cá nhân tôi. Để mọi người có thể tham khảo cũng như đóng góp ý kiến cho tôi.

## The Analysis (Phân tích) 📈

1. Tính tổng doanh số cho từng tháng tương ứng
```sql
SELECT
  MONTH,
  FORMAT(SUM(Revenue),'C') Total_Revenue
FROM sales
GROUP BY Month, DATEPART(month,transaction_date)
ORDER BY DATEPART(month,transaction_date) asc
```
2. Xác định mức chênh lệch doanh số so với tháng trước đó

```sql
WITH Table1 as   # Tạo một table đầu tiên với cột tháng (giá trị tháng bằng số)
  (SELECT
    Month,
    SUM(revenue) Revenue,
    DATEPART(month,transaction_date) Month_num
  FROM Sales
GROUP BY month, DATEPART(month,transaction_date))
------
SELECT
  Month,
  # Tính sự chệnh lệch nếu là % thì sau trừ rồi chia cho tháng trước đó
  ISNULL(FORMAT((Revenue - Previous_qty),'N0'),0) AS Difference 
FROM 
  (SELECT 
    Month,
    Revenue,
    LAG(Revenue) OVER (ORDER BY Month_Num) Previous_qty
FROM Table1) AS Table2   # Tạo thêm một bảng phụ với cột và dùng hàm LAG() để lấy doanh thu của tháng trước đó
```

3. Xác định mức tăng hoặc giảm doanh số theo tháng

```sql
WITH table1 as
  (SELECT
    Month,
    SUM(revenue) Revenue,
    DATEPART(MONTH,transaction_date) Month_num
  FROM Sales
  GROUP BY month, DATEPART(MONTH,transaction_date))
-------
SELECT
  Month,
  Revenue,
  ISNULL(CAST(CAST(((Revenue - previous_month)/previous_month)*100 as DECIMAL(5,2)) as VARCHAR(5)), 0)+'%' Growth
FROM 
  (SELECT
    Month,
    Revenue,
    lag(Revenue) OVER (ORDER BY Month_num) Previous_month
  FROM table1) AS Table2;
```
4. Tính tổng số lượng đơn Order cho từng tháng tương ứng

```sql
SELECT
  Month,
  FORMAT(COUNT(transaction_id),'N0') Number_orders
FROM Sales 
GROUP BY Month, DATEPART(month, transaction_date)
ORDER BY datepart(month,transaction_date) asc
```

5. Xác định mức chênh lệch lượng đơn Order so với tháng trước đo

```sql
With table1 as 
  (SELECT
    Month,
    COUNT(transaction_id) Number_orders,
    DATEPART(month, transaction_date) Month_num
  FROM Sales
  GROUP BY Month, DATEPART(month, transaction_date))
---------
SELECT
  Month,
  ISNULL((Number_orders - Previous_orders),0) Difference 
FROM 
  (SELECT 
    Month,
    Number_orders, 
    LAG(Number_orders) OVER (ORDER BY (month_num)) Previous_orders
  FROM table1) AS Table2
```

6. Xác định mức tăng hoặc giảm lượng đơn Order theo tháng

```sql
WITH table1 as
  (SELECT
    Month,
    COUNT(transaction_id) Number_orders,
    DATEPART(MONTH,transaction_date) Month_num
  FROM sales
  GROUP BY month, DATEPART(month,transaction_date))
-----------
SELECT 
  Month,
  Number_orders,
  Previous_orders, 
  ISNULL(CAST(CAST((Number_orders - Previous_orders)/(CAST(Number_orders as float))*100 as DECIMAL(5,2)) as VARCHAR(5)),0)+'%' '%Change'
FROM 
  (SELECT 
    Month,
    Month_num, Number_orders,
    LAG(number_orders) OVER (ORDER BY month_num) Previous_orders
  FROM table1) as table2;
```
7. Tính tổng sản lượng bán được cho từng tháng

```sql
SELECT
  Month,
  FORMAT(SUM(transaction_qty),'N0') Quantity
FROM Sales 
GROUP BY Month, DATEPART(month, transaction_date)
ORDER BY datepart(month,transaction_date) asc
```

8. Xác định mức chênh lệch sản lượng.

```sql
With table1 as 
  (SELECT
    Month,
    SUM(transaction_qty) Quantity,
    DATEPART(month, transaction_date) Month_num
FROM Sales
GROUP BY Month, DATEPART(month, transaction_date))
---------
SELECT
  Month,
  ISNULL(FORMAT((Quantity - Previous_qty),'N0'),0) Difference 
FROM 
  (SELECT 
    Month,
    Quantity, 
    LAG(Quantity) OVER (ORDER BY (month_num)) Previous_qty
FROM table1) AS Table2
```

9. Xác định mức tăng hoặc giảm sản lượng bán được.

```sql
WITH table1 as
  (SELECT
    Month,
    SUM(transaction_qty) Quantity,
    DATEPART(MONTH,transaction_date) Month_num
FROM sales
GROUP BY month, DATEPART(month,transaction_date))
-----------
SELECT 
  Month,
  Quantity,
  ISNULL(Previous_qty,0) Previous_qty, 
  ISNULL(CAST(CAST((Quantity - Previous_qty)/(CAST(Quantity as float))*100 as DECIMAL(5,2)) as VARCHAR(5)),0)+'%' '%Change'
FROM 
  (SELECT 
    Month,
    Month_num,
    Quantity,
    LAG(Quantity) OVER (ORDER BY month_num) Previous_qty
FROM table1) as table2;
```
