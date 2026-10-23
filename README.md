# End-to-End-ETL-Data-Pipeline
etl-banking-pipeline
# 🏦 End-to-End Banking ETL Pipeline & Data Warehouse (BRIMO & QRIS Analytics)

## 📌 Project Overview
Proyek ini mensimulasikan sistem *End-to-End Data Engineering Pipeline* untuk institusi perbankan, mengambil studi kasus dari kanal transaksi digital **Bank BRI** (aplikasi **BRIMO** dan pembayaran merchant **QRIS**). Proyek ini dirancang untuk mengotomatisasi proses ekstraksi data transaksi harian mentah, membersihkan data sensitif (*PII Masking*), dan menyimpannya ke dalam arsitektur *Data Warehouse* berbasis **Star Schema** guna mendukung analitik bisnis dan pelaporan eksekutif.

---

## 🏗️ Architecture & Workflow
Arsitektur pipa data ini dibangun melalui beberapa tahapan utama:
1. **Extract**: Menarik data transaksi harian mentah berformat CSV dari sistem sumber (disimulasikan menggunakan skrip generator Python).
2. **Staging (Load Area)**: Memuat data mentah secara otomatis ke tabel *Staging* PostgreSQL (`stg_brimo_txns` & `stg_qris_txns`) menggunakan Python (`SQLAlchemy`).
3. **Transform & Security (PII Masking)**: Menggunakan **Stored Procedure (PL/pgSQL)** untuk menyaring transaksi sukses, mengenkripsi nomor rekening nasabah (*PII Masking*), serta melakukan transformasi tipe data.
4. **Load (Data Warehouse / Star Schema)**: Menyimpan hasil transformasi ke tabel Dimensi dan Tabel Fakta terpusat (`fact_transactions`, `dim_customer`, `dim_merchant`) secara akumulatif dan historis.

---

## 🛠️ Tech Stack & Tools
- **Programming Language**: Python (Pandas, NumPy, SQLAlchemy)
- **Database & DWH**: PostgreSQL
- **Database IDE**: DBeaver
- **Data Modeling**: Star Schema (Fact & Dimension Tables)
- **Automation**: PL/pgSQL Stored Procedures
