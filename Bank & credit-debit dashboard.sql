use bank_loan_analytics;

### KPI
# 1) TOTAL LOAN AMT FUNDED
select concat(round(sum(funded_amount)/1000000,1),"M") as total_loan_amt_funded from bank_data;

# 2) TOTAL NO OF LOANS
SELECT distinct concat(round(count(loan_status)/1000,1),"k") AS NO_OF_LOANS FROM BANK_DATA;

# 3) TOTAL INTEREST AMOUNT
SELECT CONCAT(ROUND(SUM(TOTAL_RREC_INT)/1000000,1),"M") AS TOTAL_INTEREST FROM BANK_DATA;

# 4) TOTAL COLLECTION AMT
SELECT CONCAT(ROUND(SUM(TOTAL_RREC_INT) + SUM(TOTAL_REC_LATE_FEE) + 
SUM(TOTAL_FEES) + SUM(TOTAL_REC_PRNCP))/1000000,1),"M"
 AS TOTAL_COLLECTION FROM BANK_DATA;
 
 # 5) TOTAL DELINQUENT LOAN
 SELECT CONCAT(ROUND(COUNT(IS_DELINQUENT_LOAN)/1000,1),"K") AS TOTAL_DELINQUENT_LOAN
 FROM BANK_DATA WHERE IS_DELINQUENT_LOAN="Y" ;
 
 # 6) TOTAL DEFAULT LOAN
 SELECT CONCAT(ROUND(COUNT(IS_DEFAULT_LOAN)/1000,1),"K") AS TOTAL_DEFAULT_LOAN
 FROM BANK_DATA WHERE IS_DEFAULT_LOAN="Y" ;
 
 # 7) TOTAL VERIFIED LOANS
 SELECT CONCAT(ROUND(COUNT(VERIFICATION_STATUS)/1000,1),"K") AS VERIFIED_LOANS
 FROM BANK_DATA WHERE VERIFICATION_STATUS="VERIFIED" ;
 
  # 8) NON-VERIFIED LOANS
 SELECT CONCAT(ROUND(COUNT(VERIFICATION_STATUS)/1000,1),"K") AS NON_VERIFIED_LOANS
 FROM BANK_DATA WHERE VERIFICATION_STATUS="NOT VERIFIED" ; 
 
 ## BRANCH WISE PERFORMANCE
 
 SELECT BRANCH_NAME, CONCAT(ROUND(SUM(FUNDED_AMOUNT)/1000000,1),"M") AS FUNDED_AMT ,
 CONCAT(ROUND(SUM(TOTAL_RREC_INT)/1000000,1),"M") AS INTEREST, 
 CONCAT(ROUND(SUM(TOTAL_FEES)/1000,1),"K") AS FEE FROM BANK_DATA
 GROUP BY 1 ORDER BY 1 ;
 
 
 
 
 ## STATE WISE LOAN
 
 SELECT STATE_NAME, CONCAT(ROUND(SUM(LOAN_AMOUNT)/1000000,0),"M" ) AS LOAN_AMT 
 FROM BANK_DATA GROUP BY 1 ORDER BY LOAN_AMT DESC;
 
 ## RELIGION WISE LOAN\
 
  SELECT RELIGION, CONCAT(ROUND(SUM(LOAN_AMOUNT)/1000000,0),"M" ) AS LOAN_AMT 
 FROM BANK_DATA GROUP BY 1 ORDER BY 1;
 
 ## PRODUCT-GROUP WISE LOAN
 
 SELECT PURPOSE_CATEGORY, CONCAT(ROUND(SUM(LOAN_AMOUNT)/1000000,0),"M") AS LOAN_AMT
 FROM BANK_DATA GROUP BY 1 ORDER BY 1;
 
 ## YEAR WISE LOAN DISBURSEMENT 
 
  SELECT YEAR, CONCAT(ROUND(SUM(LOAN_AMOUNT)/1000000,0),"M" ) AS LOAN_AMT 
 FROM BANK_DATA GROUP BY 1 ORDER BY 1 ;
 
 ## GRADE WISE LOAN
 
  SELECT GRADE, CONCAT(ROUND(SUM(LOAN_AMOUNT)/1000000,0),"M" ) AS LOAN_AMT 
 FROM BANK_DATA GROUP BY 1 ORDER BY 1;
 
 ## LOAN STATUS WISE LOAN
 
  SELECT LOAN_STATUS, CONCAT(ROUND(SUM(LOAN_AMOUNT)/1000000,0),"M" ) AS LOAN_AMT 
 FROM BANK_DATA GROUP BY 1 ;
 
 ## AGE GROUP WISE LOAN
 
  SELECT AGE, CONCAT(ROUND(SUM(LOAN_AMOUNT)/1000000,0),"M" ) AS LOAN_AMT 
 FROM BANK_DATA GROUP BY 1 ORDER BY 1;
 
 ##  AVERAGE INT RATE FOR SPECIFIC TERM
 
 SELECT  TERM , CONCAT(ROUND(AVG(INT_RATE) * 100,2),"%") AS INTEREST FROM BANK_DATA GROUP BY 1;
 
 ## RISKY LOAN AMOUNR
 
 SELECT RISK,CONCAT(ROUND(SUM(LOAN_AMOUNT)/1000000,0),"M") AS LOAN_AMT FROM BANK_DATA GROUP BY 1;
 
 
 
 # HERE I HAVE CREATED STORE PROCEDURE FOR  WHICH IS HELPFUL TO GET  DATA IN ONE GO
 
 ## 1) FOR PARTICULAR STATE DEATILS
 call state_data("punjab");
 
 ## 2) for particular branch details
 call GetBranchDetails("Mathura");
 
 
 
 ### CREDIT & DEBIT DASHBOARD
 
 
 ### KPI
 
 # 1) TOTAL CREDIT AMOUNT
 
