targets=( stretch centos7 amazonlinux )
init=( "/sbin/init" "/lib/systemd/systemd" "/lib/systemd/systemd" "/usr/sbin/init" "/sbin/init" )
run_opts=( "" "--privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro" "--privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro" "--privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro" "--privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro" )

for target in ${targets[@]}; do \
    docker build --pull --no-cache -t ansible-roles-test-$target \
    -f tests/support/$target.Dockerfile tests/support;
done

ITER=0;
# for target in ${targets[@]}; do \
# 	docker run --rm -d -v $PWD:/etc/ansible/roles/nrinfragent:ro ${run_opts[$ITER]} --name ${target} --workdir /etc/ansible/roles/nrinfragent/tests ansible-roles-test-${target} ${init[$ITER]};
# 	ITER=$(expr $ITER + 1);
# done

for target in ${targets[@]}; do \
	docker run --rm -d -v $PWD:/etc/ansible/roles/nrinfragent:ro ${run_opts[$ITER]} --name ${target} --workdir /etc/ansible/roles/nrinfragent/tests ansible-roles-test-${target} ${init[$ITER]};
	ITER=$(expr $ITER + 1);

	echo "Test: " $target;
	DOCKER_CONTAINER_ID=$(docker ps --filter name=${target} -q)
	docker exec -t $DOCKER_CONTAINER_ID /bin/bash -xec "bash -x support/run-tests.sh && halt -p"
done