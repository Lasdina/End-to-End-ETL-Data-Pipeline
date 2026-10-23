CREATE OR REPLACE PROCEDURE bri_dw.sp_process_daily_etl()
LANGUAGE plpgsql
AS $$
BEGIN
    -- 1. TRANSFORM & LOAD: Mengisi Dimensi Nasabah + PII Masking
    INSERT INTO bri_dw.dim_customer (account_number, masked_account_number, customer_name)
    SELECT DISTINCT 
        account_number::VARCHAR,
        LEFT(account_number::VARCHAR, 4) || '-XXXX-' || RIGHT(account_number::VARCHAR, 4) AS masked_account_number,
        customer_name
    FROM bri_dw.stg_brimo_txns
    ON CONFLICT (account_number) DO NOTHING;

    INSERT INTO bri_dw.dim_customer (account_number, masked_account_number, customer_name)
    SELECT DISTINCT 
        customer_account::VARCHAR,
        LEFT(customer_account::VARCHAR, 4) || '-XXXX-' || RIGHT(customer_account::VARCHAR, 4) AS masked_account_number,
        'QRIS Customer' AS customer_name
    FROM bri_dw.stg_qris_txns
    ON CONFLICT (account_number) DO NOTHING;

    -- 2. TRANSFORM & LOAD: Mengisi Dimensi Merchant QRIS
    INSERT INTO bri_dw.dim_merchant (merchant_id, merchant_name, terminal_id)
    SELECT DISTINCT merchant_id::VARCHAR, merchant_name, terminal_id
    FROM bri_dw.stg_qris_txns
    ON CONFLICT (merchant_id) DO NOTHING;

    -- 3. LOAD FACT: Memasukkan Transaksi BRIMO (Haja status SUCCESS + Cast Timestamp)
    INSERT INTO bri_dw.fact_transactions (source_channel, transaction_id, customer_key, merchant_key, amount, fee_amount, status, txn_timestamp)
    SELECT 
        'BRIMO',
        s.txn_id::VARCHAR,
        c.customer_key,
        NULL,
        s.amount,
        0.00,
        s.status::VARCHAR,
        s.txn_timestamp::TIMESTAMP
    FROM bri_dw.stg_brimo_txns s
    JOIN bri_dw.dim_customer c ON s.account_number::VARCHAR = c.account_number
    WHERE s.status = 'SUCCESS';

    -- 4. LOAD FACT: Memasukkan Transaksi QRIS (Hanya status SUCCESS + Cast Timestamp)
    INSERT INTO bri_dw.fact_transactions (source_channel, transaction_id, customer_key, merchant_key, amount, fee_amount, status, txn_timestamp)
    SELECT 
        'QRIS',
        s.qris_txn_id::VARCHAR,
        c.customer_key,
        m.merchant_key,
        s.amount,
        s.mdr_fee,
        s.status::VARCHAR,
        s.txn_timestamp::TIMESTAMP
    FROM bri_dw.stg_qris_txns s
    JOIN bri_dw.dim_customer c ON s.customer_account::VARCHAR = c.account_number
    JOIN bri_dw.dim_merchant m ON s.merchant_id::VARCHAR = m.merchant_id
    WHERE s.status = 'SUCCESS';

    RAISE NOTICE 'Stored Procedure ETL berhasil dieksekusi dengan bersih!';
END;
$$;

--perintah pemanggilnya
CALL bri_dw.sp_process_daily_etl();


-- 1. Melihat ringkasan transaksi di Data Warehouse berdasarkan channel
SELECT source_channel, COUNT(*) AS total_transaksi, SUM(amount) AS total_volume 
FROM bri_dw.fact_transactions 
GROUP BY source_channel;

-- 2. Memeriksa hasil PII Masking pada data nasabah
SELECT * FROM bri_dw.dim_customer LIMIT 5;