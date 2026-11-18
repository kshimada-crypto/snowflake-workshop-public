# Snowflake Trust Center ワークショップ

- 対象：Snowflakeを利用するチームメンバー
- 所要時間：30分（アカウント準備・追加演習は開催時間外）
- 前提：各自のSnowflake Trialアカウントで、ACCOUNTADMINを選択して操作する

公式情報確認日：2026-11-18。既存の01〜99のSQLは実行確認済み。
30分版の進行全体は未検証。ロール作成・付与などの追加演習は[Appendix](./APPENDIX.md)へ分けている。

## このワークショップのゴール

- Trust Centerで何を確認できるか説明する。
- CIS Benchmarksを有効化し、実行状態を確認する（既に有効なら設定・実行状態を確認する）。
- 設定状態の指摘（Violation）と、発生イベントの検知（Detection）を区別する。
- 指摘1件から、追加で確認すること・担当者・対応案を考える。
- 閲覧・管理・使用量確認に必要なロールと、コストを確認するビューを説明する。

## 1. 事前準備

### 参加者

- [ ] 開催前に自分専用のTrialアカウントを準備し、有効期限・無料利用枠が残っていることを確認する。
- [ ] Snowsightにログインし、ユーザーメニューでACCOUNTADMINを選択できることを確認する。
- [ ] ACCOUNTADMINでTrust Centerを開けることを確認する。利用できない場合は開催前に講師へ相談する。
- [ ] [01_check_context.sql](./01_check_context.sql)を実行できるようにしておく。
- [ ] SNOWFLAKE_LEARNING_WHを利用できることを確認する。画面でウェアハウスの選択を求められた場合に使用する。

本編では、ACCOUNTADMINに既定で付与されているTrust Centerの権限を利用する。
各自のTrialでの操作を前提とし、追加のロール作成・付与や、セカンダリロールの設定変更は行わない。

継続運用で使用する最小権限の専用ロールの設計・付与は、[Appendix A](./APPENDIX.md)で扱う。
本編だけを実施する場合、02〜99のSQLは実行不要。

### 講師

- [ ] 各参加者が自分のTrialにログインし、ACCOUNTADMINでTrust Centerを開けることを確認する。
- [ ] 参加者が読み解きやすい指摘を1件選び、指摘がない場合に備えてデモ画面と架空事例を用意する。
- [ ] 参加者のCIS Benchmarksが未有効か、有効済みかを確認する。操作のためだけに有効済みの設定を無効化しない。
- [ ] 講師のデモ環境ではCIS Benchmarksの結果を用意し、参加者の実行結果が間に合わない場合に提示できるようにする。
- [ ] 有効化によるクレジット消費と、終了時に継続利用するか無効化するかを説明する。
- [ ] 開催時点の画面表記を確認する。

当日はCIS Benchmarksを有効化するが、スキャン完了は待たずに次へ進む。
結果が間に合わない場合は、既存の指摘・講師のデモ・架空事例で読み解き演習を行う。

CIS Benchmarksのスキャンはサーバーレス計算料金の対象で、Trialでは無料利用枠を消費する。
既定では1日1回実行されるため、終了時に継続利用するかを確認する。

## 2. 当日の流れ

| 時間 | 内容 | 参加者のアクション |
|---|---|---|
| 0〜3分 | 目的と用語 | ViolationとDetectionの違いを押さえる |
| 3〜8分 | 接続先・ロールを知る | ACCOUNTADMINで01を実行し、VIEWER／ADMINと費用閲覧権限の違いを聞く |
| 8〜15分 | 全体像と有効化 | パッケージ一覧を確認し、CIS Benchmarksを有効化する |
| 15〜22分 | 指摘を1件読み解く | Violationsで1件を読み、短い記録表を埋める |
| 22〜24分 | Detectionを知る | 発生時刻・対象・検知理由を確認する |
| 24〜28分 | コスト記録を知る | 使用量ビューと主要な列、TRUST_CENTERの絞り込みを理解する（SQL実行なし） |
| 28〜30分 | 振り返り | 対応前の確認事項と、有効化したパッケージの終了時の扱いを確認する |

ロールの付与・比較、費用確認SQL、Detectionの詳しい調査、追加の手動実行・スケジュール変更は開催時間外の付録とする。

## 3. 目的と用語（3分）

