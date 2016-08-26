require 'httparty'
require 'json'
require 'jsonpath'

# Functions
	def GetFullJobsList()

		jobsList = Array.new

		endpointURL = "http://jenkins.stratio.com/api/json?tree=jobs[name,jobs[name,builds[fullDisplayName,result,description,timestamp,duration],jobs[name,builds[fullDisplayName,result,description,timestamp,duration]]]]"
		
		return JSON.parse(HTTParty.get(endpointURL).body)		

	end
    
	def GetRunningWorkers()
		endpointURL = "http://jenkins.stratio.com/computer/api/json?tree=computer"
		response = JSON.parse(HTTParty.get(endpointURL).body)

		jsonPathRegexp = JsonPath.new("$.computer[*]._class")
		response = jsonPathRegexp.on(response)
		## In order to exclude master slave we remove 1 computer
		return response.count - 1
	end

	def GetRunningJobsList(fList)
 
		jsonPathRegexp = JsonPath.new('..builds[?(@.result==nil)].fullDisplayName')
		jobsDisplayNameArray = jsonPathRegexp.on(fList)		

		jsonPathRegexp = JsonPath.new('..builds[?(@.result==nil)].timestamp')
		jobsTimestampArray = jsonPathRegexp.on(fList)		
			
		theArray = Array.new
		statusArray = Array.new(jobsTimestampArray.length)

		statusArray.fill("grey")
		theArray = BuildOrderedJobsArray(jobsDisplayNameArray,jobsTimestampArray, statusArray, nil)		
		
		puts "Running jobs" + theArray.length.to_s

		return theArray.slice(0..9)															
	end

	def BuildOrderedJobsArray(nameList,posixList, statusList, durationList)

		orderingArray = Array.new 			

		for i in 0..nameList.size
			orderingHash = Hash.new 			

			if (nameList[i] != nil)
				
				orderingHash['label'] = nameList[i]							
				orderingHash['posix'] = posixList[i]
				orderingHash['status'] = statusList[i]
				
				if statusList[i]=="grey"

					orderingHash['value'] = Time.now.to_i - (posixList[i]/1000)					
					
				else
					orderingHash['value'] = durationList[i]/1000									
				end
				
				orderingHash['value'] = Time.at(orderingHash['value']).strftime("%M:%S")				
				
			end
			if (!orderingHash.empty?) 
				orderingArray.push(orderingHash)
			end
		end 

		orderingArray = orderingArray.sort_by { |h| 					
			-h['posix']
		}	
		

		return orderingArray
	end

	def GetCompletedJobsList(fList)
 		
		statusArray = Array.new
		jsonPathRegexp = JsonPath.new('..builds[?(@.result=="SUCCESS")].fullDisplayName')
		jobsDisplayNameArray = jsonPathRegexp.on(fList)		

		firstArrayl = jobsDisplayNameArray.length

		jsonPathRegexp = JsonPath.new('..builds[?(@.result=="SUCCESS")].duration')
		jobsDurationArray = jsonPathRegexp.on(fList)

		jsonPathRegexp = JsonPath.new('..builds[?(@.result=="SUCCESS")].timestamp')
		jobsTimestampArray = jsonPathRegexp.on(fList)

		statusArray.fill("green", 0..firstArrayl)

		jsonPathRegexp = JsonPath.new('..builds[?(@.result=="FAILURE")].fullDisplayName')
		jobsDisplayNameArray.push(jsonPathRegexp.on(fList))		

		jsonPathRegexp = JsonPath.new('..builds[?(@.result=="FAILURE")].duration')
		jobsDurationArray.concat(jsonPathRegexp.on(fList))


		jsonPathRegexp = JsonPath.new('..builds[?(@.result=="FAILURE")].timestamp')
		jobsTimestampArray.concat(jsonPathRegexp.on(fList))
		
		statusArray.fill("red", firstArrayl+1..jobsDisplayNameArray.length)

		theArray = Array.new	
		theArray = BuildOrderedJobsArray(jobsDisplayNameArray,jobsTimestampArray, statusArray, jobsDurationArray)		

		puts "Completed: " +theArray.length.to_s

		return theArray.slice(0..9)											
		
	end

	def GetRunningContainers()
		endpointURL = "http://jenkins.stratio.com:22375/containers/json"
		response = JSON.parse(HTTParty.get(endpointURL).body)

		return response.count

	end

interval = "10s"	

SCHEDULER.every interval, :first_in => 0 do 

	fullList = GetFullJobsList()
    	jCurrentWorkers = GetRunningWorkers()  		
    	jExecutingJobsList = GetRunningJobsList(fullList)    
    	jFinishedJobsList = GetCompletedJobsList(fullList)	
    	jRunningContainers = GetRunningContainers()

	send_event('jenkinsCurrentDockerContainers', { value: jRunningContainers })
	send_event('jenkinsCurrentWorkers', { value: jCurrentWorkers })		
	send_event('jenkinsCurrentJobsList', { items: jExecutingJobsList })		
	send_event('jenkinsCompletedJobsList', { items: jFinishedJobsList })
end
