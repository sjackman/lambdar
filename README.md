# ƛR: Lambdar

Run R on AWS Lambda using [Linuxbrew](http://linuxbrew.sh).

# tl;dr

<http://lambdar.sjackman.ca/?e=stem(rnorm(100))>

```
  The decimal point is at the |

  -2 | 3
  -1 | 87666
  -1 | 333332210
  -0 | 999988888655
  -0 | 444433333222222111110
   0 | 00001111111112223344
   0 | 5556667777889999
   1 | 00111123344
   1 | 556
   2 | 14
```

# Code

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

Sadly, HTTP PUT does not work with the redirected URL <http://lambdar.sjackman.ca>.
