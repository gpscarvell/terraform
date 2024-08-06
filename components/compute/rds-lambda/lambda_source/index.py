import sys
import os
import json
import botocore
import boto3
import logging
from botocore.exceptions import ClientError

region = os.environ['region']

rds = boto3.client('rds', region_name=region)
logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):

	logger.info("Event: " + str(event))

	dbInstance = os.environ['database']
	logger.info("dbInstance: " + str(dbInstance))
	action = event.get('action')
	if ('stop' == action):
		stop_rds_instances(dbInstance)
	elif (action == 'start'):
		start_rds_instances(dbInstance)

	return {
    	'statusCode': 200
	}

### stop rds instances
def stop_rds_instances(dbInstance):
	try:
		rds.stop_db_instance(DBInstanceIdentifier=dbInstance)
		logger.info('Success :: stop_db_instance ' + dbInstance)
	except ClientError as e:
		logger.error(e)
	return "stopped:OK"

def start_rds_instances(dbInstance):
	try:
		rds.start_db_instance(DBInstanceIdentifier=dbInstance)
		logger.info('Success :: start_db_instance ' + dbInstance)
	except ClientError as e:
		logger.error(e)
	return "started:OK"
