#!/bin/bash

isdel=$1

DIRPATH=`dirname "$(cd ${0%/*} && echo $PWD/${0##*/})"`

cd ${DIRPATH}

for f in $(ls t_*) ; do
	echo -n "build for ${DIRPATH}/${f} "

	ff=${f/t_/t-}
	ff=${ff//_/}
	ff=${ff%.lua}

	${DIRPATH}/glue  ${DIRPATH}/srlua ${DIRPATH}/${f} ${DIRPATH}/${ff}

	if [[ -f ${DIRPATH}/${ff} ]] ; then
		chmod +x ${DIRPATH}/${ff}
		echo -n ", add executable success "
	else
		echo -n ", add executable fail "
	fi

	if [[ "${isdel}" = "yes" ]] ; then
		echo -n ", delete ${DIRPATH}/$f success."
		rm -rf ${DIRPATH}/$f
	else
		echo -n ", delete ${DIRPATH}/$f fail."
	fi
	echo ""
done
