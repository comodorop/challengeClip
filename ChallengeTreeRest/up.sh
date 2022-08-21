sudo docker build -t pet:1.1 .
sudo docker run --name=pet4 --env PORT=3003 -p 3003:3003 -d pet:1.1