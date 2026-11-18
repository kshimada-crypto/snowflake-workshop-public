-- 接続先・ユーザー・SQLセッションのロールを確認（Snowsight画面のロールも別途確認）
SELECT CURRENT_ACCOUNT(), CURRENT_USER(), CURRENT_ROLE();
