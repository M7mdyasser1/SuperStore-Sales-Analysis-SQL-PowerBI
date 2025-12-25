  


EXEC sp_help Sales_Data;


--------------------------------------------------------------------------
-- 1. تصحيح نوع بيانات المبيعات (Sales)
ALTER TABLE Sales_Data 
			ALTER COLUMN Sales DECIMAL(10, 2);

-- 2. تصحيح نوع بيانات الربح (Profit)
ALTER TABLE Sales_Data 
			ALTER COLUMN Profit DECIMAL(10, 2); 

-- 3. تصحيح نوع بيانات الخصم (Discount)
ALTER TABLE Sales_Data
			ALTER COLUMN Discount DECIMAL(5, 2); 
-- (5, 2) مناسب لأن الخصم غالباً نسبة مئوية أو قيمة صغيرة.
-------------------------------------------------------------------------------
-- استبدال القيم الفارغة بالصفر في الأعمدة المالية والكمية
UPDATE Sales_Data
SET Sales = ISNULL(Sales, 0),
    Profit = ISNULL(Profit, 0),
    Quantity = ISNULL(Quantity, 0);
--------------------------------------------------------------------------------
-- استبدال القيم الفارغة بـ 'Unknown' في الأعمدة النصية
UPDATE Sales_Data
SET Region = ISNULL(Region, 'Unknown'),
    Customer_ID = ISNULL(Customer_ID, 'N/A')
    -- يمكنك تطبيق هذا على أي عمود نصي آخر مهم للتحليل
WHERE Region IS NULL OR Customer_ID IS NULL;
---------------------------------------------------------------------------------
UPDATE Sales_Data
    SET
        -- 1. الأرقام: استبدال NULL بـ 0
        Sales = ISNULL(Sales, 0),
        Profit = ISNULL(Profit, 0),
        Discount = ISNULL(Discount, 0),
        Quantity = ISNULL(Quantity, 0),
        Row_ID = ISNULL(Row_ID, 0),
        
        -- 2. النصوص: استبدال NULL بـ 'Unknown' أو 'N/A'
        Order_ID = ISNULL(Order_ID, 'N/A'),
        Ship_Mode = ISNULL(Ship_Mode, 'Unknown'),
        Customer_ID = ISNULL(Customer_ID, 'N/A'),
        Customer_Name = ISNULL(Customer_Name, 'Unknown'),
        Segment = ISNULL(Segment, 'Unknown'),
        Country = ISNULL(Country, 'Unknown'),
        City = ISNULL(City, 'Unknown'),
        State = ISNULL(State, 'Unknown'),
        Region = ISNULL(Region, 'Unknown'),
        Product_ID = ISNULL(Product_ID, 'N/A'),
        Category = ISNULL(Category, 'Unknown'),
        Sub_Category = ISNULL(Sub_Category, 'Unknown'),
        Product_Name = ISNULL(Product_Name, 'Unknown');
-----------------------------------------------------------------------------
-- أ. تصحيح المقاييس المالية (Float -> DECIMAL) وفرض NOT NULL
    ALTER TABLE Sales_Data ALTER COLUMN Sales DECIMAL(10, 2) NOT NULL;
    ALTER TABLE Sales_Data ALTER COLUMN Profit DECIMAL(10, 2) NOT NULL;
    ALTER TABLE Sales_Data ALTER COLUMN Discount DECIMAL(5, 2) NOT NULL;
    
    -- ب. الرمز البريدي: تحويله إلى نص (NVARCHAR) وفرض NOT NULL
    -- يجب التعامل مع أي NULLs متبقية هنا قبل تغيير النوع:
    UPDATE Sales_Data SET Postal_Code = 0 WHERE Postal_Code IS NULL; -- تصحيح إضافي
    ALTER TABLE Sales_Data ALTER COLUMN Postal_Code NVARCHAR(100) NOT NULL;

    -- ج. فرض NOT NULL على الأعمدة الرقمية والتواريخ الأخرى
    ALTER TABLE Sales_Data ALTER COLUMN Row_ID smallint NOT NULL;
    ALTER TABLE Sales_Data ALTER COLUMN Quantity tinyint NOT NULL;
    ALTER TABLE Sales_Data ALTER COLUMN Order_Date date NOT NULL;
    ALTER TABLE Sales_Data ALTER COLUMN Ship_Date date NOT NULL;

    -- د. فرض NOT NULL على جميع الأعمدة النصية الأخرى
    ALTER TABLE Sales_Data ALTER COLUMN Order_ID nvarchar(100) NOT NULL;
    ALTER TABLE Sales_Data ALTER COLUMN Ship_Mode nvarchar(100) NOT NULL;
    ALTER TABLE Sales_Data ALTER COLUMN Customer_ID nvarchar(100) NOT NULL;
    ALTER TABLE Sales_Data ALTER COLUMN Customer_Name nvarchar(100) NOT NULL;
    ALTER TABLE Sales_Data ALTER COLUMN Segment nvarchar(100) NOT NULL;
    ALTER TABLE Sales_Data ALTER COLUMN Country nvarchar(100) NOT NULL;
    ALTER TABLE Sales_Data ALTER COLUMN City nvarchar(100) NOT NULL;
    ALTER TABLE Sales_Data ALTER COLUMN State nvarchar(100) NOT NULL;
    ALTER TABLE Sales_Data ALTER COLUMN Region nvarchar(100) NOT NULL;
    ALTER TABLE Sales_Data ALTER COLUMN Product_ID nvarchar(100) NOT NULL;
    ALTER TABLE Sales_Data ALTER COLUMN Category nvarchar(100) NOT NULL;
    ALTER TABLE Sales_Data ALTER COLUMN Sub_Category nvarchar(100) NOT NULL;
    ALTER TABLE Sales_Data ALTER COLUMN Product_Name nvarchar(300) NOT NULL;
----------------------------------------------------------------------------------------
SELECT
    Row_ID, 
    Order_ID, 
    Order_Date, 
    Ship_Date, 
    Ship_Mode, 
    Customer_ID, 
    Product_ID,
    Postal_Code,
    Sales, 
    Quantity, 
    Discount, 
    Profit
INTO
    FactSales
FROM 
    Sales_Data;
-----------------------------------------------------------------------------------------
-- إنشاء جدول المنتجات (dProduct)
SELECT DISTINCT
    Product_ID,
    Product_Name,
    Category,
    Sub_Category
INTO 
    Dim_Product  -- هذا ينشئ جدولًا جديدًا باسم dProduct
FROM
    Sales_Data;
---------------------------------------------------------------------
-- إنشاء جدول الجغرافيا (dGeography)
SELECT DISTINCT
    Postal_Code,
    Country,
    City,
    State,
    Region
INTO 
    Dim_Geography  -- هذا ينشئ جدولًا جديدًا باسم dGeography
FROM
    Sales_Data;
----------------------------------------------------------------------------
-- إنشاء جدول العملاء (dCustomer)
SELECT DISTINCT
    Customer_ID,      -- هذا هو المفتاح الرئيسي للربط
    Customer_Name,
    Segment
INTO 
    Dim_Customer  -- هذا ينشئ جدولًا جديدًا باسم dCustomer
FROM
    Sales_Data;