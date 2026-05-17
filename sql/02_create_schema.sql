-- Séma létrehozása
-- - Táblák
-- - Szekvenciák
CREATE TABLE dim_customer (
    customer_id       NUMBER PRIMARY KEY,
    customer_name     VARCHAR2(100) NOT NULL,
    city              VARCHAR2(50),
    customer_segment  VARCHAR2(30),
    risk_category     VARCHAR2(30)
);

CREATE TABLE dim_branch (
    branch_id    NUMBER PRIMARY KEY,
    branch_name  VARCHAR2(100) NOT NULL,
    city         VARCHAR2(50),
    region       VARCHAR2(50)
);

CREATE TABLE dim_account (
    account_id    NUMBER PRIMARY KEY,
    customer_id   NUMBER NOT NULL,
    branch_id     NUMBER NOT NULL,
    account_type  VARCHAR2(50),
    opened_date   DATE,

    CONSTRAINT fk_account_customer
        FOREIGN KEY (customer_id)
        REFERENCES dim_customer(customer_id),

    CONSTRAINT fk_account_branch
        FOREIGN KEY (branch_id)
        REFERENCES dim_branch(branch_id)
);

CREATE TABLE fact_transaction (
    transaction_id    NUMBER PRIMARY KEY,
    account_id        NUMBER NOT NULL,
    transaction_date  DATE NOT NULL,
    transaction_type  VARCHAR2(50),
    amount            NUMBER(12,2),

    CONSTRAINT fk_transaction_account
        FOREIGN KEY (account_id)
        REFERENCES dim_account(account_id)
);

-- Napló tábla
create table npl_fact_transaction (
    log_id                NUMBER primary key,
    log_date              DATE default sysdate not null,
    operation_type        VARCHAR2(10) NOT NULL,
    transaction_id        NUMBER,
    old_account_id        NUMBER,
    new_account_id        NUMBER,
    old_transaction_date  DATE,
    new_transaction_date  DATE,
    old_transaction_type  VARCHAR2(50),
    new_transaction_type  VARCHAR2(50),
    old_amount            NUMBER(12,2),
    new_amount            NUMBER(12,2),
    changed_by            VARCHAR2(100),
    client_identifier     VARCHAR2(100)
)
partition by range (log_date) interval (NUMTOYMINTERVAL(1, 'MONTH'))
(
    PARTITION p_2024_01 VALUES LESS THAN (DATE '2024-02-01')
);

-- szekvenciák
CREATE SEQUENCE seq_customer_id START WITH 11 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_branch_id START WITH 11 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_account_id START WITH 111 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_transaction_id START WITH 21 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_npl_fact_transaction START WITH 1 INCREMENT BY 1 NOCACHE;