Trust Centerは、アカウントのセキュリティリスクをチェックし、結果や対応の手がかりを提供する。

| 用語 | 意味 |
|---|---|
| Scanner | 特定の条件を調べるチェック処理 |
| Scanner package | スキャナーのまとまり |
| Finding | チェックで見つかった結果の総称。ViolationとDetectionの2種類を含む |
| Violation | チェック条件を満たしていない設定状態 |
| Detection | 発生したイベントの検知 |

Violationでは「設定をどう改善するか」、Detectionでは「そのイベントが正当なものか」を考える。

## 4. 接続先とロールを確認する（5分）

### 画面と接続先を確認する（3分）

1. Snowsightのユーザーメニューで、利用ロールに**ACCOUNTADMIN**を選択する。
2. SQLワークシートでもACCOUNTADMINを選択し、[01_check_context.sql](./01_check_context.sql)を実行する。
3. 結果のアカウント・ユーザーが自分のTrialであり、CURRENT_ROLEがACCOUNTADMINであることを確認する。
4. **Governance & security → Trust Center**を開く。メニュー表記は画面の更新で異なることがある。

ワークシートとTrust Center画面では利用ロールをそれぞれ確認する。
01は接続先の確認用であり、権限付与やロール切り替えは行わない。

### Trust Center関連のロール（解説・2分）

Trust Centerの権限は、用途別のアカウントロールへアプリケーションロールを付与して使う。
本編はACCOUNTADMINで進め、以下の役割分担を解説する。ここでGRANTやロール比較のSQLは実行しない。

| ロール | 種類 | 必要となる主な操作 |
|---|---|---|
| `SNOWFLAKE.TRUST_CENTER_VIEWER` | アプリケーションロール | Overview、Violations、Detectionsの閲覧。AI Securityタブの閲覧にも使用する |
| `SNOWFLAKE.TRUST_CENTER_ADMIN` | アプリケーションロール | VIEWERの閲覧に加え、スキャナーパッケージの有効化、手動実行、スケジュール変更、指摘の状態管理 |
| `SNOWFLAKE.USAGE_VIEWER` | データベースロール | ACCOUNT_USAGEの使用量ビューを照会する。Trust CenterのVIEWER／ADMINだけでは、この権限は得られない |
| `ACCOUNTADMIN` | システムのアカウントロール | 本編の操作に使用。通常アカウントでTrust Centerのアプリケーションロールを専用ロールへ付与するときにも使用する |

例えば「閲覧担当のアカウントロール → TRUST_CENTER_VIEWER」「運用担当 → TRUST_CENTER_ADMIN」「費用確認担当 → USAGE_VIEWER」と分ける。
アプリケーションロール・データベースロールは、直接USE ROLEで選ぶものではなく、権限を付与されたアカウントロールを選択して使う。

USERADMINは学習用ロールの作成、SECURITYADMINはユーザーへのロール付与・取り消しなどで使用する。これらは付録の準備操作であり、本編の追加操作は不要。
組織アカウントで複数アカウントの指摘を見る場合は、`ORGANIZATION_SECURITY_VIEWER`など追加の組織用権限が必要で、本編の各自のTrialとは区別する。

Trust CenterのADMINでも、指摘の原因となるネットワークポリシーや認証設定を変更する権限まで一律に得られるわけではない。
同じユーザーへVIEWERとADMINを付与して比較する演習では、セカンダリロールも影響するため、実施手順は[付録A](./APPENDIX.md)を参照する。

