
# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# add path
export PATH="$HOME/.local/bin:$PATH"

# export AWS_ACCESS_KEY_ID="{{ bedrock_access_key_id }}"
# export AWS_SECRET_ACCESS_KEY="{{ bedrock_secret_access_key }}"
# export AWS_REGION="us-east-1"
#export CLAUDE_CODE_USE_BEDROCK=1
#export ANTHROPIC_MODEL="us.anthropic.claude-sonnet-4-5-20250929-v1:0"
#export ANTHROPIC_SMALL_FAST_MODEL="us.anthropic.claude-sonnet-4-5-20250929-v1:0"
# export CLAUDE_CODE_MAX_OUTPUT_TOKENS=4096
# export MAX_THINKING_TOKENS=1024
# CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1

