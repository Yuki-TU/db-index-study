#!/bin/bash

# 設定
DB_HOST="db"                        # データベースのホスト名
DB_USER="admin"                      # MySQLユーザー名
DB_PASSWORD="password"              # MySQLパスワード
DB_NAME="sample"             # データベース名
TABLE_NAME="users"                  # 挿入するテーブル名
TOTAL_ROWS=1000000                  # 挿入する総レコード数
BATCH_SIZE=10000                    # 1回の挿入で処理するレコード数
SQL_FILE="insert_data.sql"          # 挿入用の一時SQLファイル

echo "Starting to insert $TOTAL_ROWS rows into $TABLE_NAME..."
# 分割挿入ループ
for ((i=0; i<TOTAL_ROWS; i+=BATCH_SIZE)); do
  echo "Generating rows $((i+1)) to $((i+BATCH_SIZE)) in $SQL_FILE..."

  # SQLファイルを生成
  cat <<EOF > $SQL_FILE
INSERT INTO $TABLE_NAME (name, email, age, created_at, updated_at) VALUES
EOF

  # データを生成してSQLファイルに追加
  for ((j=1; j<=BATCH_SIZE; j++)); do
    CURRENT_ID=$((i+j))
    NAME="User_$CURRENT_ID"
    EMAIL="user${CURRENT_ID}@example.com"
    AGE=$((RANDOM % 60 + 18))  # 年齢: 18〜77のランダム値
    CREATED_AT="$(date '+%Y-%m-%d %H:%M:%S')"
    UPDATED_AT="$CREATED_AT"

    # 値を追加（最後のレコードはカンマを付けない）
    if [ $j -eq $BATCH_SIZE ]; then
      echo "('$NAME', '$EMAIL', $AGE, '$CREATED_AT', '$UPDATED_AT');" >> $SQL_FILE
    else
      echo "('$NAME', '$EMAIL', $AGE, '$CREATED_AT', '$UPDATED_AT')," >> $SQL_FILE
    fi
  done

  # SQLファイルを実行
  echo "Inserting batch $((i+1)) to $((i+BATCH_SIZE)) into the database..."
  mariadb --skip-ssl -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" < $SQL_FILE

  # エラーチェック
  if [ $? -ne 0 ]; then
    echo "Error occurred during batch insert! Exiting..."
    exit 1
  fi
done

# 一時SQLファイルを削除
rm -f $SQL_FILE

echo "Successfully inserted $TOTAL_ROWS rows into $TABLE_NAME!"
