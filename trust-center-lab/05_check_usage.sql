-- 付録用：30分ワークショップ本編では実行不要。APPENDIX.mdの手順に従う。
-- Trust Centerワークショップ / 05_check_usage.sql
-- このファイルを1回の実行単位として使用する。
-- UTCの当日から6日前以降のTrust Center使用クレジットを確認（当日は途中経過）。
USE ROLE LAB_TRUST_CENTER_USAGE_VIEWER;
USE WAREHOUSE SNOWFLAKE_LEARNING_WH;
-- 日付の基準をUTCに統一。変更はこのSQLセッション内で後続のSQLにも適用される。
ALTER SESSION SET TIMEZONE = 'UTC';
-- 02・03で準備した費用確認専用ロールを使用。
-- ウェアハウスのUSAGEは02で付与。使用量の反映には最大3時間かかる。
SELECT
    USAGE_DATE,
    CREDITS_USED
FROM SNOWFLAKE.ACCOUNT_USAGE.METERING_DAILY_HISTORY
WHERE SERVICE_TYPE = 'TRUST_CENTER'
  AND USAGE_DATE >= DATEADD('day', -6, CURRENT_DATE())
ORDER BY USAGE_DATE;
-- クレジット消費量であり、通貨換算の請求額ではない。
