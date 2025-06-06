# aws_pet_project
My AWS pet project to learn how things can be done there

# features 

This small lambda will download the magnificient seven stock data from Alpha Vantage in a scheduled manner, put it into a json that will be gzipped and uploaded to an s3 bucket.

I am planning to implement something that will consume this data later.

The whole thing is planned to fit the AWS free tier, but if you would like to deploy it, before you would do that, please consider to set up billing alerts.

# deploy

There is an automatic github action that will do the necessary terraform steps:

 * creates an AWS S3 bucket, and make it publicly available 
 * uploads my (data collector) AWS Lambda function, implemented in plain java, creates an env variable to pass my Alpha Vantage API key
 * schedules it using AWS EventBridge (CloudWatch Events)
 
# destroy worklfow 

As this is in AWS free tier, I needed a script to destroy everything I made with this playground.
You can run it via github action:

```
Actions tab → Destroy workflow → Run workflow
```