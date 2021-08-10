## 1. The build should trigger as soon as anyone in the dev team checks in code to master branch.

Explanation:

- We can use trigger configuration in azure pipelines to control the trigger CI based on branches.
   trigger:
      - master

## 2. There will be test projects which will create and maintained in the solution along the Web and API.

Explanation:
- We can have all 3 projects into one .Net solution and at the time of build step using "**/*.csproj" It will build both the projects and run Test project on another task "TEST".
- We can use "failTaskOnFailedTests: true" this configure in our TEST task step if any of the test is getting failed then pipeline is also going to failed.

##3. The deployment of code and artifacts should be automated to Dev environment.

Explanation:

  - yes we can automate the deployment, first stage is build stage in our pipeline which is building the code and generatic artifact and storing artifact automatically into "Build.ArtifactStagingDirectory" Path.

  - Once the artifact is available then deployment dev stage is triggering to deploy the code into Dev environment.Here we are not using any approval-check configuration so it is directly deploying the code into DEV environment.


## 4. Upon successful deployment to the Dev environment, deployment should be easily promoted to QA and Prod through      automated process.

Explanation:
  - I have included another two stage "Deploy to QA" and "Deploy to QA" after "Deploy to Dev" stage. Once the code is deployed into  Dev Environment then QA and Prod is getting triggered one by one after getting approved by Approvers.
  Based one approval we can promote same artifact into QA and Prod environment.
  - We can control Environment variable based on group level for DEV , QA and Prod environment, Pipeline variable is having different values respective of thier environments like Web-app name , Azure Subscription ID.


## 5. The deployments to QA and Prod should be enabled with Approvals from approvers only.

Explanation:

  - We can control deployment based on approvals at Environment level.
  - we can go to specific environment like QA,Prod and there is "Approval and check" configuration is available.We can choose any check like approval, Business hours or Branch control etc.
  - In our case we will choose approval and provide approval mail id either individual or group mail id. We can use control option for timeout request if request is not yet approved in certain times.
  - Now whenever QA or Prod Deployment pipeline is getting ready for deployment then it will wait for approval, once Request is approved by authorised person(mentioned in Approval check) then only Pipeline will start the deployment