参照：[必要なロールと操作の対応](https://docs.snowflake.com/en/user-guide/trust-center/overview#required-roles)、[費用確認の権限](https://docs.snowflake.com/en/user-guide/trust-center/using-the-trust-center#monitoring-cost)

## 5. 全体像を見てCIS Benchmarksを有効化する（7分）

1. **Overview**で全体の状況を見る。
2. **Violations**で指摘の件数・重大度・最終スキャン日時を確認する。
3. **Manage scanners → Scanner packages**を開き、**CIS Benchmarks**を選択する。
   ウェアハウスの選択を求められた場合は**SNOWFLAKE_LEARNING_WH**を選ぶ。
4. 有効状態とスケジュールを手元に記録する。講師から、スキャンによるクレジット消費と終了時の扱いの説明を受ける。
5. 未有効の場合は**Enable Package**（画面によっては**Enable → Continue**）を選択し、確認画面に従って有効化する。
   既に有効な場合はそのままにし、設定・実行状態の確認に進む。
6. 有効状態に変わったことを確認し、スキャナーの実行状態・最終実行日時を見る。

本編の到達点は有効化と状態確認まで。完了時刻や指摘の発生は保証せず、実行中でも15分になったら次へ進む。
指摘がない場合は既存の結果・講師の例を使い、追加の手動実行やスケジュール変更は行わない。

CIS Benchmarksは、Snowflakeの設定をCISのベストプラクティスと照合するパッケージ。
設定状態を扱うViolationの読み解きに使いやすいが、指摘がないことだけで安全を保証するものではない。

### 用意されているスキャナーパッケージ

2026-11-18時点の公式ドキュメントに掲載された、Snowflake提供の全5種類を以下に示す。
本編では全体の用途を紹介し、有効化する対象はCIS Benchmarksの1種類とする。

| パッケージ | 目的・主なチェック例 | 有効化・実行の特徴 |
|---|---|---|
| **Security Essentials** | 基本的なセキュリティ設定。人間ユーザーのMFA、認証ポリシー、アカウントのネットワークポリシーなどを確認する | 既定で有効、無効化不可。固定スケジュールの実行はサーバーレス計算料金なし。追加の手動実行は課金対象 |
| **CIS Benchmarks** | CIS Snowflake Benchmarksとの照合。認証、権限、ネットワーク、データ保護などの設定を点検する | 有効化して利用する。既定は1日1回。今回の有効化演習の対象 |
| **Threat Intelligence** | 認証・利用状況のリスク。認証失敗の多発、休眠ユーザーのサインイン、不審なIPからのログイン、認証ポリシー変更などを検知する | 定期チェックとイベント検知を含む。既定の定期実行は1日1回 |
| **AI Security** | AIの設定・利用に関するリスク。Cortex Searchの過大な所有者権限、Cortex Code CLIのPAT制限不足、エージェントによる保護されていない機密データへのアクセスなどを確認する | 既定の定期実行は1日1回。条件を満たすアカウントではAI利用に応じて自動有効化される場合がある |
| **Data Security** | 異常なデータ移動。ユーザーの過去の傾向と比較し、外部・内部ステージへの異常な量のデータ出力などを検知する | イベント型。結果はDetectionsで確認する。検知の生成は最大でも4時間に1回で、即時表示を前提にしない |

Security Essentials以外は原則として有効化が必要で、スキャンのサーバーレス計算料金が発生する。
AI Securityの自動有効化には、Business Critical／VPSとキャパシティ契約などの条件がある。
個別スキャナーにも利用機能・エディションなどの条件があるため、一覧への掲載は全Trialで同じ結果が出ることを意味しない。

上記はSnowflake提供パッケージの一覧。別途、Trust Center Extensionsで第三者提供のパッケージを追加できる場合もある。
開催時は**Manage scanners → Scanner packages**の一覧とProvider・Statusを確認し、対象アカウントで実際に表示される内容と照合する。

参照：[パッケージ一覧と各チェックの詳細](https://docs.snowflake.com/en/user-guide/trust-center/overview#scanner-packages)、[拡張パッケージ](https://docs.snowflake.com/en/user-guide/trust-center/trust-center-extensions)

参照：[CIS Benchmarksの有効化](https://docs.snowflake.com/en/user-guide/trust-center/getting-started#enable-the-cis-benchmarks-scanner-package)、[対象範囲と制限](https://docs.snowflake.com/en/user-guide/trust-center/overview#cis-benchmarks-scanner-package)

## 6. 指摘を1件読み解く（7分）

1. **Violations**から指摘を1件選ぶ（1分）。
2. 詳細を開き、判定条件・対象・重大度・改善案（Remediation）を読む（3分）。
3. 次の表を手元のメモにコピーして記入する（2分）。
4. 隣の人または全体に「何を確認してから対応するか」を説明する（1分）。

結果はアカウントごとに異なるため、同じ指摘が出る必要はない。
CIS Benchmarksの結果があれば優先して選ぶ。未完了・指摘なしの場合は、既存の別パッケージの指摘か講師の例を使う。

| 項目 | 自分の記録 |
|---|---|
| 指摘名・問題となる設定・対象 | |
| 業務上どんなリスクがあるか | |
| 変更前に追加で確認すること | |
| 対応する担当者・対応案 | |

### 指摘がないときの架空事例

「アカウントレベルのネットワークポリシーがない」という指摘を想定する。
接続元、利用中のアプリ、接続経路を何から確認するか考える。

許可IPを決める前に誰に確認するか、ポリシーが存在するだけで安全と言えるかを話し合う。
実際のネットワーク・認証設定の変更は行わず、対応案まで作る。

### 読み解くときのポイント

- 指摘の表示状態を変えることと、原因となる設定を修正することは別の操作。
- 設定修正後は、次回スキャンなどで改善を確認する。即時に指摘が消えるとは限らない。
- 指摘ゼロは、すべての設定が適切であることの保証にはならない。

## 7. Detectionを知る（2分）

1. **Detections**を開く。
2. 結果があれば、1件の発生時刻・対象・検知理由を確認する。
3. 「この情報だけで不正と断定できるか」「誰に利用目的を確認するか」を考える。

結果がない場合は「長期間使われていなかったユーザーがサインインした」例を使う。
正当な利用再開の可能性もあるため、検知だけで攻撃と断定せず、作業予定や接続元などを追加確認する。

詳しい調査の議論は[Appendix C](./APPENDIX.md)にまとめている。

## 8. コストはどこに記録されるか（解説・4分）

Trust Centerのスキャンはサーバーレス計算として使用量が記録される。
以下はSnowflakeが提供する履歴ビューであり、参加者がログ用テーブルを作成する必要はない。
Findingsはセキュリティ上の結果、ここで扱うビューは使用量・費用の記録であり、目的が異なる。

### 確認したい粒度に応じたビュー

| ビュー（SNOWFLAKEデータベース内） | 記録の粒度と用途 | 主な列 |
|---|---|---|
| `ACCOUNT_USAGE.METERING_HISTORY` | 自アカウントの時間単位の使用量。いつ消費が増えたかを見る | `SERVICE_TYPE`、`START_TIME`、`END_TIME`、`CREDITS_USED` |
| `ACCOUNT_USAGE.METERING_DAILY_HISTORY` | 自アカウントの日別集計。日ごとの消費クレジットを比較する | `SERVICE_TYPE`、`USAGE_DATE`、`CREDITS_USED`、`CREDITS_BILLED` |
| `ORGANIZATION_USAGE.METERING_DAILY_HISTORY` | 組織内のアカウント別・日別使用量。複数アカウントを比較する | `ACCOUNT_NAME`、`SERVICE_TYPE`、`USAGE_DATE`、`CREDITS_USED` |
| `ORGANIZATION_USAGE.USAGE_IN_CURRENCY_DAILY` | 組織の通貨建て日別利用額。クレジット数に加えて金額を確認する | `ACCOUNT_NAME`、`SERVICE_TYPE`、`USAGE_DATE`、`CURRENCY`、`USAGE_IN_CURRENCY` |

いずれも`SERVICE_TYPE = 'TRUST_CENTER'`でTrust Center分を取り出す。
全体のサービス使用量が入っているため、無条件に合計すると他サービスの消費も含まれる。
時間別ビューの1行を「スキャナー1回の実行ログ」とは解釈しない。

### 日別記録の読み方（説明用・実行不要）

```sql
SELECT USAGE_DATE, CREDITS_USED
FROM SNOWFLAKE.ACCOUNT_USAGE.METERING_DAILY_HISTORY
WHERE SERVICE_TYPE = 'TRUST_CENTER'
  AND USAGE_DATE >= DATEADD('day', -6, CURRENT_DATE())
ORDER BY USAGE_DATE;
```

講師は「日付・サービス種別・消費クレジットが記録され、TRUST_CENTERだけを日付順に読む」と説明する。
この例の日付計算はUTCのセッションを前提とする。実行する場合は、ロール・ウェアハウス選択とUTC設定を含む[05のSQL](./05_check_usage.sql)を付録Bの手順で使う。

- `CREDITS_USED`は消費クレジット数であり、円・ドルの金額ではない。`CREDITS_BILLED`は調整を反映した請求対象クレジットで、これも通貨額ではない。
- 日別ACCOUNT_USAGEビューの反映には最大3時間かかる。有効化直後に0件でも、無料だったとは判断しない。当日分は途中経過となる。
- 日付はUTCに揃えて確認する。組織側の日別ビューはUTC基準で、自アカウント側との照合も公式手順ではセッションをUTCにする。
- サーバーレスのスキャン費用と、使用量をSELECTするウェアハウスの費用は別。後者だけを見てTrust Centerの費用としない。

### 使用量・金額を見る権限

ACCOUNT_USAGEの上記2ビューはACCOUNTADMIN、または`SNOWFLAKE.USAGE_VIEWER`を付与したアカウントロールで確認する。
照会に使うウェアハウスのUSAGEも必要。付録では`LAB_TRUST_CENTER_USAGE_VIEWER`へ必要な権限をまとめる。

組織全体のクレジットは`SNOWFLAKE.ORGANIZATION_USAGE_VIEWER`、通貨額は`SNOWFLAKE.ORGANIZATION_BILLING_VIEWER`など、組織の閲覧権限を持つロールで確認する。
TrialのACCOUNTADMINだけで組織・請求情報をすべて閲覧できるという前提にはしない。

本編の確認ポイントは「どのビューのどの列を見るか」「クレジットと金額の違い」「管理ロールと費用閲覧権限は別」の3点。
ロール付与と実際の照会は[付録B](./APPENDIX.md)で扱う。

参照：[Trust Centerの費用確認](https://docs.snowflake.com/en/user-guide/trust-center/using-the-trust-center#monitoring-cost)、[時間別使用量](https://docs.snowflake.com/en/sql-reference/account-usage/metering_history)、[日別使用量](https://docs.snowflake.com/en/sql-reference/account-usage/metering_daily_history)、[通貨額](https://docs.snowflake.com/en/sql-reference/organization-usage/usage_in_currency_daily)

## 9. 振り返り（2分）

1. ViolationとDetectionの違いは何か。
2. 選んだ指摘について、設定変更前に何を確認するか。
3. 指摘がゼロなら安全と言い切れるか。

確認用の答え：

- Violationは設定状態、Detectionは発生イベントを扱う。
- 判定条件、影響範囲、業務上の利用、担当者などを確認してから対応する。
- チェックの有効性・実行状況・対象範囲・限界も確認する必要がある。

未解決の指摘について、次に調べることを1つ記録して終了する。
本編ではロールやユーザー設定を変更しないため、98・99による復元や取り消しは不要。

**CIS Benchmarksの終了時の扱い：**

- 今回初めて有効化した場合は、継続利用するか確認する。演習だけで使う場合は、パッケージの画面で無効化し、無効状態を確認する。
- 継続利用する場合は、定期スキャンによるクレジット消費が続くことを理解して残す。
- 元から有効だった場合は、その設定を維持する。講師のデモ環境の扱いは講師が確認する。

## 10. 本編で困ったとき

| 状況 | 確認すること・進め方 |
|---|---|
| Trust Centerを利用できない | ユーザーメニューのACCOUNTADMINと接続先を確認。解消しなければ講師の画面で続け、権限調査は開催時間外に行う |
| タブ内が完全に白紙 | 再読み込みや再ログインを試す。解消しなければ講師の画面で続ける |
| 指摘・イベントがない | 有効状態・実行状況・対象範囲を確認し、架空事例で進める |

## Appendix（開催時間外）

[追加演習ガイド](./APPENDIX.md)に、次の内容をまとめている。

| 付録 | 内容 | 使用するSQL |
|---|---|---|
| A | 最小権限のロール作成・付与と権限差の比較 | 02・03・04・04a |
| B | 専用ロールでの使用クレジット確認 | Aの02・03で準備して05 |
| C | Detectionの詳しい調査演習 | なし |
| D | 他パッケージの有効化・追加の手動実行・スケジュール変更 | 画面操作 |
| E | 追加演習で変更した設定の復元・付与の取り消し | 98・99（実施内容に応じて） |

SQLの実行順序・確認する値・後片付けの条件は付録の手順に従う。

## 公式資料

- [Trust Center概要](https://docs.snowflake.com/en/user-guide/trust-center/overview)：目的、用語、必要な権限
- [画面操作](https://docs.snowflake.com/en/user-guide/trust-center/using-the-trust-center)：スキャナー、指摘、費用
- [Trust Centerの使用開始](https://docs.snowflake.com/en/user-guide/trust-center/getting-started)：操作例

開催直前に実画面と公式情報を再確認する。本ガイドは全参加者に同じスキャン結果が出ることを前提にしていない。
