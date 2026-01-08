#!/usr/bin/env python3
"""
Claude Code Integration Test Script

このスクリプトは、LLM Proxy経由でClaude APIにアクセスできるかをテストします。
"""

import os
import sys
import json

try:
    from openai import OpenAI
except ImportError:
    print("Error: openai package not installed")
    print("Install with: pip3 install openai")
    sys.exit(1)


def test_llm_proxy_connection():
    """LLM Proxy接続のテスト"""
    
    # 環境変数から設定を取得
    api_key = os.environ.get("LITELLM_MASTER_KEY")
    base_url = os.environ.get("OPENAI_API_BASE", "http://llm-proxy.abe365.org/v1")
    model = os.environ.get("CLAUDE_MODEL", "claude-3-sonnet-fallback")
    
    if not api_key:
        print("Error: LITELLM_MASTER_KEY environment variable not set")
        print("Usage: LITELLM_MASTER_KEY=your-key python3 test_claude_integration.py")
        sys.exit(1)
    
    print("=" * 60)
    print("Claude Code Integration Test")
    print("=" * 60)
    print(f"API Base URL: {base_url}")
    print(f"Model: {model}")
    print(f"API Key: {'*' * 8}{api_key[-4:]}")
    print("-" * 60)
    
    try:
        # OpenAI clientを作成（LLM Proxy経由）
        client = OpenAI(
            api_key=api_key,
            base_url=base_url
        )
        
        # テストリクエスト
        print("Sending test request to Claude via LLM Proxy...")
        response = client.chat.completions.create(
            model=model,
            messages=[
                {
                    "role": "user",
                    "content": "Please respond in Japanese: Say 'Claude Code integration test successful!' and explain what you are."
                }
            ],
            max_tokens=200,
            temperature=0.7
        )
        
        # 結果の表示
        print("\n✓ SUCCESS! Claude responded:")
        print("-" * 60)
        print(response.choices[0].message.content)
        print("-" * 60)
        
        # 使用量の表示
        if hasattr(response, 'usage'):
            print(f"\nToken usage:")
            print(f"  Prompt tokens: {response.usage.prompt_tokens}")
            print(f"  Completion tokens: {response.usage.completion_tokens}")
            print(f"  Total tokens: {response.usage.total_tokens}")
        
        print("\n✓ Integration test passed!")
        return 0
        
    except Exception as e:
        print(f"\n✗ ERROR: {e}")
        print("\nTroubleshooting:")
        print("1. Check if LLM Proxy is running:")
        print("   curl http://llm-proxy.abe365.org/health")
        print("2. Verify LITELLM_MASTER_KEY is correct")
        print("3. Check LLM Proxy logs:")
        print("   docker-compose -f service/llm-proxy/docker-compose.yml logs -f litellm")
        return 1


if __name__ == "__main__":
    sys.exit(test_llm_proxy_connection())
