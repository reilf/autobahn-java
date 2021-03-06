BUILD_DATE=$(shell date -u +"%Y-%m-%d")
AUTOBAHN_JAVA_VERSION='17.8.2'
AUTOBAHN_JAVA_VCS_REF='unknown'

#export AUTOBAHN_TESTSUITE_VCS_REF=`git --git-dir="../autobahn-testsuite/.git" rev-list -n 1 v${AUTOBAHN_TESTSUITE_VERSION} --abbrev-commit`
#export BUILD_DATE=`date -u +"%Y-%m-%d"`

#git rev-list -n 1 v${AUTOBAHN_JAVA_VERSION} --abbrev-commit


#
# Demos
#
crossbar:
	docker run \
		--rm -it -p 8080:8080 --name crossbar \
		crossbario/crossbar

python:
	docker run \
		-it --rm --link crossbar \
		-v ${shell pwd}/demo-gallery/python:/test  \
		crossbario/autobahn-python \
		python -u /test/test_component.py

java:
	docker run -it --rm \
		--link crossbar \
		-v ${shell pwd}:/workspace \
		crossbario/autobahn-java:netty \
			/bin/bash -c "gradle installDist -PbuildPlatform=netty && DEMO_GALLERY_OPTS="-DlogLevel=INFO" demo-gallery/build/install/demo-gallery/bin/demo-gallery ws://crossbar:8080/ws"


#
# Build
#
build_autobahn:
	docker run -it --rm \
		-v ${shell pwd}:/workspace \
		crossbario/autobahn-java:netty \
		gradle -PbuildPlatform=netty distZip

#
# Toolchain
#
build_toolchain:
	time docker build \
		--build-arg BUILD_DATE=${BUILD_DATE} \
		--build-arg AUTOBAHN_JAVA_VCS_REF=${AUTOBAHN_JAVA_VCS_REF} \
		--build-arg AUTOBAHN_JAVA_VERSION=${AUTOBAHN_JAVA_VERSION} \
		-t crossbario/autobahn-java \
		-t crossbario/autobahn-java:netty \
		-t crossbario/autobahn-java:netty-${AUTOBAHN_JAVA_VERSION} \
		-f ./docker/Dockerfile.netty .

publish_toolchain:
	docker push crossbario/autobahn-java
	docker push crossbario/autobahn-java:netty
	docker push crossbario/autobahn-java:netty-${AUTOBAHN_JAVA_VERSION}

list:
	-docker images crossbario/autobahn-java:*

clean:
	sudo rm -rf ./.gradle/ ./build ./autobahn/build ./demo-gallery/build/
	./removeall.sh
