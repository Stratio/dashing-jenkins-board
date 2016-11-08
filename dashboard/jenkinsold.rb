<script type='text/javascript'>
$(function() {

   Dashing.gridsterLayout('[{"col":5,"row":1,"size_x":1,"size_y":1},{"col":5,"row":2,"size_x":1,"size_y":1},{"col":1,"row":1,"size_x":2,"size_y":2},{"col":3,"row":1,"size_x":2,"size_y":2}]')

  Dashing.widget_base_dimensions = [262, 365]
  Dashing.numColumns = 5
});
</script>
<% content_for :title do %>Jenkins Jobs<% end %>

<div class="gridster">
	<ul>
	<li data-row="1" data-col="5" data-sizex="1" data-sizey="1"> 
		<div data-id="jenkinsCurrentDockerContainers" data-view="Jenkinsmeter" data-title="Running Containers" data-min="0" data-max="50" style="background-color:#17466c"></div>
	</li>	
	<li data-row="2" data-col="5" data-sizex="1" data-sizey="1"> 	
		<div data-id="jenkinsCurrentWorkers" data-view="Jenkinsmeter" data-title="Jenkins Agents" data-min="0" data-max="20" style="background-color:#172734"></div>
	</li>		
	<li data-row="1" data-col="1" data-sizex="2" data-sizey="2">
	  	<div data-id="jenkinsCurrentJobsList" data-view="Jenkinslist" data-unordered="true" data-title="Jobs in Progress" style="background-color:#dedede; color: #172734; vertical-align:top"></div>
	</li>
	<!-- li data-row="1" data-col="3" data-sizex="2" data-sizey="2">
	 	<div data-id="jenkinsCompletedJobsList" data-view="Jenkinslist" data-unordered="true" data-title="Jobs Completed" style="background-color:#ffffff; color: #172734; vertical-align:top"></div>
	</li -->

        <li data-switcher-interval="20000" data-row="1" data-col="3" data-sizex="2" data-sizey="2">
                <div data-id="jenkinsCompletedJobsList" data-view="Jenkinslist" data-unordered="true" data-title="Jobs Completed" style="background-color:#ffffff; color: #172734; vertical-align:top"></div>
                <div data-id="iframeId1" data-view="Iframe" data-src="https://p.datadoghq.com/sb/fd2a19d0a-c786266355"></div>
        </li>
	</ul> 
</div>
