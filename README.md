To run this dashboard, mount both folders inside a dashing container and fixate the jsonpath version

docker run -v /var/lib/dashing-jenkins-board/jenkinsJob:/jobs -v /var/lib/dashing-jenkins-board/dashboard:/dashboards -e WIDGETS="ddd797bd6b3d1f9bb4984956a60e3387 52abbe6776f4655f7533efbf71bfb3f6 5ad8c764809fd4761dfd46ef042b71f5" -e GEMS="httparty jsonpath','0.7.2" -d -p 9007:3030 --restart=always --name dashing frvi/dashing

