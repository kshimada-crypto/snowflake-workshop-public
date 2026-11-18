-- 付録用：30分ワークショップ本編では実行不要。APPENDIX.mdの手順に従う。
-- 演習前のDEFAULT_SECONDARY_ROLESが["ALL"]だった場合だけ実行する。
-- 元が[]なら復元不要。その他の値は記録した設定に合わせて戻す。
-- ユーザー名の書き換えは不要。
SET lab_current_user = (SELECT '"' || REPLACE(CURRENT_USER(), '"', '""') || '"');
ALTER USER IDENTIFIER($lab_current_user) SET DEFAULT_SECONDARY_ROLES = ('ALL');
DESCRIBE USER IDENTIFIER($lab_current_user)
  ->> SELECT "property", "value"
      FROM $1
      WHERE "property" = 'DEFAULT_SECONDARY_ROLES';
UNSET lab_current_user;
-- Snowsightからサインアウトし、再ログインする。
