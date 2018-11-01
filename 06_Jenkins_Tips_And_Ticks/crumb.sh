crumb=$(curl -u "tigger:tigger" -s 'http://localhost:8080/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)')
curl -u "tigger:tigger" -H "$crumb" -X POST http://localhost:8080/job/test-curl/build?delay=0sec
curl -u "tigger:tigger" -H "$crumb" -X POST http://localhost:8080/job/test-curl-con-parametros/buildWithParameters?NAME=manolo&LASTNAME=garcia