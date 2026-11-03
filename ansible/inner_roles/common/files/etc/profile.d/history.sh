# 記録される実行コマンドの最大値
HISTSIZE=100000
# 記録される実行コマンドの最大値(基本的にHISTSIZEと同値を指定します)
HISTFILESIZE=100000
# 実行日時の書式設定
HISTTIMEFORMAT='%y/%m/%d %H:%M:%S '
# 履歴から除外するコマンド(複数指定の場合は:で区切り指定します。)
HISTIGNORE='history:pwd:ls:ls *:ll:w:top:df *:htop'
# 空白、重複履歴を保存しない
# ignoredups: 重複コマンドを無視
# ignorespace: 空白で始まるコマンドを無視
# ignoreboth: ignorespace と ignoredups の省略形
# erasedups: 現在の行と一致する履歴を保存前にすべて削除
HISTCONTROL=ignoreboth
# 履歴のリアルタイム反映
PROMPT_COMMAND='history -a; history -c; history -r'
