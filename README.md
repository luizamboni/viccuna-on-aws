Vicuna on aws
===
Using [fschat](https://pypi.org/project/fschat/), this terraform script will create an EC2 instance, install, and run Vicuna with a chat interface


A Makefile automates the entire process.

To terraform plan:
```shell
make plan
```

To terraform deploy:
```shell
make deploy
```
Upon completion, an `output.json` file will be saved in root project directory. It contains useful data about instances, such as `public domain` and `public ip`
This file will be utilized in other command like `make ssh` and `make chat_url`

To terraform destroy:
```shell
make destroy
```

During the first run the Vicuna's LLM will be downloaded and it will take a long time, some minutes. 
To speed up the startup , consider to clone the external volume and updating the volume reference in terraform script afterwards.