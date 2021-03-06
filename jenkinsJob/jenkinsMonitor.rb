require 'httparty'
require 'json'
require 'jsonpath'

# Functions
	def GetFullJobsList()

		jobsList = Array.new

		endpointURL = "http://10.120.0.5:8080/api/json?tree=jobs[name,jobs[name,builds[fullDisplayName,result,timestamp,duration],jobs[name,builds[fullDisplayName,result,timestamp,duration]]]]"
		return JSON.parse(HTTParty.get(endpointURL).body)		

	end
    
	def GetRunningWorkers()
		endpointURL = "http://10.120.0.5:8080/computer/api/json?tree=computer"
		response = JSON.parse(HTTParty.get(endpointURL).body)

		jsonPathRegexp = JsonPath.new("$.computer[*]._class")
		response = jsonPathRegexp.on(response)
		return response.count
	end

	def GetRunningJobsList(fList)
 
		jsonPathRegexp = JsonPath.new('..builds[?(@.result==nil || @_current_node["duration"]==0)].fullDisplayName')
		jobsDisplayNameArray = jsonPathRegexp.on(fList)

		jsonPathRegexp = JsonPath.new('..builds[?(@.result==nil || @_current_node["duration"]==0)].timestamp')
		jobsTimestampArray = jsonPathRegexp.on(fList)		
	
		theArray = Array.new
		statusArray = Array.new(jobsTimestampArray.length)

		statusArray.fill("grey")
		theArray = BuildOrderedJobsArray(jobsDisplayNameArray,jobsTimestampArray, statusArray, nil)		
		
		returnHash = Hash.new
		returnHash['count'] = ''
		returnHash['count'] = '+ ' + (theArray.length - 6).to_s if (theArray.length - 6) > 0
		returnHash['items'] = theArray.slice(0..5)
		return returnHash													
	end

	def BuildOrderedJobsArray(nameList,posixList, statusList, durationList)

		orderingArray = Array.new 			

		for i in 0..nameList.size
			orderingHash = Hash.new 			

			if (nameList[i] != nil)
				
				orderingHash['label'] = nameList[i].split(' » ')[-2].gsub('stratio/', '')
                                orderingHash['label'] = orderingHash['label'][0, 25] + '...' if orderingHash['label'].size > 26

				orderingHash['posix'] = posixList[i]
				orderingHash['status'] = statusList[i]
                                orderingHash['branch'] = nameList[i].split(' » ')[-1]
				
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
		jobsDisplayNameArray = jsonPathRegexp.on(fList).each {|x| x = x.sub('stratio/', '')}

		firstArrayl = jobsDisplayNameArray.length

		jsonPathRegexp = JsonPath.new('..builds[?(@.result=="SUCCESS")].duration')
		jobsDurationArray = jsonPathRegexp.on(fList)

		jsonPathRegexp = JsonPath.new('..builds[?(@.result=="SUCCESS")].timestamp')
		jobsTimestampArray = jsonPathRegexp.on(fList)

		statusArray.fill("green", 0..firstArrayl)

		jsonPathRegexp = JsonPath.new('..builds[?(@.result=="FAILURE")].fullDisplayName')
		jobsDisplayNameArray.concat(jsonPathRegexp.on(fList))

		jsonPathRegexp = JsonPath.new('..builds[?(@.result=="FAILURE")].duration')
		jobsDurationArray.concat(jsonPathRegexp.on(fList))

		jsonPathRegexp = JsonPath.new('..builds[?(@.result=="FAILURE")].timestamp')
		jobsTimestampArray.concat(jsonPathRegexp.on(fList))
		
		statusArray.fill("red", firstArrayl+1..jobsDisplayNameArray.length)

		theArray = Array.new	
		theArray = BuildOrderedJobsArray(jobsDisplayNameArray,jobsTimestampArray, statusArray, jobsDurationArray)

		returnHash = Hash.new
                returnHash['count'] = ''
                returnHash['count'] = '+ ' + (theArray.length - 10).to_s if (theArray.length - 10) > 0
                returnHash['items'] = theArray.slice(0..9)
                return returnHash
		
	end

	def GetRunningContainers()

		endpointURL = "http://niquel.stratio.com:22375/containers/json"
                jsonPathRegexp = JsonPath.new('$.[*].Names[0]')

		response = jsonPathRegexp.on(HTTParty.get(endpointURL).body)
			
		return response.length

	end

interval = "30s"	

SCHEDULER.every interval, :first_in => 0 do 

	jRunningContainers = GetRunningContainers()
	jCurrentWorkers = GetRunningWorkers()  		
	
	fullList = GetFullJobsList()
	
	jExecutingJobsList = GetRunningJobsList(fullList)    
	jFinishedJobsList = GetCompletedJobsList(fullList)	


	send_event('jenkinsCurrentDockerContainers', { current: (jRunningContainers) })
	send_event('jenkinsCurrentWorkers', { current: jCurrentWorkers })

	send_event('jenkinsCurrentJobsList', { items: jExecutingJobsList['items'], count: jExecutingJobsList['count'] })		
	send_event('jenkinsCompletedJobsList', { items: jFinishedJobsList['items'], count: jFinishedJobsList['count'] })
end
