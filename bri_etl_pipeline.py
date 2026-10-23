import pandas as pd
from sqlalchemy import create_engine

# ==========================================
# KONFIGURASI KONEKSI DATABASE POSTGRESQL
# ==========================================
DB_USER = "postgres"
DB_PASS = "admin"  # Ganti dengan password PostgreSQL Anda jika ada
DB_HOST = "localhost"
DB_PORT = "5432"
DB_NAME = "db_bri_portfolio"

# Membuat engine koneksi SQLAlchemy
connection_string = f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
engine = create_engine(connection_string)

print("--- MEMULAI PROSES EXTRACT & LOAD KE STAGING ---")

try:
    # ------------------------------------------
    # 1. EXTRACT: Membaca file CSV dari folder lokal
    # ------------------------------------------
    df_brimo = pd.read_csv('raw_brimo_txns_20261023.csv')
    df_qris = pd.read_csv('raw_qris_merchants_20261023.csv')
    
    print(f"[EXTRACT] Berhasil membaca {len(df_brimo)} baris data BRIMO dari CSV.")
    print(f"[EXTRACT] Berhasil membaca {len(df_qris)} baris data QRIS dari CSV.")

    # ------------------------------------------
    # 2. LOAD: Memasukkan data mentah ke PostgreSQL
    # ------------------------------------------
    # Data dimuat ke schema 'bri_dw' ke dalam tabel Staging
    df_brimo.to_sql('stg_brimo_txns', engine, schema='bri_dw', if_exists='replace', index=False)
    df_qris.to_sql('stg_qris_txns', engine, schema='bri_dw', if_exists='replace', index=False)
    
    print("[LOAD] Berhasil! Seluruh data mentah berhasil dimuat ke tabel Staging PostgreSQL.")

except Exception as e:
    print(f"[ERROR] Terjadi kesalahan: {e}")