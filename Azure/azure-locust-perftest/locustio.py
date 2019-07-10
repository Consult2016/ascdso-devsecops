# locustio.py
# Used by https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/Azure/azure-locust-perftest/azure-locust-perftest.sh
# Based on https://microsoft.github.io/PartsUnlimitedMRP/pandp/200.1x-PandP-LocustTest.html

from locust import HttpLocust, TaskSet, task

class UserBehavior(TaskSet):

    @task
    def get_tests(self):
        self.client.get("/tests")
        
    @task
    def put_tests(self):
        self.client.post("/tests", {
                    "name": "load testing",
                    "description": "checking if a software can handle the expected load"
                  })
        

class WebsiteUser(HttpLocust):
    task_set = UserBehavior