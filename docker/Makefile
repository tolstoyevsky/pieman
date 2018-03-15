default: docker_build

docker_build:
	@docker build \
	    --build-arg VCS_REF=`git rev-parse --short HEAD` \
	    --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
	    -t cusdeb/pieman .

