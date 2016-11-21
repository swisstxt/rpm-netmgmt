NAME=netmgmt
REPO=github.com/swisstxt/netmgmt
REPOURL=https://github.com/swisstxt/netmgmt

HOME=$(shell pwd)
SPECS=${HOME}/SPECS/
SOURCES=${HOME}/SOURCES/
GITCLONE=${SOURCES}/src/${REPO}
RPMBUILD=${HOME}/rpmbuild

VERSION=$(shell /opt/buildhelper/buildhelper getgittag ${GITCLONE})
RELEASE=${BUILD_NUMBER}
SPEC=$(shell /opt/buildhelper/buildhelper getspec ${NAME})
ARCH=$(shell /opt/buildhelper/buildhelper getarch)
OS_RELEASE=$(shell /opt/buildhelper/buildhelper getosrelease)

export GOPATH=${SOURCES}
export PATH :=${GOPATH}/bin/:$(PATH)

all: build

clean:
	rm -rf ${RPMBUILD}
	rm -rf ${SOURCES}/src ${SOURCES}/bin ${SOURCES}/lib
	rm -rf ${SOURCES}/netmgmt.bin
	mkdir -p ${RPMBUILD}/SPECS/ ${RPMBUILD}/SOURCES/
	mkdir -p ${SPECS} ${SOURCES}/src ${SOURCES}/bin ${SOURCES}/pkg
	go get github.com/tools/godep

get-src:
	echo ${GOPATH}
	git clone --branch newdevops ${REPOURL} ${GITCLONE}
	echo "$(VERSION)" >"${SOURCES}/netmgmt.version"

tidy-src:
	rm -rf ${SOURCES}/src ${SOURCES}/bin ${SOURCES}/pkg

build-src: get-src
	cd ${GITCLONE}; godep restore; godep go install
	cp ${SOURCES}/bin/netmgmt ${SOURCES}/netmgmt.bin

build: clean build-src tidy-src
	cp -r ${SPECS}/* ${RPMBUILD}/SPECS/ || true
	cp -r ${SOURCES}/* ${RPMBUILD}/SOURCES/ || true
	rpmbuild -ba ${SPEC} \
	--define "ver $(shell cat ${SOURCES}/netmgmt.version") \
	--define "rel ${RELEASE}" \
	--define "name ${NAME}" \
	--define "os_rel ${OS_RELEASE}" \
	--define "arch ${ARCH}" \
	--define "_topdir ${RPMBUILD}" \
	--define "_builddir %{_topdir}" \
	--define "_rpmdir %{_topdir}" \
	--define "_srcrpmdir %{_topdir}" \

publish:
	/opt/buildhelper/buildhelper pushrpm yum-01.stxt.media.int:8080/swisstxt-centos
