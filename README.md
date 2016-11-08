To run this, download this development at ${WORKSPACE}

docker run -v /var/lib/dashing-jenkins-board/jenkinsJob/:/jobs -v ${WORKSPACE}/dashboard:/dashboards -e WIDGETS="ddd797bd6b3d1f9bb4984956a60e3387 52abbe6776f4655f7533efbf71bfb3f6 5ad8c764809fd4761dfd46ef042b71f5" -e GEMS="httparty jsonpath" -d -p 9007:3030 --restart=always --name dashing frvi/dashing

