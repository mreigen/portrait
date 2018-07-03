
##### Minh Reigen Code Challenge

Features that I picked to work on:
 - User security
 - Non-blocking

## User security
#### Reason
I picked to work on this problem because I think security issues are very important and interesting.
#### Description
In this feature, I modeled a very simple encryption method using a 8 bytes `salt` string to generate a password using SHA2 (Secure Hash Algorithm 2). The `salt` and `encrypted_password` strings are saved in the `user` record.

When a user forgets his/her password, they can go to the `reset_password` page to enter their email, the reset instructions will be sent to that email. The instruction will include a link with a `reset_token` which will be expired (set to `nil`) after a successful password reset occurred. Clicking on the reset password link will direct them to the page where they can enter the new password and save it.

I deleted the `password` column and added a callback in the `User` model so that every time we call:

```
user.update password: 'new-password'
```
the password will be encrypted and saved to the database in the `encrypted_password` column.
#### Future optimization
I will combine these 2 columns (`salt` and `encrypted_password`) into one and store the `salt` as the first 12 chars of the `encrypted_password` (we need `4*(n/3)` to represent `n` bytes - so 8 bytes will need 12 chars to represent)

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
Scaling problems are fun and worthy to be solved. I thought I could apply Sidekiq for background processing and Pusher for realtime status update for this solution.

#### Description
I chose Sidekiq for background processing instead of other background job libraries like ActiveJob because Sidekiq is using threads to handle multiple jobs concurrently instead of hitting our database like ActiveJob.

After a user enters a site URL to be processed, the app will set the site's status to `started` and put the job in the background queue. The site's index page will display 'Processing image, please wait...' while the Javascript code will subscribe to a Pusher channel and event. After the job is processed in the queue, it will push the site's data hash to Pusher to be broadcast. Javascript code in the front-end will receive the broadcast data hash then displays the new status and processed image's URL.

The reason I'm using Pusher instead of Rails' ActionCable for this project is because it's faster to develop for this code challenge, and it's free to use with a rate limit.

#### Future optimization
For 'remote' API requests to create a site, like the one below will not wait until the processing is done and receive a response with `succeeded` status any more.
```
curl -X POST -d "site[url]=https://google.com" -H "Accept: application/json" http://admin:admin@localhost:3000/sites
```
I would love to implement a callback request (webhook) to post back the process result to the client's `callback_url`

#### Roadblocks
No major roadblocks.

#### Estimation accuracy
Time estimation: 4 hours. Actual time needed: approximately 4 hours.

#### Running instructions
I am using Pusher notification for this solution, so please add these environment variables and (re)start the app.
```
PUSHER_API_KEY=24adc735f893cf5f5661
PUSHER_APP_ID=554190
PUSHER_SECRET=24d2cb71f9817f775110
PUSHER_CLUSTER=us2
```

