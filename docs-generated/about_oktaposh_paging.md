# OktaPosh Paging

## oktaposh_paging

# SHORT DESCRIPTION

The -limit and -next parameters control paging in OktaPosh functions

# LONG DESCRIPTION

Many of the OktaPosh Get-* API calls have a preset default and max limit for the number of values returned by the server. OktaPosh exposes paging with -Limit and -Next. Limit controls the page size. After an initial call to a Get-* function you can use -Next to get the next page until no data is returned. Using -Next will get the next group, using any filtering or query values passed on the first call.  Calling Test-OktaNext you can check if next will return anything or not for root-level objects.

The current documentation has the following defaults and max limits.

Authorization Server: 200/200
Application: 20/200
Application Groups: 20/200
Application Users: 50/500
Groups: 200/200
Group Apps: 20/?
Group Users: 1000/1000
Group Rules: 50/300
Identity Providers: 20/
User: 200/200, 10/200 if -Query used
User Grants, Tokens: 20/200

# EXAMPLES
```
Get-OktaGroup -limit 10
while (Get-OktaGroup -next) { "Got some groups" }
```
A rather contrived example that keeps running until nothing returned.

```
Get-OktaGroup -limit 10
while (Test-OktaNext groups) { Get-OktaGroup -next }
```
Using the Test-OktaNext to determine if there is more data.

# NOTE
The documentation says: Don't write code that depends on the default or maximum value, as it may change.

# TROUBLESHOOTING NOTE
If you receive an HTTP 500 status code, you more than likely have exceeded the request timeout. Retry your request with a smaller limit and page the results.

# SEE ALSO
The API documentation is at https://developer.okta.com/docs/reference/api-overview/#pagination

# KEYWORDS
- Okta
- Posh
- API
- REST
- Paging

