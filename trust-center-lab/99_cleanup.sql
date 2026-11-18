-- 付録用：30分ワークショップ本編では実行不要。APPENDIX.mdの手順に従う。
-- Trust Centerワークショップ / 99_cleanup.sql
-- このファイルを1回の実行単位として使用する。
-- 検証後、必要に応じて現在のセッションのユーザーへの付与を取り消す。
-- 自分の作業権限を取り消す場合、代わりの管理経路を確認してから実行。
USE ROLE SECURITYADMIN;
-- ユーザー名の書き換えは不要。大文字・小文字や特殊文字も保持する。
SET lab_current_user = (SELECT '"' || REPLACE(CURRENT_USER(), '"', '""') || '"');
REVOKE ROLE LAB_TRUST_CENTER_VIEWER FROM USER IDENTIFIER($lab_current_user);
REVOKE ROLE LAB_TRUST_CENTER_ADMIN FROM USER IDENTIFIER($lab_current_user);
REVOKE ROLE LAB_TRUST_CENTER_USAGE_VIEWER FROM USER IDENTIFIER($lab_current_user);
UNSET lab_current_user;
-- 作成したロールは削除しない。既存ロールだった場合の誤削除を避けるため。
