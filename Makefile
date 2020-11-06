init: 
	@if [ -d files ];\
	 then echo "files dir exists";\
	 else mkdir files;\
	fi
	@if [ -d files/vesc_tool ];\
	 then echo "vesc_tool in files";\
	 else git clone https://github.com/vedderb/vesc_tool files/vesc_tool;\
	fi

build:
	docker build -t vesc-dev:1.0 -f Dockerfile .

interactive: init 
	docker run -e DISPLAY=$(shell ipconfig getifaddr en0):0 \
				--privileged \
				-v /dev/tty.usbmodem3041:/dev/tty.usbmodem3041 \
				--mount type=bind,source=$(shell pwd)/files,target=/home/vescuser \
				-it vesc-dev:1.0

attach:
	docker exec -it $(shell docker ps -lq) bash
	

# template: init
# 	docker run -e DISPLAY=192.168.8.216:0 \
# 				--privileged \
# 				-v /dev/tty.usbmodem1432301:/dev/tty.usbmodem1432301 \
# 				--mount type=bind,source=$(shell pwd)/files,target=/home/fpgauser/ \
# 				--entrypoint /usr/local/src/build_apio_template.sh \
# 				-it vesc-dev:1.0
