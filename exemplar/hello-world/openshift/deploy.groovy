import groovy.json.JsonSlurper

def inputFile = new File('openshift/properties.json')
def InputJSON = new JsonSlurper().parseText(inputFile.text)
def TEMPLATE_NAME = InputJSON.TEMPLATE_NAME
def APP_ARTIFACT_ID = InputJSON.APP_ARTIFACT_ID
def APP_NAME = InputJSON.APP_NAME
def VERSION = InputJSON.VERSION
def TARGET_REPO = InputJSON.TARGET_REPO
def TARGET_WORKSPACE = InputJSON.TARGET_WORKSPACE



def runCommand (String cmdLine = "" , long wait = 10000 ) 
{
 
 def sout = new StringBuffer() 
 def serr = new StringBuffer() 
 def piped = cmdLine.split("\\|") as List
 def p
 piped.each { cmd ->
    cmd = cmd.trim()
    def cmdList = cmd.split(' ') as List
    if(p)
       p = p.pipeTo(cmdList.execute())
     else
       p = cmdList.execute()
 }
 p.consumeProcessOutput(sout,serr)  
 p.waitForOrKill(wait)
 if(serr)
     println serr
 if(sout)
     println sout
     
 return sout
}

def message;

//login to OC
println "--------------------------------------------"
println "Start Login to OC"
println ""

println "API: ${OCP_API}"
println "Token: ${OCP_TOKEN}"
message = runCommand("/app/oc/oc login ${OCP_API} --token=${OCP_TOKEN}")

println ""
println "End Login to OC"
println "--------------------------------------------"


//switch to Project
println "--------------------------------------------"
println "Start Switch to Project"
println ""

println "Project: ${OCP_PROJECT}"
message = runCommand("/app/oc/oc project ${OCP_PROJECT}")

println ""
println "End Switch to Project"
println "--------------------------------------------"

// Get deployment config
println "--------------------------------------------"
println "Start Deployment Config"
println ""

message = runCommand("/app/oc/oc get deploymentconfig -l deploymentconfig -o name")

println ""
println "End Deployment Config"
println "--------------------------------------------"

//Get Blue and Green Tag
println "--------------------------------------------"
println "Start Blue and Green Tag"
println ""
def blue = new StringBuilder()

if(message.toString().trim() == "") {
	  blue = " "
}
else {
	  blue = message.toString()
}

def blue_tag_number = 0;
def green_tag_number = 0;
if(blue != " ") {
    def tags = blue.split('-')
    blue_tag_number = tags[tags.length-1].toInteger()
}
println("Blue Tag Number: ${blue_tag_number}")

if(blue_tag_number == 0) {
    green_tag_number = 1
}
else {
    green_tag_number = blue_tag_number + 1
}

println("Green Tag Number: ${green_tag_number}")

println ""
println "End Blue and Green Tag"
println "--------------------------------------------"

// Delete Template 
println "--------------------------------------------"
println "Start Delete Template "
println ""

message = runCommand("/app/oc/oc delete template ${TEMPLATE_NAME}")

println ""
println "End Delete Template"
println "--------------------------------------------"

// Create template
println "--------------------------------------------"
println "Start Create template"
println ""

message = runCommand("/app/oc/oc create -f openshift/deploy-template.yaml")

println ""
println "End  Create template"
println "--------------------------------------------"

//Process template
println "--------------------------------------------"
println "Start Process template"
println ""

message = runCommand("/app/oc/oc process ${TEMPLATE_NAME} -p TARGET_REPO=${TARGET_REPO} -p TARGET_WORKSPACE=${TARGET_WORKSPACE} -p APP_NAME=${APP_NAME}-${green_tag_number} -p APP_DC_NAME=${APP_NAME}-${green_tag_number} -p APP_ARTIFACT_ID=${APP_ARTIFACT_ID} -p TAG=${VERSION} | /app/oc/oc create -f -")

println ""
println "End Process template"
println "--------------------------------------------"

//Deploy Application 
println "--------------------------------------------"
println "Start Deploy Application"
println ""

message = runCommand("/app/oc/oc rollout latest ${APP_NAME}-${green_tag_number}")

println ""
println "End Deploy Application"
println "--------------------------------------------"

//Logout 
println "--------------------------------------------"
println "Start Logout"
println ""

message = runCommand("/app/oc/oc logout")

println ""
println "End Logout"
println "--------------------------------------------"

// Delete imagestream
// println "--------------------------------------------"
// println "Start Delete imagestream"
// println ""

// message = runCommand("/app/oc/oc delete is ${APP_ARTIFACT_ID}")

// println ""
// println "End Delete imagestream"
// println "--------------------------------------------"

// Import imagestream
// println "--------------------------------------------"
// println "Start Import imagestream"
// println ""

//message = runCommand("/app/oc/oc import-image --from=docker-rck0.smpartifactory.fg.smp.com/devops/pipeline/tomecat/${APP_ARTIFACT_ID}:${VERSION} ${APP_ARTIFACT_ID}:${VERSION} --confirm")

// println ""
// println "End Import imagestream"
// println "--------------------------------------------"




