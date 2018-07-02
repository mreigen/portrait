## Minh's notes

Features that I picked to work on:
 - User security

### User security
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
