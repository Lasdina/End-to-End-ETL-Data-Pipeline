-- Membuat Schema khusus untuk project Data Warehouse
CREATE SCHEMA IF NOT EXISTS bri_dw;

-- ==========================================
-- A. STAGING TABLES (Menampung mentah dari CSV)
-- ==========================================
CREATE TABLE IF NOT EXISTS bri_dw.stg_brimo_txns (
    txn_id VARCHAR(50),
    account_number VARCHAR(50),
    customer_name VARCHAR(100),
    txn_type VARCHAR(50),
    amount NUMERIC(15, 2),
    status VARCHAR(20),
    txn_timestamp TIMESTAMP
);

CREATE TABLE IF NOT EXISTS bri_dw.stg_qris_txns (
    qris_txn_id VARCHAR(50),
    merchant_id VARCHAR(50),
    merchant_name VARCHAR(100),
    customer_account VARCHAR(50),
    amount NUMERIC(15, 2),
    mdr_fee NUMERIC(15, 2),
    terminal_id VARCHAR(50),
    status VARCHAR(20),
    txn_timestamp TIMESTAMP
);

-- ==========================================
-- B. DIMENSION & FACT TABLES (Star Schema DW)
-- ==========================================
-- Tabel Dimensi Nasabah (Dengan PII Masking)
CREATE TABLE IF NOT EXISTS bri_dw.dim_customer (
    customer_key SERIAL PRIMARY KEY,
    account_number VARCHAR(50) UNIQUE,
    masked_account_number VARCHAR(50),
    customer_name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Dimensi Merchant / Agen
CREATE TABLE IF NOT EXISTS bri_dw.dim_merchant (
    merchant_key SERIAL PRIMARY KEY,
    merchant_id VARCHAR(50) UNIQUE,
    merchant_name VARCHAR(100),
    terminal_id VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Fakta Transaksi Gabungan (BRIMO & QRIS)
CREATE TABLE IF NOT EXISTS bri_dw.fact_transactions (
    fact_txn_id SERIAL PRIMARY KEY,
    source_channel VARCHAR(20), -- 'BRIMO' atau 'QRIS'
    transaction_id VARCHAR(50),
    customer_key INT REFERENCES bri_dw.dim_customer(customer_key),
    merchant_key INT REFERENCES bri_dw.dim_merchant(merchant_key),
    amount NUMERIC(15, 2),
    fee_amount NUMERIC(15, 2) DEFAULT 0,
    status VARCHAR(20),
    txn_timestamp TIMESTAMP,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


--Untuk melihat username PostgreSQL yang sedang Anda pakai
select current_user;