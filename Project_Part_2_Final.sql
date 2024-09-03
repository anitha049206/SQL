#--------------------------------------------------------------------------------------------------------
#-- 7. Write a query to display carton id, (len*width*height) as carton_vol and identify the
#--    optimum carton (carton with the least volume whose volume is greater than the total
#--    volume of all items (len * width * height * product_quantity)) for a given order whose order
#--    id is 10006, Assume all items of an order are packed into one single carton (box). 
#--------------------------------------------------------------------------------------------------------

select CARTON_ID, min(len*width*height) as CARTON_VOL from carton
where (len*width*height) >=
(select sum(product.len*product.height*product.width*order_items.product_quantity)
from product 
inner join order_items on product.product_id= order_items.product_id
where order_id = 10006
group by order_id);

#--------------------------------------------------------------------------------------------------------
#-- 8. Write a query to display details (customer id,customer fullname,order id,product
#--    quantity) of customers who bought more than ten (i.e. total order qty) products per shipped order.
#--------------------------------------------------------------------------------------------------------

select  order_header.CUSTOMER_ID, online_customer.CUSTOMER_FNAME,order_header.ORDER_ID,sum(order_items.PRODUCT_QUANTITY) as TOTAL_QUANTITY
from order_header
inner join order_items on order_header.order_id = order_items.order_id
inner join online_customer on online_customer.CUSTOMER_ID = order_header.customer_id
where order_header.ORDER_STATUS = "Shipped"
group by order_header.order_id
having TOTAL_QUANTITY > 10
ORDER BY order_header.customer_id;

#-------------------------------------------------------------------------------------------------------
#-- 9.  Write a query to display the order_id, customer id and cutomer full name of customers
#--     along with (product_quantity) as total quantity of products shipped for order ids > 10060. 
#-------------------------------------------------------------------------------------------------------

select  order_header.ORDER_ID,order_header.CUSTOMER_ID, concat( online_customer.CUSTOMER_FNAME," ", 
online_customer.customer_lname) as CUSTOMER_NAME
,sum(order_items.PRODUCT_QUANTITY) as TOTAL_QUANTITY
from order_header
inner join order_items on order_header.order_id = order_items.order_id
inner join online_customer on online_customer.CUSTOMER_ID = order_header.customer_id
where order_header.ORDER_STATUS = "Shipped" AND order_header.ORDER_ID > 10060
group by order_header.order_id
ORDER BY order_header.order_id;

#---------------------------------------------------------------------------------------------------------
#-- 10.  Write a query to display product class description ,total quantity
#--      (sum(product_quantity),Total value (product_quantity * product price) and show which class
#--      of products have been shipped highest(Quantity) to countries outside India other than USA?
#--      Also show the total value of those items.
#---------------------------------------------------------------------------------------------------------

SELECT tableB.COUNTRY,  tableB.CLASS_DESCRIPTION, tableB.TOTAL_QUANTITY, tableB.TOTAL_VALUE
FROM
(
select sum(tableA.tot_qty) AS TOTAL_QUANTITY,sum(tableA.tot_val) AS TOTAL_VALUE,tableA.PRODUCT_CLASS_CODE AS CLASS_CODE,tableA.COUNTRY,product_class.PRODUCT_CLASS_DESC AS CLASS_DESCRIPTION
from
(
select order_header.order_id,order_items.PRODUCT_ID,sum(order_items.PRODUCT_QUANTITY) as TOT_QTY, address.COUNTRY, 
sum(order_items.PRODUCT_QUANTITY)*product.PRODUCT_PRICE as  TOT_VAL, product.PRODUCT_CLASS_CODE
from order_items
inner join order_header on order_header.order_id = order_items.order_id
inner join product on product.PRODUCT_ID = order_items.product_id
inner join online_customer on online_customer.CUSTOMER_ID = order_header.CUSTOMER_ID
inner join address on address.address_id = online_customer.ADDRESS_ID
where order_header.ORDER_STATUS = "Shipped" and address.country not in ("USA","India")
group by order_items.PRODUCT_ID
) tableA
inner join product_class on tableA.PRODUCT_CLASS_CODE = product_class.PRODUCT_CLASS_CODE
group by tableA.country,tableA.PRODUCT_CLASS_CODE
) tableB
ORDER BY tableB.TOTAL_QUANTITY DESC LIMIT 1;