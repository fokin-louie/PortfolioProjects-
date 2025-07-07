 --adding new column for suspicious customers   
  alter table ECG_NsawamDistrict_BillingData
  add Suspicious_Customers varchar(50)

  update ECG_NsawamDistrict_BillingData
  set Suspicious_Customers = 'investigate'
  where Consumption_kWh = 0 and Connection_Status = 'active'

  select *
  from ECG_NsawamDistrict_BillingData

  update ECG_NsawamDistrict_BillingData
  set suspicious_customers = 'OK'
  where suspicious_customers is null


  --Top 20 customers with highest unpaid balances
  select top 20 Customer_ID, Tariff_Type, Meter_Type, sum(Billed_Amount) as Amount_Billed, sum(Paid_Amount) as Amount_Paid, sum(Loss) as total_loss
  from ECG_NsawamDistrict_BillingData
  group by Customer_ID, Tariff_Type, Meter_Type
  order by total_loss desc

  --total consumption, total billed amount, total paid amount, and total loss per Month, ordered from highest consumption to lowest
  select Month,sum(Consumption_kWh) as Total_Consumption_In_Kwh, sum(Billed_Amount) as Amount_Billed, sum(Paid_Amount) as Amount_Paid, sum(Loss) as Total_Loss
  from ECG_NsawamDistrict_BillingData
  group by Month
  order by Total_Consumption_In_Kwh

  -- compare Prepaid and Postpaid meter types
  select Meter_Type,count(distinct Customer_ID) as NumberofCustomers  , sum(Billed_Amount) as Amount_Billed, sum(Paid_Amount) as Amount_Paid, sum(Loss) as Total_Loss,
  (sum(paid_amount)/sum(Billed_Amount))*100 as Collection_rate
  from ECG_NsawamDistrict_BillingData
  group by Meter_Type
 
 -- compare different tariff_types
   select Tariff_Type,count(Distinct Customer_ID) as NumberofCustomers , sum(Consumption_kWh) as Total_Consumption_In_Kwh, sum(Billed_Amount) as Amount_Billed, sum(Paid_Amount) as Amount_Paid, sum(Loss) as Total_Loss,
 sum(Loss)/count(distinct Customer_ID) as AvgLossPerCustomer
  from ECG_NsawamDistrict_BillingData
  group by Tariff_Type


  --Zero-Usage Customers Flagged for Investigation (By Meter Type)
  select Meter_Type,Tariff_Type, count (distinct customer_id)as NumberofCustomers,
  suspicious_customers
  from ECG_NsawamDistrict_BillingData
  where suspicious_customers = 'investigate'
  group by Meter_Type,Tariff_Type,suspicious_customers

 --Monthly Collection Rate Trend orered by month
   select Month,count(distinct Customer_ID) as NumberofCustomers , sum(Billed_Amount) as Amount_Billed, sum(Paid_Amount) as Amount_Paid, sum(Loss) as Total_Loss,
  (sum(paid_amount)/sum(Billed_Amount))*100 as Collection_rate
  from ECG_NsawamDistrict_BillingData
  group by Month
  order by
  CASE Month
    WHEN 'Jan' THEN 1
    WHEN 'Feb' THEN 2
    WHEN 'Mar' THEN 3
    WHEN 'Apr' THEN 4
    WHEN 'May' THEN 5
    WHEN 'Jun' THEN 6
    WHEN 'Jul' THEN 7
    WHEN 'Aug' THEN 8
    WHEN 'Sep' THEN 9
    WHEN 'Oct' THEN 10
    WHEN 'Nov' THEN 11
    WHEN 'Dec' THEN 12
  END;


  select *
  from ECG_NsawamDistrict_BillingData
