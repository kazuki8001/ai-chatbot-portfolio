import json
import boto3

bedrock = boto3.client('bedrock-runtime', region_name='ap-northeast-1')

def lambda_handler(event, context):
    # bodyをパースする
    body = json.loads(event.get('body', '{}'))
    history = body.get('history', [])
    
    messages = []
    for msg in history:
        if not messages or messages[-1]['role'] != msg['role']:
            messages.append({
                'role': msg['role'],
                'content': [{'text': msg['content']}]
            })
    
    if not messages or messages[0]['role'] != 'user':
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'Invalid history'})
        }
    
    response = bedrock.converse(
        modelId='jp.anthropic.claude-haiku-4-5-20251001-v1:0',
        messages=messages
    )
    
    reply = response['output']['message']['content'][0]['text']
    
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps({'reply': reply}, ensure_ascii=False)
    }