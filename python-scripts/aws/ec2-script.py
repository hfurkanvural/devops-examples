import boto3

ec2 = boto3.client('ec2')

response = ec2.run_instances(
    ImageId = 'ami-00a205cb8e06c3c4e',
    MaxCount=1,
    MinCount=1,
    InstanceType='t2.micro'
)

print(response)

instance_id = response.Instances[0].InstanceId

# response = client.terminate_instances(
#     InstanceIds=[
#         instance_id,
#     ]
# )
# print(response)