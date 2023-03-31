#!/usr/bin/env sh

set -e  # exit on error
set -x  # show command before execute

apply_one() {
	# only replace filename ends with secrets.yaml
	case "$1" in
	  *secrets.yaml)
	    envsubst < $1 > temp.yaml && mv temp.yaml $1
	    ;;
	  *)
	    echo "The filename does not end with secrets.yaml"
	    ;;
	esac


        kubectl apply -f $1
}

apply() {
        for filename in $@; do
                apply_one $filename
        done

        # rollout restart
	kubectl -n crossbell rollout restart sts/safe-cfg-web
	kubectl -n crossbell rollout restart deploy/safe-cgw-web
	kubectl -n crossbell rollout restart deploy/safe-txs-scheduler
	kubectl -n crossbell rollout restart sts/safe-txs-web
	kubectl -n crossbell rollout restart deploy/safe-txs-worker-contracts-tokens
	kubectl -n crossbell rollout restart deploy/safe-txs-worker-indexer
	kubectl -n crossbell rollout restart deploy/safe-txs-worker-notifications-webhooks
	kubectl -n crossbell rollout restart deploy/safe-ui
}

apply $@
