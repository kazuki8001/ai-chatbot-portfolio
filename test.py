import boto3

# AWSの認証情報を確認する
sts = boto3.client('sts', region_name='ap-northeast-1')
identity = sts.get_caller_identity()

print("UserID:", identity['UserId'])
print("Account:", identity['Account'])
print("Arn:", identity['Arn'])