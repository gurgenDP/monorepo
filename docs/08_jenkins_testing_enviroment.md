# Jenkins testing environment deployment

> Summary of the proposed change

Deploy Jenkins testing environment to be able to integrate it with the Metrics app and be able to have a more real-world environment for testing.

# References

> Link to supporting documentation, GitHub tickets, etc.

[Jenkins](https://jenkins.io/)  
[Google Cloud Jenkins application](https://github.com/GoogleCloudPlatform/click-to-deploy/blob/master/k8s/jenkins/README.md)
[Amazon AWS](https://aws.amazon.com/)

# Motivation

> What problem is this project solving?

Creating the Jenkins test environment will provide the data for the Metrics application.
The Jenkins test environment will give us the ability to test the whole process of importing and displaying the project metrics data.

# Goals

> Identify success metrics and measurable goals.

* Jenkins server is running and available for testing by anyone in the team.
* Configuration of the Jenkins to run the tests from the test project. 

# Non-Goals

> Identify what's not in scope.

The creation of the test project is not in the scope of this project.

# Design

> Explain and diagram the technical design

`Amazon AWS instance` -> `Jenkins Server`

> Identify risks and edge cases

Because different builds require different environments for Jenkins to run the build 
(in our case - we need to run the builds with npm, so the Node.js is required), we need to run 
the builds in a separate docker container and this could require an additional configuration, 
for example, configuring the docker client, or Jenkins user roles to be able to run the docker container, etc.

# API

> What will the proposed API look like?

The Jenkins API is described in this article: [Jenkins remote access api](https://wiki.jenkins.io/display/JENKINS/Remote+access+API).

# Dependencies

> What is the project blocked on?

No blockers.

> What will be impacted by the project?

Testing of the Jenkins integration will be impacted.

# Testing

> How will the project be tested?

This project will be tested manually.

# Alternatives Considered

> Summarize alternative designs (pros & cons)

* Setups Jenkins server on Amazon AWS.
    - Pros:
         - The AWS instance is free for one year.
         - Has an excellent [setup guide](https://d1.awsstatic.com/Projects/P5505030/aws-project_Jenkins-build-server.pdf) that explains how to create an instance and deploy the Jenkins server.
         - Easy to maintain. You could just connect to the AWS instance and use it and use it the way that you would use a computer in front of you.
    - Cons:
         - You need to configure the AWS instance and firewall rules manually via the user interface (no automation available), which takes a bit more time in comparison to using the Google Kubernetes deployment.
         
         
* Setup Jenkins on Google Kubernetes Engine.
    - Pros:  
         - Easy to set up. The configuration process is fully automated, and it is needed just to configure Jenkins projects.
           It is needed just to go through the [Jenkins Google cloud setup flow](https://console.cloud.google.com/marketplace/details/google/jenkins).
         - Jenkins has a [free application](https://console.cloud.google.com/marketplace/details/google/jenkins) on the Google Cloud.
    - Cons: 
         - The Kubernetes Engine is the paid feature of the Google Cloud that uses a couple of other paid features like Compute Engine.
         - Hard to maintain because you cannot just SSH connect to the instance with the Jenkins server to make any changes. For connection, you need to use the "kubectl" CLI.
         
         
* Serve the Jenkins server using the local machine and ngrok.
    - Pros:
         - Easy to setup. You need just to run the Jenkins locally and set up the tunnel to the localhost using the ngrok for other users to be able to connect.
    - Cons: 
         - Because Jenkins stores the data (pipeline configurations, build, build artifacts, etc.) locally,
          using the file system, the Jenkins instance should be running on the same machine all the time.
         - The server will be very dependent on that configured server availability (app availability, computer availability).
         
         
* Setup Jenkins on Google Compute Engine.
    - Pros:
         - Easy to connect to the container using SSH to make any changes to the Jenkins.
    - Cons: 
         - Pretty complicated setup mechanism because we have a lot of configuration items.
         - We should set up the Jenkins storage manually in some other place like [Cloud Storage](https://cloud.google.com/storage)
          because the Compute Engine instance has too few memory to store all tools, required by Jenkins, and builds and artifacts on the instance.
         - The Compute Engine is a paid feature on the Google Cloud.

# Timeline

> Document milestones and deadlines.

DONE:
  - Investigation of ways to deploy the Jenkins server.
  - Found the best approach to create the Jenkins server.

NEXT:
  - Create the Jenkins server.
  - Set up the test project tests running on Jenkins.
  
# Results

> What was the outcome of the project?

During the investigation of the best ways to deploy the Jenkins build server, we decided to use the Amazon AWS because of the following reasons: 
 * It has a free year trial.
 * It has pretty good setup documentation. 
 * It allows you to connect to the instance Jenkins running through the SSH, which improves the maintainability.