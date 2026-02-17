import boto3
import os
import json

def lambda_handler(event, context):
    rekognition = boto3.client('rekognition')
    
    # Extract bucket and file name from the S3 event notification
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']
    
    print(f"Analyzing image: s3://{bucket}/{key}")
    
    # Get threshold from environment variable
    threshold = float(os.environ.get('CONFIDENCE_THRESHOLD', 80))
    
    # Call Rekognition
    response = rekognition.detect_labels(
        Image={'S3Object': {'Bucket': bucket, 'Name': key}},
        MinConfidence=threshold
    )
    
    # Process results
    labels = []
    for label in response['Labels']:
        result = {
            "Label": label['Name'],
            "Confidence": round(label['Confidence'], 2)
        }
        labels.append(result)
        print(f"Detected: {result['Label']} ({result['Confidence']}%)")
        
    return {
        'statusCode': 200,
        'body': json.dumps(labels)
    }