--task1
select c.first_name,c.last_name,sum(t.amount)
from customers c 
left join accounts a on c.customer_id=a.customer_id
left join transactions t on a.account_id=t.account_id
where c.customer_id=1001 and t.transaction_date >= add_months((select max(transaction_date) from transactions),-6)
group by c.first_name,c.last_name

--task2
select c.customer_id, c.first_name, sum(a.balance) as total_balans, sum(l.loan_amount) as total_amount
from customers c
left join accounts a on c.customer_id = a.customer_id
left join loans l on c.customer_id = l.customer_id
where c.status='ACTIVE'
group by c.customer_id, c.first_name;


--task3
select d.*,l.*
from deposits d
left join loans l on d.customer_id = l.customer_id
where d.end_date>sysdate

--task4
select
    c.first_name,
    c.last_name,
    a.customer_id,
    a.account_id,
    a.account_type,
    sum(t.amount) as total_mebleg
from customers c
left join accounts a on c.customer_id=a.customer_id
left join transactions t on a.account_id = t.account_id      
where a.date_opened >= add_months((select max(transaction_date) from transactions),-12)
group by c.first_name,c.last_name,a.customer_id,a.account_id,a.account_type;


--task5
select 
    c.first_name,
    c.last_name,
    a.customer_id,
    t.transaction_type,
    sum(t.amount) as total_mebleg
from customers c
left join accounts a on c.customer_id=a.customer_id
left join transactions t on a.account_id = t.account_id      
where a.date_opened >= add_months((select max(transaction_date) from transactions),-12)
group by c.first_name,c.last_name,a.customer_id,t.transaction_type;


--task6
select 
    customer_id,
    transaction_type,
    amount as max_amount
from (
    select 
        a.customer_id,
        t.transaction_type,
        t.amount,
        rank() over (partition by a.customer_id order by t.amount desc) as sira
from customers c
left join accounts a on c.customer_id=a.customer_id
left join transactions t on a.account_id = t.account_id  
    where 
        t.transaction_date >= add_months((select max(transaction_date) from transactions), -6)
) 
where sira = 1;

--task7
with ayliq as (
    select 
        c.customer_id,
        c.first_name,
        c.last_name,
        extract(year from t.transaction_date) as year,
        extract(month from t.transaction_date) as month,
        sum(t.amount) as total_balance,
        sum(d.deposit_amount) as total_deposit
    from customers c
    left join accounts a on c.customer_id = a.customer_id
    left join transactions t on a.account_id = t.account_id
    left join deposits d on c.customer_id = d.customer_id
    where t.transaction_date >= add_months((select max(transaction_date) from transactions),-12)  -- son 1 ili nəzərə al
    group by 
        c.customer_id,
        c.first_name,
        c.last_name,
        extract(year from t.transaction_date),
        extract(month from t.transaction_date)
)
select 
    customer_id,
    first_name,
    last_name,
    year,
    month,
    total_balance,
    total_deposit
from ayliq
order by customer_id, year, month;

--task8
with ayliq_cixaris as (
    select 
        c.customer_id,
        c.first_name,
        c.last_name,
        extract(year from t.transaction_date) as year,
        extract(month from t.transaction_date) as month,
        sum(t.amount) as total_balance,  -- ümumi balans (transaction-lardan)
        sum(d.deposit_amount) as deposit_balance -- depozit balansı
    from transactions t
    left join accounts a on t.account_id = a.account_id
    left join customers c on a.customer_id = c.customer_id
    left join deposits d on c.customer_id = d.customer_id
    where t.transaction_date >= add_months((select max(transaction_date) from transactions), -12)  -- son 1 il
    group by 
        c.customer_id,
        c.first_name,
        c.last_name,
        extract(year from t.transaction_date),
        extract(month from t.transaction_date)
)
select 
    customer_id,
    first_name,
    last_name,
    year,
    month,
    total_balance,
    deposit_balance
from ayliq_cixaris
order by customer_id, year, month;

--task9 
with address_balances as (
    select 
        ac.customer_id,
        ad.address_name,
        ad.type_id,
        extract(year from t.transaction_date) as year,
        extract(month from t.transaction_date) as month,
        sum(t.amount) as total_balance
    from customers c
    join accounts ac on c.customer_id = ac.customer_id
    join transactions t on ac.account_id = t.account_id
    join address ad on c.customer_id = ad.customer_id
    where t.transaction_date >= add_months((select max(transaction_date) from transactions), -3)  -- son 3 ay
    group by 
        ac.customer_id,
        ad.address_name,
        ad.type_id,
        extract(year from t.transaction_date),
        extract(month from t.transaction_date)
)
select 
    c.first_name,
    c.last_name,
    ab.address_name,
    ab.type_id,
    ab.year,
    ab.month,
    ab.total_balance
