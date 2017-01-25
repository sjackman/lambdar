# Lambdar: Evaluate an R expression on AWS Lambda

Run R on AWS Lambda using [Linuxbrew](http://linuxbrew.sh).

tl;dr: <http://lambdar.sjackman.ca/?e=rnorm(12)>

See the Lambda function [lambdar.js](lambdar.js) and [Makefile](Makefile).

# API Examples

### HTTP GET

```
❯❯❯ curl -L 'http://lambdar.sjackman.ca/?e=355/113'
[1] 3.141593
```

```
❯❯❯ curl 'https://8nhzfyyq66.execute-api.us-west-2.amazonaws.com/prod/lambdar?e=355/113'
[1] 3.141593
```

### HTTP PUT

```
❯❯❯ curl -d '355/113' https://8nhzfyyq66.execute-api.us-west-2.amazonaws.com/prod/lambdar
[1] 3.141593
```

Sadly, HTTP PUT does not work with http://lambdar.sjackman.ca.
