/*
Készíts lekérdezést, amely:

- ügyfelek teljes tranzakciós forgalmát számolja,
- régión belül rangsorolja őket,
- és jelenítse meg egymás mellett:
    - RANK()
    - DENSE_RANK()
    - ROW_NUMBER()

Az eredményt régiónként és forgalom szerint csökkenő sorrendben jelenítsd meg.
*/
with ugyfel_forgalom as (
    SELECT
        B.REGION as regio,
        C.CUSTOMER_NAME AS UGYFEL_neve,
        sum(f.amount) as forgalom,
        rank() over (partition by b.region order by sum(f.amount) desc) as rangsor,
        dense_rank() over (partition by b.region order by sum(f.amount) desc) as drank,
        ROW_NUMBER() over (partition by b.region order by sum(f.amount) desc) as r_num
    FROM
        DIM_CUSTOMER C
        INNER JOIN DIM_ACCOUNT      A ON C.CUSTOMER_ID = A.CUSTOMER_ID
        INNER JOIN FACT_TRANSACTION F ON A.ACCOUNT_ID = F.ACCOUNT_ID
        INNER JOIN DIM_BRANCH       B on B.BRANCH_ID = A.BRANCH_ID 
    group by b.region, C.CUSTOMER_NAME
)
select  ugyfel_neve, regio, forgalom, rangsor, drank, r_num
 from   ugyfel_forgalom uf
order   by regio, forgalom desc;

/*
Készíts lekérdezést, amely:

- hónaponként számolja az ügyfelek teljes tranzakciós forgalmát,
- régión belül rangsorolja őket forgalom alapján,
- és csak az adott hónap TOP 2 ügyfelét jelenítse meg régiónként.

Elvárt oszlopok:
    hónap, régió, ügyfél neve, havi forgalom, rangsor
*/

with rangsorolt_ugyfelek as (
select  b.region as regio,
        trunc(f.transaction_date, 'MM') as honap,
        c.customer_name as ugyfel, 
        sum(f.amount) as forgalom,
        rank() over(partition by trunc(f.transaction_date, 'MM'), b.region order by sum(f.amount) desc) as rangsor
  from  fact_transaction f
  inner join dim_account a on f.account_id = a.account_id
  inner join dim_customer c on a.customer_id = c.customer_id
  inner join dim_branch b on a.branch_id = b.branch_id
 group  by 
        b.region,
        trunc(f.transaction_date, 'MM'),
        c.customer_name
  )
select *
  from rangsorolt_ugyfelek
  where rangsor in (1,2)
  order by honap, regio, rangsor;

/*
Készíts lekérdezést, amely:
    - ügyfelenként,
    - hónaponként kiszámolja a teljes tranzakciós forgalmat,
    - megmutatja az előző havi forgalmat,
    - kiszámolja a havi változást,
    - valamint százalékos változást is számol.

Elvárt oszlopok:
    ügyfél neve, hónap, havi forgalom, előző havi forgalom, különbség, százalékos változás
*/
with ugyfel_eredmenyek as (
    select  c.customer_name as ugyfel, 
            trunc(f.transaction_date, 'MM') as honap,
            sum(f.amount) as forgalom,
            lag(sum(f.amount)) over (partition by c.customer_name order by trunc(f.transaction_date, 'MM')) as elozo_honap
      from  fact_transaction f
      inner join dim_account a on f.account_id = a.account_id
      inner join dim_customer c on a.customer_id = c.customer_id
     group  by 
            c.customer_name,
            trunc(f.transaction_date, 'MM')
) 
select  ugyfel,
        to_char(honap, 'YYYY-MM')                                                                               as honap,
        LPAD(to_char(forgalom, 'FM999,999,999') || ' Ft', 15, ' ')                                              as forgalom,
        LPAD(nvl2(elozo_honap, to_char(elozo_honap, 'FM999,999,999') || ' Ft', '-'), 15, ' ')                   as elozo_honap,
        LPAD(nvl2(elozo_honap, to_char(forgalom - elozo_honap, 'FM999,999,999') || ' Ft', '-'), 15, ' ')        as diff,
        LPAD(nvl2(elozo_honap, round(((forgalom - elozo_honap) / nullif(elozo_honap, 0)) * 100, 0)|| '%', '-'), 7, ' ')    as prc
  from  ugyfel_eredmenyek
  order by ugyfel, honap;
  