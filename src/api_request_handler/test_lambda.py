# test_lambda.py
import json
from main import handler as lambda_handler

class Context:
    def __init__(self):
        self.function_name = 'test_lambda_function'
        self.memory_limit_in_mb = 128
        self.invoked_function_arn = 'arn:aws:lambda:us-east-1:123456789012:function:test_lambda_function'
        self.aws_request_id = 'dummy-request-id'

def load_event(file_path):
    # Load event data from a JSON file
    with open(file_path, 'r') as f:
        return json.load(f)

def test_lambda(function_event):
    # Create a context object similar to what AWS provides
    context = Context()

    # Call the lambda handler with the event and context
    result = lambda_handler(function_event, context)

    # Print the result
    print(json.dumps(result, indent=4))

if __name__ == '__main__':
    # Replace 'event.json' with the path to your test event JSON file
    event_file_path = 'event.json'
    event_data = load_event(event_file_path)
    test_lambda(event_data)