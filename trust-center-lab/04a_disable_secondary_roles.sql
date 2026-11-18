-- 付録用：30分ワークショップ本編では実行不要。APPENDIX.mdの手順に従う。
-- 権限比較の前に、自分のユーザーの既定セカンダリロールを無効化する。
-- 先にDESCRIBEの結果を確認・記録してから、ALTER以降を実行する。
-- ユーザー名の書き換えは不要。
SET lab_current_user = (SELECT '"' || REPLACE(CURRENT_USER(), '"', '""') || '"');
DESCRIBE USER IDENTIFIER($lab_current_user)
  ->> SELECT "property", "value"
      FROM $1
      WHERE "property" = 'DEFAULT_SECONDARY_ROLES';

ALTER USER IDENTIFIER($lab_current_user) SET DEFAULT_SECONDARY_ROLES = ();
USE SECONDARY ROLES NONE;
DESCRIBE USER IDENTIFIER($lab_current_user)
  ->> SELECT "property", "value"
      FROM $1
      WHERE "property" = 'DEFAULT_SECONDARY_ROLES';
UNSET lab_current_user;
-- Snowsightからサインアウトし、再ログインしてから画面のロールを比較する。
