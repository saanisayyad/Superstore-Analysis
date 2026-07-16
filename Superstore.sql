create database superstore;
use superstore;
desc orders;

select * 
from orders 
limit 10;

-- COUNT OF RECORDS
select count(*)
from orders;

-- TOTAL SALES
select round(sum(sales), 2) as TotalSales
from orders;

-- TOTAL PROFIT
select round(sum(profit), 2) as TotalProfit
from orders;

-- TOTAL ORDERS
select count(distinct `Order Id`) as TotalOrders
from orders;

-- TOTAL CUSTOMERS
select count(distinct `Customer Id`) as TotalCustomers
from orders;

-- AVERAGE ORDER VALUE
select round(sum(sales) / count(distinct `Order Id`), 2) as AverageOrderValue
from orders;

-- SALES BY CATEGORY
select Category,
		round(sum(sales), 2) as Revenue
from orders
group by Category
order by Revenue desc;

-- SALES BY SUB-CATEGORY
select `Sub-Category`,
		round(sum(sales), 2) as Revenue
from orders
group by `Sub-Category`
order by Revenue desc;

-- SALES BY REGION
select Region,
		round(sum(sales), 2) as Revenue
from orders
group by Region
order by Revenue desc;

-- TOP 10 PRODUCTS BY REVENUE
select `Product Name`,
		round(sum(sales), 2) as Revenue
from orders
group by `Product Name`
order by Revenue desc
limit 10;

-- MOST PROFITABLE CATEGORIES
select Category,
		round(sum(profit), 2) as Profit
from orders
group by Category
order by Profit desc;

-- MOST PROFITABLE PRODUCTS
select `Product Name`,
		round(sum(profit), 2) as Profit
from orders
group by `Product Name`
order by Profit desc
limit 10;

-- LOSS MAKING PRODUCTS
select `Product Name`,
		round(sum(profit), 2) as Profit
from orders
group by `Product Name`
having Profit < 0
order by Profit;

-- TOP 10 CUSTOMERS
select `Customer Name`,
		round(sum(sales), 2) as Revenue
from orders
group by `Customer Name`
order by Revenue desc
limit 10;

-- MOST PROFITABLE CUSTOMERS
select `Customer Name`,
		round(sum(profit), 2) as Profit
from orders
group by `Customer Name`
order by Profit desc
limit 10;

-- REPEAT CUSTOMERS
select `Customer Name`,
		count(distinct `Order Id`) as OrdersCount
from orders
group by `Customer Name`
having OrdersCount > 1
order by OrdersCount desc;

-- MONTHLY REVENUE
select year(str_to_date(`Order Date`, '%d-%m-%Y')) as Year,
		month(str_to_date(`Order Date`, '%d-%m-%Y')) as Month,
		round(sum(sales), 2) as Revenue
from orders
group by Year, Month
order by Year, Month;

-- MONTHLY PROFIT
select year(str_to_date(`Order Date`, '%d-%m-%Y')) as Year,
		month(str_to_date(`Order Date`, '%d-%m-%Y')) as Month,
		round(sum(profit), 2) as Profit
from orders
group by Year, Month
order by Year, Month;

-- RANK CUSTOMERS BY REVENUE
select `Customer Name`,
		sum(sales) as Revenue,
        rank() over(order by sum(sales) desc) as RevenueRank
from orders
group by `Customer Name`;

-- TOP PRODUCT IN EACH CATEGORY
with ProductSales as (
	select Category,
			`Product Name`,
            sum(sales) as Revenue,
            rank() over(partition by Category 
						order by sum(sales) desc) as rnk
from orders
group by Category, `Product Name`
)
select *
from ProductSales
where rnk = 1;

-- REVENUE CONTRIBUTION
select Category,
		round(
			sum(sales) * 100 /
            (select sum(sales) from orders)
        ) as PercentRevenue
from orders
group by Category;

-- CUSTOMER LIFETIME VALUE
select `Customer Name`,
		round(sum(sales), 2) as CLV
from orders
group by `Customer Name`
order by CLV desc;

-- Top 20% Customers Generating Revenue
with CustomerRevenue as(
	select `Customer Name`,
			sum(sales) as Revenue
	from orders
    group by `Customer Name`
),

RevenueRanked as(
	select `Customer Name`,
			Revenue,
            sum(Revenue) over (order by Revenue desc) as RunningRevenue,
            sum(Revenue) over () as TotalRevenue
	from CustomerRevenue
)

select `Customer Name`,
		Revenue,
		round(RunningRevenue * 100 / TotalRevenue, 2) as CumulativeRevenuePercent
from RevenueRanked
where RunningRevenue <= TotalRevenue * 0.20
order by Revenue desc;