import boto3
import json
import logging
import uuid
from datetime import datetime, timezone
import os

from boto3.session import Session

MGMT_ASSUME_ROLE = os.environ["MGMT_ASSUME_ROLE"]



logger = logging.getLogger()
logger.setLevel(logging.INFO)
ddb = boto3.client("dynamodb")

def put_ddb_item(table_name, item):
    #ddb = boto3.client("dynamodb")
    #table = ddb.Table(table_name)
    response = ddb.put_item(TableName=table_name, Item=item)
    
    return response

def assume_role(assume_role_arn, role_session_name):
    sts = boto3.client("sts")
    response = sts.assume_role(
        RoleArn=assume_role_arn, RoleSessionName=role_session_name
    )
    return boto3.client(
            'organizations',
            aws_access_key_id=response['Credentials']['AccessKeyId'],
            aws_secret_access_key=response['Credentials']['SecretAccessKey'],
            aws_session_token=response['Credentials']['SessionToken']
        )

def handler(event, context):
    logger.info(f"Received event: {json.dumps(event)}")
    body = event['body']
    account_email = json.loads(body).get('accountEmail')
    request_id = ""

    try:
        #organizations = assume_role("arn:aws:iam::253490781334:role/test-lambda-role", "Organization_Session")
        organizations = assume_role(MGMT_ASSUME_ROLE, "Organization_Session")
        paginator = organizations.get_paginator('list_accounts')
        for page in paginator.paginate():
            for account in page['Accounts']:
                if account.get('Email') == account_email:
                    return {
                        'statusCode': 409,
                        'body': json.dumps({'message': 'Account already exists'})
                    }
        print(f"{account_email} does not exist")
        
        # call the GitHub Actions endpoint

        # create the values for the request
        request_uuid = str(uuid.uuid4())
        timestamp = str(datetime.now().isoformat())
        logger.info(timestamp)
        status = "INITIATED"

        # put the request in ddb
        put_ddb_item(table_name="aft-api-metadata", 
            item={  # Ensure the structure is correct
                'id': {'S': request_uuid},  # Wrap the string in a dictionary with type indicator
                'status': {'S': status},     # Wrap the string in a dictionary with type indicator
                'timestamp': {'S': timestamp} # Wrap the string in a dictionary with type indicator
            }
        )
        # ddb.put_item(TableName="aft-api-metadata",
        # Item={  
        #     'id': {'S': request_uuid}, 
        #     'status': {'S': status},     
        #     'timestamp': {'S': timestamp} 
        # })

        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': f'Request created for {account_email}: {request_uuid}',
                'requestId': "empty" if request_uuid == "" else request_uuid
            })
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'message': f'Error processing request: {str(e)}'})
        }
