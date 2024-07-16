package main

import (
	"context"
	"encoding/json"
	"fmt"
	"testing"

	"github.com/aws/aws-lambda-go/events"
)

func TestHandleRequest(t *testing.T) {
	jwtIssuer = "https://keycloak-cqen-redhat-sso.apps.dev.openshift.cqen.ca/auth/realms/lab-cqen"
	jwtIssuerCertsPath = "/protocol/openid-connect/certs"
	jwtAudience = "lab-api"

	event := events.APIGatewayCustomAuthorizerRequest{
		Type:               "TOKEN",
		MethodArn:          "arn:aws:execute-api:ca-central-1:123456789012:xxx0abcd1e/*/GET/",
		AuthorizationToken: "**VALID TOKEN HERE**",
	}

	resp, err := HandleRequest(context.TODO(), event)

	if err != nil {
		t.Fatal(err.Error())
	}

	output, _ := json.Marshal(resp)

	t.Log(fmt.Sprintf("%s", output))
}