select concat(round(sum(amount)/1000000,1),"M") as credit_amt from data WHERE TRANSACTION_TYPE="CREDIT";

# 2) TOTAL DEBIT AMOUNT

select concat(round(sum(amount)/1000000,1),"M") as credit_amt from data WHERE TRANSACTION_TYPE="DEBIT";

# 3) TOTAL BALANCE

select concat(round(sum(BALANCE)/1000000,1),"M") as TOTAL_BALANCE from data;

# 4) NET TRANSACTION AMOUNT

select concat(round((sum(case when transaction_type="credit" then amount else 0 end) -
sum(case when transaction_type="debit" then amount else 0 end))/1000000,2),"M") as net_transaction_amt from data;
 
 # 5) ACCOUNT ACTIVITY RATIO
 
 select (count(transaction_type) / sum(balance)) as acc_activity_ratio from data;
 
 # 6) CREDIT & DBEIT RATIO
 
 select sum(case when transaction_type ="credit" then amount else 0 end) /
 sum(case when transaction_type ="debit" then amount else 0 end) as credit_debit_ratio from data;
 
 
 ### TRANSACTION PER DAY/WEEK/MONTH
 set sql_safe_updates =0;
 
 describe data;
 
 UPDATE data
SET transaction_date = STR_TO_DATE(transaction_date, '%d-%m-%Y');

 ALTER TABLE data 
MODIFY transaction_date DATE;

 
 SELECT 
    DATE(Transaction_Date) AS Day,
    COUNT(*) AS Transactions_Per_Day
FROM data
GROUP BY DATE(Transaction_Date)
ORDER BY Day;

SELECT 
    week(Transaction_Date) AS week ,
    COUNT(*) AS Transactions_Per_week
FROM data
GROUP BY week(Transaction_Date)
ORDER BY week;

select month_name,count(transaction_type) as transaction_per_month from data group by 1;


### TRANSACTION AMOUNT BY BANK

select bank_name,concat(round(sum(amount)/1000000,1),"M") as transaction_amt from data group by 1; 

## OR

call GetBankDetails("HDFC BANK");

### TRANSACTION AMOUNT & COUNT BY BRANCH

select branch,CONCAT(ROUND(count(transaction_type)/1000,1),"K") as count_of_transaction,
concat(round(sum(amount)/1000000,1),"M") as transaction_amt from data group by 1 order by 3 desc; 

### TRANSACTION METHOD DISTRIBUTION

select transaction_method,
concat(round(count(transaction_type)/1000,1),"K") as count_of_transaction,
concat(round(sum(amount)/1000000,1),"M") as transaction_amt from data group by 1; 

### RISKY TRANSACTION 

select transaction_flag,
concat(round(count(transaction_type)/1000,1),"K") as count_of_transaction,
concat(round(sum(amount)/1000000,1),"M") as transaction_amt from data group by 1; 

### SUSPICIOUS TRANSACTIOS

select
 month_name,
transaction_flag,
concat(round(count(transaction_type)/1000,1),"K") as count_of_transaction,
concat(round(sum(amount)/1000000,1),"M") as transaction_amt
 from data group by 1,2 order by  2; 