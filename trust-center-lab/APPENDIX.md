# Appendix：Trust Centerの追加演習

[30分ワークショップ本編へ戻る](./README.md)

この付録は開催時間外の自習・追加演習用。30分の本編では実施しない。
SQLファイルは既存の名前・配置を維持している。番号が続いていても、本編の01から99までを一括実行しない。
既存の全SQLは参加者による実行確認済み。今回の変更は教材の構成と用途を示すコメントで、SQLの処理は変更していない。

## A. 最小権限のロール設計と権限差の比較

本編は各自のTrialでACCOUNTADMINを使う。継続運用では用途別の専用ロールへ権限を分ける。
この追加演習では、ロール作成・付与と、VIEWER／ADMINの違いを確認する。

USERADMIN・SECURITYADMIN・ACCOUNTADMINを選択できることと、SNOWFLAKE_LEARNING_WHの存在を事前に確認する。
最初に[01_check_context.sql](./01_check_context.sql)で、操作するアカウントと自分のユーザーを確認する。
03・04a・98・99は現在のユーザーを自動取得するため、ユーザー名の書き換えは不要。

### A-1. 学習用ロールを準備

1. 各自のTrialアカウントで[02_create_roles.sql](./02_create_roles.sql)を実行する。
   ファイル内でUSERADMINに切り替えて次の3つのロールを作成し、ACCOUNTADMINに切り替えてアプリケーションロールと使用量閲覧用データベースロールを付与する。
   最後にSECURITYADMINで、費用確認専用ロールへSNOWFLAKE_LEARNING_WHのUSAGEを付与する。

2. 続いて [03_grant_roles.sql](./03_grant_roles.sql) を同じセッションで先頭から順に実行する。
   SECURITYADMINに切り替え、現在のセッションのユーザーを自動取得して3つのロールを自分に付与する。

3. [04_check_grants.sql](./04_check_grants.sql) を実行し、各SHOW文の結果を次の確認項目と照合する。

| 学習用アカウントロール | 付与するアプリケーション／データベースロール | 用途 |
|---|---|---|
| LAB_TRUST_CENTER_VIEWER | SNOWFLAKE.TRUST_CENTER_VIEWER | 結果の閲覧 |
| LAB_TRUST_CENTER_ADMIN | SNOWFLAKE.TRUST_CENTER_ADMIN | スキャナー・指摘の管理 |
| LAB_TRUST_CENTER_USAGE_VIEWER | SNOWFLAKE.USAGE_VIEWER | 使用量の閲覧（Trust Center以外の使用量も閲覧可能） |

**04の結果で確認すること：**

- `SHOW GRANTS TO ROLE`：各学習用ロールに、上の表にあるアプリケーション／データベースロールが付与されていることを確認する。
- `SHOW GRANTS OF ROLE`：各学習用ロールの付与先に、自分のユーザー名が表示されていることを確認する。

SHOW文ごとに結果を表示して確認する。最後のSHOW文の結果だけで、すべての付与を確認したと判断しない。

### A-2. セカンダリロールを無効化して再ログイン

同じユーザーにVIEWERとADMINの両方を付与しているため、セカンダリロールが有効だと、VIEWERを選択してもADMINの権限が併用されることがある。
画面で権限差を比べる前に、自分のユーザーのログイン時の既定設定を一時的に変更する。

1. [04a_disable_secondary_roles.sql](./04a_disable_secondary_roles.sql)を開き、最初のSETと、続くDESCRIBEからWHERE末尾のセミコロンまでを実行する。
2. 結果には`DEFAULT_SECONDARY_ROLES`の1行だけが表示される。
   `value`列の元の値を、再ログイン後も参照できる手元のメモに記録する。
3. 同じワークシート・セッションで、残りのALTER以降を実行する。
   最後のDESCRIBEで`DEFAULT_SECONDARY_ROLES`の値が`[]`になったことを確認する。
4. Snowsightのユーザーメニューからサインアウトし、同じユーザーで再ログインする。
   ブラウザーの再読み込みだけで済ませない。

この変更はセカンダリロールの利用禁止ではなく、ログイン時に有効化しない設定である。
演習中は`USE SECONDARY ROLES ALL`を実行しない。
ワークシートでの`USE SECONDARY ROLES NONE`だけではTrust Center画面に適用されないため、再ログインが必要となる。

04aは自分のユーザーだけを変更し、管理ロールへの切り替えは指定しない。
ALTERで権限エラーになる場合は、そのユーザーのOWNERSHIPを持つロール、またはそれを継承するロールで実行する。SECURITYADMINのMANAGE GRANTSだけでユーザーの設定変更ができるとは限らない。

