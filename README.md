
##### Minh Reigen Code Challenge

Features that I picked to work on:
 - User security
 - Non-blocking
 - Efficiencies of Scale

## User security
#### Reason
I picked to work on this problem because I think security issues are very important and interesting.
#### Description
##### Salt / Encrypted Password
In this feature, I modeled a very simple encryption method using a 8 bytes `salt` string to generate a password using SHA2 (Secure Hash Algorithm 2). The `salt` and `encrypted_password` strings are saved in the `user` record.

##### Forgot password
When a user forgets his/her password, they can go to the `reset_password` page to enter their email, the reset instructions will be sent to that email. The instruction will include a link with a `reset_token` which will be expired (set to `nil`) after a successful password reset occurred. Clicking on the reset password link will direct them to the page where they can enter the new password and save it.

I deleted the `password` column and added a callback in the `User` model so that every time we call:

```
user.update password: 'new-password'
```
the password will be encrypted and saved to the database in the `encrypted_password` column.
#### Future optimization
I will combine these 2 columns (`salt` and `encrypted_password`) into one and store the `salt` as the first 12 chars of the `encrypted_password` (we need `4*(n/3)` to represent `n` bytes - so 8 bytes will need 12 chars to represent)

Password reset token should have an expiration date/time (for example 24 hours). If it is not used within this time frame, then it will be set to invalid (expired)

#### Roadblocks
No major roadblocks.
#### Estimation accuracy
Time estimation: 8 hours. Actual time needed: 10 hours. Time spent: new code base, refactor, set up tools (email sending, test helpers...), actual feature implementation.

#### Running instructions

Please set up an environment variable BASE_URL to http://localhost:3000. If you are to deploy this app, please set it to your rails server's url.

Since I removed the `password` column inside the `users` table and added a few columns for password encryption, password reset token and email, please run:

```
rake db:drop
rake db:create
rake db:migrate
rake db:seed
```
To start the app
```
rails s
```
To run the test suite
```
rspec
```

## Non-blocking
#### Reason
Scaling problems are fun and worthy to be solved. I thought I could apply Sidekiq for background processing, Pusher for realtime status update for this solution and *webhook callback* for remote API requests.

#### Description
I chose Sidekiq for background processing instead of other background job libraries like ActiveJob (async or inline) because Sidekiq is using Redis and threads to handle multiple jobs concurrently instead of hitting our database like ActiveJob (async or inline adapters.)

After a user enters a site URL to be processed, the app will set the site's status to `started` and put the job in the background queue. The site's index page will display 'Processing image, please wait...' while the Javascript code will subscribe to a Pusher channel and event. After the job is finished processing in the queue, it will push the site's data hash to Pusher to be broadcast and send a POST request to the `callback_url` if it is present. Javascript code in the front-end will receive the broadcast data hash, then displays the new status and processed image's URL - without having the page to refresh.

The reason I'm using Pusher instead of Rails' ActionCable for this project is because it's faster to develop for this code challenge, and it's free to use with a rate limit.

Image processing is in progress.
![enter image description here](https://s3-us-west-1.amazonaws.com/survey-monkey-test/processing-please-wait.png)

Processing is finished.
![enter image description here](https://s3-us-west-1.amazonaws.com/survey-monkey-test/process-done.png)

#### Monitoring
Queues and jobs can be monitored via Sidekiq UI here:
http://localhost:3000/sidekiq/queues


#### Webhook
For remote API requests to create a site, a parameter `site[callback_url]=http://callmeback.com/post` can be sent along with `site[url]`. A `started` status will be in the response while the background job is processing the image generation.

```
curl -X POST -d "site[url]=https://google.com&site[callback_url]=http://ptsv2.com/t/l4j09-1530644184/post" -H "Accept: application/json" http://admin:admin@localhost:3000/sites
```
A callback request (webhook) will be sent (as a POST) with the processing results to the client's `callback_url`

In this example, I am using the POST test service from http://ptsv2.com to verify the POST callbacks.  You can create your own POST url for the `callback_url`, or use the one I have created `site[callback_url]=http://ptsv2.com/t/l4j09-1530644184/post`

After the image generation is finished, you can verify if the data was posted back correctly to the `callback_url` by going here http://ptsv2.com/t/l4j09-1530644184

#### Future optimization
Currently, each `site` will have its own `callback_url` for each request. I would love to have each `user` to have their own `callback_url` so that when that user sends image generation requests, the app will automatically sends callbacks to the `user`'s `callback_url`. Site's `callback_url` if present - will override User's `callback_url`.

#### Roadblocks
No major roadblocks.

#### Estimation accuracy
Time estimation: 4 hours. Actual time needed: approximately 4.5 hours. (including webhook callback implementation, documentation: 30-45mins)

#### Running instructions
I am using Pusher notification for this solution, so please add these environment variables and (re)start the app.
```
PUSHER_API_KEY=24adc735f893cf5f5661
PUSHER_APP_ID=554190
PUSHER_SECRET=24d2cb71f9817f775110
PUSHER_CLUSTER=us2
```

## Efficiencies of Scale
#### Reason
I picked this feature because it is related to non-blocking and interesting. I was asked a similar question in the interview so I wanted to implement this.

#### Description
My solution is to have the app look for an already captured site that has the same `url` provided. Since we are searching for already captured sites by their `url` so I indexed the column `url` in the `Sites` table so that it can be quickly looked up.

#### Future optimization
There is a timing issue with the front-end. Since looking up the already captured sites by the indexed `url` column is very fast, sometimes the JavaScript Pusher code is not ready yet to receive broadcast notifications. This would cause the fast processes to display `Processing image. Please wait...` and won't change to the image's URL until after we refresh the page. I would love to find a solution for this.

#### Roadblocks
No major roadblocks.

#### Estimation accuracy
Time estimation: 3 hours. Actual time needed: approximately 3 hours!
#### Running instructions
I have added a "Delete All" (all sites) button to make testing this easier. You can clear out all the sites for this logged in user first before capturing sites. After you capture a site, wait for the image to be processed. The view will be updated automatically with real-time callback (done in non-blocking.) After the first image is done processing, please capture the same site again. You will notice that this time, the process is much faster. This is because the back-end doesn't have to capture the site again, but it found an already captured site and re-use its image.
