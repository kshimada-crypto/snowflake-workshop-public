-- 付録用：30分ワークショップ本編では実行不要。APPENDIX.mdの手順に従う。
-- Trust Centerワークショップ / 03_grant_roles.sql
-- このファイルを1回の実行単位として使用する。
-- 現在のセッションのユーザーに付与（ユーザー名の書き換えは不要）
USE ROLE SECURITYADMIN;
-- 大文字・小文字や特殊文字を含むユーザー名も識別子として扱えるよう引用する。
SET lab_current_user = (SELECT '"' || REPLACE(CURRENT_USER(), '"', '""') || '"');
-- 各自のTrialで3つのロールを自分に付与し、Snowsight側で切り替えて比較。
GRANT ROLE LAB_TRUST_CENTER_VIEWER TO USER IDENTIFIER($lab_current_user);
GRANT ROLE LAB_TRUST_CENTER_ADMIN TO USER IDENTIFIER($lab_current_user);
GRANT ROLE LAB_TRUST_CENTER_USAGE_VIEWER TO USER IDENTIFIER($lab_current_user);
UNSET lab_current_user;
