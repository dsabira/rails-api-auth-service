# Simple Rails API Auth Service Example  
Utilizes:  
* OAUth2  
* OpenID Connect  
* JWT / Identity Token  
* Opaque Access Token  
* Rails API  
* PostgreSQL  
  
This is a *very basic* example.  Many additional improvements should be made for a Production ready product.  
Assumes Front End operates on localhost:3000 (CORS)  
Assumes this auth service operates on localhost:4000  
Requires a private key in the initializer for doorkeeper\openid\_connect  
`ssh-keygen -t rsa -b 4096 -f i ~/.ssh/TEST-AUTH -N ''`
`sed 's/$/\\n/' ~/.ssh/TEST-AUTH | tr -d '\n'` and add to initializer (not directly, do not commit to repo, consider Figaro / dotenv, etc.)  

## To Use for Development  
1.  Generate Private Key as outlined above and add to doorkeeper\_openid\_connect initializer.  
2.  Run the auth service on localhost:4000
3.  Access via a client on localhost:3000 (or Postman, etc)  


## Steps Taken to Create This Service 
1.  `bundle install` devise, doorkeeper, doorkeeper-openid\_connect, rack-cors gems  
2.  `rails db:create`  
3.  Configure `config/initializers/cors` as needed (least privilege necessary)  
4.  Install Devise  
```
rails g devise:install  
rails g devise user
rails db:migrate  
```
4.  Install Doorkeeper  
`rails g doorkeeper:install`  
[Configure Doorkeeper Initializer](https://github.com/doorkeeper-gem/doorkeeper#installation)  
`rails g doorkeeper:migration && rails db:migrate`  
5.  Add migration designating User as the resource_owner && `rails db:migrate`   
6.  Configure api controller for authorization & json   
7.  Remove doorkeeper authorization from controllers as appropriate with `skip\_before\_action`  
8.  `rails g devise:controllers [users]`  
9.  Config barebone Devise route  
10.  Add strong params to registrations controller  
11.  Seed database for dummy front end client (NOTE: usually handled via config variables but skipped for simplicity)  
  `rails db:seed`  
12.  From rails console, obtain client_id for OAuth requests  `Doorkeeper::Application.last.uid` (remember: simple example, not production)   
13.  Config barebone Doorkeeper routes  
14.  Install Doorkeeper Open ID Connect  
```
rails generate doorkeeper:openid\_connect:install  
rails generate doorkeeper:openid\_connect:migration  
rails db:migrate  
```  
15.  Update doorkeeper_openid_connect initializer  
16.  Start your basic sample auth service on localhost:4000
17.  Submit requests from client (see documentation below)  
18.  Decode JWT (client, other service, etc) with the Public Key  


## API Documentation
### Authentication via Devise  
* Registration
    POST /users email, password, password_confirmation (validate client side)
```
{
  "user": {
    "email": "josh@gmail.com",
    "password": "newpass",
    "password_confirmation": "newpass"
  }
}
```
    Return user resource 
```
{
  "id": 1,
  "email": "josh@gmail.com",
  "created_at": "2017-01-06T15:15:46.912Z",
  "updated_at": "2017-01-06T15:15:46.916Z"
}
```
### Delegation via Doorkeeper  
* Access Token
  POST /oauth/token grant_type, email, password, client_id
```
{
  "grant_type": "password",
  "email": "josh@gmail.com",
  "password": "newpass",
  "scope": "openid",
  "client_id": "506b281cbd25d7d8b573db77dce4-generated-client-id"
}
```
  Returns tokens
```
{
  "access_token": "800302477be2b381fbb7b90bf4a92d945a809ca3dc0771c690556ef35d6572b7",
  "token_type": "bearer",
  "expires_in": 86400,
  "scope": "openid",
  "created_at": 1483718426,
  "id_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6IlFXTThGa05KYlBWVjNHaFdTN2ZtSmpTSmNOZ0VHREZZQkxWeGtIU0lnU0EifQ.eyJpc3MiOiJodHRwOi8vbG9jYWxob3N0OjQwMDAiLCJzdWIiOiIxIiwiYXVkIjoiNTA2YjI4MWNiZDI1ZDdkOGI1NzNkYjc3ZGNlNDZjODg0ZWQ1OGU5MGZkMzdhYTNhODJhYmVjODVhZGYwNjRjYSIsImV4cCI6MTQ4MzcxODU0NiwiaWF0IjoxNDgzNzE4NDI2LCJhdXRoX3RpbWUiOjE0ODM3MTg0MjZ9.eYebizB1IoimCzEdTnizdSnl0Qvnpmw8_1zcfJuYqdTzI0ox_t_OUQi8lu06Gts03ybWfIdfdGy6La3oR1E8XiQLcRCU2t_CagC2203DJJoxhK3vi5HP7fSlYvGWLXXNLZLXLNgLCkQvsWaatqaOJSlNoD6nelHnQNQ6aUT2vDLhOHXtoXY7Q78g68EG64RLItiRgGipgBGsjcNRV0w9Zscrd40GuMxnbjgLEl6iEU0RTyG10p154ilepjP3nVHYmx5kx_qPSzF8_58kBActH2ECojaLX83ROZ4frTDS4zbIlVEh_RxW_AgVGE5o8HyW559jaOT3a4YnercYESqMFkjW1Or_BCKI_BWkI69ePwXfkvsRFif5XO2vIg2BOcpxoVOt3MEGVunvG8BFYU0SEalChB4i4vuniAFxIZ2VrQWK3cBAcwVtP7RxrYH1ukzqsQcsHsVoFQH0ijAdtgIFmg43xtP_96qUQ0fOVlDTzUph4EWmHLmT3oevcjN07j0WMgt7skZta-L49nV4W3Ykij3IFB7E1rNGxJO0lT1nmFlz9ni099-tuIpaPSasiIGfvqbz-50WQ5nzWQCnnEWvcqm_Vi8aWbLVnDUDwtcYcXWGQ7UdV6rfTkjJHDXLe1lwPVpye71rjB87DwfH4_15F_nm00RuoDWzCVpABiePThY"
}
```  
* Access Token Info  
  GET /oauth/token/info  Authorization: Bearer AT  
  Must pass Access Token as an Authorization Header  
  Returns Access Token Info  
```
{
  "resource_owner_id": 1,
  "scopes": [
    "openid"
  ],
  "expires_in_seconds": 86302,
  "application": {
    "uid": "506b281cbd25d7d8b573db77dce46c884ed58e90fd37aa3a82abec85adf064ca"
  },
  "created_at": 1483719570
}
```

* Revoke Access Token  
  POST /oauth/revoke token  
  Returns 200  

### Identity via Doorkeeper OpenID Connect  
* Get Identity Info  
  GET /oauth/userinfo  Authorization: Bearer AT  
  Must pass Access Token as an Authorization Header  
  `Authorization: Bearer 800302477be2b381fbb7b90bf4a92d945a809ca3dc0771c690556ef35d6572b7`  
  Returns sub & additional claims if created / specified (not included here but see below)  
```
{
  "sub": "1"
}
```
  


## Additional Features to Consider  
Add more claims such as profile
Configure Devise Model: add name to model, migration, controller (strong parameters) and doorkeeper_openid_connect so it can be returned with Identity  
Configure Devise Model: remove options (rememberable, for example) & update with a migration   
Add more routes as appropriate (Devise has many built in)  
uuid:   
  Enable uuid as primary key [uuid in Rails 5](http://blog.bigbinary.com/2016/04/04/rails-5-provides-application-config-to-use-UUID-as-primary-key.html)  
  [uuid in Doorkeeper / Postgres](https://github.com/doorkeeper-gem/doorkeeper/wiki/Using-PostgreSQL-UUIDs-as-primary-keys-with-Doorkeeper)  
json-api: [How and Why to Use JSON API w/ Rails](http://blog.arkency.com/2016/02/how-and-why-should-you-use-json-api-in-your-rails-api/)
Figaro:  [Use Figaro env variables for database secrets](http://www.ickessoftware.com/blog/rails-postgres-installation-tutorial)
CORS:  Lock down CORS in initializer
Add custom mailer - extend application_mailer, create custom mailer, add custom mailer layouts, add to devise initializer  
  Consider moving mailer to separate service  
  Install SES API gem for mailing, if appropriate