参照：[ユーザーの既定設定](https://docs.snowflake.com/en/sql-reference/sql/alter-user)、[セカンダリロールのセッション設定](https://docs.snowflake.com/en/sql-reference/sql/use-secondary-roles)

### A-3. できることを確認

| 操作 | VIEWER | ADMIN |
|---|:---:|:---:|
| Overview・Violations・Detectionsを閲覧 | ○ | ○ |
| Manage scannersで一覧・詳細を確認 | × | ○ |
| スキャナーの有効化・手動実行・スケジュール変更 | × | ○（機能ごとの制限あり） |
| 指摘をMutedへ変更・Unmute | × | ○ |
| ネットワークポリシーなど実際の設定を変更 | 別の権限が必要 | 別の権限が必要 |

ADMINは結果閲覧もできるため、指摘の件数や内容が同じでも問題ない。差はManage scannersなどの管理機能で確認する。
A-2を実施してもVIEWERで管理機能が使える場合は、VIEWERへのADMIN権限の付与やロール継承を確認する。

参照：[必要なロールと付与SQL](https://docs.snowflake.com/en/user-guide/trust-center/overview#required-roles)

### 付録で使うSQLと実行順序

| ファイル | 実行するタイミング | 内容・事前条件 |
|---|---|---|
| [01_check_context.sql](./01_check_context.sql) | 最初 | 接続先・ユーザー・現在のロールを確認 |
| [02_create_roles.sql](./02_create_roles.sql) | 権限準備 | USERADMINで学習用ロールを作成し、ACCOUNTADMINでアプリケーション／データベースロールを付与 |
| [03_grant_roles.sql](./03_grant_roles.sql) | 02の後 | SECURITYADMINで現在のセッションのユーザーに3つのロールを付与（書き換え不要） |
| [04_check_grants.sql](./04_check_grants.sql) | 03の後 | SECURITYADMINで作成したロールの権限・付与先を確認。SHOWごとの結果を確認 |
| [04a_disable_secondary_roles.sql](./04a_disable_secondary_roles.sql) | 04の後・画面比較の前 | 元の設定を記録し、自分の既定セカンダリロールを無効化。実行後に再ログイン |
| [05_check_usage.sql](./05_check_usage.sql) | 費用確認 | 費用確認専用ロールとSNOWFLAKE_LEARNING_WHを自動選択し、UTCの当日から6日前以降の使用クレジットを確認 |
| [98_restore_secondary_roles.sql](./98_restore_secondary_roles.sql) | 終了時・99の前 | 元が["ALL"]だった場合に既定設定を復元。実行後に再ログイン |
| [99_cleanup.sql](./99_cleanup.sql) | 終了時・任意 | SECURITYADMINで実行。現在のユーザーを自動取得し、一時的に付与した3つのロールを取り消す（書き換え不要） |

`99_cleanup.sql` はロールの削除・スキャナーの無効化・ウェアハウス停止を行わない。それらは終了時のチェックに沿って個別に確認する。

## B. 費用確認SQL（任意）

更新後の02・03で費用確認専用ロールを準備してから、[05_check_usage.sql](./05_check_usage.sql)を実行する。

05はLAB_TRUST_CENTER_USAGE_VIEWERに切り替える。Trust CenterのVIEWER／ADMIN付与だけでは費用情報の閲覧権限は得られない。

ウェアハウスは、Snowflakeの学習環境として用意される`SNOWFLAKE_LEARNING_WH`に統一する。
02で専用ロールへUSAGEを付与し、05の`USE WAREHOUSE`で選択するため、参加者による名前の書き換えや画面での選択は不要。
既に02を実行済みの場合は、更新後の02末尾にあるウェアハウスの権限付与を実行する。

停止中の場合は管理者がAUTO_RESUME設定や起動状態を確認する。

この学習環境は無効化・削除されている場合もあるため、開催前に存在を確認する。存在しない場合は講師が環境を準備し、05の実行中には新規作成しない。
参照：[Snowsightの学習用環境](https://docs.snowflake.com/en/user-guide/ui-snowsight/snowsight-templates)

05では権限付与やウェアハウスの設定変更を行わない。

**日付条件の基準：**

05は`ALTER SESSION SET TIMEZONE = 'UTC'`を実行し、日付の基準をUTCに揃える。
下限の`CURRENT_DATE()`もUTCの日付になるため、日本時間やログイン時のタイムゾーンに左右されない。

対象はUTCの当日を含む直近7日分を目安に、当日から6日前以降とする。当日以下の上限条件は設けない。
当日は途中経過であり、日本時間の午前0時を区切りとする7日間の集計ではない。

この設定はワークシートのSQLセッション内で後続のSQLにも適用される。ユーザーやアカウントの既定設定は変更しない。
別のタイムゾーンで作業を続ける場合は、同じセッションで必要な値に戻す。例えば日本時間なら`ALTER SESSION SET TIMEZONE = 'Asia/Tokyo';`を実行する。

- 得られるのは使用クレジットで、通貨換算の請求額ではない。
- 使用量情報の反映には最大3時間かかる。行がない場合に、直前の操作が無料だったと断定しない。
- 運用では「誰が確認するか」「何を優先するか」「誰が改善するか」を決める。
- Trialではメール送信の実演をせず、通知設定の考え方を紹介する。

参照：[費用確認](https://docs.snowflake.com/en/user-guide/trust-center/using-the-trust-center#monitoring-cost)、[メール通知とTrialの制約](https://docs.snowflake.com/en/user-guide/trust-center/notifications-trust-center)

日付基準と反映遅延の参照：[METERING_DAILY_HISTORY](https://docs.snowflake.com/en/sql-reference/account-usage/metering_daily_history)。公式のUTCでの照合手順に合わせており、このビューの保存形式がUTC固定であると断定するものではない。

## C. Detectionの追加演習（任意・10分目安）

1. **Detections** を開く。
2. 結果があれば発生時刻、対象、検知理由を確認する。
3. 結果がない場合は、以下の架空事例で議論する。Trialでは履歴が少なく、イベントが出ないこともある。

**架空事例：長期間使われていなかったユーザーがサインインした。**

- この検知だけで攻撃と判断できるか。
- 誰に何を確認するか。
- サインイン時刻、接続元IP、認証方法、作業予定から何を判断するか。
- 不正が疑われる場合は、誰に連絡し、どの社内対応手順へつなぐか。

**考え方：** 正当な利用再開の可能性もある。

Detectionは発生済みイベントなので、設定状態の指摘と同じように「修正して消す」とは考えない。
事実関係を確認し、その後の対処・再発防止を決める。

## D. スキャナー設定の追加演習（任意）

本編ではCIS Benchmarksの有効化までを行う。ここでは他パッケージの有効化や、追加の手動実行・スケジュール変更を扱う。

1. 対象パッケージの有効状態とスケジュールを手元に記録する。
2. 講師が指定したパッケージについて、有効化・手動実行・スケジュール変更のいずれかを試す。
3. 実行状態と結果を確認する。終了を待つ時間は別途確保する。
4. 記録した設定に戻すか、継続利用するかを決める。

追加スキャンはサーバーレス計算料金の対象で、Trialの無料利用枠も消費する。
元から有効だったパッケージを一括で無効化しない。

参照：[スキャナーの操作](https://docs.snowflake.com/en/user-guide/trust-center/using-the-trust-center)

## E. 追加演習の後片付け

1. 04aを実行した場合は、記録したDEFAULT_SECONDARY_ROLESの元の値へ戻す。
   元が`["ALL"]`なら[98_restore_secondary_roles.sql](./98_restore_secondary_roles.sql)を実行し、結果を確認してサインアウト・再ログインする。
   元が`[]`なら復元不要。元が別のロール一覧なら98のALLをその一覧に置き換える。
2. 今回付与した学習用ロールを外す場合だけ、[99_cleanup.sql](./99_cleanup.sql)を実行する。
   SECURITYADMINで現在のユーザーから3つの学習用ロールを取り消す。代わりの管理経路を確認してから行う。
3. 変更したスキャナーの設定と、SQL用ウェアハウスの起動状態を確認する。

99はロールの削除、ウェアハウスのUSAGE取り消し、スキャナーの無効化、ウェアハウス停止は行わない。
98は既定セカンダリロールの復元専用であり、99だけでは元に戻らない。

## 困ったとき

| 状況 | 確認すること |
|---|---|
| VIEWERでも管理機能を利用できる | A-2の設定・再ログイン、ADMIN権限の継承 |
| 05で権限エラー | A-1の02・03、SNOWFLAKE.USAGE_VIEWERの付与 |
| ウェアハウスのエラー | SNOWFLAKE_LEARNING_WHの存在、02でのUSAGE付与、AUTO_RESUMEと起動状態 |
| ロールが既に存在する | 講師に確認し、CREATE OR REPLACEで上書きしない |
