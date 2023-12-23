Content-Type: multipart/mixed; boundary="//"
MIME-Version: 1.0

--//
Content-Type: text/cloud-config; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="cloud-config.txt"

#cloud-config
cloud_final_modules:
- [scripts-user, always]

--//
Content-Type: text/x-shellscript; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="userdata.txt"

#!/bin/bash
sudo apt update
sudo apt install python3 python3-pip -y

pip3 install --upgrade pip  # enable PEP 660 support
pip3 install "fschat[model_worker,webui]==0.2.34" jinja2==3.1.2
# to see log>>s of user_data
# cat /var/log/cloud-init-output.log

# volume mapping
sudo lsblk -f
sudo mkfs -t xfs /dev/nvme1n1
sudo mkdir /hugginface
sudo mount /dev/nvme1n1 /hugginface



sudo cat <<'EOF' >/etc/profile.d/script.sh
#!/bin/bash
export HUGGINGFACE_HUB_CACHE=/hugginface
EOF

sudo cat <<'EOF' >/etc/environment
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"
HUGGINGFACE_HUB_CACHE=/hugginface
EOF

source /etc/profile.d/script.sh

# cli
# sudo python3 -m fastchat.serve.cli --model-path lmsys/vicuna-7b-v1.3 --device cpu 

# chat cpu
python3 -m fastchat.serve.controller &
python3 -m fastchat.serve.model_worker --model-path lmsys/vicuna-7b-v1.3  --device cpu &
python3 -m fastchat.serve.openai_api_server --host localhost --port 8000 &

# ui 
python3 -m fastchat.serve.gradio_web_server &
