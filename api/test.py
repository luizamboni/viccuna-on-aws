import openai
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--host", required=True)
args = parser.parse_args()

vicuna_api_base = f"http://{args.host}:8000/v1"

# save openai orignal key
openai_api_key = openai.api_key
openai_api_base = openai.api_base

openai.api_key = "EMPTY"
openai.api_base = vicuna_api_base

model = "vicuna-7b-v1.3"
prompt = "Once upon a time"

# create a completion
completion = openai.Completion.create(model=model, prompt=prompt, max_tokens=64)
# print the completion
print(prompt + completion.choices[0].text)