from addressbalances ab
join customers c on ab.customer_id = c.customer_id
order by c.customer_id, ab.year, ab.month, ab.type_id;

--task11
select 
    c.first_name,
    c.last_name,
    trunc(t.transaction_date) as transaction_date,
    count(*) as transaction_sayi
from 
    customers c
left join accounts a on c.customer_id = a.customer_id
left join transactions t on a.account_id = t.account_id
where 
    t.transaction_date >= add_months((select max(transaction_date) from transactions), -12)  -- Son 1 il
group by 
    c.first_name, 
    c.last_name, 
    trunc(t.transaction_date)  -- Hər gün üzrə qruplaşdırma
order by 
    c.first_name, c.last_name desc;


--task12
select c.*,l.loan_amount
from customers c 
left join loans l on c.customer_id=l.customer_id
where l.start_date >= add_months((select max(start_date) from loans),-6) and l.loan_amount=(select max(loan_amount) from loans)


--task13
with deyisim as (
    select 
        a.customer_id,
        extract(year from t.transaction_date) as year,
        extract(month from t.transaction_date) as month,
        sum(t.amount) as total_balance_change
    from transactions t
    left join accounts a on t.account_id = a.account_id
    where t.transaction_date >= add_months((select max(start_date) from loans),-12)
    group by 
        a.customer_id,
        extract(year from t.transaction_date),
        extract(month from t.transaction_date)
),max_deyisim as (
    select 
        customer_id,
        year,
        month,
        total_balance_change,
        row_number() over (partition by customer_id order by total_balance_change desc) as rn
    from deyisim
)
select 
    c.first_name, c.last_name, m.year, m.month, m.total_balance_change
from max_deyisim m 
left join customers c on m.customer_id = c.customer_id
where m.rn = 1
order by c.customer_id, m.year, m.month;

--task14
with say as (
    select 
        a.customer_id,
        t.transaction_type,
        count(*) as transaction_sayi, 
        row_number() over (partition by a.customer_id order by count(*) desc) as rn
    from transactions t
    join accounts a on t.account_id = a.account_id
    where t.transaction_date >= add_months(sysdate, -12)
    group by a.customer_id, t.transaction_type
)
select 
    c.first_name, 
    c.last_name, 
    s.transaction_type, 
    s.transaction_sayi
from say s
join customers c on c.customer_id = s.customer_id
where s.rn = 1
order by c.customer_id;


--task15
select 
    c.first_name,
    c.last_name,
    l.loan_id,
    l.loan_type,
    l.loan_amount,
    l.interest_rate,
    l.start_date,
    l.end_date,
    (l.end_date - l.start_date) as gun_ferqi
from loans l
left join customers c on l.customer_id = c.customer_id
where (l.end_date - l.start_date) = (
    select max(l2.end_date - l2.start_date) from loans l2 where l2.customer_id = l.customer_id
)

--task16
with balans as (
    select 
        c.customer_id,
        c.first_name,
        c.last_name,
        a.account_id,
        -- balansı sadəcə əməliyyatların cəmindən hesablayırıq
        sum(t.amount) as monthly_balance,
        extract(year from t.transaction_date) as year,
        extract(month from t.transaction_date) as month,
        row_number() over (partition by c.customer_id, extract(year from t.transaction_date), extract(month from t.transaction_date)
        order by sum(t.amount) desc
        ) as rn
    from accounts a
    join customers c on a.customer_id = c.customer_id
    join transactions t on a.account_id = t.account_id
    where t.transaction_date >= add_months((select max(transaction_date) from transactions), -12)  -- son 1 il
    group by 
        c.customer_id,
        c.first_name,
        c.last_name,
        a.account_id,
        extract(year from t.transaction_date),
        extract(month from t.transaction_date)
)
select 
    first_name,
    last_name,
    account_id,
    monthly_balance,
    year,
    month
from balans
where rn = 1  -- yalnız ən yüksək balansı olan hesabı seçirik
order by customer_id, year, month;



















